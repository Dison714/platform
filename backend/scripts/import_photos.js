// Photo importer (Photos chunk, Step 2C).
//
// Reads a manifest (produced from Drive folder listings, applying the Step 2B
// folder→product decisions) and, per product:
//   - downloads each source photo from Drive over public HTTPS (folders must be
//     shared "anyone with link"),
//   - resizes with sharp to 3 WebP sizes (thumb 400w / gallery 800w / hero 1200w),
//   - writes frontend/public/bikes/<slug>/{thumb,gallery,hero}/NN.webp,
//   - inserts one product_photos row (storage_path = bikes/<slug>/NN, size-agnostic;
//     the size dir is added at render time).
//
// Idempotent: a photo already present in product_photos (matched by
// product_id + source_url = Drive fileId) is skipped; existing NN/sort_order are
// preserved, new files append after the current max sort_order.
//
// Usage:
//   node scripts/import_photos.js --manifest scripts/photos_manifest.json            # all products in manifest
//   node scripts/import_photos.js --manifest ... --slugs a,b,c                        # only these slugs
//   node scripts/import_photos.js --manifest ... --check                             # validate manifest↔DB, no download
//
// DEPLOY NOTE: this script is meant for a LOCAL (macOS) run only. HEIC inputs are
// decoded via macOS `sips` before sharp (libheif in sharp hits a security-limit
// bug on the same iPhone HEIC files regardless of OS — see Photos chunk notes);
// `sips` does not exist on the Coolify Linux container, so re-running this script
// there will fail on any HEIC source. The R2/S3 migration (open question, see
// PROJECT_STATUS.md) should upload the already-generated .webp files already
// sitting in frontend/public/bikes/, not re-derive them from Drive/HEIC.

import { readFile, mkdir, writeFile, access, stat, unlink } from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';
import { exec } from 'node:child_process';
import { promisify } from 'node:util';
import { randomUUID } from 'node:crypto';
import sharp from 'sharp';
import { pool } from '../src/db/pool.js';

const execFileP = promisify(exec);

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PUBLIC_BIKES = path.resolve(__dirname, '..', '..', 'frontend', 'public', 'bikes');

const SIZES = { thumb: 400, gallery: 800, hero: 1200 };
const WEBP = { quality: 82, effort: 4 };

function arg(name) {
  const i = process.argv.indexOf(name);
  return i !== -1 ? process.argv[i + 1] : undefined;
}
const hasFlag = (name) => process.argv.includes(name);

const pad2 = (n) => String(n).padStart(2, '0');
const isImage = (f) => typeof f.mime === 'string' && f.mime.startsWith('image/') && f.name !== '.DS_Store';
// natural sort: folder order as given, then numeric-aware filename order within folder
function orderFiles(files) {
  const folders = [...new Set(files.map((f) => f.folder))];
  return files
    .filter(isImage)
    .sort((a, b) => {
      const fa = folders.indexOf(a.folder), fb = folders.indexOf(b.folder);
      if (fa !== fb) return fa - fb;
      return a.name.localeCompare(b.name, undefined, { numeric: true, sensitivity: 'base' });
    });
}

async function exists(p) {
  try { await access(p); return true; } catch { return false; }
}

// Download a Drive file's bytes over public HTTPS. Handles the large-file
// "confirm" interstitial (not expected for ~5MB images, but safe).
async function downloadDriveFile(fileId) {
  const base = `https://drive.google.com/uc?export=download&id=${fileId}`;
  let res = await fetch(base, { redirect: 'follow' });
  let ct = res.headers.get('content-type') || '';
  if (ct.includes('text/html')) {
    const html = await res.text();
    const m = html.match(/confirm=([0-9A-Za-z_-]+)/);
    if (m) {
      res = await fetch(`${base}&confirm=${m[1]}`, { redirect: 'follow' });
      ct = res.headers.get('content-type') || '';
    }
    if (ct.includes('text/html')) {
      throw new Error('got HTML (folder not public / access denied) — set Drive folder to "anyone with link"');
    }
  }
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return Buffer.from(await res.arrayBuffer());
}

// iPhone HEIC files exceed libheif's iref-reference security limit inside sharp,
// so decode them with macOS `sips` (→ JPEG) before handing to sharp. Non-HEIC
// buffers pass through unchanged.
async function decodeMaybeHeic(buf, name) {
  if (!/\.hei[cf]$/i.test(name)) return buf;
  const tmpIn = path.join(os.tmpdir(), `imp-${randomUUID()}.heic`);
  const tmpOut = `${tmpIn}.jpg`;
  try {
    await writeFile(tmpIn, buf);
    await execFileP(`sips -s format jpeg ${JSON.stringify(tmpIn)} --out ${JSON.stringify(tmpOut)}`);
    return await readFile(tmpOut);
  } finally {
    await unlink(tmpIn).catch(() => {});
    await unlink(tmpOut).catch(() => {});
  }
}

