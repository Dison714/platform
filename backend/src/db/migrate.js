import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { pool } from './pool.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const migrationsDir = path.join(__dirname, '..', '..', 'migrations');

async function ensureMigrationsTable(client) {
    await client.query(`
        CREATE TABLE IF NOT EXISTS schema_migrations (
            filename     TEXT PRIMARY KEY,
            applied_at   TIMESTAMPTZ NOT NULL DEFAULT now()
        )
    `);
}

async function getAppliedMigrations(client) {
    const { rows } = await client.query('SELECT filename FROM schema_migrations');
    return new Set(rows.map((r) => r.filename));
}

async function getMigrationFiles() {
    const files = await readdir(migrationsDir);
    return files.filter((f) => f.endsWith('.sql')).sort();
}

async function up() {
    const client = await pool.connect();
    try {
        await ensureMigrationsTable(client);
        const applied = await getAppliedMigrations(client);
        const files = await getMigrationFiles();

        for (const file of files) {
            if (applied.has(file)) continue;
            const sql = await readFile(path.join(migrationsDir, file), 'utf8');
            console.log(`Applying ${file}...`);
            await client.query('BEGIN');
            try {
                await client.query(sql);
                await client.query('INSERT INTO schema_migrations (filename) VALUES ($1)', [file]);
                await client.query('COMMIT');
                console.log(`  done.`);
            } catch (err) {
                await client.query('ROLLBACK');
                throw err;
            }
        }
        console.log('Migrations up to date.');
    } finally {
        client.release();
        await pool.end();
    }
}

async function status() {
    const client = await pool.connect();
    try {
        await ensureMigrationsTable(client);
        const applied = await getAppliedMigrations(client);
        const files = await getMigrationFiles();
        for (const file of files) {
            console.log(`${applied.has(file) ? '[x]' : '[ ]'} ${file}`);
        }
    } finally {
        client.release();
        await pool.end();
    }
}

const command = process.argv[2] ?? 'up';
if (command === 'up') {
    await up();
} else if (command === 'status') {
    await status();
} else {
    console.error(`Unknown command: ${command}`);
    process.exit(1);
}
