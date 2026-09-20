import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

// One-time extraction: Blog/blog-r*.md (H1 title + 2 italic editorial-metadata
// lines + body) -> routes_data/ru/<baseSlug>.md (body only, matching the
// bike_models_data/ru/*.md convention — title lives in manifest.json / the
// H1 itself is re-derived by build_ru_json.mjs, editorial metadata lines are
// internal authoring notes, not public content).

const dir = path.dirname(fileURLToPath(import.meta.url));
const blogDir = path.join(dir, '..', '..', '..', 'Blog');
const manifest = JSON.parse(readFileSync(path.join(dir, 'manifest.json'), 'utf8'));

for (const a of manifest) {
  const raw = readFileSync(path.join(blogDir, a.file), 'utf8');
  const lines = raw.split('\n');
  if (!lines[0].startsWith('# ')) throw new Error(`${a.file}: expected H1 on line 1`);
  const title = lines[0].slice(2).trim();

  // drop the H1, then drop leading italic editorial-metadata lines (start
  // with '*' and end with '*', e.g. "*Категория: ... язык: ru*")
  let i = 1;
  while (i < lines.length && lines[i].trim() === '') i++;
  while (i < lines.length && /^\*.+\*$/.test(lines[i].trim())) {
    i++;
    while (i < lines.length && lines[i].trim() === '') i++;
  }
  const body = lines.slice(i).join('\n').trim();

  writeFileSync(path.join(dir, 'ru', `${a.baseSlug}.md`), body + '\n');
  console.log(a.baseSlug, '- title:', title, '- body chars:', body.length);
}
