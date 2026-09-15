import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

// Builds bike_models_sync.sql (15 articles x 11 languages = 165 translations)
// for the 'bike-models' article_categories.slug, straight from locally
// authored JSON (bike_models/<lang>.json + manifest.json) — no local dev DB
// involved (unlike gen_blog_sync.mjs/gen_legal_blog_sync.mjs, which pull from
// a live localhost:5432 dev DB; that DB isn't reachable in this environment,
// so content was authored directly as data files instead). Same idempotent
// upsert-by-slug contract as those scripts, applied to prod the same way
// (backup -> scp/docker cp -> psql -f).
//
// 3 of the 15 baseSlugs (honda-adv-review, yamaha-nmax-review,
// yamaha-xsr-155-review-retro-style) are REUSED pre-existing draft stub rows
// from 048_blog_seed.sql (empty content, en-only) — Dmitry confirmed reusing
// them (updating in place) rather than creating duplicate new slugs. The
// INSERT...ON CONFLICT (slug) DO UPDATE below handles that transparently: it
// updates the existing row by its existing slug instead of inserting a new one.

const dir = path.dirname(fileURLToPath(import.meta.url));
const LANGS = ['en', 'ru', 'de', 'fr', 'es', 'it', 'ja', 'ko', 'ar', 'hi', 'zh-Hans'];

const manifest = JSON.parse(readFileSync(path.join(dir, 'manifest.json'), 'utf8'));
const byLang = {};
for (const lang of LANGS) {
  byLang[lang] = JSON.parse(readFileSync(path.join(dir, `${lang}.json`), 'utf8'));
  if (byLang[lang].length !== manifest.length) {
    throw new Error(`${lang}.json has ${byLang[lang].length} entries, expected ${manifest.length}`);
  }
}

function esc(v) {
  if (v === null || v === undefined) return 'NULL';
  if (typeof v === 'boolean') return v ? 'TRUE' : 'FALSE';
  return `'${String(v).replace(/'/g, "''")}'`;
}

const MD_LEFTOVER = [/\[.+\]\(.+\)/, /\*[^*]+\*/, /_[^_]+_/];
function assertCleanExcerpt(baseSlug, lang, excerpt) {
  if (!excerpt || !excerpt.trim()) throw new Error(`empty excerpt: ${baseSlug} / ${lang}`);
  for (const re of MD_LEFTOVER) {
    if (re.test(excerpt)) {
      throw new Error(`excerpt contains markdown syntax (${re}): ${baseSlug} / ${lang} — "${excerpt}"`);
    }
  }
}

function assertNoTodoLeftover(baseSlug, lang, content) {
  if (/\[TODO|\[Draft|внутренняя пометка|→ ссылка/i.test(content)) {
    throw new Error(`unresolved placeholder/internal note left in content: ${baseSlug} / ${lang}`);
  }
}

const out = [];
out.push('-- bike_models_sync.sql — generated ' + new Date().toISOString().slice(0, 10));
out.push("-- Syncs article_categories.slug = 'bike-models' (15 articles x 11 languages = 165 translations).");
out.push('-- Idempotent (INSERT ... ON CONFLICT DO UPDATE), safe to re-run.');
out.push('-- Does NOT touch deposit-safety/legal/routes/digital-nomads categories, or the other 5');
out.push('-- unrelated bike-models draft stubs (Vario/Scoopy/Forza-comparison/custom-bikes/model-guide).');
out.push('-- Upsert key: articles.slug (stable business key). 3 of the 15 slugs below already exist as');
out.push('-- empty en-only draft stubs (honda-adv-review, yamaha-nmax-review,');
out.push('-- yamaha-xsr-155-review-retro-style) and are intentionally reused/updated in place.');
out.push('BEGIN;\n');

out.push(`-- articles: ${manifest.length} rows (status -> 'published', published_at stamped fresh via COALESCE)`);
for (const a of manifest) {
  const familyLookup = a.familyCode
    ? `(SELECT id FROM product_families WHERE code = ${esc(a.familyCode)})`
    : 'NULL';
  out.push(
    `INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)\n` +
    `  SELECT ${esc(a.baseSlug)}, ac.id, FALSE, ${familyLookup}, 'published', now(), ${manifest.indexOf(a) + 1}\n` +
    `  FROM article_categories ac WHERE ac.slug = 'bike-models'\n` +
    `  ON CONFLICT (slug) DO UPDATE SET\n` +
    `    related_product_family_id = EXCLUDED.related_product_family_id,\n` +
    `    status = 'published',\n` +
    `    display_order = EXCLUDED.display_order,\n` +
    `    published_at = COALESCE(articles.published_at, now());`
  );
}
out.push('');

let translationCount = 0;
out.push(`-- article_translations: ${manifest.length} articles x ${LANGS.length} languages`);
for (const lang of LANGS) {
  for (const t of byLang[lang]) {
    assertCleanExcerpt(t.baseSlug, lang, t.excerpt);
    assertNoTodoLeftover(t.baseSlug, lang, t.content);
    translationCount++;
    out.push(
      `INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)\n` +
      `  SELECT a.id, ${esc(lang)}, ${esc(t.title)}, ${esc(t.slug)}, ${esc(t.excerpt)}, ${esc(t.content)}, ${esc(t.seo_title)}, ${esc(t.seo_description)}\n` +
      `  FROM articles a WHERE a.slug = ${esc(t.baseSlug)}\n` +
      `  ON CONFLICT (article_id, language_code) DO UPDATE SET\n` +
      `    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,\n` +
      `    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,\n` +
      `    updated_at = now();`
    );
  }
}
out.push('');
out.push('COMMIT;');

writeFileSync(path.join(dir, 'bike_models_sync.sql'), out.join('\n') + '\n');
console.log(`Wrote bike_models_sync.sql — ${manifest.length} articles, ${translationCount} translations.`);
