import { Pool } from 'pg';
import { writeFile } from 'node:fs/promises';

const pool = new Pool({ connectionString: 'postgres://localhost:5432/mdb_platform' });

const slugs = [
  'custom-frankenstein-white',
  'kawasaki-dtracker250-black',
  'yamaha-mt25-black-abs',
  'yamaha-mt25-chameleon-abs',
  'yamaha-mt25-chameleon-v1',
  'yamaha-scorpio225-black-garage',
  'yamaha-scorpio225-total-black',
  'suzuki-vstrom250-black-topbox',
  'suzuki-vstrom250-total-black-lightening',
  'suzuki-vstrom250-total-black-topbox',
  'honda-adv-light-cream-abs',
  'honda-adv-white-box',
  'honda-adv-white-bracket',
  'yamaha-byson150-black',
  'yamaha-xsr-black-original',
  'yamaha-xsr-black-original-new',
  'yamaha-xsr-custom-black',
  'honda-pcx-pink-teal',
  'honda-pcx-white',
  'kawasaki-versys-black-topbox',
  'tvs-ronin225-total-black-2',
  'honda-pcx-dark-pink-abs',
];

function esc(v) {
  if (v === null || v === undefined) return 'NULL';
  if (typeof v === 'boolean') return v ? 'TRUE' : 'FALSE';
  if (typeof v === 'number') return String(v);
  return `'${String(v).replace(/'/g, "''")}'`;
}

const out = [];
out.push('-- price_sync.sql — regenerated ' + new Date().toISOString().slice(0, 10));
out.push('-- Fills 30-day price_rules for the 21 products that only had 5 anchor rows.');
out.push('-- Upserts on the real unique key (rule_set_id, product_id, rental_days), not id —');
out.push('-- ids are freshly generated locally and never match whatever prod already has.');
out.push('BEGIN;\n');

let totalRows = 0;
for (const slug of slugs) {
  const { rows: [product] } = await pool.query('select id from products where slug=$1', [slug]);
  if (!product) throw new Error('product not found: ' + slug);
  const { rows } = await pool.query(
    'select rule_set_id, product_id, rental_days, price_idr from price_rules where product_id=$1 order by rental_days',
    [product.id]
  );
  out.push(`-- ${slug}: ${rows.length} rows`);
  for (const r of rows) {
    out.push(
      `INSERT INTO price_rules (id, rule_set_id, product_id, rental_days, price_idr) VALUES (gen_random_uuid(), ${esc(r.rule_set_id)}, ${esc(r.product_id)}, ${r.rental_days}, ${r.price_idr})\n` +
      `  ON CONFLICT (rule_set_id, product_id, rental_days) DO UPDATE SET price_idr = EXCLUDED.price_idr;`
    );
    totalRows++;
  }
  out.push('');
}
out.push('COMMIT;\n');

await writeFile(new URL('../../price_sync.sql', import.meta.url), out.join('\n'));
console.log('written price_sync.sql, ' + totalRows + ' rows across ' + slugs.length + ' products');
await pool.end();
