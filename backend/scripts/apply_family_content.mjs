// Применяет переводы из family_content_data.mjs к family_content_translations
// (задача 2, Webvisor 01.09.2026 — блок "Key Benefits/Expert Tips/FAQ" ниже
// калькулятора, пропущенный прошлым аудитом product_translations т.к. живёт
// на уровне Family, не Product). Пилот (Frankenstein/Honda ADV/Kawasaki
// ZX-25R, RU+DE) одобрен дословно — этот прогон лишь добавляет остальные
// 16 family и остальные 5 языков поверх него, не переписывая одобренный текст.
//
// Usage: node scripts/apply_family_content.mjs [--dry-run]

import { pool } from '../src/db/pool.js';
import { FAMILY_CONTENT } from './family_content_data.mjs';

const DRY_RUN = process.argv.includes('--dry-run');
const TARGET_LANGS = ['ru', 'de', 'fr', 'es', 'it', 'ja', 'ar'];

const { rows: families } = await pool.query(`
  SELECT id, brand, model_name FROM product_families ORDER BY brand, model_name
`);

let missing = 0;
const writes = [];
for (const family of families) {
  const key = `${family.brand}|${family.model_name || ''}`;
  const content = FAMILY_CONTENT[key];
  if (!content) {
    console.error(`NO CONTENT for family "${key}"`);
    missing++;
    continue;
  }
  for (const lang of TARGET_LANGS) {
    if (!content[lang]) {
      console.error(`NO ${lang.toUpperCase()} content for family "${key}"`);
      missing++;
      continue;
    }
    writes.push({ familyId: family.id, key, lang, html: content[lang] });
  }
}

console.log(`Families: ${families.length}, writes planned: ${writes.length}, missing: ${missing}`);
if (missing) {
  console.error('Aborting — fill gaps in family_content_data.mjs first.');
  process.exit(1);
}

if (DRY_RUN) {
  console.log(writes.slice(0, 3).map((w) => ({ key: w.key, lang: w.lang, len: w.html.length })));
  console.log(`... (${writes.length} total)`);
  await pool.end();
  process.exit(0);
}

let count = 0;
for (const w of writes) {
  await pool.query(
    `INSERT INTO family_content_translations (family_id, language_code, content_html)
     VALUES ($1, $2, $3)
     ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html`,
    [w.familyId, w.lang, w.html]
  );
  count++;
}
console.log(`Done. Upserted ${count} family_content_translations rows.`);
await pool.end();
