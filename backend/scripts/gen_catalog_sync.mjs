import { Pool } from 'pg';
import { writeFile } from 'node:fs/promises';

const pool = new Pool({ connectionString: 'postgres://localhost:5432/mdb_platform' });

function esc(v) {
  if (v === null || v === undefined) return 'NULL';
  if (typeof v === 'boolean') return v ? 'TRUE' : 'FALSE';
  if (typeof v === 'number') return String(v);
  if (v instanceof Date) return `'${v.toISOString()}'`;
  return `'${String(v).replace(/'/g, "''")}'`;
}

// updated_at feeds sitemap.js lastmod (frontend/src/app/sitemap.js) — a plain
// EXCLUDED.updated_at here would stamp prod's row with dev's timestamp on
// every sync even when nothing about the row actually changed, corrupting
// the freshness signal. CASE it against a real diff of the other columns so
// prod's own updated_at (from its own live edits) survives a no-op sync.
async function dumpTable(table, pkCol = 'id') {
  const { rows } = await pool.query(`SELECT * FROM ${table} ORDER BY created_at NULLS FIRST`);
  if (rows.length === 0) return `-- ${table}: empty, nothing to sync\n`;
  const cols = Object.keys(rows[0]);
  const updateCols = cols.filter((c) => c !== pkCol);
  const hasUpdatedAt = cols.includes('updated_at');
  const businessCols = updateCols.filter((c) => c !== 'created_at' && c !== 'updated_at');
  const updatedAtSet = hasUpdatedAt && businessCols.length
    ? `updated_at = CASE WHEN ${businessCols.map((c) => `${table}.${c} IS DISTINCT FROM EXCLUDED.${c}`).join(' OR ')} THEN EXCLUDED.updated_at ELSE ${table}.updated_at END`
    : null;
  let sql = `-- ${table}: ${rows.length} rows\n`;
  for (const row of rows) {
    const vals = cols.map((c) => esc(row[c])).join(', ');
    const setClause = updateCols
      .map((c) => (c === 'updated_at' && updatedAtSet ? updatedAtSet : `${c} = EXCLUDED.${c}`))
      .join(', ');
    sql += `INSERT INTO ${table} (${cols.join(', ')}) VALUES (${vals})\n`;
    sql += `  ON CONFLICT (${pkCol}) DO UPDATE SET ${setClause};\n`;
  }
  return sql + '\n';
}

// product_photos: ids are regenerated on every local rebuild (full delete+reinsert
// per product, see resyncPhotos in resync_lib.mjs), so they never line up with
// whatever ids prod already has for the same logical photos. ON CONFLICT(id) would
// leave stale rows behind (and collide on the partial unique index
// product_photos_one_hero). Full replace instead: local is the source of truth.
async function dumpPhotosFullReplace(table) {
  const { rows } = await pool.query(`SELECT * FROM ${table} ORDER BY created_at NULLS FIRST`);
  if (rows.length === 0) return `-- ${table}: empty, nothing to sync\n`;
  const cols = Object.keys(rows[0]);
  let sql = `-- ${table}: ${rows.length} rows (full replace, ids not stable across environments)\n`;
  sql += `DELETE FROM ${table};\n`;
  for (const row of rows) {
    const vals = cols.map((c) => esc(row[c])).join(', ');
    sql += `INSERT INTO ${table} (${cols.join(', ')}) VALUES (${vals});\n`;
  }
  return sql + '\n';
}

const out = [];
out.push('-- catalog_sync.sql — regenerated ' + new Date().toISOString().slice(0, 10));
out.push('-- Snapshot of product_families/products/product_photos from local dev DB.');
out.push('-- Idempotent (INSERT ... ON CONFLICT DO UPDATE) — safe to re-run.');
out.push('-- Apply on prod AFTER photos are already synced to R2 (see DEPLOY_RUNBOOK.md step 3).');
out.push('BEGIN;\n');
out.push(await dumpTable('product_families'));
out.push(await dumpTable('products'));
out.push(await dumpPhotosFullReplace('product_photos'));
out.push('COMMIT;\n');

await writeFile(new URL('../../catalog_sync.sql', import.meta.url), out.join('\n'));
console.log('written catalog_sync.sql');
await pool.end();
