import { pool } from '../db/pool.js';
import { createPengirimanTaskIfReady, finalizePengirimanTaskOutcome } from './driverTaskDispatch.js';

// =====================================================================
// BOOKING LIFECYCLE — CRM v1.1, первый функциональный срез (сессия
// 2026-09-26). createBooking() (services/booking.js) доводит бронь только
// до status='created' и дальше никогда её не двигает — это и есть дыра,
// которую закрывают функции этого файла.
//
// Согласованный с Дмитрием порядок (НЕ порядок объявления enum booking_status
// в 001_foundation.sql — тот шире и не совпадает с реальным операционным
// потоком):
//   created → fleet_item_assigned → confirmed → driver_assigned →
//   awaiting_payment → paid → fulfilled
// 'ai_processing' — зарезервирован под v1.4 (AI Customer Manager), в этом
// срезе для него вообще не пишется строка в booking_status_history.
//
// Каждая функция — один переход, одна транзакция, одна строка в
// booking_status_history. Бэкенд жёстко проверяет текущий статус брони
// (assertStatus) — нельзя пропустить шаг вызовом не в том порядке.
// =====================================================================

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
function conflict(message) {
    const e = new Error(message);
    e.status = 409;
    return e;
}

async function loadBookingForUpdate(client, bookingId) {
    const { rows } = await client.query('SELECT * FROM bookings WHERE id = $1 FOR UPDATE', [bookingId]);
    if (!rows.length) throw notFound('booking not found');
    return rows[0];
}

function assertStatus(booking, expected) {
    if (booking.status !== expected) {
        throw conflict(`booking.status is '${booking.status}', expected '${expected}' for this action`);
    }
}

async function recordTransition(client, bookingId, fromStatus, toStatus, note) {
    await client.query(`UPDATE bookings SET status = $2, updated_at = now() WHERE id = $1`, [bookingId, toStatus]);
    await client.query(
        `INSERT INTO booking_status_history (booking_id, from_status, to_status, note) VALUES ($1, $2, $3, $4)`,
        [bookingId, fromStatus, toStatus, note]
    );
}

async function withTransaction(fn) {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        const result = await fn(client);
        await client.query('COMMIT');
        return result;
    } catch (e) {
        await client.query('ROLLBACK');
        throw e;
    } finally {
        client.release();
    }
}

// ---------------------------------------------------------------------
// 1. created → fleet_item_assigned — диспетчер выбирает конкретный байк.
// fleet_items.status → 'reserved' (НЕ 'rented' — байк ещё не выдан
// физически, см. CLAUDE.md §3.2: Rental создаётся только при передаче).
//
// Три допустимых уровня совпадения (дизайн подтверждён Дмитрием
// 2026-09-27, CLAUDE.md §3.1 replacement_groups): точный product_id брони
// (tier 1) → тот же product_families.family_id, другой цвет (tier 2) →
// та же product_families.replacement_group_id (tier 3, обе НЕ NULL).
// Любой уровень кроме tier 1 — реальная замена, требует непустой
// replacement_reason (bookings.replacement_reason, ТЗ п.7.3).
// ---------------------------------------------------------------------
export async function assignFleetItem(bookingId, fleetItemId, replacementReason = null) {
    if (typeof fleetItemId !== 'string' || !fleetItemId) throw badReq('fleet_item_id is required');
    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'created');

        const { rows: bfRows } = await client.query(
            `SELECT p.family_id, pf.replacement_group_id
             FROM products p JOIN product_families pf ON pf.id = p.family_id
             WHERE p.id = $1`,
            [booking.product_id]
        );
        const bookingFamilyId = bfRows[0]?.family_id ?? null;
        const bookingReplacementGroupId = bfRows[0]?.replacement_group_id ?? null;

        const { rows: fRows } = await client.query(
            `SELECT fi.id, fi.product_id, fi.status, p.family_id, pf.replacement_group_id
             FROM fleet_items fi
             JOIN products p ON p.id = fi.product_id
             JOIN product_families pf ON pf.id = p.family_id
             WHERE fi.id = $1 FOR UPDATE`,
            [fleetItemId]
        );
        if (!fRows.length) throw notFound('fleet_item not found');
        const fleetItem = fRows[0];

        const isExact = fleetItem.product_id === booking.product_id;
        const isSameFamily = !isExact && fleetItem.family_id === bookingFamilyId;
        const isReplacementGroup = !isExact && !isSameFamily
            && bookingReplacementGroupId != null
            && fleetItem.replacement_group_id === bookingReplacementGroupId;

        if (!isExact && !isSameFamily && !isReplacementGroup) {
            throw badReq('fleet_item is not an exact match, a same-family alternative, or a replacement-group alternative for this booking');
        }

        const reason = typeof replacementReason === 'string' ? replacementReason.trim() : '';
        if (!isExact && !reason) {
            throw badReq('replacement_reason is required when assigning a fleet_item outside the exact product match');
        }

        if (!['available', 'prepared'].includes(fleetItem.status)) {
            throw conflict(`fleet_item.status is '${fleetItem.status}', must be 'available' or 'prepared'`);
        }

        await client.query(
            'UPDATE bookings SET assigned_fleet_item = $2, replacement_reason = $3 WHERE id = $1',
            [bookingId, fleetItemId, isExact ? null : reason]
        );
        await client.query(`UPDATE fleet_items SET status = 'reserved', updated_at = now() WHERE id = $1`, [fleetItemId]);
        await recordTransition(
            client, bookingId, 'created', 'fleet_item_assigned',
            isExact
                ? 'Fleet item assigned via /internal/bookings'
                : `Fleet item assigned via /internal/bookings (replacement: ${reason})`
        );

        return { booking_id: bookingId, status: 'fleet_item_assigned', fleet_item_id: fleetItemId };
    });
}

