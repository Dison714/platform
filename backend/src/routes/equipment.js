import { Router } from 'express';
import { listAddonOptions } from '../services/equipment.js';

export const equipmentRouter = Router();

// GET /api/equipment — список доп-опций (оборудование + страховка) для
// отрисовки чекбоксами на сайте. Только клиентские поля, без внутренних.
equipmentRouter.get('/equipment', async (req, res, next) => {
    try {
        const data = await listAddonOptions(req.query.lang);
        res.json({ data, meta: { currency: 'IDR' } });
    } catch (err) {
        next(err);
    }
});
