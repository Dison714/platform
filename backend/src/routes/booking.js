import { Router } from 'express';
import { createBooking } from '../services/booking.js';
import { deliverNotification } from '../services/notify.js';
import { resolveApiClient } from '../middleware/apiClient.js';
import { bookingsLimiter } from '../middleware/rateLimit.js';

export const bookingRouter = Router();

// POST /api/bookings — приём заявки с сайта (Booking v1, без онлайн-оплаты).
// Сервер сам пересчитывает цену (фронту не доверяет), сохраняет снимок,
// уведомляет менеджера в Telegram fire-and-forget.
// resolveApiClient — без X-Api-Key (сегодняшний сайт) req.apiClient=null,
// поведение не меняется. С валидным ключом — source='telegram_bot'
// (record_source enum, все 3 сегодняшних клиента — Telegram-боты, см.
// createBooking) вместо 'website'; точная идентичность вызывающего —
// bookings.api_client_id (FK на api_clients, 065_api_clients_seed.sql) —
// для будущей CRM-отчётности, не путать с грубой категорией source.
// bookingsLimiter — ПЕРЕД resolveApiClient (дешёвая in-memory проверка до
// похода в БД за ключом).
bookingRouter.post('/bookings', bookingsLimiter, resolveApiClient, async (req, res, next) => {
    try {
        const result = await createBooking(req.body ?? {}, { apiClient: req.apiClient });

        // Заявка уже в БД (committed). Отвечаем клиенту сразу.
        res.status(201).json({
            data: {
                booking_id: result.booking.id,
                booking_number: result.booking.booking_number, // монотонный номер
                booking_ref: result.ref,                       // тот же BR-номер, что у менеджера
                status: result.booking.status,
                created_at: result.booking.created_at,
                location_link: result.link,
                ...result.quote, // product, rental_days, currency, breakdown, total_payable_idr, deposit
            },
            meta: { currency: 'IDR' },
        });

        // Эскалация менеджерам — после ответа, по одной попытке на каждый
        // chat_id (своя запись/статус). Не влияет на заявку.
        for (const id of result.notificationIds) deliverNotification(id);
    } catch (err) {
        next(err);
    }
});
