import { pool } from '../db/pool.js';
import { ceilMonths } from './pricing.js';
import { getActiveRuleSetId } from './ruleSet.js';

const CURRENCY = 'IDR';

// Доступные клиенту допы для отрисовки чекбоксами на сайте: оборудование
// (только is_customer_addon, без внутренней фурнитуры) + страховка (виды/тарифы).
// Внутренние поля (закупка, списание с депозита) НЕ отдаются — только то, что
// нужно для выбора: название, цена аренды, тип тарификации.
const DEFAULT_LANG = 'en';

export async function listAddonOptions(lang = DEFAULT_LANG) {
    const ruleSetId = await getActiveRuleSetId();

    // Имя локализуем: COALESCE(перевод[lang] → перевод[en] → базовое name).
    const { rows: eq } = await pool.query(
        `SELECT et.code,
                COALESCE(tl.name, te.name, et.name) AS name,
                et.charge_basis, et.rental_price_idr, et.addon_group
         FROM equipment_types et
         LEFT JOIN equipment_type_translations tl ON tl.equipment_type_id = et.id AND tl.language_code = $1
         LEFT JOIN equipment_type_translations te ON te.equipment_type_id = et.id AND te.language_code = 'en'
         WHERE et.is_customer_addon = TRUE AND et.is_active = TRUE
         ORDER BY et.addon_group, et.rental_price_idr, name`,
        [lang]
    );
    const equipment = eq.map((r) => ({
        code: r.code,
        name: r.name,
        addon_group: r.addon_group,          // helmet | topcase | other — для группировки на фронте
        charge_basis: r.charge_basis,        // per_rental | per_month
        rental_price_idr: Number(r.rental_price_idr),
        currency: CURRENCY,
    }));

    const { rows: plans } = await pool.query(
        `SELECT kind, driver_exp, coverage_idr, monthly_idr, bali_only
         FROM insurance_plans WHERE rule_set_id = $1
         ORDER BY kind, coverage_idr, driver_exp`,
        [ruleSetId]
    );
    const theftPlan = plans.find((p) => p.kind === 'theft');
    // Damage группируем по покрытию: фронт выбирает уровень покрытия, цена
    // зависит от категории водителя (определяется на расчёте /api/quote).
    const byCoverage = new Map();
    for (const p of plans.filter((p) => p.kind === 'damage')) {
        const cov = Number(p.coverage_idr);
        if (!byCoverage.has(cov)) {
            byCoverage.set(cov, { coverage_idr: cov, currency: CURRENCY, experienced: null, inexperienced: null });
        }
        byCoverage.get(cov)[p.driver_exp] = { monthly_idr: Number(p.monthly_idr) };
    }

    const insurance = {
        charge_basis: 'per_month', // считается целыми месяцами вверх (ceil(дни/30))
        theft: theftPlan
            ? { monthly_idr: Number(theftPlan.monthly_idr), bali_only: theftPlan.bali_only, currency: CURRENCY }
            : null,
        damage: [...byCoverage.values()].sort((a, b) => a.coverage_idr - b.coverage_idr),
    };

    return { equipment, insurance };
}

// Оборудование (опционально). Тариф из equipment_types.charge_basis:
//   per_rental — фиксировано за весь срок;
//   per_month  — помесячно, с тем же округлением вверх, что у страховки.
const HELMET_CAP = 2; // на байк ровно 2 слота под шлемы — потолок

export async function computeEquipment(equipmentInput, rentalDays, lang = DEFAULT_LANG) {
    if (!Array.isArray(equipmentInput) || equipmentInput.length === 0) return null;

    const months = ceilMonths(rentalDays);
    const codes = equipmentInput.map((e) => e?.code);
    // Имя — в локали клиента (тот же резолв, что в /api/equipment): это имя
    // ляжет в снимок и в уведомление менеджеру (которое целиком на locale заявки).
    const { rows } = await pool.query(
        `SELECT et.code,
                COALESCE(tl.name, te.name, et.name) AS name,
                et.charge_basis, et.rental_price_idr, et.addon_group
         FROM equipment_types et
         LEFT JOIN equipment_type_translations tl ON tl.equipment_type_id = et.id AND tl.language_code = $2
         LEFT JOIN equipment_type_translations te ON te.equipment_type_id = et.id AND te.language_code = 'en'
         WHERE et.code = ANY($1)`,
        [codes, lang]
    );
    const byCode = new Map(rows.map((r) => [r.code, r]));

    const items = [];
    let total = 0;
    let helmetQty = 0; // суммарно по группе helmet — сервер сам ограничивает потолок
    for (const sel of equipmentInput) {
        const t = byCode.get(sel?.code);
        if (!t) { const e = new Error(`Неизвестное оборудование: ${sel?.code}`); e.status = 400; throw e; }
        const qty = Number.isInteger(sel.quantity) && sel.quantity > 0 ? sel.quantity : 1;
        if (t.addon_group === 'helmet') helmetQty += qty;
        const unit = Number(t.rental_price_idr);
        const perMonth = t.charge_basis === 'per_month';
        const lineTotal = perMonth ? unit * months * qty : unit * qty;
        items.push({
            code: t.code,
            name: t.name,
            charge_basis: t.charge_basis,
            unit_price_idr: unit,
            quantity: qty,
            ...(perMonth ? { months } : {}),
            total_idr: lineTotal,
        });
        total += lineTotal;
    }

    // Источник правды по потолку шлемов — сервер: блокирует и подделанное тело
    // (>2 шлема), а не только UI. Багажник/прочее в группу helmet не входят.
    if (helmetQty > HELMET_CAP) {
        const e = new Error(`Maximum ${HELMET_CAP} helmets per bike`);
        e.status = 400;
        throw e;
    }

    return { items, total_idr: total };
}
