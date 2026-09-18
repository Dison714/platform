// Bike Models category (2026-09-18): sets articles.featured_image_url and
// prepends one Markdown embed image (![alt](url)) to article_translations
// .content for 14 review articles + the PCX/ADV/Nmax comparison + the
// smart-key article. Photos are existing product_photos (storage_path only,
// cdn_url is unpopulated fleet-wide — resolvePhotoUrl in frontend/src/lib/
// photos.js builds the real URL from storage_path + size dir + .webp).
// content is rendered as Markdown via react-markdown (no rehype-raw), so
// embeds must use `![alt](url)`, not raw <img> — a literal <img> tag would
// not render at all.
//
// Input: /tmp/content_export.csv, produced on the prod DB with:
//   COPY (select at.id, art.slug, at.language_code, at.content
//         from article_translations at join articles art on art.id = at.article_id
//         where art.slug in (<15 slugs>)) TO '...' WITH (FORMAT csv, HEADER true);
// Output: /tmp/apply_photo_content.sql — reviewed, then applied via the
// scp + docker cp + psql -f pattern (see CLAUDE.md §6). featured_image_url
// was applied separately via bike_models_photos_featured_sync.sql (plain
// per-slug UPDATEs, no export needed since it doesn't touch existing text).
import fs from 'node:fs';

const CDN = 'https://cdn.bikebalirent.com';
function url(storagePath, size) {
  const i = storagePath.lastIndexOf('/');
  const dir = storagePath.slice(0, i);
  const name = storagePath.slice(i + 1);
  return `${CDN}/${dir}/${size}/${name}.webp`;
}

const PHRASES = {
  en: { front: 'rental {kind} in Bali — front view', side: 'rental {kind} in Bali — side view', rear: 'rental {kind} in Bali — rear view' },
  ru: { front: '{kind} напрокат на Бали — вид спереди', side: '{kind} напрокат на Бали — вид сбоку', rear: '{kind} напрокат на Бали — вид сзади' },
  de: { front: 'Miet{kind} auf Bali — Frontansicht', side: 'Miet{kind} auf Bali — Seitenansicht', rear: 'Miet{kind} auf Bali — Heckansicht' },
  fr: { front: '{kind} de location à Bali — vue de face', side: '{kind} de location à Bali — vue de côté', rear: '{kind} de location à Bali — vue arrière' },
  es: { front: '{kind} de alquiler en Bali — vista frontal', side: '{kind} de alquiler en Bali — vista lateral', rear: '{kind} de alquiler en Bali — vista trasera' },
  it: { front: '{kind} a noleggio a Bali — vista frontale', side: '{kind} a noleggio a Bali — vista laterale', rear: '{kind} a noleggio a Bali — vista posteriore' },
  ja: { front: 'バリ島のレンタル{kind} — 正面から', side: 'バリ島のレンタル{kind} — 側面から', rear: 'バリ島のレンタル{kind} — 背面から' },
  ar: { front: '{kind} للإيجار في بالي — منظر أمامي', side: '{kind} للإيجار في بالي — منظر جانبي', rear: '{kind} للإيجار في بالي — منظر خلفي' },
  ko: { front: '발리 렌탈 {kind} — 정면 모습', side: '발리 렌탈 {kind} — 측면 모습', rear: '발리 렌탈 {kind} — 후면 모습' },
  hi: { front: 'बाली में किराये की {kind} — सामने से दृश्य', side: 'बाली में किराये की {kind} — बगल से दृश्य', rear: 'बाली में किराये की {kind} — पीछे से दृश्य' },
  'zh-Hans': { front: '巴厘岛租赁{kind} — 正面视图', side: '巴厘岛租赁{kind} — 侧面视图', rear: '巴厘岛租赁{kind} — 后视图' },
};
const KIND_WORD = {
  en: { scooter: 'scooter', motorcycle: 'motorcycle' },
  ru: { scooter: 'скутер', motorcycle: 'мотоцикл' },
  de: { scooter: 'roller', motorcycle: 'motorrad' },
  fr: { scooter: 'scooter', motorcycle: 'moto' },
  es: { scooter: 'scooter', motorcycle: 'moto' },
  it: { scooter: 'scooter', motorcycle: 'moto' },
  ja: { scooter: 'スクーター', motorcycle: 'バイク' },
  ar: { scooter: 'سكوتر', motorcycle: 'دراجة نارية' },
  ko: { scooter: '스쿠터', motorcycle: '오토바이' },
  hi: { scooter: 'स्कूटर', motorcycle: 'मोटरसाइकिल' },
  'zh-Hans': { scooter: '踏板车', motorcycle: '摩托车' },
};
function altText(lang, model, kind, angle) {
  const phrase = PHRASES[lang][angle].replace('{kind}', KIND_WORD[lang][kind]);
  return `${model}, ${phrase}`;
}

