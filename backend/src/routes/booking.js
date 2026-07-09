import { Router } from 'express';
import { createBooking } from '../services/booking.js';
import { deliverNotification } from '../services/notify.js';

export const bookingRouter = Router();

// POST /api/bookings — приём заявки с сайта (Booking v1, без онлайн-оплаты).
// Сервер сам пересчитывает цену (фронту не доверяет), сохраняет снимок,
// уведомляет менеджера в Telegram fire-and-forget.
bookingRouter.post('/bookings', async (req, res, next) => {
    try {
        const result = await createBooking(req.body ?? {});

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
