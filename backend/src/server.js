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
import { locationPagesRouter } from './routes/locationPages.js';
import { requireInternalToken } from './middleware/internalAuth.js';

const app = express();
// Единственный обратный прокси — Traefik (Coolify), в той же Docker-сети
// 'coolify' (см. rateLimit.js). Без этого req.ip был бы IP Traefik-контейнера
// для ВСЕГО публичного трафика — rate limit по IP не мог бы отличить внешних
// клиентов друг от друга, а internal-network skip ошибочно захватывал бы и
// прокси реального внешнего трафика.
// РОВНО 1 хоп, не `true` — `true` доверяет X-Forwarded-For от кого угодно
// без ограничения глубины; express-rate-limit v7 явно валидирует это и
// деградирует до общего на всех ключа (ERR_ERL_PERMISSIVE_TRUST_PROXY,
// найдено при верификации на dev 2026-09-25 — реальный 429 после 5-6
// запросов вместо заявленных 300, все клиенты схлопывались в один counter).
// `1` — ровно то, что рекомендует сам Express при одном прокси перед
// приложением: доверяет самому правому (последнему добавленному) значению
// X-Forwarded-For, остальное игнорирует.
app.set('trust proxy', 1);
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

// API layer v1.0 (сессия 2026-09-25/26) — версионированный префикс.
// Единственный потребитель непроверсионированного /api/* был наш же код
// (фронтенд, см. фронтенд-правки того же коммита) — атомарный cutover,
// без периода параллельной поддержки старых путей (внешних клиентов на
// них не было, см. аудит API-слоя от 25.09).
const API_PREFIX = '/api/v1';

// Rate limiting (publicGetLimiter/quoteLimiter/bookingsLimiter) — НЕ здесь.
// app.use(prefix, mw, router) вешает mw на ВЕСЬ путь-префикс, а не на
// конкретный маршрут внутри router: любой запрос, не совпавший с более
// ранним роутером, проваливается СКВОЗЬ него дальше по цепочке (тот же
// механизм, что ниже объясняет обязательный порядок deliveryAdminRouter
// перед requireInternalToken-шлюзами). Найдено при верификации на dev
// 2026-09-25: обычный GET /api/v1/equipment реально проходил через
// publicGetLimiter (catalog-mount), затем через quoteLimiter И
// bookingsLimiter (мимо, но СЧИТАЕТСЯ) перед тем как equipmentRouter его
// наконец обслуживал — крошечный бюджет /api/v1/bookings (5/10мин)
// вычерпывался обычным каталожным трафиком. Лимитеры навешаны точечно на
// конкретный route внутри каждого router-файла (catalog.js/equipment.js/
// blog.js/locationPages.js/deliveryAdmin.js/quote.js/routes/booking.js),
// не здесь.
app.use(API_PREFIX, catalogRouter);
app.use(API_PREFIX, deliveryRouter);
app.use(API_PREFIX, quoteRouter);
app.use(API_PREFIX, bookingRouter);
app.use(API_PREFIX, webEventsRouter);
app.use(API_PREFIX, equipmentRouter);
app.use(API_PREFIX, blogRouter);
app.use(API_PREFIX, locationPagesRouter);
// deliveryAdminRouter должен быть смонтирован ДО любого
// app.use(API_PREFIX, requireInternalToken, ...) ниже: requireInternalToken там
// навешан на весь путь API_PREFIX (не на конкретный роутер), значит он
// перехватывает ЛЮБОЙ непойманный выше запрос под /api/v1/*, включая тот, что
// на самом деле предназначен deliveryAdminRouter, если смонтировать его
// после первого такого шлюза. GET /delivery-fee-rules читает сам продуктовый
// сайт (bikes/[slug]/page.js — калькулятор доставки, JSON-LD
// shippingDetails) и должен остаться публичным; POST/PUT/DELETE внутри
// deliveryAdmin.js гейтятся requireInternalToken точечно, на уровне
// конкретного route-handler'а — так это работает независимо от порядка
// монтирования.
app.use(API_PREFIX, deliveryAdminRouter);
// Configuration First admin-разделы (ТЗ п.12) — за requireInternalToken.
// Публичные роуты выше (catalog/delivery/quote/booking/equipment/delivery-
// admin's GET) им не защищены и не должны быть — их дёргает сам сайт.
app.use(API_PREFIX, requireInternalToken, seasonalMultipliersRouter);
app.use(API_PREFIX, requireInternalToken, insuranceAdminRouter);
app.use(API_PREFIX, requireInternalToken, depositAdminRouter);
app.use(API_PREFIX, requireInternalToken, replacementGroupsAdminRouter);
app.use(API_PREFIX, requireInternalToken, blogAdminRouter);

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
