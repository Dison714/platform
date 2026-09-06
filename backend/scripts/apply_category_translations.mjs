// Заполняет vehicle_category_translations для ru (Webvisor 01.09.2026,
// продолжение задачи 2). Аудит показал: de/fr/es/it/ja/ar уже полностью
// переведены (10/10 каждая), en вообще без строк (не нужно — базовое
// vehicle_categories.name уже на английском, служит EN-фоллбеком по
// COALESCE, см. 038_vehicle_category_translations.sql), ru — 0/10, полный
// пробел. Brand+model категории (Honda ADV 160 и т.п.) — латиницей, как и
// во всех остальных языках; переводятся только 5 "жанровых" категорий.
import { pool } from '../src/db/pool.js';

const RU_NAMES = {
  honda_adv160: 'Honda ADV 160',
  honda_pcx160: 'Honda PCX 160',
  honda_vario160: 'Honda Vario 160',
  yamaha_nmax155: 'Yamaha Nmax 155',
  yamaha_xmax250: 'Yamaha Xmax 250',
  touring: 'Туризм / Эндуро',
  naked_classic: 'Найкед / Классика',
  sport: 'Спорт',
  cruiser: 'Круизер / Боббер / Чоппер',
  neo_retro_roadster: 'Нео-ретро родстер',
};

const { rows: categories } = await pool.query('SELECT id, code FROM vehicle_categories');

let count = 0;
for (const cat of categories) {
  const name = RU_NAMES[cat.code];
  if (!name) { console.error(`NO RU NAME for category code "${cat.code}"`); process.exit(1); }
  await pool.query(
    `INSERT INTO vehicle_category_translations (category_id, language_code, name)
     VALUES ($1, 'ru', $2)
     ON CONFLICT (category_id, language_code) DO UPDATE SET name = EXCLUDED.name`,
    [cat.id, name]
  );
  count++;
}
console.log(`Done. Upserted ${count} ru category translations.`);
await pool.end();
