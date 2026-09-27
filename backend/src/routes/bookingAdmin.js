import { Router } from 'express';
import { pool } from '../db/pool.js';
import { getCompanyId } from '../services/config.js';
import {
    assignFleetItem,
    confirmBooking,
    assignDriver,
    retryPengirimanTask,
    markAwaitingPayment,
    markPaid,
    fulfillBooking,
    unassignFleetItem,
    unconfirmBooking,
    unassignDriver,
    unmarkAwaitingPayment,
    unmarkPaid,
    unfulfillBooking,
} from '../services/bookingLifecycle.js';

export const bookingAdminRouter = Router();

// Configuration First / CRM v1.1 (ТЗ п.12, CLAUDE.md §3.2) — /internal/bookings.
// Доступ закрыт requireInternalToken на уровне монтирования в server.js (как
// у 5 остальных admin-роутеров), Basic Auth — на уровне Next.js middleware.

// GET /bookings?status=created — очередь диспетчера. Без status — все НЕ
// терминальные брони (обычный дефолт экрана), с status — конкретный срез
// (напр. чтобы посмотреть уже fulfilled).
bookingAdminRouter.get('/bookings', async (req, res, next) => {
    try {
        const companyId = await getCompanyId();
        const status = typeof req.query.status === 'string' && req.query.status ? req.query.status : null;
        const params = [companyId];
        let where = 'b.company_id = $1';
        if (status) {
            params.push(status);
            where += ` AND b.status = $${params.length}`;
        } else {
            where += ` AND b.status NOT IN ('fulfilled','cancelled','expired')`;
        }
        const { rows } = await pool.query(
            `SELECT b.id, b.booking_number, b.status, b.product_id, b.start_date, b.end_date, b.rental_days,
                    b.total_payable_idr, b.assigned_fleet_item, b.assigned_driver_slot, b.locale,
                    b.created_at, b.location_link, b.delivery_time,
                    c.full_name AS customer_name, c.phone, c.whatsapp, c.telegram_username,
                    (c.phone IS NOT NULL OR c.whatsapp IS NOT NULL OR c.telegram_username IS NOT NULL OR c.telegram_id IS NOT NULL) AS has_customer_contact,
                    p.internal_name AS product_name, pf.brand, pf.model_name,
                    fi.internal_number AS fleet_internal_number, fi.license_plate AS fleet_license_plate,
                    d.name AS driver_name,
                    EXISTS (SELECT 1 FROM driver_tasks dt WHERE dt.booking_id = b.id AND dt.type_code = 'pengiriman') AS has_pengiriman_task
             FROM bookings b
             JOIN customers c ON c.id = b.customer_id
             JOIN products p ON p.id = b.product_id
             JOIN product_families pf ON pf.id = p.family_id
             LEFT JOIN fleet_items fi ON fi.id = b.assigned_fleet_item
             LEFT JOIN drivers d ON d.driver_slot = b.assigned_driver_slot
             WHERE ${where}
             ORDER BY b.created_at DESC
             LIMIT 200`,
            params
        );
        res.json({ data: rows });
    } catch (err) { next(err); }
});

// GET /bookings/:id — деталка (нужна форме подтверждения: quote_snapshot
// для депозита на шаге fulfill, контакты клиента).
bookingAdminRouter.get('/bookings/:id', async (req, res, next) => {
    try {
        const { rows } = await pool.query(
            `SELECT b.*, c.full_name AS customer_name, c.phone, c.whatsapp,
                    c.telegram_username, c.telegram_id, c.email,
                    p.internal_name AS product_name, pf.brand, pf.model_name,
                    d.name AS driver_name
             FROM bookings b
             JOIN customers c ON c.id = b.customer_id
             JOIN products p ON p.id = b.product_id
             JOIN product_families pf ON pf.id = p.family_id
             LEFT JOIN drivers d ON d.driver_slot = b.assigned_driver_slot
             WHERE b.id = $1`,
            [req.params.id]
        );
        if (!rows.length) { const e = new Error('booking not found'); e.status = 404; throw e; }
        res.json({ data: rows[0] });
    } catch (err) { next(err); }
});

