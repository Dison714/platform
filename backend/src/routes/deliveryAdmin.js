import { Router } from 'express';
import { pool } from '../db/pool.js';
import { getActiveRuleSetId } from '../services/ruleSet.js';
import { requireInternalToken } from '../middleware/internalAuth.js';

export const deliveryAdminRouter = Router();

// Configuration First (п.12 ТЗ) — /internal/delivery, запись через Basic
// Auth + requireInternalToken (см. ниже на POST/PUT/DELETE). GET читается
// и оттуда, и напрямую публичным сайтом (bikes/[slug]/page.js) — поэтому
// не гейтится, в отличие от остальных 4 admin-роутеров в server.js.

// GET /api/delivery-fee-rules — тиры активного rule_set.
deliveryAdminRouter.get('/delivery-fee-rules', async (req, res, next) => {
    try {
        const ruleSetId = await getActiveRuleSetId();
        const { rows } = await pool.query(
            `SELECT id, min_days, max_days, fee_idr, manager_approval, note
             FROM delivery_fee_rules WHERE rule_set_id = $1
             ORDER BY min_days`,
            [ruleSetId]
        );
        res.json({ data: rows });
    } catch (err) { next(err); }
});

function badReq(message) {
    const e = new Error(message);
    e.status = 400;
    return e;
}

function validateBody(body) {
    const { min_days, max_days, fee_idr, manager_approval, note } = body ?? {};
    const min = Number(min_days);
    if (!Number.isInteger(min) || min < 1) throw badReq('min_days must be a positive integer');
    let max = null;
    if (max_days !== null && max_days !== undefined && max_days !== '') {
        max = Number(max_days);
        if (!Number.isInteger(max) || max < min) throw badReq('max_days must be an integer >= min_days, or empty for no upper bound');
    }
    const fee = Number(fee_idr);
    if (!Number.isFinite(fee) || fee < 0) throw badReq('fee_idr must be a non-negative number');
    return {
        min_days: min,
        max_days: max,
        fee_idr: fee,
        manager_approval: manager_approval === true,
        note: typeof note === 'string' && note.trim() ? note.trim() : null,
    };
}

// Exclusion-констрейнт (миграция 036) ловит пересекающиеся тиры —
// перехватываем как понятный 409, а не голый 500.
function isOverlapError(err) {
    return err.code === '23P01'; // exclusion_violation
}

// POST /api/delivery-fee-rules — новый тир.
deliveryAdminRouter.post('/delivery-fee-rules', requireInternalToken, async (req, res, next) => {
    try {
        const v = validateBody(req.body);
        const ruleSetId = await getActiveRuleSetId();
        const { rows } = await pool.query(
            `INSERT INTO delivery_fee_rules (rule_set_id, min_days, max_days, fee_idr, manager_approval, note)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING id, min_days, max_days, fee_idr, manager_approval, note`,
            [ruleSetId, v.min_days, v.max_days, v.fee_idr, v.manager_approval, v.note]
        );
        res.status(201).json({ data: rows[0] });
    } catch (err) {
        if (isOverlapError(err)) err.status = 409;
        next(err);
    }
});

// PUT /api/delivery-fee-rules/:id — обновить тир.
deliveryAdminRouter.put('/delivery-fee-rules/:id', requireInternalToken, async (req, res, next) => {
    try {
        const v = validateBody(req.body);
        const { rows } = await pool.query(
            `UPDATE delivery_fee_rules
             SET min_days = $1, max_days = $2, fee_idr = $3, manager_approval = $4, note = $5
             WHERE id = $6
             RETURNING id, min_days, max_days, fee_idr, manager_approval, note`,
            [v.min_days, v.max_days, v.fee_idr, v.manager_approval, v.note, req.params.id]
        );
        if (rows.length === 0) { const e = new Error('not_found'); e.status = 404; throw e; }
        res.json({ data: rows[0] });
    } catch (err) {
        if (isOverlapError(err)) err.status = 409;
        next(err);
    }
});

// DELETE /api/delivery-fee-rules/:id
deliveryAdminRouter.delete('/delivery-fee-rules/:id', requireInternalToken, async (req, res, next) => {
    try {
        const { rowCount } = await pool.query('DELETE FROM delivery_fee_rules WHERE id = $1', [req.params.id]);
        if (rowCount === 0) { const e = new Error('not_found'); e.status = 404; throw e; }
        res.status(204).end();
    } catch (err) { next(err); }
});
