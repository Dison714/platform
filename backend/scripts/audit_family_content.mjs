// Аудит family_content_translations.content_html (Webvisor 01.09.2026,
// задача 2, продолжение — блок "Подробнее об этом байке" пропущен прошлым
// аудитом product_translations, т.к. живёт на уровне Family в отдельной
// таблице, не в product_translations.description). Тот же метод: строка
// отсутствует / поле пустое / дословное совпадение с фоллбеком (en).
//
// Usage: node scripts/audit_family_content.mjs [--format csv]

import { pool } from '../src/db/pool.js';

function arg(name, fallback) {
  const i = process.argv.indexOf(`--${name}`);
  return i !== -1 ? process.argv[i + 1] : fallback;
}
const FALLBACK = arg('fallback', 'en');
const FORMAT = arg('format', 'table');
const SITE_LOCALES = ['en', 'ru', 'de', 'fr', 'es', 'it', 'ja', 'ar', 'ko'];
const languages = SITE_LOCALES.filter((c) => c !== FALLBACK);

const { rows: families } = await pool.query(`
  SELECT pf.id, pf.brand, pf.model_name
  FROM product_families pf
  ORDER BY pf.brand, pf.model_name
`);

const { rows: allContent } = await pool.query(`
  SELECT family_id, language_code, content_html FROM family_content_translations
`);
const byFamilyLang = new Map(allContent.map((r) => [`${r.family_id}:${r.language_code}`, r.content_html]));

const findings = [];
for (const family of families) {
  const label = `${family.brand} ${family.model_name}`.trim();
  const fbValue = byFamilyLang.get(`${family.id}:${FALLBACK}`)?.trim() || '';
  for (const lang of languages) {
    const value = byFamilyLang.get(`${family.id}:${lang}`)?.trim() || '';
    let status = null;
    if (!value) {
      status = fbValue ? 'empty' : 'empty (fallback also empty)';
    } else if (fbValue && value === fbValue) {
      status = 'not_translated (matches fallback verbatim)';
    } else if (fbValue && value.length / fbValue.length < 0.5) {
      status = `suspicious_short (${value.length} vs fallback ${fbValue.length} chars)`;
    }
    if (status) findings.push({ language: lang, family: label, chars_en: fbValue.length, status });
  }
}

if (FORMAT === 'csv') {
  console.log('language,family,chars_en,status');
  for (const f of findings) console.log([f.language, f.family, f.chars_en, `"${f.status}"`].join(','));
} else {
  console.log(`Fallback language: ${FALLBACK}`);
  console.log(`Languages checked: ${languages.join(', ')}`);
  console.log(`Families: ${families.length}`);
  console.log(`Findings: ${findings.length}\n`);
  console.table(findings);
  const byLang = {};
  for (const f of findings) byLang[f.language] = (byLang[f.language] || 0) + 1;
  console.log('Summary by language:', byLang);
  const totalCharsMissing = findings.reduce((s, f) => s + f.chars_en, 0);
  console.log('Total EN chars needing translation (sum across all findings):', totalCharsMissing);
}
await pool.end();
