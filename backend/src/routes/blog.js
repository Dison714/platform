import { Router } from 'express';
import { pool } from '../db/pool.js';

export const blogRouter = Router();

// Публичная витрина блога (ТЗ п.4.15) — только status='published'. Резолв
// статьи по (language_code, slug) из article_translations, не по
// articles.slug (тот стабильный, служебный — см. 047_blog.sql), в
// соответствии с локализацией URL (ТЗ п.4.9.3: своя страница на язык, не
// JS-переключатель).

const DEFAULT_LANG = 'en';

// GET /api/blog/posts?lang=xx — список опубликованных статей на языке.
blogRouter.get('/blog/posts', async (req, res, next) => {
    try {
        const lang = req.query.lang || DEFAULT_LANG;
        const { rows } = await pool.query(
            `SELECT at.title, at.slug, at.excerpt, a.featured_image_url, a.published_at, a.is_pillar,
                    ac.slug AS category_slug, COALESCE(act.name, ac.slug) AS category_name
             FROM articles a
             JOIN article_translations at ON at.article_id = a.id AND at.language_code = $1
             JOIN article_categories ac ON ac.id = a.category_id
             LEFT JOIN article_category_translations act ON act.category_id = ac.id AND act.language_code = $1
             WHERE a.status = 'published'
             ORDER BY a.published_at DESC NULLS LAST`,
            [lang]
        );
        res.json({ data: rows });
    } catch (err) { next(err); }
});

// GET /api/blog/posts/:slug?lang=xx — одна опубликованная статья.
blogRouter.get('/blog/posts/:slug', async (req, res, next) => {
    try {
        const lang = req.query.lang || DEFAULT_LANG;
        const { rows } = await pool.query(
            `SELECT at.title, at.slug, at.excerpt, at.content, at.seo_title, at.seo_description,
                    a.featured_image_url, a.published_at, a.author, a.is_pillar,
                    ac.slug AS category_slug, COALESCE(act.name, ac.slug) AS category_name
             FROM articles a
             JOIN article_translations at ON at.article_id = a.id AND at.language_code = $2
             JOIN article_categories ac ON ac.id = a.category_id
             LEFT JOIN article_category_translations act ON act.category_id = ac.id AND act.language_code = $2
             WHERE a.status = 'published' AND at.slug = $1`,
            [req.params.slug, lang]
        );
        if (rows.length === 0) return res.status(404).json({ error: 'post_not_found' });
        res.json({ data: rows[0] });
    } catch (err) { next(err); }
});
