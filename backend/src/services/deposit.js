import { pool } from '../db/pool.js';
import { getCompanyId, getConfig } from './config.js';

// Депозит (возвращаемый залог, НЕ входит в "к оплате"). База — из
// system_config.standard_deposit_idr; исключения — deposit_rules по family+сроку
// (напр. ZX25R/Morbidelli при <7 дней = 2 млн). Привязка к family_id (FK).
export async function computeDeposit(familyId, rentalDays) {
    const companyId = await getCompanyId();

    const { rows } = await pool.query(
        `SELECT deposit_idr, note FROM deposit_rules
         WHERE company_id = $1 AND family_id = $2
           AND (max_rental_days IS NULL OR $3 <= max_rental_days)
         ORDER BY priority DESC LIMIT 1`,
        [companyId, familyId, rentalDays]
    );
    if (rows.length > 0) {
        return {
            amount_idr: Number(rows[0].deposit_idr),
            refundable: true,
            rule: 'family_short_term',
            note: rows[0].note ?? null,
        };
    }

    const base = Number(await getConfig(companyId, 'standard_deposit_idr')) || 1000000;
    return { amount_idr: base, refundable: true, rule: 'base', note: null };
}
