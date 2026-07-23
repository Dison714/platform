import { pool } from '../db/pool.js';
import { getActiveRuleSetId } from './ruleSet.js';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Округление срока вверх до целых месяцев (ВВЕРХ): 1-30 дней = 1 мес,
// 31-60 = 2 мес. Общая логика для страховки и помесячного оборудования.
export function ceilMonths(rentalDays) {
    return Math.max(1, Math.ceil(rentalDays / 30));
}

// Округление итоговой цены ВВЕРХ до 50 000 IDR (решение владельца, Блок 2:
// сезонный мультипликатор) — единая точка, источник истины бэкенд, фронт
// округление не дублирует.
export function roundUpTo50k(amountIdr) {
    return Math.ceil(amountIdr / 50000) * 50000;
}

// Активный сезонный мультипликатор на ДАТУ НАЧАЛА аренды (конец не
// учитывается, CLAUDE.md решение Блока 2). Без startDate (каталог/форма без
// дат) — множитель 1 (мультипликатор не применяется). scoped (по
// pricing_rule_set_id) и global (NULL) никогда не пересекаются по датам
// (см. триггер check_seasonal_multiplier_overlap), поэтому здесь ORDER BY —
// просто defensive tie-break, не смысловой выбор.
async function getSeasonalMultiplier(ruleSetId, startDate) {
    if (!startDate) return 1;
    const { rows } = await pool.query(
        `SELECT multiplier FROM seasonal_multipliers
         WHERE date_from <= $2 AND date_to >= $2
           AND (pricing_rule_set_id = $1 OR pricing_rule_set_id IS NULL)
         ORDER BY pricing_rule_set_id NULLS LAST
         LIMIT 1`,
        [ruleSetId, startDate]
    );
    return rows.length ? Number(rows[0].multiplier) : 1;
}

// Находит активный (витринный) продукт по id или slug.
export async function findProduct(idOrSlug) {
    const byUuid = UUID_RE.test(idOrSlug);
    const { rows } = await pool.query(
        `SELECT p.id, p.slug, p.color_name, p.variant, p.family_id,
                pf.brand, pf.model_name, pf.code AS family_code
         FROM products p
         JOIN product_families pf ON pf.id = p.family_id
         WHERE p.is_active = TRUE AND (${byUuid ? 'p.id = $1::uuid' : 'p.slug = $1'})`,
        [idOrSlug]
    );
    return rows[0] ?? null;
}

// База аренды: 1-30 дней — напрямую из price_rules; >30 — price(30)/30 × N
// (CLAUDE.md §3.4, считается в коде, не в БД). startDate (опц.) — дата
// начала аренды, для сезонного мультипликатора (Блок 2); без неё —
// множитель 1, цена как есть (кроме округления до 50к, применяется всегда).
export async function computeBaseRental(productId, rentalDays, startDate = null) {
    const ruleSetId = await getActiveRuleSetId();

    let base;
    if (rentalDays <= 30) {
        const { rows } = await pool.query(
            `SELECT price_idr FROM price_rules
             WHERE rule_set_id = $1 AND product_id = $2 AND rental_days = $3`,
            [ruleSetId, productId, rentalDays]
        );
        if (rows.length === 0) {
            const err = new Error(`Нет цены для ${rentalDays} дней`);
            err.status = 500;
            throw err;
        }
        base = { rental_days: rentalDays, price_idr: Number(rows[0].price_idr), note: 'direct' };
    } else {
        const { rows } = await pool.query(
            `SELECT price_idr FROM price_rules
             WHERE rule_set_id = $1 AND product_id = $2 AND rental_days = 30`,
            [ruleSetId, productId]
        );
        if (rows.length === 0) {
            const err = new Error('Нет цены за 30 дней для расчёта >30');
            err.status = 500;
            throw err;
        }
        const price30 = Number(rows[0].price_idr);
        base = {
            rental_days: rentalDays,
            price_idr: Math.round((price30 / 30) * rentalDays),
            note: 'price(30)/30×N',
        };
    }

    const multiplier = await getSeasonalMultiplier(ruleSetId, startDate);
    const finalPrice = roundUpTo50k(base.price_idr * multiplier);
    return {
        ...base,
        price_idr: finalPrice,
        ...(multiplier !== 1 ? { seasonal_multiplier: multiplier } : {}),
    };
}
