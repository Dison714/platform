import { Router } from 'express';
import { pool } from '../db/pool.js';
import { getCompanyId } from '../services/config.js';
import { nextDriverNotificationSeq, computePeralatan, loadBookingSnapshot } from '../services/booking.js';
import { dispatchDriverTask } from '../services/driverTaskDispatch.js';
import { SEND_ALLOWED_CODES } from '../config/driverTaskTemplates.js';

export const driverTasksAdminRouter = Router();

function badReq(message) {
    const e = new Error(message);
    e.status = 400;
    return e;
}
function notFound(message) {
    const e = new Error(message);
    e.status = 404;
    return e;
}

// GET /drivers — ростер слотов (используется и здесь, и на /internal/bookings
// для шага "назначить водителя").
driverTasksAdminRouter.get('/drivers', async (req, res, next) => {
    try {
        const { rows } = await pool.query('SELECT driver_slot, name, is_active FROM drivers ORDER BY driver_slot');
        res.json({ data: rows });
    } catch (err) { next(err); }
});

// GET /driver-tasks?status=&type_code=&scheduled_date=
driverTasksAdminRouter.get('/driver-tasks', async (req, res, next) => {
    try {
        const companyId = await getCompanyId();
        const { status, type_code: typeCode, scheduled_date: scheduledDate } = req.query;
        const params = [companyId];
        let where = 'dt.company_id = $1';
        if (typeof status === 'string' && status) { params.push(status); where += ` AND dt.status = $${params.length}`; }
        if (typeof typeCode === 'string' && typeCode) { params.push(typeCode); where += ` AND dt.type_code = $${params.length}`; }
        if (typeof scheduledDate === 'string' && scheduledDate) { params.push(scheduledDate); where += ` AND dt.scheduled_date = $${params.length}`; }
        const { rows } = await pool.query(
            `SELECT dt.id, dt.type_code, tt.name_id AS type_name_id, tt.name_ru AS type_name_ru,
                    dt.seq_label, dt.daily_seq, dt.status, dt.priority, dt.scheduled_date, dt.scheduled_time, dt.time_code,
                    dt.booking_id, dt.rental_id, dt.fleet_item_id, dt.assigned_driver_slot,
                    dt.location_text, dt.customer_contact, dt.comment, dt.created_at,
                    b.booking_number, d.name AS driver_name,
                    fi.internal_number AS fleet_internal_number
             FROM driver_tasks dt
             JOIN task_types tt ON tt.code = dt.type_code
             LEFT JOIN bookings b ON b.id = dt.booking_id
             LEFT JOIN drivers d ON d.driver_slot = dt.assigned_driver_slot
             LEFT JOIN fleet_items fi ON fi.id = dt.fleet_item_id
             WHERE ${where}
             ORDER BY dt.scheduled_date DESC, dt.created_at DESC
             LIMIT 200`,
            params
        );
        res.json({ data: rows.map((r) => ({ ...r, send_allowed: SEND_ALLOWED_CODES.includes(r.type_code) })) });
    } catch (err) { next(err); }
});

// GET /task-types — активные типы задач, для дропдауна создания.
driverTasksAdminRouter.get('/task-types', async (req, res, next) => {
    try {
        const { rows } = await pool.query(
            `SELECT code, name_id, name_ru, needs_customer, needs_fleet_item
             FROM task_types WHERE is_active = TRUE ORDER BY name_id`
        );
        res.json({ data: rows.map((r) => ({ ...r, send_allowed: SEND_ALLOWED_CODES.includes(r.code) })) });
    } catch (err) { next(err); }
});

