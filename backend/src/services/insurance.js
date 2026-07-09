import { pool } from '../db/pool.js';
import { getActiveRuleSetId } from './ruleSet.js';
import { getCompanyId, getConfig } from './config.js';
import { ceilMonths } from './pricing.js';

const VALID_COVERAGE = [1500000, 4500000];

// Категория водителя (ТЗ п.6.3.3): inexperienced, если ВОЗРАСТ < порога
// (system_config.driver_inexperienced_age_max, по умолчанию 33; строго меньше)
// ИЛИ нет прав ИЛИ малый стаж. Любой из критериев независимо → inexperienced.
export async function determineDriverCategory(driver) {
    const companyId = await getCompanyId();
    const ageMax = Number(await getConfig(companyId, 'driver_inexperienced_age_max')) || 33;
    const age = driver?.age;
    const youngerThanThreshold = typeof age === 'number' && age < ageMax;
    const noLicense = driver?.has_license === false;
    const lowExperience = driver?.experienced === false;
    return youngerThanThreshold || noLicense || lowExperience ? 'inexperienced' : 'experienced';
}

// Страховка целыми месяцами (округление вверх). theft и/или damage — опционально.
export async function computeInsurance(insuranceInput, rentalDays) {
    if (!insuranceInput) return null;
    const wantsTheft = insuranceInput.theft === true;
    const wantsDamage = !!insuranceInput.damage;
    if (!wantsTheft && !wantsDamage) return null;

    const ruleSetId = await getActiveRuleSetId();
    const months = ceilMonths(rentalDays);
    const { rows: plans } = await pool.query(
        `SELECT kind, driver_exp, coverage_idr, monthly_idr, bali_only
         FROM insurance_plans WHERE rule_set_id = $1`,
        [ruleSetId]
    );

    let theft = null;
    let damage = null;
    let total = 0;

    if (wantsTheft) {
        const p = plans.find((r) => r.kind === 'theft');
        if (!p) { const e = new Error('Нет тарифа theft'); e.status = 500; throw e; }
        const t = Number(p.monthly_idr) * months;
        theft = { monthly_idr: Number(p.monthly_idr), months, total_idr: t, bali_only: p.bali_only };
        total += t;
    }

    if (wantsDamage) {
        const coverage = Number(insuranceInput.damage.coverage_idr);
        if (!VALID_COVERAGE.includes(coverage)) {
            const e = new Error(`Недопустимое покрытие damage: ${coverage}. Допустимо: ${VALID_COVERAGE.join(', ')}`);
            e.status = 400;
            throw e;
        }
        if (!insuranceInput.driver) {
            const e = new Error('Для damage нужны параметры водителя (driver: age / has_license / experienced)');
            e.status = 400;
            throw e;
        }
        const category = await determineDriverCategory(insuranceInput.driver);
        const p = plans.find(
            (r) => r.kind === 'damage' && r.driver_exp === category && Number(r.coverage_idr) === coverage
        );
        if (!p) { const e = new Error(`Нет тарифа damage для ${category}/${coverage}`); e.status = 500; throw e; }
        const t = Number(p.monthly_idr) * months;
        damage = {
            driver_category: category,
            coverage_idr: coverage,
            monthly_idr: Number(p.monthly_idr),
            months,
            total_idr: t,
        };
        total += t;
    }

    return { months, theft, damage, total_idr: total };
}
