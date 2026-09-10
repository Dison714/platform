import { Router } from 'express';
import { pool } from '../db/pool.js';

export const locationPagesRouter = Router();

// SEO-районные страницы (scooter-rental-<district>) — резолв по (slug,
// language_code), тот же паттерн, что blog.js для article_translations
// (see 051_location_pages.sql).

const DEFAULT_LANG = 'en';

// GET /api/location-pages?lang=xx — список активных районных страниц с
// переводом на язык (для sitemap.js, по образцу /api/blog/posts).
locationPagesRouter.get('/location-pages', async (req, res, next) => {
    try {
        const lang = req.query.lang || DEFAULT_LANG;
        const { rows } = await pool.query(
            `SELECT lp.slug, GREATEST(lp.updated_at, lpt.updated_at) AS updated_at
             FROM location_pages lp
             JOIN location_page_translations lpt ON lpt.location_page_id = lp.id AND lpt.language_code = $1
             WHERE lp.is_active = TRUE
             ORDER BY lp.slug`,
            [lang]
        );
        res.json({ data: rows });
    } catch (err) { next(err); }
});

// GET /api/location-pages/:slug?lang=xx
locationPagesRouter.get('/location-pages/:slug', async (req, res, next) => {
    try {
        const lang = req.query.lang || DEFAULT_LANG;
        const { rows } = await pool.query(
            `SELECT lpt.seo_title, lpt.seo_description, lpt.h1, lpt.intro, lpt.delivery_summary,
                    lpt.delivery_html, lpt.delivery_disclaimer, lpt.getting_around_html, lpt.distances,
                    lpt.which_bike_html, lpt.route_html, lpt.popular_locations, lpt.faq, lpt.cta_text
             FROM location_pages lp
             JOIN location_page_translations lpt ON lpt.location_page_id = lp.id AND lpt.language_code = $2
             WHERE lp.is_active = TRUE AND lp.slug = $1`,
            [req.params.slug, lang]
        );
        if (rows.length === 0) return res.status(404).json({ error: 'location_page_not_found' });
        res.json({ data: rows[0] });
    } catch (err) { next(err); }
});

// GET /api/location-pages/:slug/translations?lang=xx — какие локали есть у
// этой страницы (для hreflang) — по образцу blog.js /translations. Не
// хардкодим "все 11" — 2026-09-10 все 9 страниц реально переведены на все
// 11, но это факт данных, не гарантия схемы (следующий район может
// какое-то время существовать только на en).
locationPagesRouter.get('/location-pages/:slug/translations', async (req, res, next) => {
    try {
        const lang = req.query.lang || DEFAULT_LANG;
        const { rows } = await pool.query(
            `SELECT lpt2.language_code
             FROM location_page_translations lpt1
             JOIN location_pages lp ON lp.id = lpt1.location_page_id
             JOIN location_page_translations lpt2 ON lpt2.location_page_id = lp.id
             WHERE lp.slug = $1 AND lpt1.language_code = $2 AND lp.is_active = TRUE`,
            [req.params.slug, lang]
        );
        if (rows.length === 0) return res.status(404).json({ error: 'location_page_not_found' });
        res.json({ data: rows });
    } catch (err) { next(err); }
});
