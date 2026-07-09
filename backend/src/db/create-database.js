import pg from 'pg';
import { env } from '../config/env.js';

const target = new URL(env.databaseUrl);
const dbName = target.pathname.replace(/^\//, '');

const adminUrl = new URL(env.databaseUrl);
adminUrl.pathname = '/postgres';

const client = new pg.Client({ connectionString: adminUrl.toString() });

await client.connect();
const { rowCount } = await client.query('SELECT 1 FROM pg_database WHERE datname = $1', [dbName]);
if (rowCount === 0) {
    await client.query(`CREATE DATABASE "${dbName}"`);
    console.log(`Created database "${dbName}"`);
} else {
    console.log(`Database "${dbName}" already exists`);
}
await client.end();
