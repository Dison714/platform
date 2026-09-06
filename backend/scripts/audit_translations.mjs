// Аудит переводов карточек байков (Webvisor 01.09.2026, Задача 2) — только
// отчёт, ничего не правит. Сравнивает product_translations по всем языкам с
// фоллбек-языком (--fallback, по умолчанию en — DEFAULT_LOCALE сайта,
// frontend/src/i18n/config.js). Пусто/NULL, дословное совпадение с фоллбеком
// (= не переведено, скопировано) и подозрительная длина (короче фоллбека
// более чем в K раз, --ratio, по умолчанию 3) — на каждое поле из --fields
// (по умолчанию description; можно title,seo_title,seo_description).
//
// Usage:
//   node scripts/audit_translations.mjs
//   node scripts/audit_translations.mjs --fallback ru --fields description,seo_description --ratio 2.5
//   node scripts/audit_translations.mjs --format csv > report.csv

import { pool } from '../src/db/pool.js';

function arg(name, fallback) {
  const i = process.argv.indexOf(`--${name}`);
  return i !== -1 ? process.argv[i + 1] : fallback;
}

const FALLBACK = arg('fallback', 'en');
const FIELDS = arg('fields', 'description').split(',').map((s) => s.trim());
const RATIO = parseFloat(arg('ratio', '3'));
const FORMAT = arg('format', 'table'); // table | csv

// Только реально включённые на сайте локали (frontend/src/i18n/config.js
// LOCALES enabled:true) — languages в БД уже содержит Phase 2/3 заготовки
// (nl, pt, pl, cs, sk, ko, zh-Hans, zh-Hant), для них пустые переводы не
// баг, эти языки ещё не запущены (ТЗ §5). Список обновлять synced с i18n/config.js.
const SITE_LOCALES = ['en', 'ru', 'de', 'fr', 'es', 'it', 'ja', 'ar'];
const languages = SITE_LOCALES.filter((c) => c !== FALLBACK);

const { rows: products } = await pool.query(`
  SELECT p.id, p.slug, p.internal_name AS name
  FROM products p
  ORDER BY p.slug
`);

const { rows: allTranslations } = await pool.query(`
  SELECT product_id, language_code, title, description, seo_title, seo_description
  FROM product_translations
`);

const byProductLang = new Map();
for (const t of allTranslations) {
  byProductLang.set(`${t.product_id}:${t.language_code}`, t);
}

const findings = [];

for (const product of products) {
  const fb = byProductLang.get(`${product.id}:${FALLBACK}`);
  for (const field of FIELDS) {
    const fbValue = fb?.[field]?.trim() || '';
    for (const lang of languages) {
      const t = byProductLang.get(`${product.id}:${lang}`);
      const value = t?.[field]?.trim() || '';

      let status = null;
      if (!value) {
        status = fbValue ? 'empty' : 'empty (fallback also empty)';
      } else if (fbValue && value === fbValue) {
        status = 'not_translated (matches fallback verbatim)';
      } else if (fbValue && value.length > 0 && fbValue.length / value.length >= RATIO) {
        status = `suspicious_short (${value.length} vs fallback ${fbValue.length} chars)`;
      }

      if (status) {
        findings.push({
          language: lang,
          product_slug: product.slug,
          product_name: product.name,
          field,
          url: `/${lang}/bikes/${product.slug}`,
          status,
        });
      }
    }
  }
}

if (FORMAT === 'csv') {
  console.log('language,product_slug,field,url,status');
  for (const f of findings) {
    console.log([f.language, f.product_slug, f.field, f.url, `"${f.status}"`].join(','));
  }
} else {
  console.log(`Fallback language: ${FALLBACK}`);
  console.log(`Fields checked: ${FIELDS.join(', ')}`);
  console.log(`Languages checked: ${languages.join(', ')}`);
  console.log(`Products: ${products.length}`);
  console.log(`Findings: ${findings.length}\n`);
  console.table(findings);

  const byStatus = {};
  for (const f of findings) {
    const key = f.status.split(' (')[0];
    byStatus[key] = (byStatus[key] || 0) + 1;
  }
  console.log('\nSummary by status:', byStatus);

  const byLang = {};
  for (const f of findings) byLang[f.language] = (byLang[f.language] || 0) + 1;
  console.log('Summary by language:', byLang);
}

await pool.end();
