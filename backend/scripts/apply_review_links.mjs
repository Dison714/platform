// Добавляет ссылку на обзор модели в family_content_translations.content_html
// (см. review_links.mjs). Меняются только строки семей с опубликованным
// обзором; остальной текст блока не трогается. Одна транзакция.
//
// Usage: node scripts/apply_review_links.mjs [--dry-run]
// Перед запуском на проде: pg_dump -t family_content_translations (бэкап).

import { pool } from '../src/db/pool.js';
import { withReviewLink } from './review_links.mjs';

const DRY_RUN = process.argv.includes('--dry-run');

const { rows } = await pool.query(
  `SELECT t.id, t.family_id, t.language_code, t.content_html, f.code
     FROM family_content_translations t JOIN product_families f ON f.id = t.family_id
    ORDER BY f.code, t.language_code`
);

const changes = [];
const noReview = new Set();
for (const r of rows) {
  const next = await withReviewLink(pool, r.family_id, r.language_code, r.content_html);
  if (next === r.content_html) { noReview.add(r.code); continue; }
  changes.push({ id: r.id, code: r.code, lang: r.language_code, html: next });
}
console.log(`rows: ${rows.length}, to update: ${changes.length}, families without review (untouched or already up to date): ${[...noReview].join(', ') || '-'}`);
console.log(changes.slice(0, 2).map((c) => `${c.code}/${c.lang}: ${c.html.slice(0, 260).replace(/\n/g, ' ')}`).join('\n'));

if (DRY_RUN) { console.log('dry-run: nothing written'); await pool.end(); process.exit(0); }

const client = await pool.connect();
try {
  await client.query('BEGIN');
  for (const c of changes) await client.query('UPDATE family_content_translations SET content_html = $2 WHERE id = $1', [c.id, c.html]);
  await client.query('COMMIT');
  console.log(`updated ${changes.length} rows`);
} catch (err) {
  await client.query('ROLLBACK');
  throw err;
} finally {
  client.release();
  await pool.end();
}