// ---------------------------------------------------------------------
// 2. fleet_item_assigned → confirmed — без побочных эффектов в этом срезе
// (без авто-отправки задачи водителю — это отдельное ручное действие на
// экране Driver Tasks, Коммит 3).
// ---------------------------------------------------------------------
export async function confirmBooking(bookingId) {
    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'fleet_item_assigned');
        await recordTransition(client, bookingId, 'fleet_item_assigned', 'confirmed', 'Confirmed via /internal/bookings');
        return { booking_id: bookingId, status: 'confirmed' };
    });
}

// ---------------------------------------------------------------------
// 3. confirmed → driver_assigned — назначение по слоту (drivers.driver_slot,
// миграция 068), не по конкретному users.id. Без отслеживания "водитель
// ответил ОК" (решение Дмитрия — вне схемы, живёт в реальном Telegram-чате).
// ---------------------------------------------------------------------
// confirmed → driver_assigned триггерит автосоздание+автоотправку задачи
// 'pengiriman' (CRM v1.1 Раздел 1, дизайн подтверждён Дмитрием 2026-09-27):
// как только бронь получила И байк (tier-назначение выше), И водителя —
// проверяем достаточность данных (контакт клиента, location_link,
// delivery_time) и, если всё есть, создаём+шлём карточку тем же путём, что
// кнопка "отправить тест" на /internal/driver-tasks. Если данных не
// хватает — статус-переход всё равно происходит (водитель назначен), но
// задача НЕ создаётся молча — вызывающая сторона получает missing_fields
// в driver_task и должна дозаполнить их через retryPengirimanTask() ниже.
export async function assignDriver(bookingId, driverSlot) {
    const slot = Number(driverSlot);
    if (![1, 2, 3].includes(slot)) throw badReq('driver_slot must be 1, 2 or 3');
    const taskOutcome = await withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'confirmed');

        const { rows: dRows } = await client.query('SELECT is_active FROM drivers WHERE driver_slot = $1', [slot]);
        if (!dRows.length) throw notFound('driver slot not found');
        if (!dRows[0].is_active) throw badReq('driver slot is not active');

        await client.query('UPDATE bookings SET assigned_driver_slot = $2 WHERE id = $1', [bookingId, slot]);
        await recordTransition(client, bookingId, 'confirmed', 'driver_assigned', `Driver slot ${slot} assigned via /internal/bookings`);

        return createPengirimanTaskIfReady(client, bookingId);
    });

    const driverTask = await finalizePengirimanTaskOutcome(taskOutcome);
    return { booking_id: bookingId, status: 'driver_assigned', driver_slot: slot, driver_task: driverTask };
}

// Дозаполнение недостающих полей (location_link/delivery_time) и повторная
// попытка создать+отправить 'pengiriman', когда assignDriver() выше не смог
// это сделать сразу. customer_contact здесь не чинится — это поле
// customers, не bookings, чинится за пределами этой формы (см. Раздел 1
// задания). Идемпотентна — если задача уже была создана параллельно/ранее,
// createPengirimanTaskIfReady() просто вернёт alreadyExisted, без дубля.
export async function retryPengirimanTask(bookingId, { location_link, delivery_time } = {}) {
    const taskOutcome = await withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        if (booking.status !== 'driver_assigned') {
            throw conflict(`booking.status is '${booking.status}', expected 'driver_assigned' for this action`);
        }
        if (typeof location_link === 'string' && location_link.trim()) {
            await client.query('UPDATE bookings SET location_link = $2, updated_at = now() WHERE id = $1', [bookingId, location_link.trim()]);
        }
        if (typeof delivery_time === 'string' && /^\d{2}:\d{2}$/.test(delivery_time)) {
            await client.query('UPDATE bookings SET delivery_time = $2, updated_at = now() WHERE id = $1', [bookingId, delivery_time]);
        }
        return createPengirimanTaskIfReady(client, bookingId);
    });

    const driverTask = await finalizePengirimanTaskOutcome(taskOutcome);
    return { booking_id: bookingId, driver_task: driverTask };
}

