import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const dir = path.dirname(fileURLToPath(import.meta.url));
const manifest = JSON.parse(readFileSync(path.join(dir, 'manifest.json'), 'utf8'));
const ruSlugs = JSON.parse(readFileSync(path.join(dir, 'ru_slugs.json'), 'utf8'));

const out = manifest.map((a) => {
  const content = readFileSync(path.join(dir, 'ru', a.file), 'utf8').trim();
  return {
    baseSlug: a.baseSlug,
    title: a.title.ru,
    slug: ruSlugs[a.baseSlug],
    excerpt: a.excerpt.ru,
    content,
    seo_title: a.title.ru,
    seo_description: a.seo_description.ru,
  };
});

if (out.length !== 15) throw new Error(`expected 15, got ${out.length}`);
for (const o of out) {
  if (!o.slug) throw new Error(`missing ru slug for ${o.baseSlug}`);
}

writeFileSync(path.join(dir, 'ru.json'), JSON.stringify(out, null, 2) + '\n');
console.log('wrote ru.json —', out.length, 'articles');
