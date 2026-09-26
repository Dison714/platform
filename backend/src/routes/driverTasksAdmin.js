import { Router } from 'express';
import { pool } from '../db/pool.js';
import { getCompanyId, getConfig } from '../services/config.js';
import { esc, ddk, buildContactsHtml, computePeralatan, nextDriverNotificationSeq } from '../services/booking.js';
import { deliverNotification } from '../services/notify.js';
import { DRIVER_TASK_TEMPLATES, SEND_ALLOWED_CODES } from '../config/driverTaskTemplates.js';

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

// product_name (products.internal_name) сюда сознательно не включён — после
// ревью Дмитрия (Коммит 3, v3) Motor в карточке больше не берёт "упрощённое"
// имя товара, а строится напрямую из fleet_items/products/product_families
// (см. send-test ниже) только когда у задачи есть конкретный fleet_item_id.
async function loadBookingSnapshot(client, bookingId) {
    const { rows } = await client.query(
        `SELECT b.id, b.quote_snapshot, b.location_link, b.assigned_fleet_item,
                c.full_name, c.phone, c.whatsapp, c.telegram_username, c.telegram_id, c.email,
                vc.code AS category_code
         FROM bookings b
         JOIN customers c ON c.id = b.customer_id
         JOIN products p ON p.id = b.product_id
         JOIN product_families pf ON pf.id = p.family_id
         JOIN vehicle_categories vc ON vc.id = pf.category_id
         WHERE b.id = $1`,
        [bookingId]
    );
    return rows[0] ?? null;
}

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
        const { rows: taskRows } = await pool.query(
            `SELECT dt.*, tt.name_id AS type_name
             FROM driver_tasks dt JOIN task_types tt ON tt.code = dt.type_code
             WHERE dt.id = $1`,
            [req.params.id]
        );
        if (!taskRows.length) throw notFound('driver_task not found');
        const task = taskRows[0];

        if (!SEND_ALLOWED_CODES.includes(task.type_code)) {
            throw badReq(`sending is not enabled for type_code '${task.type_code}' (allowed: ${SEND_ALLOWED_CODES.join(', ')})`);
        }

        let clientContactHtml = null;
        let motorName = null;
        let hargaK = null;
        let depositK = null;
        let totalK = null;
        let peralatan = task.payload?.peralatan ?? null;
        let sopir = null;

        // Pakai — НЕ тот же байк, что Motor (ревью Дмитрия после теста v2):
        // Motor — байк, который сдаётся клиенту; Pakai — байк, на котором
        // ВОДИТЕЛЬ едет выполнять задачу и возвращается (для одиночного
        // водителя штатно пусто — он возвращается на такси). В этом срезе
        // источника данных под Pakai нет вообще (в схеме нет ни второго
        // слота водителя на задачу, ни поля под "возвратный" fleet_item) —
        // будущий отдельный срез, если появится сценарий с двумя водителями
        // на одну задачу. Оставляю как всегда-пустое поле шаблона, чтобы
        // было куда его прикрутить, без бизнес-логики за ним.
        const pakai = null;

        if (task.assigned_driver_slot != null) {
            const { rows: dRows } = await pool.query('SELECT name FROM drivers WHERE driver_slot = $1', [task.assigned_driver_slot]);
            sopir = dRows[0]?.name ?? null;
        }

        if (task.booking_id) {
            const snap = await loadBookingSnapshot(pool, task.booking_id);
            if (snap) {
                clientContactHtml = buildContactsHtml(snap);
                const quote = snap.quote_snapshot;
                if (quote) {
                    hargaK = ddk(quote.total_payable_idr);
                    depositK = ddk(quote.deposit.amount_idr);
                    totalK = ddk(Number(quote.total_payable_idr) + Number(quote.deposit.amount_idr));
                }
                if (!peralatan && quote?.breakdown) {
                    peralatan = computePeralatan(quote.breakdown.equipment?.items, snap.category_code);
                }
            }
        }
        if (!clientContactHtml && task.customer_contact) {
            clientContactHtml = esc(task.customer_contact);
        }
        // Motor — напрямую из fleet_items/products/product_families, как
        // они есть в базе, без "упрощённого" имени (ревью Дмитрия: раньше
        // бралось products.internal_name — снято). Формат:
        // "<internal_number>.<Brand> <Model> <Цвет> <license_plate>"
        // (license_plate уже хранится со своим "#", доп. "#" не добавляем).
        // Только если у задачи есть конкретный fleet_item — иначе пусто,
        // как остальные поля без источника (buildDriverText-конвенция).
        if (task.fleet_item_id) {
            const { rows: fRows } = await pool.query(
                `SELECT fi.internal_number, fi.license_plate, p.color_name, pf.brand, pf.model_name
                 FROM fleet_items fi
                 JOIN products p ON p.id = fi.product_id
                 JOIN product_families pf ON pf.id = p.family_id
                 WHERE fi.id = $1`,
                [task.fleet_item_id]
            );
            if (fRows.length) {
                const f = fRows[0];
                motorName = `${f.internal_number}.${f.brand} ${f.model_name} ${f.color_name} ${f.license_plate}`;
            }
        }

        const template = DRIVER_TASK_TEMPLATES[task.type_code];
        const text = template({
            seq: task.daily_seq,
            typeNameLower: task.type_name.toLowerCase(),
            scheduledDate: task.scheduled_date,
            scheduledTime: task.scheduled_time ? String(task.scheduled_time).slice(0, 5) : null,
            sopir,
            pakai,
            location: task.location_text,
            clientContactHtml,
            motorName,
            hargaK,
            depositK,
            totalK,
            peralatan,
            komentar: task.comment,
        });

        const companyId = await getCompanyId();
        const chatIds = (await getConfig(companyId, 'manager_telegram_chat_ids')) || [];
        const results = [];
        for (const chatId of chatIds) {
            const { rows: nRows } = await pool.query(
                `INSERT INTO notifications (company_id, channel, status, template_code, payload, booking_id)
                 VALUES ($1,'telegram','queued','driver_task_test',$2,$3) RETURNING id`,
                [companyId, { chat_id: chatId, text, parse_mode: 'HTML' }, task.booking_id]
            );
            const notificationId = nRows[0].id;
            await deliverNotification(notificationId);
            const { rows: statusRows } = await pool.query(
                'SELECT status, error FROM notifications WHERE id = $1',
                [notificationId]
            );
            results.push({ chat_id: chatId, status: statusRows[0].status, error: statusRows[0].error });
        }

        res.json({ data: { text, results } });
    } catch (err) { next(err); }
});
