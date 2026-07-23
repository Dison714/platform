import { Router } from 'express';
import { pool } from '../db/pool.js';
import { getActiveRuleSetId } from '../services/ruleSet.js';

export const seasonalMultipliersRouter = Router();

// Админка /internal/pricing (Blок 2) — доступ уже закрыт Basic Auth на
// уровне Next.js middleware (frontend), этот роутер сам по себе не
// публично доступен (внутренний Docker-alias mdb-backend, не проброшен
// наружу).

// GET /api/seasonal-multipliers — список периодов + название rule_set (для UI).
seasonalMultipliersRouter.get('/seasonal-multipliers', async (req, res, next) => {
    try {
        const { rows } = await pool.query(
            `SELECT sm.id, sm.date_from, sm.date_to, sm.multiplier, sm.pricing_rule_set_id
             FROM seasonal_multipliers sm
             ORDER BY sm.date_from`
        );
        res.json({ data: rows });
    } catch (err) { next(err); }
});

function badReq(message) {
    const e = new Error(message);
    e.status = 400;
    return e;
}

// scope: 'global' (для всех rule_set) | 'current' (только активный rule_set,
// резолвится сервером — клиент не оперирует UUID rule_set вручную).
async function validateBody(body) {
    const { date_from, date_to, multiplier, scope } = body ?? {};
    if (typeof date_from !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(date_from)) {
        throw badReq('date_from must be YYYY-MM-DD');
    }
    if (typeof date_to !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(date_to)) {
        throw badReq('date_to must be YYYY-MM-DD');
    }
    if (date_to < date_from) throw badReq('date_to must be >= date_from');
    const mult = Number(multiplier);
    if (!Number.isFinite(mult) || mult <= 0) throw badReq('multiplier must be a positive number');
    if (scope !== 'global' && scope !== 'current') throw badReq('scope must be "global" or "current"');
    const pricing_rule_set_id = scope === 'current' ? await getActiveRuleSetId() : null;
    return { date_from, date_to, multiplier: mult, pricing_rule_set_id };
}

// Триггер БД ловит пересечения периодов и бросает RAISE EXCEPTION —
// перехватываем и отдаём как понятный 409, а не голый 500.
function isOverlapError(err) {
    return typeof err.message === 'string' && err.message.includes('пересекается с существующим периодом');
}

// POST /api/seasonal-multipliers — создать период.
seasonalMultipliersRouter.post('/seasonal-multipliers', async (req, res, next) => {
    try {
        const v = await validateBody(req.body);
        const { rows } = await pool.query(
            `INSERT INTO seasonal_multipliers (date_from, date_to, multiplier, pricing_rule_set_id)
             VALUES ($1, $2, $3, $4) RETURNING id, date_from, date_to, multiplier, pricing_rule_set_id`,
            [v.date_from, v.date_to, v.multiplier, v.pricing_rule_set_id]
        );
        res.status(201).json({ data: rows[0] });
    } catch (err) {
        if (isOverlapError(err)) { err.status = 409; }
        next(err);
    }
});

// PUT /api/seasonal-multipliers/:id — обновить период.
seasonalMultipliersRouter.put('/seasonal-multipliers/:id', async (req, res, next) => {
    try {
        const v = await validateBody(req.body);
        const { rows } = await pool.query(
            `UPDATE seasonal_multipliers
             SET date_from = $1, date_to = $2, multiplier = $3, pricing_rule_set_id = $4
             WHERE id = $5
             RETURNING id, date_from, date_to, multiplier, pricing_rule_set_id`,
            [v.date_from, v.date_to, v.multiplier, v.pricing_rule_set_id, req.params.id]
        );
        if (rows.length === 0) { const e = new Error('not_found'); e.status = 404; throw e; }
        res.json({ data: rows[0] });
    } catch (err) {
        if (isOverlapError(err)) { err.status = 409; }
        next(err);
    }
});

// DELETE /api/seasonal-multipliers/:id
seasonalMultipliersRouter.delete('/seasonal-multipliers/:id', async (req, res, next) => {
    try {
        const { rowCount } = await pool.query(
            'DELETE FROM seasonal_multipliers WHERE id = $1',
            [req.params.id]
        );
        if (rowCount === 0) { const e = new Error('not_found'); e.status = 404; throw e; }
        res.status(204).end();
    } catch (err) { next(err); }
});
