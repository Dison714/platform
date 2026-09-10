// Переводы 9 районных страниц (Delivery/Getting Around/Which Bike Fits/
// Popular Locations/FAQ/CTA) на 10 локалей, кроме en (уже есть) — задача
// Дмитрия 2026-09-10, после ревью видимости Route/Distances.
//
// Popular Locations: названия мест НЕ переводятся ни на одном языке —
// это реальные топонимы/имена заведений с прямой ссылкой на Google Maps
// (как products.slug), перевод сделал бы их нераспознаваемыми на месте.
// Distances у Canggu (единственный район с реальными данными) — тот же
// массив на всех языках: цифры + км/мин универсальны, названия
// направлений (Ngurah Rai Airport, Seminyak, Uluwatu, Ubud) — топонимы.
// Route — NULL везде (скрыт, нечего переводить, см. 058).
import { pool } from '../src/db/pool.js';
import { DISTRICT_META } from './i18n_location_pages/meta.mjs';

const LANGS = process.argv.slice(2);
if (LANGS.length === 0) {
    console.error('Usage: node apply_location_i18n.mjs <lang1> [lang2] ...');
    process.exit(1);
}

const IDP_HREF = '/en/blog/riding-in-bali-without-a-license-the-real-risks';
const DEPOSIT_HREF = '/en/blog#deposit-safety';

const { rows: pages } = await pool.query('SELECT id, slug FROM location_pages');
const pageIdBySlug = Object.fromEntries(pages.map((p) => [p.slug, p.id]));

const { rows: enRows } = await pool.query(
    `SELECT lp.slug, lpt.popular_locations, lpt.distances
     FROM location_pages lp JOIN location_page_translations lpt ON lpt.location_page_id = lp.id
     WHERE lpt.language_code = 'en'`
);
const enBySlug = Object.fromEntries(enRows.map((r) => [r.slug, r]));

let total = 0;
for (const lang of LANGS) {
    const mod = await import(`./i18n_location_pages/${lang}.mjs`);
    const data = mod.default;

    for (const [slug, meta] of Object.entries(DISTRICT_META)) {
        const d = data.districts[slug];
        if (!d) { console.error(`Missing district "${slug}" in ${lang}.mjs`); process.exit(1); }
        const pageId = pageIdBySlug[slug];
        const en = enBySlug[slug];

        // d.name/d.prep — локализованные имя района и предлог (см. языковой
        // файл); НЕ meta.name/meta.prep (те английские, попадание "in
        // Canggu"/"around Uluwatu" внутрь переведённого предложения — баг,
        // найденный на живой /ru/ странице 2026-09-10). prep может быть ''
        // у языков без отдельного предлога (ja/ko/zh-Hans — частицы уже
        // вшиты в faqIdpQ/ctaBody напрямую) — обязателен только name.
        if (!d.name) { console.error(`Missing name for "${slug}" in ${lang}.mjs`); process.exit(1); }
        if (d.prep === undefined) { console.error(`Missing prep (use '' if unused) for "${slug}" in ${lang}.mjs`); process.exit(1); }
        const faq = [
            { q: d.faqQ1, a: d.faqA1 },
            { q: data.faqMinRental.q, a: data.faqMinRental.a },
            { q: data.faqIdpQ(d.name, d.prep), a: data.faqIdpA, link: { href: IDP_HREF, label: data.faqIdpLinkLabel } },
            { q: d.faqQ4, a: d.faqA4 },
            { q: data.faqDepositQ, a: data.faqDepositA, link: { href: DEPOSIT_HREF, label: data.faqDepositLinkLabel } },
        ];

        await pool.query(
            `INSERT INTO location_page_translations (
                location_page_id, language_code, seo_title, seo_description, h1, intro,
                delivery_summary, delivery_html, delivery_disclaimer, getting_around_html, distances,
                which_bike_html, route_html, popular_locations, faq, cta_text
            ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,NULL,$13,$14,$15)
            ON CONFLICT (location_page_id, language_code) DO UPDATE SET
                seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
                h1 = EXCLUDED.h1, intro = EXCLUDED.intro,
                delivery_summary = EXCLUDED.delivery_summary, delivery_html = EXCLUDED.delivery_html,
                delivery_disclaimer = EXCLUDED.delivery_disclaimer, getting_around_html = EXCLUDED.getting_around_html,
                distances = EXCLUDED.distances, which_bike_html = EXCLUDED.which_bike_html,
                route_html = EXCLUDED.route_html, popular_locations = EXCLUDED.popular_locations,
                faq = EXCLUDED.faq, cta_text = EXCLUDED.cta_text, updated_at = now()`,
            [
                pageId, lang, d.seoTitle, d.seoDescription, d.h1, d.intro,
                d.deliverySummary, d.deliveryHtml, data.deliveryDisclaimer, d.gettingAroundHtml,
                slug === 'canggu' ? JSON.stringify(en.distances) : null,
                data.whichBikeHtml,
                JSON.stringify(en.popular_locations),
                JSON.stringify(faq),
                data.ctaBody(d.name, d.prep),
            ]
        );
        total++;
    }
    console.log(`${lang}: 9 districts upserted.`);
}
console.log(`Done. ${total} rows upserted across ${LANGS.length} language(s).`);
await pool.end();
