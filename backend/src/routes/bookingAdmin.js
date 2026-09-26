import { Router } from 'express';
import { pool } from '../db/pool.js';
import { getCompanyId } from '../services/config.js';
import {
    assignFleetItem,
    confirmBooking,
    assignDriver,
    markAwaitingPayment,
    markPaid,
    fulfillBooking,
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
                    b.created_at,
                    c.full_name AS customer_name, c.phone, c.whatsapp, c.telegram_username,
                    p.internal_name AS product_name, pf.brand, pf.model_name,
                    fi.internal_number AS fleet_internal_number, fi.license_plate AS fleet_license_plate,
                    d.name AS driver_name
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

// --- 6 переходов жизненного цикла (bookingLifecycle.js) — по одному на
// action, каждый со своей проверкой текущего статуса внутри сервиса. ---

bookingAdminRouter.post('/bookings/:id/assign-fleet-item', async (req, res, next) => {
    try {
        const data = await assignFleetItem(req.params.id, req.body?.fleet_item_id);
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
