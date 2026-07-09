import { pool } from '../db/pool.js';
import { getActiveRuleSetId } from './ruleSet.js';
import { getCompanyId, getConfig } from './config.js';

// =====================================================================
// DELIVERY — расчёт стоимости доставки.
// Развилка режимов (ТЗ п.6.2): ядро диспетчеризуется по system_config
// 'delivery_mode'. Сейчас реализован только by_duration (по сроку аренды).
// by_distance (по дорогам через Google Distance API) — место зарезервировано,
// добавляется без переписывания этого модуля.
// =====================================================================

export const DELIVERY_MODES = { BY_DURATION: 'by_duration', BY_DISTANCE: 'by_distance' };
const CURRENCY = 'IDR';

export async function getDeliveryMode(companyId) {
    const mode = await getConfig(companyId, 'delivery_mode');
    return mode || DELIVERY_MODES.BY_DURATION;
}

export async function computeDeliveryFee({ rentalDays, companyCode = 'mdb_bali' }) {
    if (!Number.isInteger(rentalDays) || rentalDays < 1) {
        const err = new Error('rental_days must be a positive integer');
        err.status = 400;
        throw err;
    }
    const companyId = await getCompanyId(companyCode);
    const mode = await getDeliveryMode(companyId);

    switch (mode) {
        case DELIVERY_MODES.BY_DURATION:
            return byDuration(rentalDays, mode);
        case DELIVERY_MODES.BY_DISTANCE: {
            // Зарезервировано: расстояние ПО ДОРОГАМ через Google Distance API.
            const err = new Error('delivery_mode "by_distance" is not implemented yet');
            err.status = 501;
            throw err;
        }
        default: {
            const err = new Error(`Unknown delivery_mode: ${mode}`);
            err.status = 500;
            throw err;
        }
    }
}

// Тарифы по сроку — из delivery_fee_rules (config, версионируется rule_set'ом).
async function byDuration(rentalDays, mode) {
    const ruleSetId = await getActiveRuleSetId();
    const { rows } = await pool.query(
        `SELECT min_days, max_days, fee_idr, manager_approval
         FROM delivery_fee_rules
         WHERE rule_set_id = $1
           AND min_days <= $2
           AND (max_days IS NULL OR max_days >= $2)
         ORDER BY min_days
         LIMIT 1`,
        [ruleSetId, rentalDays]
    );
    if (rows.length === 0) {
        const err = new Error(`Нет правила доставки для ${rentalDays} дней`);
        err.status = 500;
        throw err;
    }
    const r = rows[0];
    return {
        mode,
        fee_idr: Number(r.fee_idr),
        currency: CURRENCY,
        free: Number(r.fee_idr) === 0,
        manager_approval: r.manager_approval,
        tier: { min_days: r.min_days, max_days: r.max_days },
    };
}
