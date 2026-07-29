import { Pool } from 'pg';

const pool = new Pool({ connectionString: 'postgres://localhost:5432/mdb_platform' });

const edits = [
  { slug: 'honda-pcx-black-abs-sticker-custom', color_name: 'Sticker LV' },
  { slug: 'honda-pcx-pink-blue-cbs-anime', color_name: 'Print Anime', print_name: null },
  { slug: 'honda-pcx-yellow-green', variant: 'ABS' },
  { slug: 'yamaha-nmax-chameleon-sky-pink', color_name: 'Chameleon Print Sky Pink', print_name: null },
  { slug: 'yamaha-nmax-pink-blue', color_name: 'Print Blue Sky' },
  { slug: 'yamaha-scorpio225-black-garage', print_name: null },
  { slug: 'yamaha-xsr-black-original-new', color_name: 'Black Original New', print_name: null },
];

const client = await pool.connect();
try {
  await client.query('BEGIN');
  for (const { slug, ...fields } of edits) {
    const cols = Object.keys(fields);
    const setClause = cols.map((c, i) => `${c} = $${i + 2}`).join(', ');
    const vals = cols.map((c) => fields[c]);
    const { rowCount } = await client.query(
      `UPDATE products SET ${setClause} WHERE slug = $1`,
      [slug, ...vals]
    );
    if (rowCount !== 1) throw new Error(`expected 1 row updated for ${slug}, got ${rowCount}`);
    console.log(slug + ': ' + JSON.stringify(fields));
  }
  await client.query('COMMIT');
  console.log('COMMIT ok');
} catch (e) {
  await client.query('ROLLBACK');
  console.error('ROLLBACK:', e.message);
  process.exitCode = 1;
} finally {
  client.release();
  await pool.end();
}
