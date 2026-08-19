import { Pool } from 'pg';
import { writeFile } from 'node:fs/promises';

// Syncs ONLY the deposit-safety category (8 articles x 8 languages) from
// local dev DB to prod. Upsert by slug, not id — dev/prod generate their
// own gen_random_uuid() independently at INSERT time, so ids never line up
// even for the "same" logical row (unlike catalog_sync.sql's product ids,
// which stayed in sync from an earlier id-preserving seed). Other 4
// categories (legal/bike-models/routes/digital-nomads) and blog-09+ are
// intentionally out of scope — left as the draft/en-only stubs from
// 048_blog_seed.sql, not touched by this script.

const pool = new Pool({ connectionString: 'postgres://localhost:5432/mdb_platform' });

function esc(v) {
  if (v === null || v === undefined) return 'NULL';
  if (typeof v === 'boolean') return v ? 'TRUE' : 'FALSE';
  if (v instanceof Date) return `'${v.toISOString()}'`;
  return `'${String(v).replace(/'/g, "''")}'`;
}

async function main() {
  const { rows: articles } = await pool.query(
    `SELECT a.slug, a.is_pillar, a.status
     FROM articles a
     JOIN article_categories ac ON ac.id = a.category_id
     WHERE ac.slug = 'deposit-safety'
     ORDER BY a.slug`
  );
  if (articles.length !== 8) throw new Error(`expected 8 deposit-safety articles, found ${articles.length}`);

  const { rows: translations } = await pool.query(
    `SELECT a.slug AS article_slug, at.language_code, at.title, at.slug,
            at.excerpt, at.content, at.seo_title, at.seo_description
     FROM articles a
     JOIN article_translations at ON at.article_id = a.id
     JOIN article_categories ac ON ac.id = a.category_id
     WHERE ac.slug = 'deposit-safety'
     ORDER BY a.slug, at.language_code`
  );
  if (translations.length !== 64) throw new Error(`expected 64 translations (8 articles x 8 langs), found ${translations.length}`);

  const out = [];
  out.push('-- blog_deposit_safety_sync.sql — regenerated ' + new Date().toISOString().slice(0, 10));
  out.push('-- Syncs ONLY article_categories.slug = \'deposit-safety\' (8 articles x 8 languages)');
  out.push('-- from local dev DB to prod. Idempotent (INSERT ... ON CONFLICT DO UPDATE), safe to re-run.');
  out.push('-- Does NOT touch legal/bike-models/routes/digital-nomads categories or blog-09+.');
  out.push('-- Upsert key: articles.slug (stable business key), NOT id (dev/prod ids differ).');
  out.push('BEGIN;\n');

  out.push(`-- articles: ${articles.length} rows (status set to 'published', published_at stamped fresh`);
  out.push('-- on prod at apply time via COALESCE — does not overwrite an existing prod published_at');
  out.push('-- on re-run, so re-applying this script does not bump the public "published" date).');
  for (const a of articles) {
    out.push(
      `INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at)\n` +
      `  SELECT ${esc(a.slug)}, ac.id, ${esc(a.is_pillar)}, NULL, 'published', now()\n` +
      `  FROM article_categories ac WHERE ac.slug = 'deposit-safety'\n` +
      `  ON CONFLICT (slug) DO UPDATE SET\n` +
      `    is_pillar = EXCLUDED.is_pillar,\n` +
      `    status = 'published',\n` +
      `    published_at = COALESCE(articles.published_at, now());`
    );
  }
  out.push('');

  out.push(`-- article_translations: ${translations.length} rows (8 articles x 8 languages)`);
  out.push('-- article_id resolved via parent article slug at insert time, not carried from dev.');
  for (const t of translations) {
    out.push(
      `INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)\n` +
      `  SELECT a.id, ${esc(t.language_code)}, ${esc(t.title)}, ${esc(t.slug)}, ${esc(t.excerpt)}, ${esc(t.content)}, ${esc(t.seo_title)}, ${esc(t.seo_description)}\n` +
      `  FROM articles a WHERE a.slug = ${esc(t.article_slug)}\n` +
      `  ON CONFLICT (article_id, language_code) DO UPDATE SET\n` +
      `    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,\n` +
      `    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,\n` +
      `    updated_at = now();`
    );
  }
  out.push('');
  out.push('COMMIT;');

  await writeFile(new URL('../../blog_deposit_safety_sync.sql', import.meta.url), out.join('\n') + '\n');
  console.log('written blog_deposit_safety_sync.sql —', articles.length, 'articles,', translations.length, 'translations');
  await pool.end();
}

main().catch((e) => { console.error(e); process.exit(1); });
