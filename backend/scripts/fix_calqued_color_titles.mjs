// Одноразовый точечный фикс (сессия 2026-09-07, задача 2): исправляет две
// калькированные (транслитерация вместо перевода) записи в COLOR_PHRASES,
// одобренные Дмитрием — "Total Black" только RU, "Custom Black" RU/JA/AR.
// DE/FR/ES/IT для обеих фраз НЕ трогаются (уже корректны). apply_product_translations.mjs
// для этого не годится — его ON CONFLICT намеренно не перезаписывает title
// для уже существующих строк (см. комментарий в шапке того файла), только description.
//
// Usage: node scripts/fix_calqued_color_titles.mjs [--dry-run]

import { pool } from '../src/db/pool.js';
import { COLOR_PHRASES } from './translations_data.mjs';

const DRY_RUN = process.argv.includes('--dry-run');

// фраза (как она встречается в en_title после Brand+Model) -> какие языки чинить
const FIXES = {
  'Total black': ['ru'],
  'Total Black': ['ru'],
  'Custom Black': ['ru', 'ja', 'ar'],
};

const { rows: products } = await pool.query(`
  SELECT p.id, p.slug, pf.brand, pf.model_name, ten.title en_title
  FROM products p
  JOIN product_families pf ON pf.id = p.family_id
  JOIN product_translations ten ON ten.product_id = p.id AND ten.language_code = 'en'
  WHERE ten.title ILIKE '%total black%' OR ten.title ILIKE '%custom black%'
  ORDER BY p.slug
`);

const writes = [];
for (const p of products) {
  const prefix = (p.brand + (p.model_name ? ` ${p.model_name}` : '')).trim();
  const colorPhrase = p.en_title.startsWith(prefix) ? p.en_title.slice(prefix.length).trim() : null;
  const langs = FIXES[colorPhrase];
  if (!langs) {
    console.error(`Unrecognized phrase "${colorPhrase}" for ${p.slug} (en_title="${p.en_title}") — skipping`);
    continue;
  }
  const colorTranslations = COLOR_PHRASES[colorPhrase];
  for (const lang of langs) {
    const title = `${prefix} ${colorTranslations[lang]}`.trim();
    writes.push({ productId: p.id, slug: p.slug, lang, title });
  }
}

console.log(`Products matched: ${products.length}, title updates planned: ${writes.length}`);
console.log(writes);

if (DRY_RUN) {
  await pool.end();
  process.exit(0);
}

let updated = 0;
for (const w of writes) {
  const { rowCount } = await pool.query(
    `UPDATE product_translations SET title = $1 WHERE product_id = $2 AND language_code = $3`,
    [w.title, w.productId, w.lang]
  );
  updated += rowCount;
}
console.log(`Done. Updated ${updated} product_translations rows.`);
await pool.end();
