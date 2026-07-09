import express from 'express';
import { env } from './config/env.js';
import { pool } from './db/pool.js';
import { catalogRouter } from './routes/catalog.js';
import { deliveryRouter } from './routes/delivery.js';
import { quoteRouter } from './routes/quote.js';
import { bookingRouter } from './routes/booking.js';
import { equipmentRouter } from './routes/equipment.js';

const app = express();
app.use(express.json());

app.get('/health', async (req, res) => {
    try {
        await pool.query('SELECT 1');
        res.json({ status: 'ok', db: 'connected' });
    } catch (err) {
        res.status(503).json({ status: 'error', message: err.message });
    }
});

app.use('/api', catalogRouter);
app.use('/api', deliveryRouter);
app.use('/api', quoteRouter);
app.use('/api', bookingRouter);
app.use('/api', equipmentRouter);

// Централизованный обработчик ошибок: err.status (напр. 400/404/501) или 500.
const ERROR_LABELS = { 400: 'bad_request', 404: 'not_found', 501: 'not_implemented' };
app.use((err, req, res, next) => {
    const status = err.status ?? 500;
    if (status >= 500) console.error(err);
    res.status(status).json({ error: ERROR_LABELS[status] ?? (status >= 500 ? 'internal_error' : 'error'), message: err.message });
});

app.listen(env.port, () => {
    console.log(`MDB Platform API listening on port ${env.port}`);
});
