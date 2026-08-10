import { Router } from 'express';
import { recordWebEvent } from '../services/webEvents.js';

export const webEventsRouter = Router();

// POST /api/web-events — вызывается из frontend/src/middleware.js (не из
// браузера напрямую), fire-and-forget при редиректе с голого домена.
// Отвечает сразу, запись в БД — best-effort внутри recordWebEvent.
webEventsRouter.post('/web-events', (req, res) => {
    const { event_code, metadata } = req.body ?? {};
    recordWebEvent(event_code, metadata);
    res.status(202).json({ data: { accepted: true } });
});
