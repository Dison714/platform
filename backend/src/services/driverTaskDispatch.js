import { pool } from '../db/pool.js';
import { getCompanyId, getConfig } from './config.js';
import { esc, ddk, buildContactsHtml, computePeralatan, nextDriverNotificationSeq, loadBookingSnapshot } from './booking.js';
import { deliverNotification } from './notify.js';
import { DRIVER_TASK_TEMPLATES, SEND_ALLOWED_CODES } from '../config/driverTaskTemplates.js';

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

// =====================================================================
// Общая точка сборки текста и отправки карточки задачи водителю —
// переиспользуется кнопкой "отправить тест" (driverTasksAdmin.js,
// templateCode='driver_task_test') и автосозданием pengiriman-задачи из
// bookingLifecycle.assignDriver()/retryPengirimanTask()
// (templateCode='driver_task_auto'). Раньше жила только внутри
// POST /driver-tasks/:id/send-test — вынесена сюда при добавлении
// автодиспатча (CRM v1.1, Раздел 1), чтобы не дублировать сборку ctx.
// Всегда шлёт в manager_telegram_chat_ids — реальный водительский бот ещё
// не подключён (см. CLAUDE.md §3.10), это ограничение НЕ снимается здесь.
// =====================================================================
export async function dispatchDriverTask(taskId, { templateCode = 'driver_task_test' } = {}) {
    const { rows: taskRows } = await pool.query(
        `SELECT dt.*, tt.name_id AS type_name
         FROM driver_tasks dt JOIN task_types tt ON tt.code = dt.type_code
         WHERE dt.id = $1`,
        [taskId]
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
    // Pakai — байк, на котором ВОДИТЕЛЬ едет выполнять задачу и возвращается
    // (не Motor — тот сдаётся/забирается у клиента). Раздел 5C, миграция 073:
    // источник данных теперь есть — pakai_fleet_item_id (select по парку) ИЛИ
    // pakai_text (свободный текст), взаимоисключимо. Пусто, если ни то ни другое
    // не заполнено (штатно для одного водителя — он возвращается на такси).
    let pakai = null;
    if (task.pakai_fleet_item_id) {
        const { rows: pkRows } = await pool.query(
            `SELECT fi.internal_number, fi.license_plate, p.color_name, pf.brand, pf.model_name
             FROM fleet_items fi
             JOIN products p ON p.id = fi.product_id
             JOIN product_families pf ON pf.id = p.family_id
             WHERE fi.id = $1`,
            [task.pakai_fleet_item_id]
        );
        if (pkRows.length) {
            const pk = pkRows[0];
            pakai = `${pk.internal_number}.${pk.brand} ${pk.model_name} ${pk.color_name} ${pk.license_plate}`;
        }
    } else if (task.pakai_text) {
        pakai = task.pakai_text;
    }

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
             VALUES ($1,'telegram','queued',$2,$3,$4) RETURNING id`,
            [companyId, templateCode, { chat_id: chatId, text, parse_mode: 'HTML' }, task.booking_id]
        );
        const notificationId = nRows[0].id;
        await deliverNotification(notificationId);
        const { rows: statusRows } = await pool.query(
            'SELECT status, error FROM notifications WHERE id = $1',
            [notificationId]
        );
        results.push({ chat_id: chatId, status: statusRows[0].status, error: statusRows[0].error });
    }

    return { text, results };
}

// =====================================================================
// Автосоздание задачи 'pengiriman' сразу по факту confirmed→driver_assigned
// (bookingLifecycle.assignDriver(), CRM v1.1 Раздел 1, дизайн подтверждён
// Дмитрием 2026-09-27). Идемпотентна — повторный вызов для той же брони
// (напр. retryPengirimanTask после дозаполнения формы) не создаёт вторую
// задачу, если она уже есть.
//
// Возвращает:
//   { ok: true, taskId, alreadyExisted } — задача создана (или уже была)
//   { ok: false, missingFields: [...] }  — недостаточно данных, ничего не
//                                          создано и не отправлено молча
//
// client — коннекшн внутри транзакции bookingLifecycle (FOR UPDATE на
// bookings уже держится вызывающей стороной), либо pool вне транзакции
// (retryPengirimanTask открывает свою).
// =====================================================================
export async function createPengirimanTaskIfReady(client, bookingId) {
    const { rows: existing } = await client.query(
        `SELECT id FROM driver_tasks WHERE booking_id = $1 AND type_code = 'pengiriman' LIMIT 1`,
        [bookingId]
    );
    if (existing.length) return { ok: true, taskId: existing[0].id, alreadyExisted: true };

    const { rows: bRows } = await client.query(
        `SELECT b.id, b.company_id, b.location_link, b.delivery_time, b.start_date,
                b.assigned_fleet_item, b.assigned_driver_slot, b.quote_snapshot,
                c.phone, c.whatsapp, c.telegram_username, c.telegram_id,
                vc.code AS category_code
         FROM bookings b
         JOIN customers c ON c.id = b.customer_id
         JOIN products p ON p.id = b.product_id
         JOIN product_families pf ON pf.id = p.family_id
         JOIN vehicle_categories vc ON vc.id = pf.category_id
         WHERE b.id = $1`,
        [bookingId]
    );
    if (!bRows.length) throw notFound('booking not found');
    const b = bRows[0];

    const contact = b.whatsapp || b.phone || b.telegram_username || b.telegram_id || null;
    const missingFields = [];
    if (!contact) missingFields.push('customer_contact');
    if (!b.location_link) missingFields.push('location_link');
    if (!b.delivery_time) missingFields.push('delivery_time');
    if (missingFields.length) return { ok: false, missingFields };

    let peralatan = null;
    if (b.quote_snapshot?.breakdown) {
        peralatan = computePeralatan(b.quote_snapshot.breakdown.equipment?.items, b.category_code);
    }

    const dailySeq = await nextDriverNotificationSeq(client, b.company_id);
    const { rows: tRows } = await client.query(
        `INSERT INTO driver_tasks (
            company_id, type_code, daily_seq, booking_id, fleet_item_id,
            assigned_driver_slot, priority, status, scheduled_date, scheduled_time,
            customer_contact, location_text, payload, source
         ) VALUES ($1,'pengiriman',$2,$3,$4,$5,'planned','pending',$6,$7,$8,$9,$10,'manual')
         RETURNING id`,
        [
            b.company_id, dailySeq, bookingId, b.assigned_fleet_item,
            b.assigned_driver_slot, b.start_date, b.delivery_time,
            contact, b.location_link, { peralatan },
        ]
    );
    return { ok: true, taskId: tRows[0].id, alreadyExisted: false };
}

// Отправка (dispatchDriverTask — сетевой вызов) обязана идти ПОСЛЕ коммита
// транзакции, где создавалась задача (не держать лок на bookings/driver_tasks
// на время HTTP-похода к Telegram). Вызывающая сторона (bookingLifecycle.js)
// коммитит транзакцию сама и уже потом зовёт эту обёртку.
export async function finalizePengirimanTaskOutcome(taskOutcome) {
    if (!taskOutcome.ok) {
        return { created: false, missing_fields: taskOutcome.missingFields };
    }
    if (taskOutcome.alreadyExisted) {
        return { created: true, task_id: taskOutcome.taskId, already_existed: true };
    }
    const dispatch = await dispatchDriverTask(taskOutcome.taskId, { templateCode: 'driver_task_auto' });
    return { created: true, task_id: taskOutcome.taskId, dispatch };
}
