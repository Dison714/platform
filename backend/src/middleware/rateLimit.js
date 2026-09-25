import rateLimit from 'express-rate-limit';

// API layer v1.0 (сессия 2026-09-25/26). Пороги калиброваны по реальному
// трафику сайта (GA4/Windsor, последние 30 дней на момент проектирования):
// пик 51 сессия/день, ≤2 booking_form_submit/день — с большим запасом
// сверху, не впритык (см. аудит API-слоя от 25.09).

// Docker-сеть 'coolify' (подтверждено `docker network inspect coolify` на
// проде, 2026-09-25): frontend (10.0.1.10) и backend (10.0.1.11) — один и
// тот же контейнерный IP-диапазон. SSR-трафик фронтенда (sitemap.js,
// [locale]/page.js и т.п., API_BASE_URL=http://mdb-backend:3000) идёт
// НАПРЯМУЮ на backend, минуя Traefik — легитимный, потенциально залповый
// (генерация sitemap проходит по всем товарам × 11 локалям почти
// одновременно). Публичный внешний трафик тоже физически проходит через
// тот же Docker-сегмент (Traefik → backend), но приходит с TRUSTED
// X-Forwarded-For (см. `app.set('trust proxy', ...)` в server.js) — req.ip
// после этого — реальный внешний IP клиента, не адрес Traefik. Поэтому
// проверка "IP из 10.0.1.0/24" ловит ИМЕННО прямые внутренние вызовы
// (frontend → backend без Traefik), а не внешних клиентов, проксированных
// через Traefik по той же docker-сети.
const INTERNAL_NETWORK_PREFIX = '10.0.1.';

function isInternalNetworkIp(ip) {
    if (!ip) return false;
    // ::ffff:10.0.1.10 (IPv4-mapped IPv6) — тот же адрес, другая запись.
    const normalized = ip.startsWith('::ffff:') ? ip.slice(7) : ip;
    return normalized.startsWith(INTERNAL_NETWORK_PREFIX);
}

const RATE_LIMIT_HEADERS = { standardHeaders: true, legacyHeaders: false };

// Публичные GET-каталог/блог/districts (catalog/equipment/blog/location-
// pages/delivery-fee-rules GET). Порог — на 2 порядка выше наблюдаемой
// органики (пик 51 сессия/день ≈ 2/час), не режет реальных посетителей,
// режет флуд/скрейпинг. skip — не-GET (сами эти роутеры смешивают методы,
// напр. deliveryAdminRouter; их write-пути уже защищены
// requireInternalToken отдельно) и внутренний Docker-трафик.
export const publicGetLimiter = rateLimit({
    windowMs: 5 * 60 * 1000,
    limit: 300,
    ...RATE_LIMIT_HEADERS,
    skip: (req) => req.method !== 'GET' || isInternalNetworkIp(req.ip),
    message: { error: 'rate_limited', message: 'Too many requests, slow down.' },
});

// POST /api/v1/quote — калькулятор дебаунсит 400мс между вводами; активная
// правка формы теоретически даёт наиболее интенсивную минуту порядка
// нескольких десятков запросов. Порог — с запасом сверху этого сценария.
// Не вызывается из SSR — skip по internal-сети не нужен.
export const quoteLimiter = rateLimit({
    windowMs: 60 * 1000,
    limit: 40,
    ...RATE_LIMIT_HEADERS,
    message: { error: 'rate_limited', message: 'Too many quote requests, slow down.' },
});

// POST /api/v1/bookings — самое узкое место: 0 авторизации по умолчанию +
// реальный побочный эффект (Telegram менеджеру и водителям на каждый
// успешный POST). Порог режет спам/DoS-по-Telegram, а не capacity — при
// ≤2 заявках/день с сайта запас на легитимные повторные попытки (сетевая
// ошибка, повторный сабмит) не требует высокого порога.
export const bookingsLimiter = rateLimit({
    windowMs: 10 * 60 * 1000,
    limit: 5,
    ...RATE_LIMIT_HEADERS,
    message: { error: 'rate_limited', message: 'Too many booking attempts, please contact us directly.' },
});