const ARTICLES = {
  'honda-pcx160-review': { model: 'Honda PCX160', kind: 'scooter', embed: 'bikes/honda-pcx-pink-blue-cbs/08', angle: 'front' },
  'honda-adv-review': { model: 'Honda ADV160', kind: 'scooter', embed: 'bikes/honda-adv-white/28', angle: 'side' },
  'yamaha-nmax-review': { model: 'Yamaha Nmax', kind: 'scooter', embed: 'bikes/yamaha-nmax-blue/05', angle: 'side' },
  'yamaha-xmax250-review': { model: 'Yamaha XMAX250', kind: 'scooter', embed: 'bikes/yamaha-xmax-grey/02', angle: 'side' },
  'yamaha-mt25-review': { model: 'Yamaha MT-25', kind: 'motorcycle', embed: 'bikes/yamaha-mt25-black/02', angle: 'side' },
  'kawasaki-ninja-zx-25r-review': { model: 'Kawasaki Ninja ZX-25R', kind: 'motorcycle', embed: 'bikes/kawasaki-zx25r-blue/06', angle: 'side' },
  'yamaha-xsr-155-review-retro-style': { model: 'Yamaha XSR155', kind: 'motorcycle', embed: 'bikes/yamaha-xsr-black-original/01', angle: 'side' },
  'kawasaki-versys-x250-review': { model: 'Kawasaki Versys-X 250', kind: 'motorcycle', embed: 'bikes/kawasaki-versys-black/03', angle: 'side' },
  'suzuki-v-strom-250-review': { model: 'Suzuki V-Strom 250', kind: 'motorcycle', embed: 'bikes/suzuki-vstrom250-black/02', angle: 'side' },
  'tvs-ronin-225-review': { model: 'TVS Ronin 225', kind: 'motorcycle', embed: 'bikes/tvs-ronin225-total-black/02', angle: 'side' },
  'keeway-road-falcon-250-review': { model: 'Keeway Road Falcon 250', kind: 'motorcycle', embed: 'bikes/keeway-road-falcon-250-black/01', angle: 'front' },
  'morbidelli-c252v-review': { model: 'Morbidelli C252V', kind: 'motorcycle', embed: 'bikes/morbidelli-c252v-black/09', angle: 'rear' },
  'honda-cbr250rr-review': { model: 'Honda CBR250RR', kind: 'motorcycle', embed: 'bikes/honda-cbr250rr-white-blue/03', angle: 'rear' },
  'honda-cb150x-review': { model: 'Honda CB150X', kind: 'motorcycle', embed: 'bikes/honda-cb150x-black/01', angle: 'side' },
  'how-to-start-and-use-your-rental-scooters-smart-key': { model: 'Yamaha XMAX250', kind: 'scooter', embed: 'bikes/yamaha-xmax-grey/02', angle: 'side' },
};

const COMPARISON_SLUG = 'pcx160-vs-adv160-vs-nmax-how-to-choose';
const COMPARISON_IMAGES = [
  { model: 'Honda PCX160', kind: 'scooter', path: 'bikes/honda-pcx-pink-blue-cbs/04', angle: 'side' },
  { model: 'Honda ADV160', kind: 'scooter', path: 'bikes/honda-adv-white/30', angle: 'front' },
  { model: 'Yamaha Nmax', kind: 'scooter', path: 'bikes/yamaha-nmax-blue/01', angle: 'front' },
];

// --- minimal RFC4180 CSV parser (handles quoted fields with embedded
// newlines/commas/doubled quotes, as produced by Postgres COPY ... CSV) ---
function parseCsv(text) {
  const rows = [];
  let row = [];
  let field = '';
  let inQuotes = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (inQuotes) {
      if (c === '"') {
        if (text[i + 1] === '"') { field += '"'; i++; }
        else inQuotes = false;
      } else field += c;
    } else {
      if (c === '"') inQuotes = true;
      else if (c === ',') { row.push(field); field = ''; }
      else if (c === '\n') { row.push(field); rows.push(row); row = []; field = ''; }
      else if (c === '\r') { /* skip */ }
      else field += c;
    }
  }
  if (field.length || row.length) { row.push(field); rows.push(row); }
  return rows;
}

const csvText = fs.readFileSync('/tmp/content_export.csv', 'utf8');
const [header, ...rows] = parseCsv(csvText).filter((r) => r.length > 1 || r[0] !== '');
console.log('header:', header, 'rows:', rows.length);

const sqlLines = ['BEGIN;'];
let updated = 0, skipped = 0;

for (const r of rows) {
  const [id, slug, lang, content] = r;
  if (!id) continue;

  let newContent;
  if (slug === COMPARISON_SLUG) {
    if (content.trimStart().startsWith('![')) { skipped++; continue; }
    const block = COMPARISON_IMAGES
      .map((img) => `![${altText(lang, img.model, img.kind, img.angle)}](${url(img.path, 'gallery')})`)
      .join('\n\n');
    newContent = `${block}\n\n${content}`;
  } else {
    const a = ARTICLES[slug];
    if (!a) throw new Error(`no photo config for slug ${slug}`);
    if (content.trimStart().startsWith('![')) { skipped++; continue; }
    const alt = altText(lang, a.model, a.kind, a.angle);
    const embedUrl = url(a.embed, 'gallery');
    newContent = `![${alt}](${embedUrl})\n\n${content}`;
  }

  const escaped = newContent.replace(/'/g, "''");
  sqlLines.push(`UPDATE article_translations SET content = '${escaped}' WHERE id = '${id}';`);
  updated++;
}
sqlLines.push('COMMIT;');

fs.writeFileSync('/tmp/apply_photo_content.sql', sqlLines.join('\n'));
console.log(`updated: ${updated}, skipped (already had image): ${skipped}`);
