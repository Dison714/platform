import { Router } from 'express';
import { pool } from '../db/pool.js';

export const blogAdminRouter = Router();

// Configuration First (п.12 ТЗ) — /internal/blog. Доступ уже закрыт Basic
// Auth на уровне Next.js middleware + X-Internal-Admin-Token здесь (см.
// server.js). Список/форма только на английском (EN) — единственный
// засеянный язык статей на этом этапе (см. CLAUDE.md §4.15 задачу,
// остальные языки — отдельный следующий шаг, не эта миграция/сессия).
// Только list + edit (не create/delete) — все 29 статей уже засеяны
// (048_blog_seed.sql), создание новых/удаление вне формы, описанной в
// задаче, здесь не запрашивалось.

const LANG = 'en';

// GET /api/blog/articles — список статей + категории + families (для формы).
blogAdminRouter.get('/blog/articles', async (req, res, next) => {
    try {
        const { rows: articles } = await pool.query(
            `SELECT a.id, a.slug, a.is_pillar, a.status, a.updated_at,
                    ac.slug AS category_slug, COALESCE(act.name, ac.slug) AS category_name,
                    COALESCE(at.title, a.slug) AS title
             FROM articles a
             JOIN article_categories ac ON ac.id = a.category_id
             LEFT JOIN article_category_translations act ON act.category_id = ac.id AND act.language_code = $1
             LEFT JOIN article_translations at ON at.article_id = a.id AND at.language_code = $1
             ORDER BY ac.display_order, a.is_pillar DESC, title`,
            [LANG]
        );
        const { rows: categories } = await pool.query(
            `SELECT ac.id, ac.slug, COALESCE(act.name, ac.slug) AS name
             FROM article_categories ac
             LEFT JOIN article_category_translations act ON act.category_id = ac.id AND act.language_code = $1
             ORDER BY ac.display_order`,
            [LANG]
        );
        const { rows: families } = await pool.query(
            `SELECT id, code, brand, model_name FROM product_families
             WHERE is_active = TRUE ORDER BY brand, model_name`
        );
        res.json({ data: { articles, categories, families } });
    } catch (err) { next(err); }
});

// GET /api/blog/articles/:id — одна статья для формы редактирования.
blogAdminRouter.get('/blog/articles/:id', async (req, res, next) => {
    try {
        const { rows } = await pool.query(
            `SELECT a.id, a.slug, a.is_pillar, a.status, a.featured_image_url,
                    a.related_product_family_id, ac.slug AS category_slug,
                    COALESCE(act.name, ac.slug) AS category_name,
                    at.title, at.slug AS translation_slug, at.excerpt, at.content
             FROM articles a
             JOIN article_categories ac ON ac.id = a.category_id
             LEFT JOIN article_category_translations act ON act.category_id = ac.id AND act.language_code = $2
             LEFT JOIN article_translations at ON at.article_id = a.id AND at.language_code = $2
             WHERE a.id = $1`,
            [req.params.id, LANG]
        );
        if (rows.length === 0) { const e = new Error('not_found'); e.status = 404; throw e; }
        res.json({ data: rows[0] });
    } catch (err) { next(err); }
});

function badReq(message) {
    const e = new Error(message);
    e.status = 400;
    return e;
}

function validateBody(body) {
    const { title, slug, excerpt, content, status, featured_image_url, related_product_family_id } = body ?? {};
    if (typeof title !== 'string' || !title.trim()) throw badReq('title is required');
    if (typeof slug !== 'string' || !/^[a-z0-9-]+$/.test(slug)) throw badReq('slug must be lowercase letters, digits, hyphens');
    if (status !== 'draft' && status !== 'published') throw badReq('status must be draft or published');
    return {
        title: title.trim(),
        slug,
        excerpt: typeof excerpt === 'string' && excerpt.trim() ? excerpt.trim() : null,
        content: typeof content === 'string' && content.trim() ? content.trim() : null,
        status,
        featured_image_url: typeof featured_image_url === 'string' && featured_image_url.trim() ? featured_image_url.trim() : null,
        related_product_family_id: related_product_family_id === '' || related_product_family_id === null || related_product_family_id === undefined
            ? null : related_product_family_id,
    };
}

function isUniqueViolation(err) {
    return err.code === '23505';
}

// PUT /api/blog/articles/:id — сохранить title/slug/excerpt/content (en)
// + status/featured_image_url/related_product_family_id (articles).
blogAdminRouter.put('/blog/articles/:id', async (req, res, next) => {
    const client = await pool.connect();
    try {
        const v = validateBody(req.body);
        await client.query('BEGIN');

        // published_at проставляется один раз, при первом переходе в published —
        // COALESCE(published_at, now()) держит исходную дату публикации при
        // повторных сохранениях (напр. правка опубликованной статьи), не гоняет
        // её вперёд. Возврат в draft published_at не трогает — сохраняем как
        // историческую метку "когда была впервые опубликована".
        const articleRes = await client.query(
            `UPDATE articles
             SET status = $1::article_status, featured_image_url = $2, related_product_family_id = $3,
                 published_at = CASE WHEN $1::article_status = 'published' THEN COALESCE(published_at, now()) ELSE published_at END
             WHERE id = $4
             RETURNING id`,
            [v.status, v.featured_image_url, v.related_product_family_id, req.params.id]
        );
        if (articleRes.rows.length === 0) { const e = new Error('not_found'); e.status = 404; throw e; }

        await client.query(
            `INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content)
             VALUES ($1, $2, $3, $4, $5, $6)
             ON CONFLICT (article_id, language_code)
             DO UPDATE SET title = $3, slug = $4, excerpt = $5, content = $6, updated_at = now()`,
            [req.params.id, LANG, v.title, v.slug, v.excerpt, v.content]
        );

        await client.query('COMMIT');
        res.json({ data: { id: req.params.id } });
    } catch (err) {
        await client.query('ROLLBACK');
        if (isUniqueViolation(err)) err.status = 409;
        next(err);
    } finally {
        client.release();
    }
});
