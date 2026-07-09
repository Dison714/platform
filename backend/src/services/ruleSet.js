import { pool } from '../db/pool.js';

// Текущий действующий ценовой rule_set (ТЗ п.6.7: версионирование цен/доставки/
// страховки одним набором). На v1 — одна компания, один набор (valid_to IS NULL).
export async function getActiveRuleSetId() {
    const { rows } = await pool.query(
        `SELECT id FROM pricing_rule_sets
         WHERE valid_from <= now() AND (valid_to IS NULL OR valid_to > now())
         ORDER BY valid_from DESC LIMIT 1`
    );
    if (rows.length === 0) throw new Error('Нет действующего pricing_rule_set');
    return rows[0].id;
}
