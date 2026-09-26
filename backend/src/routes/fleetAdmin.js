import { Router } from 'express';
import { pool } from '../db/pool.js';
import { getCompanyId } from '../services/config.js';

export const fleetAdminRouter = Router();

// fleet_status enum (001_foundation.sql) — минимальный список для валидации
// PATCH-а; ручная правка статуса здесь же служит fallback'ом для брони,
// заброшенной после assign-fleet-item (см. bookingLifecycle.js) — вернуть
// 'reserved' обратно в 'available' вручную.
const FLEET_STATUSES = ['available', 'prepared', 'reserved', 'rented', 'maintenance', 'repair', 'retired'];

function badReq(message) {
    const e = new Error(message);
    e.status = 400;
    return e;
}

// GET /fleet-items?product_id=&status= — список для экрана /internal/fleet
// И для дропдауна выбора байка в форме подтверждения брони (тот же
// эндпоинт, product_id+status=available,prepared фильтруют его до нужного
// набора на фронте).
fleetAdminRouter.get('/fleet-items', async (req, res, next) => {
    try {
        const companyId = await getCompanyId();
        const { product_id: productId, status } = req.query;
        const params = [companyId];
        let where = 'fi.company_id = $1';
        if (typeof productId === 'string' && productId) {
            params.push(productId);
            where += ` AND fi.product_id = $${params.length}`;
        }
        if (typeof status === 'string' && status) {
            params.push(status);
            where += ` AND fi.status = $${params.length}`;
        }
        const { rows } = await pool.query(
            `SELECT fi.id, fi.internal_number, fi.license_plate, fi.status, fi.current_odo_km,
                    fi.rent_until_date, fi.notes, fi.product_id,
                    p.internal_name AS product_name, pf.brand, pf.model_name
             FROM fleet_items fi
             JOIN products p ON p.id = fi.product_id
             JOIN product_families pf ON pf.id = p.family_id
             WHERE ${where}
             ORDER BY fi.internal_number`,
            params
        );
        res.json({ data: rows });
    } catch (err) { next(err); }
});

// PATCH /fleet-items/:id — минимум под "видеть и поправить руками"
// (склад/финансы вне этого среза): только status.
fleetAdminRouter.patch('/fleet-items/:id', async (req, res, next) => {
    try {
        const { status } = req.body ?? {};
        if (!FLEET_STATUSES.includes(status)) {
            throw badReq(`status must be one of: ${FLEET_STATUSES.join(', ')}`);
        }
        const { rows } = await pool.query(
            `UPDATE fleet_items SET status = $2, updated_at = now() WHERE id = $1 RETURNING id, status`,
            [req.params.id, status]
        );
        if (!rows.length) { const e = new Error('fleet_item not found'); e.status = 404; throw e; }
        res.json({ data: rows[0] });
    } catch (err) { next(err); }
});