// ---------------------------------------------------------------------
// 4-5. driver_assigned → awaiting_payment → paid — чистые флаги отметки
// факта (Дмитрий: "простой переключатель, без finance_transactions, без
// сумм" — расчёты остаются за Finance-срезом, v1.3).
// ---------------------------------------------------------------------
export async function markAwaitingPayment(bookingId) {
    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'driver_assigned');
        await recordTransition(client, bookingId, 'driver_assigned', 'awaiting_payment', 'Marked awaiting payment via /internal/bookings');
        return { booking_id: bookingId, status: 'awaiting_payment' };
    });
}

export async function markPaid(bookingId) {
    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'awaiting_payment');
        await recordTransition(client, bookingId, 'awaiting_payment', 'paid', 'Marked paid via /internal/bookings');
        return { booking_id: bookingId, status: 'paid' };
    });
}

function parseDateOnly(s) {
    if (typeof s !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(s)) return null;
    const d = new Date(`${s}T00:00:00Z`);
    return Number.isNaN(d.getTime()) ? null : d;
}

// ---------------------------------------------------------------------
// 6. paid → fulfilled — момент фактической передачи байка. Дмитрий:
// "не просто выдано, а момент, когда фиксируется итоговый срок аренды —
// бронирование считается исполненным, дальше жизнь идёт в rentals".
// ЗДЕСЬ создаётся rentals (CLAUDE.md §3.2: Rental только при передаче) +
// fleet_items.status → 'rented' + событие bike_delivered (код уже
// существует, 004_booking_rental.sql).
//
// Минимальный набор полей rentals — договор/фото/видео/одометр остаются
// NULL до отдельного будущего экрана фактической передачи (не этот срез,
// см. план). start_date/end_date по умолчанию берутся из брони, но
// администратор может передать фактические даты, если они отличаются от
// изначально запрошенных.
// ---------------------------------------------------------------------
export async function fulfillBooking(bookingId, { start_date, end_date } = {}) {
    if (start_date !== undefined && start_date !== null && !parseDateOnly(start_date)) throw badReq('start_date must be YYYY-MM-DD');
    if (end_date !== undefined && end_date !== null && !parseDateOnly(end_date)) throw badReq('end_date must be YYYY-MM-DD');

    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'paid');
        if (!booking.assigned_fleet_item) throw conflict('booking has no assigned_fleet_item — cannot fulfill');

        const startDate = start_date || booking.start_date;
        const endDate = end_date || booking.end_date;
        const depositAmount = Number(booking.quote_snapshot?.deposit?.amount_idr) || 0;

        let rentalId;
        try {
            const { rows: rRows } = await client.query(
                `INSERT INTO rentals (booking_id, customer_id, fleet_item_id, status, start_date, end_date, deposit_amount_idr)
                 VALUES ($1, $2, $3, 'active', $4, $5, $6)
                 RETURNING id`,
                [bookingId, booking.customer_id, booking.assigned_fleet_item, startDate, endDate, depositAmount]
            );
            rentalId = rRows[0].id;
        } catch (e) {
            // no_overlapping_active_rentals (btree_gist exclusion, 004_booking_rental.sql) —
            // тот же физический байк уже выдан на пересекающиеся даты другой активной арендой.
            if (e.code === '23P01') throw conflict('fleet_item already has an overlapping active rental for these dates');
            throw e;
        }

        await client.query(
            `UPDATE fleet_items SET status = 'rented', rent_until_date = $2, updated_at = now() WHERE id = $1`,
            [booking.assigned_fleet_item, endDate]
        );

        await client.query(
            `INSERT INTO events (type_code, source, booking_id, rental_id, fleet_item_id, customer_id, payload)
             VALUES ('bike_delivered', 'manual', $1, $2, $3, $4, '{}')`,
            [bookingId, rentalId, booking.assigned_fleet_item, booking.customer_id]
        );

        await recordTransition(client, bookingId, 'paid', 'fulfilled', 'Fulfilled via /internal/bookings — rental created');

        return { booking_id: bookingId, status: 'fulfilled', rental_id: rentalId };
    });
}

