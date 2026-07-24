import { Router } from 'express';
import { pool } from '../db/pool.js';
import { getCompanyId, getConfig, setConfig } from '../services/config.js';

export const depositAdminRouter = Router();

// Configuration First (п.12 ТЗ) — /internal/deposit. Доступ уже закрыт
// Basic Auth на уровне Next.js middleware.

// GET /api/deposit-config — база (system_config.standard_deposit_idr) +
// исключения (deposit_rules) + список families для формы одним запросом
// (страница целиком собирается за один fetch).
depositAdminRouter.get('/deposit-config', async (req, res, next) => {
    try {
        const companyId = await getCompanyId();
        const base = Number(await getConfig(companyId, 'standard_deposit_idr')) || 0;
        const { rows: rules } = await pool.query(
            `SELECT dr.id, dr.family_id, pf.code AS family_code, pf.brand, pf.model_name,
                    dr.max_rental_days, dr.deposit_idr, dr.priority, dr.note
             FROM deposit_rules dr
             LEFT JOIN product_families pf ON pf.id = dr.family_id
             WHERE dr.company_id = $1
             ORDER BY dr.priority DESC, pf.brand, pf.model_name`,
            [companyId]
        );
        const { rows: families } = await pool.query(
            `SELECT id, code, brand, model_name FROM product_families
             WHERE company_id = $1 AND is_active = TRUE
             ORDER BY brand, model_name`,
            [companyId]
        );
        res.json({ data: { base_idr: base, rules, families } });
    } catch (err) { next(err); }
});

function badReq(message) {
    const e = new Error(message);
    e.status = 400;
    return e;
}

// PUT /api/deposit-config/base — базовая сумма депозита.
depositAdminRouter.put('/deposit-config/base', async (req, res, next) => {
    try {
        const amount = Number(req.body?.deposit_idr);
        if (!Number.isFinite(amount) || amount < 0) throw badReq('deposit_idr must be a non-negative number');
        const companyId = await getCompanyId();
        await setConfig(companyId, 'standard_deposit_idr', amount);
        res.json({ data: { base_idr: amount } });
    } catch (err) { next(err); }
});

function validateRuleBody(body) {
    const { family_id, max_rental_days, deposit_idr, priority, note } = body ?? {};
    if (typeof family_id !== 'string' || !family_id) throw badReq('family_id is required');
    let maxDays = null;
    if (max_rental_days !== null && max_rental_days !== undefined && max_rental_days !== '') {
        maxDays = Number(max_rental_days);
        if (!Number.isInteger(maxDays) || maxDays < 1) throw badReq('max_rental_days must be a positive integer, or empty for any duration');
    }
    const deposit = Number(deposit_idr);
    if (!Number.isFinite(deposit) || deposit < 0) throw badReq('deposit_idr must be a non-negative number');
    const prio = priority === undefined || priority === '' ? 0 : Number(priority);
    if (!Number.isInteger(prio)) throw badReq('priority must be an integer');
    return {
        family_id,
        max_rental_days: maxDays,
        deposit_idr: deposit,
        priority: prio,
        note: typeof note === 'string' && note.trim() ? note.trim() : null,
    };
}

// POST /api/deposit-rules — новое исключение.
depositAdminRouter.post('/deposit-rules', async (req, res, next) => {
    try {
        const v = validateRuleBody(req.body);
        const companyId = await getCompanyId();
        const { rows } = await pool.query(
            `INSERT INTO deposit_rules (company_id, family_id, max_rental_days, deposit_idr, priority, note)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING id`,
            [companyId, v.family_id, v.max_rental_days, v.deposit_idr, v.priority, v.note]
        );
        res.status(201).json({ data: { id: rows[0].id } });
    } catch (err) { next(err); }
});

// PUT /api/deposit-rules/:id — обновить исключение.
depositAdminRouter.put('/deposit-rules/:id', async (req, res, next) => {
    try {
        const v = validateRuleBody(req.body);
        const { rows } = await pool.query(
            `UPDATE deposit_rules
             SET family_id = $1, max_rental_days = $2, deposit_idr = $3, priority = $4, note = $5
             WHERE id = $6
             RETURNING id`,
            [v.family_id, v.max_rental_days, v.deposit_idr, v.priority, v.note, req.params.id]
        );
        if (rows.length === 0) { const e = new Error('not_found'); e.status = 404; throw e; }
        res.json({ data: { id: rows[0].id } });
    } catch (err) { next(err); }
});

// DELETE /api/deposit-rules/:id
depositAdminRouter.delete('/deposit-rules/:id', async (req, res, next) => {
    try {
        const { rowCount } = await pool.query('DELETE FROM deposit_rules WHERE id = $1', [req.params.id]);
        if (rowCount === 0) { const e = new Error('not_found'); e.status = 404; throw e; }
        res.status(204).end();
    } catch (err) { next(err); }
});
