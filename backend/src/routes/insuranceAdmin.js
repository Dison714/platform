import { Router } from 'express';
import { pool } from '../db/pool.js';
import { getActiveRuleSetId } from '../services/ruleSet.js';

export const insuranceAdminRouter = Router();

// Configuration First (п.12 ТЗ) — /internal/insurance. Доступ уже закрыт
// Basic Auth на уровне Next.js middleware (frontend), этот роутер сам по
// себе не публично доступен (внутренний Docker-alias mdb-backend).

// GET /api/insurance-plans — тарифы активного rule_set (сейчас всего один,
// как у сезонных цен — переключателя rule_set в UI нет).
insuranceAdminRouter.get('/insurance-plans', async (req, res, next) => {
    try {
        const ruleSetId = await getActiveRuleSetId();
        const { rows } = await pool.query(
            `SELECT id, kind, driver_exp, coverage_idr, monthly_idr, bali_only
             FROM insurance_plans WHERE rule_set_id = $1
             ORDER BY kind, driver_exp NULLS FIRST, coverage_idr NULLS FIRST`,
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

// PUT /api/insurance-plans/:id — правка суммы тарифа (monthly_idr).
// Намеренно только monthly_idr, без add/delete и без правки
// kind/driver_exp/coverage_idr: computeInsurance() (services/insurance.js)
// ищет ровно 5 фиксированных комбинаций (theft + damage×experienced/
// inexperienced×1.5M/4.5M) — добавление произвольной новой комбинации
// здесь ничего не изменило бы в расчёте (калькулятор её не ищет), а
// удаление одной из пяти сломало бы расчёт ("Нет тарифа..." в этой
// комбинации). Расширять набор комбинаций — отдельная задача на код,
// не на данные.
insuranceAdminRouter.put('/insurance-plans/:id', async (req, res, next) => {
    try {
        const monthly = Number(req.body?.monthly_idr);
        if (!Number.isFinite(monthly) || monthly < 0) throw badReq('monthly_idr must be a non-negative number');
        const { rows } = await pool.query(
            `UPDATE insurance_plans SET monthly_idr = $1
             WHERE id = $2
             RETURNING id, kind, driver_exp, coverage_idr, monthly_idr, bali_only`,
            [monthly, req.params.id]
        );
        if (rows.length === 0) { const e = new Error('not_found'); e.status = 404; throw e; }
        res.json({ data: rows[0] });
    } catch (err) { next(err); }
});
