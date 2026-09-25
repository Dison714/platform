import { Router } from 'express';
import { listAddonOptions } from '../services/equipment.js';
import { publicGetLimiter } from '../middleware/rateLimit.js';

export const equipmentRouter = Router();

// GET /api/equipment — список доп-опций (оборудование + страховка) для
// отрисовки чекбоксами на сайте. Только клиентские поля, без внутренних.
equipmentRouter.get('/equipment', publicGetLimiter, async (req, res, next) => {
    try {
        const data = await listAddonOptions(req.query.lang);
        res.json({ data, meta: { currency: 'IDR' } });
    } catch (err) {
        next(err);
    }
});
