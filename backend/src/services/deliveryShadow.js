import { pool } from '../db/pool.js';
import { getConfig } from './config.js';

// =====================================================================
// DELIVERY SHADOW — теневой сбор статистики по локации (shadow mode).
// Назначение: материал для проверки гипотезы by_distance ДО перехода на неё.
// ГАРАНТИИ: не влияет на цену клиента, не задерживает ответ (вызывается
// после res.json, без await), НИКОГДА не бросает в вызывающий код — любая
// ошибка пишется в delivery_shadow_stats как fail.
// =====================================================================

const EXPAND_TIMEOUT_MS = 5000;

// Точка входа: всегда резолвится, никогда не реджектится.
export function collectShadowStats(args) {
    return runShadow(args).catch((err) => {
        // Подстраховка: даже непредвиденная ошибка не должна всплыть.
        console.error('[delivery-shadow] unexpected error:', err?.message);
    });
}

async function runShadow({ companyId, bookingId = null, locationLink, rentalDays, actualFeeIdr, deliveryMode }) {
    let expandSuccess = false;
    let expandError = null;
    let lat = null;
    let lng = null;
    let distanceKm = null;
    let zone = null;
    let shadowFee = null;

    try {
        const finalUrl = await expandLink(locationLink);
        const coords = extractCoords(finalUrl) || extractCoords(locationLink);
        if (!coords) {
            expandError = 'coords_not_found';
        } else {
            expandSuccess = true;
            lat = coords.lat;
            lng = coords.lng;
            // Расстояние/зона/цена считаются только если задана база (иначе
            // shadow-расстояние «временно отключено», координаты всё равно пишем).
            const base = await getBaseCoords(companyId);
            if (base) {
                distanceKm = haversineKm(base, coords);
                const z = pickZone(await getShadowZones(companyId), distanceKm);
                if (z) {
                    zone = z.zone ?? null;
                    shadowFee = z.fee_idr ?? null;
                }
            }
        }
    } catch (e) {
        expandError = e?.name === 'AbortError' ? 'network_timeout' : (e?.message || 'unknown_error');
    }

    // Пишем строку в любом случае — и success, и fail (fail = материал тоже).
    try {
        await pool.query(
            `INSERT INTO delivery_shadow_stats
                (company_id, booking_id, location_link, expand_success, expand_error,
                 extracted_lat, extracted_lng, distance_km, distance_zone, shadow_fee_idr,
                 actual_fee_idr, rental_days, delivery_mode)
             VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)`,
            [companyId, bookingId, locationLink, expandSuccess, expandError,
             lat, lng, distanceKm, zone, shadowFee, actualFeeIdr, rentalDays ?? null, deliveryMode]
        );
    } catch (e) {
        console.error('[delivery-shadow] stat write failed:', e?.message);
    }
}

// Разворачивает короткую ссылку (maps.app.goo.gl и т.п.), следуя редиректам.
// Таймаут, чтобы не висеть; сеть может быть закрыта в песочнице — тогда throw.
async function expandLink(url) {
    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), EXPAND_TIMEOUT_MS);
    try {
        const res = await fetch(url, { method: 'GET', redirect: 'follow', signal: ctrl.signal });
        return res.url || url;
    } finally {
        clearTimeout(timer);
    }
}

// Извлекает координаты из разных форматов ссылок Google Maps.
export function extractCoords(url) {
    if (!url) return null;
    let m;
    if ((m = url.match(/@(-?\d+\.\d+),(-?\d+\.\d+)/))) return { lat: +m[1], lng: +m[2] };           // .../@lat,lng,zoom
    if ((m = url.match(/!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)/))) return { lat: +m[1], lng: +m[2] };        // data=!3dlat!4dlng
    if ((m = url.match(/[?&](?:q|ll|query|destination|center)=(-?\d+\.\d+),(-?\d+\.\d+)/)))           // ?q=lat,lng
        return { lat: +m[1], lng: +m[2] };
    return null;
}

// Расстояние по прямой (haversine), км. Реальный by_distance будет считать по дорогам.
function haversineKm(a, b) {
    const R = 6371;
    const toRad = (d) => (d * Math.PI) / 180;
    const dLat = toRad(b.lat - a.lat);
    const dLng = toRad(b.lng - a.lng);
    const s = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(a.lat)) * Math.cos(toRad(b.lat)) * Math.sin(dLng / 2) ** 2;
    return Math.round(R * 2 * Math.asin(Math.sqrt(s)) * 1000) / 1000;
}

async function getBaseCoords(companyId) {
    const c = await getConfig(companyId, 'delivery_base_coords');
    if (c && typeof c.lat === 'number' && typeof c.lng === 'number') return { lat: c.lat, lng: c.lng };
    return null;
}

async function getShadowZones(companyId) {
    const z = await getConfig(companyId, 'delivery_shadow_km_zones');
    if (!Array.isArray(z)) return [];
    // max_km === null = открытая верхняя зона (">N км"), всегда последняя.
    return [...z].sort((a, b) => {
        if (a.max_km == null) return 1;
        if (b.max_km == null) return -1;
        return a.max_km - b.max_km;
    });
}

function pickZone(zones, km) {
    for (const z of zones) if (z.max_km == null || km <= z.max_km) return z;
    return null; // зоны не заданы — не угадываем
}