async function resizeToWebp(srcBuf, slug, nn) {
  const dir = path.join(PUBLIC_BIKES, slug);
  for (const [size, width] of Object.entries(SIZES)) {
    const outDir = path.join(dir, size);
    await mkdir(outDir, { recursive: true });
    const out = path.join(outDir, `${nn}.webp`);
    const buf = await sharp(srcBuf)
      .rotate() // respect EXIF orientation
      .resize({ width, withoutEnlargement: true })
      .webp(WEBP)
      .toBuffer();
    await writeFile(out, buf);
  }
}

async function run() {
  const manifestPath = arg('--manifest');
  if (!manifestPath) throw new Error('missing --manifest <path>');
  const manifest = JSON.parse(await readFile(path.resolve(__dirname, '..', manifestPath), 'utf8'));
  const only = arg('--slugs')?.split(',').map((s) => s.trim()).filter(Boolean);
  const checkOnly = hasFlag('--check');

  const slugs = Object.keys(manifest.products).filter((s) => !only || only.includes(s));

  // resolve slug → product_id, report any manifest slug missing in DB
  const { rows: prodRows } = await pool.query('SELECT id, slug FROM products');
  const idBySlug = new Map(prodRows.map((r) => [r.slug, r.id]));
  const missing = slugs.filter((s) => !idBySlug.has(s));
  if (missing.length) {
    console.error('MANIFEST references slugs not in DB:', missing.join(', '));
    if (checkOnly) { await pool.end(); process.exitCode = 1; return; }
    throw new Error('aborting: unknown slugs in manifest');
  }
  console.log(`manifest OK: ${slugs.length} product(s), all slugs exist in DB`);
  if (checkOnly) { await pool.end(); return; }

  let tot = { new: 0, skipped: 0, errors: 0, heic: 0 };
  const zero = [];

  for (const slug of slugs) {
    const files = orderFiles(manifest.products[slug]);
    const productId = idBySlug.get(slug);
    const { rows: existing } = await pool.query(
      'SELECT source_url, sort_order FROM product_photos WHERE product_id=$1', [productId]);
    const have = new Set(existing.map((r) => r.source_url));
    let nextOrder = existing.reduce((m, r) => Math.max(m, r.sort_order), 0);
    const foldersUsed = [...new Set(files.map((f) => f.folder))];
    let n = 0, s = 0, h = 0, e = 0;

    for (const f of files) {
      if (have.has(f.fileId)) { s++; continue; }
      nextOrder += 1;
      const nn = pad2(nextOrder);
      try {
        const dir = path.join(PUBLIC_BIKES, slug);
        const done = (await Promise.all(Object.keys(SIZES).map((sz) =>
          exists(path.join(dir, sz, `${nn}.webp`))))).every(Boolean);
        if (!done) {
          const buf = await downloadDriveFile(f.fileId);
          const src = await decodeMaybeHeic(buf, f.name);
          await resizeToWebp(src, slug, nn);
        }
        await pool.query(
          `INSERT INTO product_photos (product_id, source_url, storage_path, sort_order, cdn_url, is_hero)
           VALUES ($1,$2,$3,$4,NULL,FALSE)`,
          [productId, f.fileId, `bikes/${slug}/${nn}`, nextOrder]);
        n++;
      } catch (err) {
        const heic = /heic|heif/i.test(f.name) || /heif/i.test(err.message);
        if (heic) { h++; console.warn(`   HEIC WARN ${slug} ${f.name}: ${err.message}`); }
        else { e++; console.error(`   ERROR ${slug} ${f.name}: ${err.message}`); }
        nextOrder -= 1; // don't consume an index for a failed file
      }
    }

    const count = existing.length + n;
    if (count === 0) zero.push(slug);
    console.log(`${slug} | folders: ${foldersUsed.join(' + ') || '—'} | new ${n} | skipped ${s} | heic-warn ${h} | errors ${e} | total ${count}`);
    tot.new += n; tot.skipped += s; tot.errors += e; tot.heic += h;
  }

  console.log('\n=== SUMMARY ===');
  console.log(`products processed: ${slugs.length}`);
  console.log(`photos: new ${tot.new} | skipped(existing) ${tot.skipped} | errors ${tot.errors} | heic-warn ${tot.heic}`);
  console.log(`products with 0 photos after import: ${zero.length ? zero.join(', ') : 'none'}`);
  await pool.end();
}

run().catch(async (e) => { console.error('FATAL:', e.message); try { await pool.end(); } catch {} process.exitCode = 1; });
