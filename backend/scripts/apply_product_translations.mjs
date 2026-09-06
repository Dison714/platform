// Применяет переводы из translations_data.mjs к product_translations (задача 2,
// Webvisor 01.09.2026). Одноразовый прогон на LOCAL dev DB — см. CLAUDE.md,
// прод обновляется отдельно через gen_product_translations_sync.mjs после
// явного разрешения на деплой.
//
// Логика на (product, language):
//   - Строка уже существует (79 товаров в de/fr/es/it/ja/ar) → title НЕ
//     трогаем (берём как есть из БД), обновляем только description (сейчас
//     везде NULL, кроме en).
//   - Строки нет (22 товара в de/fr/es/it/ja/ar; все 101 в ru) → создаём
//     title из COLOR_PHRASES (Brand+Model латиницей + переведённый цвет) и
//     description из DESCRIPTIONS.
//
// Usage: node scripts/apply_product_translations.mjs [--dry-run]

import { pool } from '../src/db/pool.js';
import { COLOR_PHRASES, DESCRIPTIONS } from './translations_data.mjs';

const DRY_RUN = process.argv.includes('--dry-run');
const TARGET_LANGS = ['ru', 'de', 'fr', 'es', 'it', 'ja', 'ar'];

const { rows: products } = await pool.query(`
  SELECT p.id, p.slug, pf.brand, pf.model_name,
    ten.title en_title, ten.description en_description
  FROM products p
  JOIN product_families pf ON pf.id = p.family_id
  JOIN product_translations ten ON ten.product_id = p.id AND ten.language_code = 'en'
  ORDER BY p.slug
`);

const { rows: existingRows } = await pool.query(`
  SELECT product_id, language_code, title
  FROM product_translations
  WHERE language_code = ANY($1)
`, [TARGET_LANGS]);
const existingTitle = new Map(existingRows.map((r) => [`${r.product_id}:${r.language_code}`, r.title]));

let missingColorPhrase = 0;
let missingDescription = 0;
const writes = [];

for (const p of products) {
  const prefix = (p.brand + (p.model_name ? ` ${p.model_name}` : '')).trim();
  const colorPhrase = p.en_title.startsWith(prefix) ? p.en_title.slice(prefix.length).trim() : null;
  const descTranslations = DESCRIPTIONS[p.en_description];

  if (!descTranslations) {
    console.error(`NO DESCRIPTION TRANSLATION for "${p.en_description}" (${p.slug})`);
    missingDescription++;
    continue;
  }

  for (const lang of TARGET_LANGS) {
    const existing = existingTitle.get(`${p.id}:${lang}`);
    let title;
    if (existing) {
      title = existing;
    } else {
      const colorTranslations = colorPhrase ? COLOR_PHRASES[colorPhrase] : null;
      if (!colorTranslations) {
        console.error(`NO COLOR PHRASE TRANSLATION for "${colorPhrase}" (${p.slug}, en_title="${p.en_title}")`);
        missingColorPhrase++;
        continue;
      }
      title = `${prefix} ${colorTranslations[lang]}`.trim();
    }
    writes.push({ productId: p.id, slug: p.slug, lang, title, description: descTranslations[lang], isNewRow: !existing });
  }
}

console.log(`Products: ${products.length}, writes planned: ${writes.length}, missing color phrase: ${missingColorPhrase}, missing description: ${missingDescription}`);
if (missingColorPhrase || missingDescription) {
  console.error('Aborting — fill gaps in translations_data.mjs first.');
  process.exit(1);
}

if (DRY_RUN) {
  console.log(writes.slice(0, 10));
  console.log(`... (${writes.length} total, showing first 10)`);
  await pool.end();
  process.exit(0);
}

let inserted = 0;
let updated = 0;
for (const w of writes) {
  const { rowCount } = await pool.query(
    `INSERT INTO product_translations (product_id, language_code, title, description)
     VALUES ($1, $2, $3, $4)
     ON CONFLICT (product_id, language_code) DO UPDATE SET
       description = EXCLUDED.description
     RETURNING (xmax = 0) AS inserted_flag`,
    [w.productId, w.lang, w.title, w.description]
  );
  if (rowCount) {
    if (w.isNewRow) inserted++; else updated++;
  }
}
console.log(`Done. Inserted: ${inserted}, updated (description only): ${updated}`);
await pool.end();
