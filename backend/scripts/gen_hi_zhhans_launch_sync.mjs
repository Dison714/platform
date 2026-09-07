import { Pool } from 'pg';
import { writeFile } from 'node:fs/promises';

// One-off launch sync for hi + zh-Hans (2026-09-07 session): languages row
// (hi only — zh-Hans was already pre-seeded on both dev and prod),
// product_translations, vehicle_category_translations,
// family_content_translations, article_translations (14 published articles,
// deposit-safety + legal), article_category_translations (2 categories with
// published articles). From local dev DB to prod. Idempotent
// (INSERT ... ON CONFLICT DO UPDATE), safe to re-run. Upsert by business key
// (slug/code), not id — dev/prod ids are generated independently and never
// line up (CLAUDE.md §6).

const pool = new Pool({ connectionString: 'postgres://localhost:5432/mdb_platform' });
const LANGS = ['hi', 'zh-Hans'];

function esc(v) {
  if (v === null || v === undefined) return 'NULL';
  if (typeof v === 'boolean') return v ? 'TRUE' : 'FALSE';
  return `'${String(v).replace(/'/g, "''")}'`;
}

async function main() {
  const out = [];
  out.push('-- hi_zhhans_launch_sync.sql — generated ' + new Date().toISOString().slice(0, 10));
  out.push('-- Full launch sync for hi + zh-Hans: languages row (hi), product_translations,');
  out.push('-- vehicle_category_translations, family_content_translations, article_translations');
  out.push('-- (14 published articles), article_category_translations (2). From local dev DB to');
  out.push('-- prod. Idempotent (INSERT ... ON CONFLICT DO UPDATE), safe to re-run.');
  out.push('BEGIN;\n');

  // languages (hi only — zh-Hans already exists on both sides)
  const { rows: langRows } = await pool.query(`SELECT code, name, launch_phase, is_active, sort_order FROM languages WHERE code = 'hi'`);
  out.push(`-- languages: ${langRows.length} row (hi)`);
  for (const r of langRows) {
    out.push(
      `INSERT INTO languages (code, name, launch_phase, is_active, sort_order)\n` +
      `  VALUES (${esc(r.code)}, ${esc(r.name)}, ${r.launch_phase}, ${esc(r.is_active)}, ${r.sort_order})\n` +
      `  ON CONFLICT (code) DO NOTHING;`
    );
  }
  out.push('');

  // product_translations
  const { rows: prodRows } = await pool.query(
    `SELECT p.slug AS product_slug, t.language_code, t.title, t.description
     FROM product_translations t JOIN products p ON p.id = t.product_id
     WHERE t.language_code = ANY($1) ORDER BY p.slug, t.language_code`,
    [LANGS]
  );
  out.push(`-- product_translations: ${prodRows.length} rows (${prodRows.length / LANGS.length} products x ${LANGS.length} languages)`);
  for (const r of prodRows) {
    out.push(
      `INSERT INTO product_translations (product_id, language_code, title, description)\n` +
      `  SELECT p.id, ${esc(r.language_code)}, ${esc(r.title)}, ${esc(r.description)}\n` +
      `  FROM products p WHERE p.slug = ${esc(r.product_slug)}\n` +
      `  ON CONFLICT (product_id, language_code) DO UPDATE SET\n` +
      `    title = EXCLUDED.title, description = EXCLUDED.description;`
    );
  }
  out.push('');

  // vehicle_category_translations
  const { rows: vcRows } = await pool.query(
    `SELECT vc.code AS category_code, vct.language_code, vct.name
     FROM vehicle_category_translations vct JOIN vehicle_categories vc ON vc.id = vct.category_id
     WHERE vct.language_code = ANY($1) ORDER BY vc.sort_order, vct.language_code`,
    [LANGS]
  );
  out.push(`-- vehicle_category_translations: ${vcRows.length} rows`);
  for (const r of vcRows) {
    out.push(
      `INSERT INTO vehicle_category_translations (category_id, language_code, name)\n` +
      `  SELECT vc.id, ${esc(r.language_code)}, ${esc(r.name)}\n` +
      `  FROM vehicle_categories vc WHERE vc.code = ${esc(r.category_code)}\n` +
      `  ON CONFLICT (category_id, language_code) DO UPDATE SET name = EXCLUDED.name;`
    );
  }
  out.push('');

  // family_content_translations
  const { rows: fcRows } = await pool.query(
    `SELECT pf.code AS family_code, fc.language_code, fc.content_html
     FROM family_content_translations fc JOIN product_families pf ON pf.id = fc.family_id
     WHERE fc.language_code = ANY($1) ORDER BY pf.code, fc.language_code`,
    [LANGS]
  );
  out.push(`-- family_content_translations: ${fcRows.length} rows (${fcRows.length / LANGS.length} families x ${LANGS.length} languages)`);
  for (const r of fcRows) {
    out.push(
      `INSERT INTO family_content_translations (family_id, language_code, content_html)\n` +
      `  SELECT pf.id, ${esc(r.language_code)}, ${esc(r.content_html)}\n` +
      `  FROM product_families pf WHERE pf.code = ${esc(r.family_code)}\n` +
      `  ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html;`
    );
  }
  out.push('');

  // article_category_translations (only categories with published articles: deposit-safety, legal)
  const { rows: actRows } = await pool.query(
    `SELECT ac.slug AS category_slug, act.language_code, act.name, act.slug, act.description
     FROM article_category_translations act JOIN article_categories ac ON ac.id = act.category_id
     WHERE act.language_code = ANY($1) AND ac.slug IN ('deposit-safety','legal')
     ORDER BY ac.slug, act.language_code`,
    [LANGS]
  );
  out.push(`-- article_category_translations: ${actRows.length} rows`);
  for (const r of actRows) {
    out.push(
      `INSERT INTO article_category_translations (category_id, language_code, name, slug, description)\n` +
      `  SELECT ac.id, ${esc(r.language_code)}, ${esc(r.name)}, ${esc(r.slug)}, ${esc(r.description)}\n` +
      `  FROM article_categories ac WHERE ac.slug = ${esc(r.category_slug)}\n` +
      `  ON CONFLICT (category_id, language_code) DO UPDATE SET\n` +
      `    name = EXCLUDED.name, slug = EXCLUDED.slug, description = EXCLUDED.description;`
    );
  }
  out.push('');

  // article_translations (14 published articles across deposit-safety + legal)
  const { rows: atRows } = await pool.query(
    `SELECT a.slug AS article_slug, at.language_code, at.title, at.slug, at.excerpt, at.content, at.seo_title, at.seo_description
     FROM articles a JOIN article_translations at ON at.article_id = a.id
     JOIN article_categories ac ON ac.id = a.category_id
     WHERE at.language_code = ANY($1) AND ac.slug IN ('deposit-safety','legal') AND a.status = 'published'
     ORDER BY a.slug, at.language_code`,
    [LANGS]
  );
  if (atRows.length !== 28) throw new Error(`expected 28 article_translations rows (14 articles x 2 langs), found ${atRows.length}`);
  out.push(`-- article_translations: ${atRows.length} rows (14 articles x ${LANGS.length} languages)`);
  for (const r of atRows) {
    out.push(
      `INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)\n` +
      `  SELECT a.id, ${esc(r.language_code)}, ${esc(r.title)}, ${esc(r.slug)}, ${esc(r.excerpt)}, ${esc(r.content)}, ${esc(r.seo_title)}, ${esc(r.seo_description)}\n` +
      `  FROM articles a WHERE a.slug = ${esc(r.article_slug)}\n` +
      `  ON CONFLICT (article_id, language_code) DO UPDATE SET\n` +
      `    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,\n` +
      `    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,\n` +
      `    updated_at = now();`
    );
  }
  out.push('');

  out.push('COMMIT;');

  const sql = out.join('\n') + '\n';
  await writeFile(new URL('../../hi_zhhans_launch_sync.sql', import.meta.url), sql);
  console.log(`Wrote hi_zhhans_launch_sync.sql (${langRows.length} lang + ${prodRows.length} product + ${vcRows.length} category + ${fcRows.length} family + ${actRows.length} article-category + ${atRows.length} article rows).`);
  await pool.end();
}

main().catch((err) => { console.error(err); process.exit(1); });
