import { Router } from 'express';
import { buildQuote } from '../services/quote.js';
import { collectShadowStats } from '../services/deliveryShadow.js';
import { getCompanyId } from '../services/config.js';

export const quoteRouter = Router();

// POST /api/quote — полный расчёт стоимости аренды.
// body: {
//   product: "<id|slug>", rental_days: int>=1,
//   insurance?: { theft?: bool, damage?: { coverage_idr }, driver?: { age, has_license, experienced } },
//   equipment?: [ { code, quantity? } ],
//   location_link?: string  // для водителя + shadow; на цену не влияет
// }
quoteRouter.post('/quote', async (req, res, next) => {
    try {
        const { product, rental_days, insurance, equipment, location_link, lang } = req.body ?? {};
        const rentalDays = Number(rental_days);

        const quote = await buildQuote({ product, rentalDays, insurance, equipment, lang });

        const link = typeof location_link === 'string' && location_link.trim() ? location_link.trim() : null;
        res.json({ data: { ...quote, location_link: link }, meta: { currency: 'IDR' } });

        // SHADOW (после ответа, fire-and-forget, не влияет на цену/не роняет запрос).
        if (link) {
            getCompanyId()
                .then((companyId) =>
                    collectShadowStats({
                        companyId,
                        locationLink: link,
                        rentalDays,
                        actualFeeIdr: quote.breakdown.delivery.fee_idr,
                        deliveryMode: quote.breakdown.delivery.mode,
                    })
                )
                .catch((e) => console.error('[delivery-shadow] trigger failed:', e?.message));
        }
    } catch (err) {
        next(err);
    }
});
