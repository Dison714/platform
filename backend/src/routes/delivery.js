import { Router } from 'express';
import { computeDeliveryFee } from '../services/delivery.js';
import { collectShadowStats } from '../services/deliveryShadow.js';
import { getCompanyId } from '../services/config.js';

export const deliveryRouter = Router();

// POST /api/delivery/quote — стоимость доставки по сроку аренды.
// body: { rental_days: int>=1, location_link?: string }
// location_link принимается и возвращается КАК ЕСТЬ (для водителя), на цену
// не влияет. Shadow-сбор статистики идёт ПОСЛЕ ответа, асинхронно.
deliveryRouter.post('/delivery/quote', async (req, res, next) => {
    try {
        const { rental_days, location_link } = req.body ?? {};
        const rentalDays = Number(rental_days);
        if (!Number.isInteger(rentalDays) || rentalDays < 1) {
            return res.status(400).json({ error: 'bad_request', message: 'rental_days must be a positive integer' });
        }
        const link = typeof location_link === 'string' && location_link.trim() ? location_link.trim() : null;

        const delivery = await computeDeliveryFee({ rentalDays });

        // Клиент получает цену сразу.
        res.json({ data: { delivery, location_link: link }, meta: { currency: 'IDR' } });

        // SHADOW: после ответа, не влияет на цену, не задерживает, не роняет запрос.
        if (link) {
            getCompanyId()
                .then((companyId) =>
                    collectShadowStats({
                        companyId,
                        locationLink: link,
                        rentalDays,
                        actualFeeIdr: delivery.fee_idr,
                        deliveryMode: delivery.mode,
                    })
                )
                .catch((e) => console.error('[delivery-shadow] trigger failed:', e?.message));
        }
    } catch (err) {
        next(err);
    }
});