// =====================================================================
// РАЗДЕЛ 2 (2026-09-27) — симметричные обратные переходы ("← Назад").
// Тот же паттерн: транзакция, FOR UPDATE, запись в booking_status_history.
// paid → awaiting_payment — последний шаг, где откат делается без вопросов
// (Дмитрий). fulfilled → paid (unfulfillBooking, ниже) — особый случай: на
// этом шаге уже создана реальная rentals-запись, откат должен быть
// ПОЛНЫМ, а не сменой статуса.
// =====================================================================

// fleet_item_assigned → created — байк возвращается в пул ('available'),
// replacement_reason сбрасывается (он был написан именно под это, теперь
// уже отменённое, назначение).
export async function unassignFleetItem(bookingId) {
    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'fleet_item_assigned');
        if (booking.assigned_fleet_item) {
            await client.query(`UPDATE fleet_items SET status = 'available', updated_at = now() WHERE id = $1`, [booking.assigned_fleet_item]);
        }
        await client.query('UPDATE bookings SET assigned_fleet_item = NULL, replacement_reason = NULL WHERE id = $1', [bookingId]);
        await recordTransition(client, bookingId, 'fleet_item_assigned', 'created', '← Назад via /internal/bookings');
        return { booking_id: bookingId, status: 'created' };
    });
}

// confirmed → fleet_item_assigned — только статус назад, без побочных эффектов.
export async function unconfirmBooking(bookingId) {
    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'confirmed');
        await recordTransition(client, bookingId, 'confirmed', 'fleet_item_assigned', '← Назад via /internal/bookings');
        return { booking_id: bookingId, status: 'fleet_item_assigned' };
    });
}

// driver_assigned → confirmed — очищаем assigned_driver_slot; если для этой
// брони уже успела создаться (Раздел 1) задача 'pengiriman' и она ещё не
// выполнена — отменяем её (status='cancelled'), НЕ удаляем — остаётся для
// истории.
export async function unassignDriver(bookingId) {
    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'driver_assigned');

        await client.query(
            `UPDATE driver_tasks SET status = 'cancelled', updated_at = now()
             WHERE booking_id = $1 AND type_code = 'pengiriman' AND status NOT IN ('completed', 'cancelled')`,
            [bookingId]
        );
        await client.query('UPDATE bookings SET assigned_driver_slot = NULL WHERE id = $1', [bookingId]);
        await recordTransition(client, bookingId, 'driver_assigned', 'confirmed', '← Назад via /internal/bookings');
        return { booking_id: bookingId, status: 'confirmed' };
    });
}

// awaiting_payment → driver_assigned — только статус назад.
export async function unmarkAwaitingPayment(bookingId) {
    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'awaiting_payment');
        await recordTransition(client, bookingId, 'awaiting_payment', 'driver_assigned', '← Назад via /internal/bookings');
        return { booking_id: bookingId, status: 'driver_assigned' };
    });
}

// paid → awaiting_payment — только статус назад.
export async function unmarkPaid(bookingId) {
    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'paid');
        await recordTransition(client, bookingId, 'paid', 'awaiting_payment', '← Назад via /internal/bookings');
        return { booking_id: bookingId, status: 'awaiting_payment' };
    });
}

// fulfilled → paid — ПОЛНЫЙ откат ошибочного Fulfilled (дизайн подтверждён
// Дмитрием 2026-09-27: "если Fulfilled нажали по ошибке и реальной выдачи
// байка не было — откат должен быть полным"). rentals удаляется целиком —
// не переводится в какой-то статус ('cancelled' не входит в rental_status
// enum active|returned|closed, и по факту аренды не было вообще), events
// (bike_delivered) для неё удаляется, fleet_item возвращается в 'reserved'
// (не 'available' — байк всё ещё назначен на эту бронь).
// booking_status_history получает НОВУЮ запись fulfilled→paid — старая
// запись о переходе в fulfilled не трогается, остаётся в истории.
export async function unfulfillBooking(bookingId) {
    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'fulfilled');

        const { rows: rentalRows } = await client.query(
            'SELECT id, fleet_item_id FROM rentals WHERE booking_id = $1 FOR UPDATE',
            [bookingId]
        );
        if (!rentalRows.length) throw conflict('no rentals row found for this booking — cannot unfulfill');
        const rental = rentalRows[0];

        await client.query(`DELETE FROM events WHERE type_code = 'bike_delivered' AND rental_id = $1`, [rental.id]);
        await client.query('DELETE FROM rentals WHERE id = $1', [rental.id]);
        await client.query(`UPDATE fleet_items SET status = 'reserved', updated_at = now() WHERE id = $1`, [rental.fleet_item_id]);
        await recordTransition(client, bookingId, 'fulfilled', 'paid', 'Откат ошибочного Fulfilled — реальной выдачи не было');

        return { booking_id: bookingId, status: 'paid' };
    });
}