// POST /driver-tasks — создание. Если передан booking_id, недостающие поля
// (fleet_item_id/location_text/customer_contact/payload.peralatan)
// преднаполняются из брони — тот же расчёт Peralatan, что уже используется
// в карточке водителю при создании брони (computePeralatan, services/booking.js).
// Явно переданные в теле значения не перезаписываются.
driverTasksAdminRouter.post('/driver-tasks', async (req, res, next) => {
    try {
        const body = req.body ?? {};
        const {
            type_code: typeCode,
            booking_id: bookingId = null,
            rental_id: rentalId = null,
            assigned_driver_slot: driverSlot = null,
            scheduled_date: scheduledDate,
            scheduled_time: scheduledTime = null,
            time_code: timeCode = null,
            comment = null,
            seq_label: seqLabel = null,
        } = body;
        let { fleet_item_id: fleetItemId = null, location_text: locationText = null, customer_contact: customerContact = null, payload = {} } = body;
        payload = payload && typeof payload === 'object' && !Array.isArray(payload) ? { ...payload } : {};

        if (typeof typeCode !== 'string' || !typeCode) throw badReq('type_code is required');
        if (typeof scheduledDate !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(scheduledDate)) throw badReq('scheduled_date must be YYYY-MM-DD');

        const { rows: ttRows } = await pool.query('SELECT code, is_active FROM task_types WHERE code = $1', [typeCode]);
        if (!ttRows.length) throw badReq(`unknown type_code: ${typeCode}`);
        if (!ttRows[0].is_active) throw badReq(`type_code '${typeCode}' is not active`);

        if (driverSlot != null) {
            const { rows: dRows } = await pool.query('SELECT is_active FROM drivers WHERE driver_slot = $1', [Number(driverSlot)]);
            if (!dRows.length) throw badReq('unknown driver_slot');
        }

        if (bookingId) {
            const snap = await loadBookingSnapshot(pool, bookingId);
            if (!snap) throw badReq('booking not found');
            if (!fleetItemId) fleetItemId = snap.assigned_fleet_item;
            if (!locationText) locationText = snap.location_link;
            if (!customerContact) {
                customerContact = snap.whatsapp || snap.phone || snap.telegram_username || snap.email || null;
            }
            // breakdown.equipment сам может быть null (клиент ничего не выбрал) —
            // computePeralatan всё равно нужен: dudukan hp/lap идут в Peralatan
            // всегда, независимо от чекбоксов клиента (services/booking.js).
            // Проверяем наличие breakdown, а не truthy equipment.
            if (payload.peralatan === undefined && snap.quote_snapshot?.breakdown) {
                payload.peralatan = computePeralatan(snap.quote_snapshot.breakdown.equipment?.items, snap.category_code);
            }
        }

        const companyId = await getCompanyId();
        // Сквозной номер за день (069_driver_tasks_daily_seq.sql) — тот же
        // общий счётчик, что и у driver-карточки при создании брони.
        // Присваивается один раз, здесь, а не при отправке.
        const dailySeq = await nextDriverNotificationSeq(pool, companyId);
        const { rows } = await pool.query(
            `INSERT INTO driver_tasks (
                company_id, type_code, seq_label, daily_seq, booking_id, rental_id, fleet_item_id,
                assigned_driver_slot, priority, status, scheduled_date, scheduled_time, time_code,
                customer_contact, location_text, payload, comment, source
             ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,'planned','pending',$9,$10,$11,$12,$13,$14,$15,'manual')
             RETURNING id, daily_seq`,
            [
                companyId, typeCode, seqLabel, dailySeq, bookingId, rentalId, fleetItemId,
                driverSlot != null ? Number(driverSlot) : null, scheduledDate, scheduledTime, timeCode,
                customerContact, locationText, payload, comment,
            ]
        );
        res.status(201).json({ data: { id: rows[0].id, daily_seq: rows[0].daily_seq } });
    } catch (err) { next(err); }
});

const PATCHABLE_FIELDS = {
    assigned_driver_slot: 'assigned_driver_slot',
    scheduled_date: 'scheduled_date',
    scheduled_time: 'scheduled_time',
    time_code: 'time_code',
    location_text: 'location_text',
    customer_contact: 'customer_contact',
    comment: 'comment',
    payload: 'payload',
    seq_label: 'seq_label',
};

// PATCH /driver-tasks/:id — правка до отправки (те же поля, что в форме
// создания). Статус/тип/привязки к booking/rental/fleet_item здесь не
// меняются — пересоздать задачу, если это нужно.
driverTasksAdminRouter.patch('/driver-tasks/:id', async (req, res, next) => {
    try {
        const body = req.body ?? {};
        const sets = [];
        const params = [req.params.id];
        for (const [key, column] of Object.entries(PATCHABLE_FIELDS)) {
            if (Object.prototype.hasOwnProperty.call(body, key)) {
                params.push(body[key]);
                sets.push(`${column} = $${params.length}`);
            }
        }
        if (!sets.length) throw badReq('no patchable fields provided');
        const { rows } = await pool.query(
            `UPDATE driver_tasks SET ${sets.join(', ')}, updated_at = now() WHERE id = $1 RETURNING id`,
            params
        );
        if (!rows.length) throw notFound('driver_task not found');
        res.json({ data: { id: rows[0].id } });
    } catch (err) { next(err); }
});

// POST /driver-tasks/:id/send-test — шлёт черновой текст менеджеру
// (manager_telegram_chat_ids — тот же канал, что booking-эскалации), НЕ в
// реальный водительский чат (бота туда ещё нет, см. план CRM v1.1). Не
// меняет driver_tasks.status — тестовая отправка не то же самое, что
// реальный диспатч.
driverTasksAdminRouter.post('/driver-tasks/:id/send-test', async (req, res, next) => {
    try {
        const data = await dispatchDriverTask(req.params.id, { templateCode: 'driver_task_test' });
        res.json({ data });
    } catch (err) { next(err); }
});