// GET /rentals — активные аренды (вкладка "Аренды" на том же экране).
bookingAdminRouter.get('/rentals', async (req, res, next) => {
    try {
        const { rows } = await pool.query(
            `SELECT r.id, r.status, r.start_date, r.end_date, r.deposit_amount_idr, r.created_at,
                    b.booking_number,
                    c.full_name AS customer_name, c.phone, c.whatsapp,
                    fi.internal_number AS fleet_internal_number, fi.license_plate,
                    p.internal_name AS product_name, pf.brand, pf.model_name
             FROM rentals r
             JOIN bookings b ON b.id = r.booking_id
             JOIN customers c ON c.id = r.customer_id
             JOIN fleet_items fi ON fi.id = r.fleet_item_id
             JOIN products p ON p.id = fi.product_id
             JOIN product_families pf ON pf.id = p.family_id
             WHERE r.status = 'active'
             ORDER BY r.end_date`
        );
        res.json({ data: rows });
    } catch (err) { next(err); }
});

// GET /bookings/:id/assignable-fleet-items — три ступени подбора байка для
// "Назначить байк" (дизайн подтверждён Дмитрием 2026-09-27): точный
// product_id брони → тот же product_families (другой цвет) → тот же
// replacement_groups.id, что у family брони (CLAUDE.md §3.1). Каждая
// ступень отдельным массивом — фронт обязан показать оператору, какую
// именно ступень он выбирает, не сваливать всё в один список молча.
bookingAdminRouter.get('/bookings/:id/assignable-fleet-items', async (req, res, next) => {
    try {
        const { rows: bRows } = await pool.query(
            `SELECT b.product_id, p.family_id, pf.replacement_group_id
             FROM bookings b
             JOIN products p ON p.id = b.product_id
             JOIN product_families pf ON pf.id = p.family_id
             WHERE b.id = $1`,
            [req.params.id]
        );
        if (!bRows.length) { const e = new Error('booking not found'); e.status = 404; throw e; }
        const { product_id: productId, family_id: familyId, replacement_group_id: replacementGroupId } = bRows[0];

        const fleetItemSelect = `fi.id, fi.internal_number, fi.license_plate, fi.status,
                    p.id AS product_id, p.color_name, pf.brand, pf.model_name`;

        const { rows: exact } = await pool.query(
            `SELECT ${fleetItemSelect}
             FROM fleet_items fi
             JOIN products p ON p.id = fi.product_id
             JOIN product_families pf ON pf.id = p.family_id
             WHERE fi.product_id = $1 AND fi.status IN ('available','prepared')
             ORDER BY fi.internal_number`,
            [productId]
        );

        const { rows: sameFamily } = await pool.query(
            `SELECT ${fleetItemSelect}
             FROM fleet_items fi
             JOIN products p ON p.id = fi.product_id
             JOIN product_families pf ON pf.id = p.family_id
             WHERE p.family_id = $1 AND fi.product_id != $2 AND fi.status IN ('available','prepared')
             ORDER BY fi.internal_number`,
            [familyId, productId]
        );

        let replacementGroup = [];
        let replacementGroupName = null;
        if (replacementGroupId != null) {
            const { rows: rgRows } = await pool.query('SELECT name FROM replacement_groups WHERE id = $1', [replacementGroupId]);
            replacementGroupName = rgRows[0]?.name ?? null;
            const { rows } = await pool.query(
                `SELECT ${fleetItemSelect}
                 FROM fleet_items fi
                 JOIN products p ON p.id = fi.product_id
                 JOIN product_families pf ON pf.id = p.family_id
                 WHERE pf.replacement_group_id = $1 AND pf.id != $2 AND fi.status IN ('available','prepared')
                 ORDER BY pf.brand, pf.model_name, fi.internal_number`,
                [replacementGroupId, familyId]
            );
            replacementGroup = rows;
        }

        res.json({
            data: {
                exact,
                same_family: sameFamily,
                replacement_group: replacementGroup,
                replacement_group_name: replacementGroupName,
            },
        });
    } catch (err) { next(err); }
});

