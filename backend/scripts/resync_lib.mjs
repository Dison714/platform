import { readFile, mkdir, writeFile, rm, readdir } from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { randomUUID } from 'node:crypto';
import { exec } from 'node:child_process';
import { promisify } from 'node:util';
import sharp from 'sharp';
import pg from 'pg';

const execP = promisify(exec);
const { Pool } = pg;
export const pool = new Pool({ connectionString: 'postgres://localhost:5432/mdb_platform' });

export const SRC_ROOT = '/Users/dmitry/Documents/Документы с 05.2013/Инвестиции/Индонезия/Байки/Фото байков для сайта';
export const PUBLIC_BIKES = '/Users/dmitry/Documents/Документы с 05.2013/Инвестиции/Индонезия/Байки/Сайт Platform/Claude/Claude Code/platform/frontend/public/bikes';
const SIZES = { thumb: 400, gallery: 800, hero: 1200 };
const WEBP = { quality: 82, effort: 4 };
export const RULE_SET_ID = '97c17d94-f90b-48d8-8eff-7da88e2c14fe';
export const COMPANY_ID = 'd813b6be-41a1-41e7-9bb6-9d8bbedf5901';

const pad2 = (n) => String(n).padStart(2, '0');

async function decodeMaybeHeic(buf, name) {
  if (!/\.hei[cf]$/i.test(name)) return buf;
  const tmpIn = path.join(os.tmpdir(), `rs-${randomUUID()}.heic`);
  const tmpOut = `${tmpIn}.jpg`;
  await writeFile(tmpIn, buf);
  await execP(`sips -s format jpeg ${JSON.stringify(tmpIn)} --out ${JSON.stringify(tmpOut)}`);
  const out = await readFile(tmpOut);
  return out;
}

export async function getProductId(slug) {
  const { rows } = await pool.query('SELECT id FROM products WHERE slug=$1', [slug]);
  return rows[0]?.id ?? null;
}

// Полная пересборка фото продукта: удаляет ВСЕ текущие фото (rows+files) и
// заливает заново строго из указанной папки/списка файлов — без сохранения
// старых, без частичного патча. folder — относительно SRC_ROOT.
export async function resyncPhotos(slug, folder, files, heroFile) {
  const productId = await getProductId(slug);
  if (!productId) throw new Error(`product not found: ${slug}`);

  const oldDirs = ['thumb', 'gallery', 'hero'];
  for (const size of oldDirs) {
    const dir = path.join(PUBLIC_BIKES, slug, size);
    try {
      const existing = await readdir(dir);
      for (const f of existing) await rm(path.join(dir, f), { force: true });
    } catch { /* dir may not exist yet */ }
  }
  await pool.query('DELETE FROM product_photos WHERE product_id=$1', [productId]);

  const dir = path.join(PUBLIC_BIKES, slug);
  for (let i = 0; i < files.length; i++) {
    const fname = files[i];
    const nn = pad2(i + 1);
    const raw = await readFile(path.join(SRC_ROOT, folder, fname));
    const buf = await decodeMaybeHeic(raw, fname);
    for (const [size, width] of Object.entries(SIZES)) {
      const outDir = path.join(dir, size);
      await mkdir(outDir, { recursive: true });
      const webpBuf = await sharp(buf).rotate().resize({ width, withoutEnlargement: true }).webp(WEBP).toBuffer();
      await writeFile(path.join(outDir, `${nn}.webp`), webpBuf);
    }
    await pool.query(
      `INSERT INTO product_photos (product_id, source_url, storage_path, sort_order, cdn_url, is_hero)
       VALUES ($1,$2,$3,$4,NULL,$5)`,
      [productId, `local:${folder}/${fname}`, `bikes/${slug}/${nn}`, i + 1, fname === heroFile]
    );
  }
  await pool.query('UPDATE products SET need_photos=FALSE WHERE id=$1', [productId]);
  console.log(`resynced ${slug} <- ${folder} (${files.length} photos, hero=${heroFile})`);
}

export async function createProduct({ familyCode, slug, color_name, variant = '', print_name = null, equipment_variant = null, internal_name, priceTier }) {
  const existing = await getProductId(slug);
  if (existing) { console.log(`product already exists: ${slug}`); return existing; }
  const fam = await pool.query('SELECT id FROM product_families WHERE code=$1', [familyCode]);
  if (!fam.rows.length) throw new Error(`family not found: ${familyCode}`);
  const familyId = fam.rows[0].id;
  const ins = await pool.query(
    `INSERT INTO products (family_id, color_name, slug, internal_name, variant, print_name, equipment_variant, is_active, is_bookable, need_photos, archived_color, partner_bike)
     VALUES ($1,$2,$3,$4,$5,$6,$7,TRUE,TRUE,TRUE,FALSE,FALSE) RETURNING id`,
    [familyId, color_name, slug, internal_name, variant, print_name, equipment_variant]
  );
  const productId = ins.rows[0].id;
  for (const [days, priceIdr] of priceTier) {
    await pool.query(
      `INSERT INTO price_rules (rule_set_id, product_id, rental_days, price_idr) VALUES ($1,$2,$3,$4)`,
      [RULE_SET_ID, productId, days, priceIdr]
    );
  }
  console.log(`created product: ${slug} (${productId})`);
  return productId;
}

export async function attachVideo(slug, folder, videoFile, slot = 1) {
  const srcPath = path.join(SRC_ROOT, folder, videoFile);
  const outName = slot === 1 ? 'video.mp4' : `video-${slot}.mp4`;
  const outPath = path.join(PUBLIC_BIKES, slug, outName);
  await mkdir(path.dirname(outPath), { recursive: true });
  await execP(
    `ffmpeg -y -i ${JSON.stringify(srcPath)} -vf "scale=1920:1080:force_original_aspect_ratio=decrease:force_divisible_by=2" -c:v libx264 -preset medium -crf 23 -pix_fmt yuv420p -c:a aac -b:a 128k -movflags +faststart ${JSON.stringify(outPath)} -loglevel error`
  );
  console.log(`video attached: ${slug} slot${slot} <- ${videoFile}`);
}

export const PRICE_TIER_XSR = [[3, 900000], [7, 1200000], [14, 1800000], [21, 2300000], [30, 2500000]];
