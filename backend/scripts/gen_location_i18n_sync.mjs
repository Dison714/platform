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

  const stmts = rows.map((r) => `
UPDATE location_page_translations lpt SET
    seo_title = ${esc(r.seo_title)}, seo_description = ${esc(r.seo_description)},
    h1 = ${esc(r.h1)}, intro = ${esc(r.intro)},
    delivery_summary = ${esc(r.delivery_summary)}, delivery_html = ${esc(r.delivery_html)},
    delivery_disclaimer = ${esc(r.delivery_disclaimer)}, getting_around_html = ${esc(r.getting_around_html)},
    distances = ${jsonEsc(r.distances)}, which_bike_html = ${esc(r.which_bike_html)},
    route_html = ${esc(r.route_html)}, photos_note = ${esc(r.photos_note)},
    popular_locations = ${jsonEsc(r.popular_locations)}, faq = ${jsonEsc(r.faq)},
    cta_text = ${esc(r.cta_text)}, updated_at = now()
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = ${esc(r.slug)} AND lpt.language_code = ${esc(r.language_code)};`.trim());

  const sql = stmts.join('\n\n') + '\n';
  await writeFile('/tmp/location_i18n_sync.sql', sql);
  console.log(`Wrote /tmp/location_i18n_sync.sql — ${rows.length} rows across ${langs.length} language(s).`);
  await pool.end();
}

main();