// --- 6 переходов жизненного цикла (bookingLifecycle.js) — по одному на
// action, каждый со своей проверкой текущего статуса внутри сервиса. ---

bookingAdminRouter.post('/bookings/:id/assign-fleet-item', async (req, res, next) => {
    try {
        const data = await assignFleetItem(req.params.id, req.body?.fleet_item_id, req.body?.replacement_reason ?? null);
        res.json({ data });
    } catch (err) { next(err); }
});

bookingAdminRouter.post('/bookings/:id/confirm', async (req, res, next) => {
    try {
        const data = await confirmBooking(req.params.id);
        res.json({ data });
    } catch (err) { next(err); }
});

bookingAdminRouter.post('/bookings/:id/assign-driver', async (req, res, next) => {
    try {
        const data = await assignDriver(req.params.id, req.body?.driver_slot);
        res.json({ data });
    } catch (err) { next(err); }
});

// POST /bookings/:id/driver-task-followup — дозаполнение location_link/
// delivery_time и повторная попытка создать+отправить задачу 'pengiriman',
// когда assign-driver не смог это сделать сразу (CRM v1.1 Раздел 1).
bookingAdminRouter.post('/bookings/:id/driver-task-followup', async (req, res, next) => {
    try {
        const data = await retryPengirimanTask(req.params.id, {
            location_link: req.body?.location_link,
            delivery_time: req.body?.delivery_time,
        });
        res.json({ data });
    } catch (err) { next(err); }
});

bookingAdminRouter.post('/bookings/:id/mark-awaiting-payment', async (req, res, next) => {
    try {
        const data = await markAwaitingPayment(req.params.id);
        res.json({ data });
    } catch (err) { next(err); }
});

bookingAdminRouter.post('/bookings/:id/mark-paid', async (req, res, next) => {
    try {
        const data = await markPaid(req.params.id);
        res.json({ data });
    } catch (err) { next(err); }
});

bookingAdminRouter.post('/bookings/:id/fulfill', async (req, res, next) => {
    try {
        const data = await fulfillBooking(req.params.id, {
            start_date: req.body?.start_date,
            end_date: req.body?.end_date,
        });
        res.json({ data });
    } catch (err) { next(err); }
});

// --- Раздел 2 (2026-09-27) — симметричные обратные переходы ("← Назад"),
// один роут на действие, та же логика проверки статуса внутри сервиса. ---

bookingAdminRouter.post('/bookings/:id/unassign-fleet-item', async (req, res, next) => {
    try {
        const data = await unassignFleetItem(req.params.id);
        res.json({ data });
    } catch (err) { next(err); }
});

bookingAdminRouter.post('/bookings/:id/unconfirm', async (req, res, next) => {
    try {
        const data = await unconfirmBooking(req.params.id);
        res.json({ data });
    } catch (err) { next(err); }
});

bookingAdminRouter.post('/bookings/:id/unassign-driver', async (req, res, next) => {
    try {
        const data = await unassignDriver(req.params.id);
        res.json({ data });
    } catch (err) { next(err); }
});

bookingAdminRouter.post('/bookings/:id/unmark-awaiting-payment', async (req, res, next) => {
    try {
        const data = await unmarkAwaitingPayment(req.params.id);
        res.json({ data });
    } catch (err) { next(err); }
});

bookingAdminRouter.post('/bookings/:id/unmark-paid', async (req, res, next) => {
    try {
        const data = await unmarkPaid(req.params.id);
        res.json({ data });
    } catch (err) { next(err); }
});

bookingAdminRouter.post('/bookings/:id/unfulfill', async (req, res, next) => {
    try {
        const data = await unfulfillBooking(req.params.id);
        res.json({ data });
    } catch (err) { next(err); }
});
