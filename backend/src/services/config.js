import { pool } from '../db/pool.js';

const DEFAULT_COMPANY = 'mdb_bali';
const companyCache = new Map();

export async function getCompanyId(code = DEFAULT_COMPANY) {
    if (companyCache.has(code)) return companyCache.get(code);
    const { rows } = await pool.query('SELECT id FROM companies WHERE code = $1', [code]);
    if (rows.length === 0) throw new Error(`Компания ${code} не найдена`);
    companyCache.set(code, rows[0].id);
    return rows[0].id;
}

// Скалярная бизнес-константа из system_config (Configuration First, CLAUDE.md §12).
// pg парсит jsonb в JS-значение (строка/число/объект/массив/null).
export async function getConfig(companyId, key) {
    const { rows } = await pool.query(
        'SELECT value FROM system_config WHERE company_id = $1 AND key = $2',
        [companyId, key]
    );
    return rows.length ? rows[0].value : null;
}
