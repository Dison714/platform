// Аудит vehicle_category_translations (фильтры каталога /bikes) — часть
// чек-листа CLAUDE.md §3.8 "все три таблицы разом". Тот же метод, что и
// остальные audit_*: нет строки / пустое поле / дословная копия фоллбека.
// EN сознательно без строк (vehicle_categories.name — сам EN-фоллбек, см.
// 038_vehicle_category_translations.sql) — не считается пробелом.
//
// Usage: node scripts/audit_category_translations.mjs [--format csv]

import { pool } from '../src/db/pool.js';

const FORMAT = process.argv.includes('--format') ? process.argv[process.argv.indexOf('--format') + 1] : 'table';
const SITE_LOCALES = ['ru', 'de', 'fr', 'es', 'it', 'ja', 'ar']; // без en — см. комментарий выше

const { rows: categories } = await pool.query('SELECT id, code, name AS fallback_name FROM vehicle_categories ORDER BY sort_order');
const { rows: allTranslations } = await pool.query(
  `SELECT category_id, language_code, name FROM vehicle_category_translations WHERE language_code = ANY($1)`,
  [SITE_LOCALES]
);
const byCatLang = new Map(allTranslations.map((r) => [`${r.category_id}:${r.language_code}`, r.name]));

const findings = [];
for (const cat of categories) {
  for (const lang of SITE_LOCALES) {
    const value = byCatLang.get(`${cat.id}:${lang}`)?.trim() || '';
    let status = null;
    if (!value) status = 'empty';
    else if (value === cat.fallback_name) status = 'not_translated (matches fallback verbatim)';
    if (status) findings.push({ language: lang, category: cat.code, status });
  }
}

if (FORMAT === 'csv') {
  console.log('language,category,status');
  for (const f of findings) console.log([f.language, f.category, `"${f.status}"`].join(','));
} else {
  console.log(`Categories: ${categories.length}, languages checked: ${SITE_LOCALES.join(', ')}`);
  console.log(`Findings: ${findings.length}\n`);
  console.table(findings);
}
await pool.end();
