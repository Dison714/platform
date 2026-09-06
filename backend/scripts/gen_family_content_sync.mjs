import { Pool } from 'pg';
import { writeFile } from 'node:fs/promises';

// Syncs family_content_translations (ru/de/fr/es/it/ja/ar — the "Key
// Benefits/Expert Tips/FAQ" block below the calculator) from local dev DB to
// prod. Upsert by (product_families.brand + model_name, language_code), not
// family_id — ids differ between dev/prod. EN rows untouched (source of truth).

const pool = new Pool({ connectionString: 'postgres://localhost:5432/mdb_platform' });
const LANGS = ['ru', 'de', 'fr', 'es', 'it', 'ja', 'ar'];

function esc(v) {
  if (v === null || v === undefined) return 'NULL';
  return `'${String(v).replace(/'/g, "''")}'`;
}

async function main() {
  const { rows } = await pool.query(
    `SELECT pf.brand, pf.model_name, fc.language_code, fc.content_html
     FROM family_content_translations fc
     JOIN product_families pf ON pf.id = fc.family_id
     WHERE fc.language_code = ANY($1)
     ORDER BY pf.brand, pf.model_name, fc.language_code`,
    [LANGS]
  );

  const out = [];
  out.push('-- family_content_sync.sql — regenerated ' + new Date().toISOString().slice(0, 10));
  out.push('-- Syncs family_content_translations (Key Benefits/Expert Tips/FAQ block) for');
  out.push('-- ru/de/fr/es/it/ja/ar from local dev DB to prod. Idempotent, safe to re-run.');
  out.push('-- Upsert key: (product_families.brand, model_name, language_code) — NOT family_id.');
  out.push('BEGIN;');
  out.push('');
  out.push(`-- family_content_translations: ${rows.length} rows (${rows.length / LANGS.length} families x ${LANGS.length} languages)`);
  for (const r of rows) {
    out.push(
      `INSERT INTO family_content_translations (family_id, language_code, content_html)\n` +
      `  SELECT pf.id, ${esc(r.language_code)}, ${esc(r.content_html)}\n` +
      `  FROM product_families pf WHERE pf.brand = ${esc(r.brand)} AND pf.model_name = ${esc(r.model_name)}\n` +
      `  ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html;`
    );
  }
  out.push('');
  out.push('COMMIT;');

  const sql = out.join('\n') + '\n';
  await writeFile(new URL('../../family_content_sync.sql', import.meta.url), sql);
  console.log(`Wrote family_content_sync.sql (${rows.length} rows).`);
  await pool.end();
}

main().catch((err) => { console.error(err); process.exit(1); });
