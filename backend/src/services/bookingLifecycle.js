import { pool } from '../db/pool.js';

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
// ---------------------------------------------------------------------
export async function assignFleetItem(bookingId, fleetItemId) {
    if (typeof fleetItemId !== 'string' || !fleetItemId) throw badReq('fleet_item_id is required');
    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'created');

        const { rows: fRows } = await client.query(
            'SELECT id, product_id, status FROM fleet_items WHERE id = $1 FOR UPDATE',
            [fleetItemId]
        );
        if (!fRows.length) throw notFound('fleet_item not found');
        const fleetItem = fRows[0];
        if (fleetItem.product_id !== booking.product_id) {
            throw badReq('fleet_item does not belong to the product requested in this booking');
        }
        if (!['available', 'prepared'].includes(fleetItem.status)) {
            throw conflict(`fleet_item.status is '${fleetItem.status}', must be 'available' or 'prepared'`);
        }

        await client.query('UPDATE bookings SET assigned_fleet_item = $2 WHERE id = $1', [bookingId, fleetItemId]);
        await client.query(`UPDATE fleet_items SET status = 'reserved', updated_at = now() WHERE id = $1`, [fleetItemId]);
        await recordTransition(client, bookingId, 'created', 'fleet_item_assigned', 'Fleet item assigned via /internal/bookings');

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
export async function assignDriver(bookingId, driverSlot) {
    const slot = Number(driverSlot);
    if (![1, 2, 3].includes(slot)) throw badReq('driver_slot must be 1, 2 or 3');
    return withTransaction(async (client) => {
        const booking = await loadBookingForUpdate(client, bookingId);
        assertStatus(booking, 'confirmed');

        const { rows: dRows } = await client.query('SELECT is_active FROM drivers WHERE driver_slot = $1', [slot]);
        if (!dRows.length) throw notFound('driver slot not found');
        if (!dRows[0].is_active) throw badReq('driver slot is not active');

        await client.query('UPDATE bookings SET assigned_driver_slot = $2 WHERE id = $1', [bookingId, slot]);
        await recordTransition(client, bookingId, 'confirmed', 'driver_assigned', `Driver slot ${slot} assigned via /internal/bookings`);

        return { booking_id: bookingId, status: 'driver_assigned', driver_slot: slot };
    });
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
