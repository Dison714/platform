import express from 'express';
import { env } from './config/env.js';
import { pool } from './db/pool.js';
import { catalogRouter } from './routes/catalog.js';
import { deliveryRouter } from './routes/delivery.js';
import { quoteRouter } from './routes/quote.js';
import { bookingRouter } from './routes/booking.js';
import { webEventsRouter } from './routes/webEvents.js';
import { equipmentRouter } from './routes/equipment.js';
import { seasonalMultipliersRouter } from './routes/seasonalMultipliers.js';
import { insuranceAdminRouter } from './routes/insuranceAdmin.js';
import { deliveryAdminRouter } from './routes/deliveryAdmin.js';
import { depositAdminRouter } from './routes/depositAdmin.js';
import { replacementGroupsAdminRouter } from './routes/replacementGroupsAdmin.js';
import { blogRouter } from './routes/blog.js';
import { blogAdminRouter } from './routes/blogAdmin.js';
import { requireInternalToken } from './middleware/internalAuth.js';

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

// Лёгкая liveness-проверка без похода в БД — процесс поднят, event loop жив.
// /health (выше) — readiness (реально готов обслуживать трафик, БД доступна).
app.get('/health/live', (req, res) => {
    res.json({ status: 'ok' });
});

app.use('/api', catalogRouter);
app.use('/api', deliveryRouter);
app.use('/api', quoteRouter);
app.use('/api', bookingRouter);
app.use('/api', webEventsRouter);
app.use('/api', equipmentRouter);
app.use('/api', blogRouter);
// deliveryAdminRouter должен быть смонтирован ДО любого
// app.use('/api', requireInternalToken, ...) ниже: requireInternalToken там
// навешан на весь путь '/api' (не на конкретный роутер), значит он
// перехватывает ЛЮБОЙ непойманный выше запрос под /api/*, включая тот, что
// на самом деле предназначен deliveryAdminRouter, если смонтировать его
// после первого такого шлюза. GET /delivery-fee-rules читает сам продуктовый
// сайт (bikes/[slug]/page.js — калькулятор доставки, JSON-LD
// shippingDetails) и должен остаться публичным; POST/PUT/DELETE внутри
// deliveryAdmin.js гейтятся requireInternalToken точечно, на уровне
// конкретного route-handler'а — так это работает независимо от порядка
// монтирования.
app.use('/api', deliveryAdminRouter);
// Configuration First admin-разделы (ТЗ п.12) — за requireInternalToken.
// Публичные роуты выше (catalog/delivery/quote/booking/equipment/delivery-
// admin's GET) им не защищены и не должны быть — их дёргает сам сайт.
app.use('/api', requireInternalToken, seasonalMultipliersRouter);
app.use('/api', requireInternalToken, insuranceAdminRouter);
app.use('/api', requireInternalToken, depositAdminRouter);
app.use('/api', requireInternalToken, replacementGroupsAdminRouter);
app.use('/api', requireInternalToken, blogAdminRouter);

// Централизованный обработчик ошибок: err.status (напр. 400/404/409/501) или 500.
const ERROR_LABELS = { 400: 'bad_request', 404: 'not_found', 409: 'conflict', 501: 'not_implemented' };
app.use((err, req, res, next) => {
    const status = err.status ?? 500;
    if (status >= 500) console.error(err);
    res.status(status).json({ error: ERROR_LABELS[status] ?? (status >= 500 ? 'internal_error' : 'error'), message: err.message });
});

// Явный биндинг на все интерфейсы — обязателен в контейнере (Coolify/Docker
// пробрасывают порт снаружи на 0.0.0.0, не на loopback).
app.listen(env.port, '0.0.0.0', () => {
    console.log(`MDB Platform API listening on port ${env.port}`);
});
