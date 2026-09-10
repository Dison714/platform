// Syncs location_page_translations (9 districts) from local dev DB to prod,
// upsert by (slug, language_code) — not id, same reasoning as
// gen_blog_sync.mjs (dev/prod generate their own gen_random_uuid()
// independently, ids never line up). Generated for the 2026-09-10
// [TODO]-leak fix (059_fix_district_todo_leaks.sql + the 10 i18n_location_
// pages/*.mjs source files) but general-purpose — run again for any future
// content edit to this table, langs defaults to all 11.
import { Pool } from 'pg';
import { writeFile } from 'node:fs/promises';

const pool = new Pool({ connectionString: 'postgres://localhost:5432/mdb_platform' });

function esc(v) {
  if (v === null || v === undefined) return 'NULL';
  if (v instanceof Date) return `'${v.toISOString()}'`;
  return `'${String(v).replace(/'/g, "''")}'`;
}
function jsonEsc(v) {
  return v === null || v === undefined ? 'NULL' : `${esc(JSON.stringify(v))}::jsonb`;
}

const langs = process.argv.slice(2);
if (langs.length === 0) { console.error('usage: node gen_location_i18n_sync.mjs <lang1> [lang2] ...'); process.exit(1); }

async function main() {
  const { rows } = await pool.query(
    `SELECT lp.slug, lpt.*
     FROM location_pages lp JOIN location_page_translations lpt ON lpt.location_page_id = lp.id
     WHERE lpt.language_code = ANY($1)
     ORDER BY lp.slug, lpt.language_code`,
    [langs]
  );
  if (rows.length === 0) throw new Error('no rows found for given languages');

  // Real upsert (INSERT ... ON CONFLICT), not a plain UPDATE — a plain
  // UPDATE silently affects 0 rows for a (location_page_id, language_code)
  // pair that doesn't exist yet on prod (found 2026-09-10: the airport
  // page's 10 non-EN rows didn't exist on prod before this script ran, so
  // the earlier UPDATE-only version no-op'd on all of them without error —
  // `psql` still printed "UPDATE 1" for the OTHER 9 districts' real
  // updates, so the silent no-ops on airport went unnoticed until a
  // separate row-count check). location_page_id is resolved via the
  // subquery on prod's own location_pages, same reasoning as the plain
  // UPDATE version (dev/prod ids never match).
  const stmts = rows.map((r) => `
INSERT INTO location_page_translations (
    location_page_id, language_code, seo_title, seo_description, h1, intro,
    delivery_summary, delivery_html, delivery_disclaimer, getting_around_html, distances,
    which_bike_html, route_html, photos_note, popular_locations, faq, cta_text
) VALUES (
    (SELECT id FROM location_pages WHERE slug = ${esc(r.slug)}), ${esc(r.language_code)},
    ${esc(r.seo_title)}, ${esc(r.seo_description)}, ${esc(r.h1)}, ${esc(r.intro)},
    ${esc(r.delivery_summary)}, ${esc(r.delivery_html)}, ${esc(r.delivery_disclaimer)}, ${esc(r.getting_around_html)},
    ${jsonEsc(r.distances)}, ${esc(r.which_bike_html)}, ${esc(r.route_html)}, ${esc(r.photos_note)},
    ${jsonEsc(r.popular_locations)}, ${jsonEsc(r.faq)}, ${esc(r.cta_text)}
)
ON CONFLICT (location_page_id, language_code) DO UPDATE SET
    seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    h1 = EXCLUDED.h1, intro = EXCLUDED.intro,
    delivery_summary = EXCLUDED.delivery_summary, delivery_html = EXCLUDED.delivery_html,
    delivery_disclaimer = EXCLUDED.delivery_disclaimer, getting_around_html = EXCLUDED.getting_around_html,
    distances = EXCLUDED.distances, which_bike_html = EXCLUDED.which_bike_html,
    route_html = EXCLUDED.route_html, photos_note = EXCLUDED.photos_note,
    popular_locations = EXCLUDED.popular_locations, faq = EXCLUDED.faq,
    cta_text = EXCLUDED.cta_text, updated_at = now();`.trim());

  const sql = stmts.join('\n\n') + '\n';
  await writeFile('/tmp/location_i18n_sync.sql', sql);
  console.log(`Wrote /tmp/location_i18n_sync.sql — ${rows.length} rows across ${langs.length} language(s).`);
  await pool.end();
}

main();
