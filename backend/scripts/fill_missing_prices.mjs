import { Pool } from 'pg';
import { randomUUID } from 'node:crypto';

const pool = new Pool({ connectionString: 'postgres://localhost:5432/mdb_platform' });

const RULE_SET_ID = '97c17d94-f90b-48d8-8eff-7da88e2c14fe';

const donorForSlug = {
  'custom-frankenstein-white': 'yamaha-mt25-black',
  'kawasaki-dtracker250-black': 'yamaha-mt25-black',
  'yamaha-mt25-black-abs': 'yamaha-mt25-black',
  'yamaha-mt25-chameleon-abs': 'yamaha-mt25-black',
  'yamaha-mt25-chameleon-v1': 'yamaha-mt25-black',
  'yamaha-scorpio225-black-garage': 'yamaha-mt25-black',
  'yamaha-scorpio225-total-black': 'yamaha-mt25-black',
  'suzuki-vstrom250-black-topbox': 'yamaha-mt25-black',
  'suzuki-vstrom250-total-black-lightening': 'yamaha-mt25-black',
  'suzuki-vstrom250-total-black-topbox': 'yamaha-mt25-black',

  'honda-adv-light-cream-abs': 'honda-adv-total-black',
  'honda-adv-white-box': 'honda-adv-total-black',
  'honda-adv-white-bracket': 'honda-adv-total-black',
  'yamaha-byson150-black': 'honda-adv-total-black',
  'yamaha-xsr-black-original': 'honda-adv-total-black',
  'yamaha-xsr-black-original-new': 'honda-adv-total-black',
  'yamaha-xsr-custom-black': 'honda-adv-total-black',

  'honda-pcx-pink-teal': 'honda-pcx-red',
  'honda-pcx-white': 'honda-pcx-red',

  'kawasaki-versys-black-topbox': 'kawasaki-versys-black',
  'tvs-ronin225-total-black-2': 'tvs-ronin225-total-black',
};

const client = await pool.connect();
try {
  await client.query('BEGIN');
  for (const [targetSlug, donorSlug] of Object.entries(donorForSlug)) {
    const { rows: [target] } = await client.query('select id from products where slug=$1', [targetSlug]);
    const { rows: [donor] } = await client.query('select id from products where slug=$1', [donorSlug]);
    if (!target) throw new Error('target not found: ' + targetSlug);
    if (!donor) throw new Error('donor not found: ' + donorSlug);

    const { rows: existing } = await client.query(
      'select rental_days from price_rules where product_id=$1',
      [target.id]
    );
    const existingDays = new Set(existing.map((r) => r.rental_days));

    const { rows: donorRows } = await client.query(
      'select rental_days, price_idr from price_rules where product_id=$1 order by rental_days',
      [donor.id]
    );

    let inserted = 0;
    for (const dr of donorRows) {
      if (existingDays.has(dr.rental_days)) continue;
      await client.query(
        'insert into price_rules (id, rule_set_id, product_id, rental_days, price_idr) values ($1,$2,$3,$4,$5)',
        [randomUUID(), RULE_SET_ID, target.id, dr.rental_days, dr.price_idr]
      );
      inserted++;
    }
    console.log(targetSlug + ' <- ' + donorSlug + ': inserted ' + inserted + ' rows');
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
