// Подготовка скриншотов отзывов (WhatsApp) к публикации на сайте.
//
// Что делает: кропает исходный экспорт (1632x2040, формат Instagram-сторис с
// градиентной подложкой) до самой переписки и жмёт в WebP 900w.
//
// Кроп двухрежимный:
//   auto   — граница ищется по дисперсии строки/колонки: градиентная подложка
//            однородна по X, область чата с пузырями — нет. Годится, когда на
//            скриншоте только сообщения клиента.
//   manual — явный box, когда из кадра надо вырезать наши собственные реплики
//            (просьба об отзыве, промо Instagram) или логистику возврата.
//            Публикуем только то, что написал клиент.
//
// Запуск (из backend/):
//   node scripts/prep_reviews.mjs <src-dir> <out-dir>
// Дальше — аплоад в R2 под префикс reviews/ (см. DEPLOY_RUNBOOK.md).

import sharp from 'sharp';
import { mkdirSync } from 'node:fs';
import path from 'node:path';

const OUT_WIDTH = 900;
const WEBP_QUALITY = 82;
const PAD = 12;          // поля вокруг найденной полосы, px исходника
const STD_THRESHOLD = 6; // порог дисперсии «контент vs подложка»

// id — бизнес-ключ отзыва, он же имя файла и ссылка из reviews.json.
// Осознанно НЕ производный от имени исходника: IMG_2743 ничего не говорит.
const SOURCES = [
  { src: 'IMG_2741.PNG', id: 'great-experience-message-back', crop: 'auto' },
  { src: 'IMG_2743.PNG', id: 'vstrom-250-breakdown-handled', crop: { left: 240, top: 30, width: 1150, height: 1980 } },
  { src: 'IMG_2744.PNG', id: 'pleasure-to-ride-good-condition', crop: 'auto' },
  // Середина кадра — наша просьба об отзыве и ссылка на Instagram: не публикуем.
  { src: 'IMG_2745.JPEG', id: 'best-service-ive-had-in-bali', crop: { left: 280, top: 1390, width: 930, height: 560 } },
  { src: 'IMG_2746.JPEG', id: 'want-the-same-bike-next-time', crop: { left: 66, top: 300, width: 1250, height: 480 } },
  // Верх кадра — договорённость о возврате байка, отзыв только в последнем абзаце.
  { src: 'IMG_2748.JPEG', id: 'will-definitely-rent-again-manu', crop: { left: 66, top: 1050, width: 1240, height: 530 } },
  // Верх — наша реплика; оставляем сообщения клиента, включая просьбу дать Google-аккаунт.
  { src: 'IMG_2749.PNG', id: 'good-bikes-good-service-good-people', crop: { left: 72, top: 450, width: 1290, height: 810 } },
  // IMG_2747 не берём: сообщение про helmetsack — операционка, не отзыв.

  // Партия 2 (2026-08-07)
  { src: 'IMG_2797.PNG', id: 'fast-replies-recommend', crop: 'auto' },
  { src: 'IMG_2798.PNG', id: 'treated-bike-like-our-own', crop: 'auto' },
  { src: 'IMG_2799.PNG', id: 'helped-find-bike-same-day', crop: 'auto' },
  { src: 'IMG_2800.PNG', id: 'clean-bikes-deposit-returned-full', crop: 'auto' },
  { src: 'IMG_2801.PNG', id: 'helped-beyond-the-rental', crop: 'auto' },
  { src: 'IMG_2802.PNG', id: 'great-service-good-prices', crop: 'auto' },
  // Верх кадра — наша реплика "No problem at all!"; берём только ответ клиента.
  { src: 'IMG_2803.PNG', id: 'the-bikes-amazing-thank-you', crop: { left: 0, top: 150, width: 1124, height: 180 } },
  { src: 'IMG_2804.PNG', id: 'good-time-with-your-bikes', crop: 'auto' },
  // Полный скрин переписки с Peter: вырезаем только его реплику про байк,
  // логистику встречи и наши ответы не публикуем. photo_...-55 (продолжение
  // той же переписки, жалоба на боковые кофры) не берём — это операционка.
  { src: 'photo_2026-08-07_12-00-53.jpg', id: 'really-great-bike-love-it', crop: { left: 0, top: 685, width: 590, height: 100 } },
];

async function autoBox(img, w, h) {
  const { data } = await img.clone().greyscale().raw().toBuffer({ resolveWithObject: true });
  const std = (vals) => {
    let sum = 0, sq = 0;
    for (const v of vals) { sum += v; sq += v * v; }
    const mean = sum / vals.length;
    return Math.sqrt(Math.max(0, sq / vals.length - mean * mean));
  };

  const rowStd = [];
  for (let y = 0; y < h; y++) {
    const row = [];
    for (let x = 0; x < w; x++) row.push(data[y * w + x]);
    rowStd.push(std(row));
  }
  let top = rowStd.findIndex((s) => s > STD_THRESHOLD);
  let bot = h - 1;
  while (bot > 0 && rowStd[bot] <= STD_THRESHOLD) bot--;
  if (top < 0 || bot <= top) { top = 0; bot = h - 1; }

  const colStd = [];
  for (let x = 0; x < w; x++) {
    const col = [];
    for (let y = top; y <= bot; y++) col.push(data[y * w + x]);
    colStd.push(std(col));
  }
  let left = colStd.findIndex((s) => s > STD_THRESHOLD);
  let right = w - 1;
  while (right > 0 && colStd[right] <= STD_THRESHOLD) right--;
  if (left < 0 || right <= left) { left = 0; right = w - 1; }

  return {
    left: Math.max(0, left - PAD),
    top: Math.max(0, top - PAD),
    width: Math.min(w, right + PAD) - Math.max(0, left - PAD),
    height: Math.min(h, bot + PAD) - Math.max(0, top - PAD),
  };
}

const [, , srcDir, outDir] = process.argv;
if (!srcDir || !outDir) {
  console.error('usage: node scripts/prep_reviews.mjs <src-dir> <out-dir>');
  process.exit(1);
}
mkdirSync(outDir, { recursive: true });

for (const { src, id, crop } of SOURCES) {
  const img = sharp(path.join(srcDir, src));
  const { width, height } = await img.metadata();
  const box = crop === 'auto' ? await autoBox(img, width, height) : crop;

  const out = path.join(outDir, `${id}.webp`);
  const info = await img
    .clone()
    .extract(box)
    .resize({ width: OUT_WIDTH, withoutEnlargement: true })
    .webp({ quality: WEBP_QUALITY })
    .toFile(out);

  console.log(
    `${src} → ${id}.webp  ${info.width}x${info.height}  ${(info.size / 1024).toFixed(0)} KB` +
    `  [${crop === 'auto' ? 'auto' : 'manual'}]`
  );
}
