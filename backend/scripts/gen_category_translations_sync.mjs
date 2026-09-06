import { Pool } from 'pg';
import { writeFile } from 'node:fs/promises';

// Syncs vehicle_category_translations (ru only — de/fr/es/it/ja/ar were
// already complete before this batch, see audit in the Webvisor
// 01.09.2026 session) from local dev DB to prod. Upsert by (category
// code, language_code) — category_id is a SMALLSERIAL, not guaranteed to
// line up between dev and prod, so resolve it via vehicle_categories.code
// (stable business key) at insert time, same principle as product slug in
// gen_product_translations_sync.mjs.

const pool = new Pool({ connectionString: 'postgres://localhost:5432/mdb_platform' });

function esc(v) {
  if (v === null || v === undefined) return 'NULL';
  return `'${String(v).replace(/'/g, "''")}'`;
}

async function main() {
  const { rows } = await pool.query(`
    SELECT vc.code AS category_code, vct.language_code, vct.name
    FROM vehicle_category_translations vct
    JOIN vehicle_categories vc ON vc.id = vct.category_id
    WHERE vct.language_code = 'ru'
    ORDER BY vc.sort_order
  `);

  const out = [];
  out.push('-- category_translations_sync.sql — regenerated ' + new Date().toISOString().slice(0, 10));
  out.push('-- Syncs vehicle_category_translations for ru (catalog filter labels) from local dev DB to');
  out.push('-- prod. Idempotent (INSERT ... ON CONFLICT DO UPDATE), safe to re-run.');
  out.push('-- Upsert key: (vehicle_categories.code, language_code) — NOT category_id (dev/prod ids differ).');
  out.push('BEGIN;');
  out.push('');
  out.push(`-- vehicle_category_translations: ${rows.length} rows (ru)`);
  for (const r of rows) {
    out.push(
      `INSERT INTO vehicle_category_translations (category_id, language_code, name)\n` +
      `  SELECT vc.id, ${esc(r.language_code)}, ${esc(r.name)}\n` +
      `  FROM vehicle_categories vc WHERE vc.code = ${esc(r.category_code)}\n` +
      `  ON CONFLICT (category_id, language_code) DO UPDATE SET name = EXCLUDED.name;`
    );
  }
  out.push('');
  out.push('COMMIT;');

  const sql = out.join('\n') + '\n';
  await writeFile(new URL('../../category_translations_sync.sql', import.meta.url), sql);
  console.log(`Wrote category_translations_sync.sql (${rows.length} rows).`);
  await pool.end();
}

main().catch((err) => { console.error(err); process.exit(1); });
