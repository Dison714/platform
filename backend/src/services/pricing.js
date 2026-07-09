import { pool } from '../db/pool.js';
import { getActiveRuleSetId } from './ruleSet.js';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Округление срока вверх до целых месяцев (ВВЕРХ): 1-30 дней = 1 мес,
// 31-60 = 2 мес. Общая логика для страховки и помесячного оборудования.
export function ceilMonths(rentalDays) {
    return Math.max(1, Math.ceil(rentalDays / 30));
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
// (CLAUDE.md §3.4, считается в коде, не в БД).
export async function computeBaseRental(productId, rentalDays) {
    const ruleSetId = await getActiveRuleSetId();

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
        return { rental_days: rentalDays, price_idr: Number(rows[0].price_idr), note: 'direct' };
    }

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
    return {
        rental_days: rentalDays,
        price_idr: Math.round((price30 / 30) * rentalDays),
        note: 'price(30)/30×N',
    };
}
