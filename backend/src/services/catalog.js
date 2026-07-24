import { pool } from '../db/pool.js';
import { getActiveRuleSetId } from './ruleSet.js';

// =====================================================================
// CATALOG SERVICE — read-only витрина каталога (ТЗ: Website видит только
// клиентские данные, никогда внутреннее состояние флота).
// Никаких полей fleet_items (has_abs, internal_number, VIN, статусы,
// закупочные/юр.поля) здесь не выбирается — даже случайно.
// =====================================================================

const DEFAULT_LANG = 'en';
const CURRENCY = 'IDR';
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Цена-превью для карточки = цена за 30 дней. Выбор осознанный: цены за 1 день
// у большинства продуктов одинаковы (≈600k), поэтому day-1 не различал бы
// карточки и скрывал бы наценку ABS/Road Sync. Цена за 30 дней реально
// отличается между вариантами и отражает «месячную» стоимость, по которой
// сравнивают аренду на Бали. Значение реальное из price_rules, без деления.
const PREVIEW_DAYS = 30;

// --- кэш активных языков (меняются редко) ---
let activeLangs = null;
async function getActiveLanguages() {
    if (activeLangs) return activeLangs;
    const { rows } = await pool.query('SELECT code FROM languages WHERE is_active = TRUE');
    activeLangs = new Set(rows.map((r) => r.code));
    return activeLangs;
}

export async function resolveLanguage(requested) {
    const langs = await getActiveLanguages();
    return requested && langs.has(requested) ? requested : DEFAULT_LANG;
}

// --- человекочитаемое имя карточки ---
// variant — часть идентичности продукта (миграция 011). Показываем по-разному:
// Road Sync — это комплектация, читается как часть названия; ABS/CBS —
// технический подвид, выносим в скобки. has_abs клиенту НЕ отдаём.
function variantLabel(variant) {
    return variant && variant.trim() !== '' ? variant : null;
}

// Суффикс варианта (формат A, подтверждён): Road Sync — частью имени,
// ABS/CBS — в скобках. Добавляется к УЖЕ переведённому базовому имени
// (см. displayName), а НЕ вшит в него — поэтому переводная цепочка не
// ломается. ABS/CBS/Road Sync — международные обозначения и остаются как
// есть во всех языках; переводится базовое имя (модель+цвет).
function variantSuffix(variant) {
    if (!variant) return '';
    if (variant === 'Road Sync') return ` ${variant}`;
    return ` (${variant})`; // ABS / CBS
}

// Базовое имя из справочных полей — финальный fallback, когда перевода нет.
// brand/model — имена собственные (не переводятся), цвет пока из CRM.
function baseName(brand, model, color) {
    return `${brand} ${model} ${color}`.replace(/\s+/g, ' ').trim();
}

// Комплектация (equipment_variant) — часть идентичности Product (миграция 025),
// поэтому обязана различать карточки: без неё «+box»-Product совпал бы по имени
// с базовым. Метки английские (как ABS/CBS/Road Sync — международные), v1.
const EQUIPMENT_LABEL = {
    box: '+ Box',
    bracket: '+ Bracket',
    crashbar: '+ Crashbar',
    all_boxes: '+ All boxes',
    no_boxes: '− No boxes',
};
function equipmentSuffix(equipment) {
    return equipment && EQUIPMENT_LABEL[equipment] ? ` ${EQUIPMENT_LABEL[equipment]}` : '';
}

// Имя карточки = (переведённый title ИЛИ собранный base) + суффикс варианта.
// Контракт переводов: product_translations.title хранит базовое имя
// (модель+цвет) БЕЗ ABS/CBS/Road Sync — суффикс добавляет API единообразно,
// поэтому при заполнении переводов аббревиатура корректно встаёт к
// локализованному имени, а не теряется.
export function displayName(title, brand, model, color, variant, equipment) {
    return (title ?? baseName(brand, model, color)) + variantSuffix(variant) + equipmentSuffix(equipment);
}

function familyName(brand, model) {
    return `${brand} ${model}`.replace(/\s+/g, ' ').trim();
}

// =====================================================================
// GET /api/products
// =====================================================================
export async function listProducts({ lang, category, available } = {}) {
    const language = await resolveLanguage(lang);
    const ruleSetId = await getActiveRuleSetId();

    // Валидация фильтра category — отдаём явную ошибку, а не молча пустой список.
    if (category) {
        const { rows } = await pool.query('SELECT 1 FROM vehicle_categories WHERE code = $1', [category]);
        if (rows.length === 0) {
            const err = new Error(`Unknown category: ${category}`);
            err.status = 400;
            throw err;
        }
    }

    // available=true (Блок 5, виджет на главной) — только продукты, у которых
    // прямо сейчас есть хотя бы один fleet_item в статусе 'available'. Никаких
    // полей fleet_items наружу не идёт (см. комментарий выше) — только сам факт
    // наличия, тем же способом, что и остальная выдача каталога.
    const { rows } = await pool.query(
        `SELECT
            p.id, p.slug, p.color_name, p.variant, p.equipment_variant, p.is_bookable,
            p.archived_color, p.print_name, p.need_photos, p.updated_at,
            pf.code AS family_code, pf.brand, pf.model_name,
            vc.code AS category_code, vc.name AS category_name,
            COALESCE(t.title, ten.title) AS title,
            ph.storage_path AS ph_path, ph.cdn_url AS ph_cdn, ph.source_url AS ph_src,
            pr.price_idr AS preview_price
         FROM products p
         JOIN product_families pf ON pf.id = p.family_id AND pf.is_active = TRUE
         JOIN vehicle_categories vc ON vc.id = pf.category_id
         LEFT JOIN product_translations t   ON t.product_id   = p.id AND t.language_code   = $1
         LEFT JOIN product_translations ten ON ten.product_id = p.id AND ten.language_code = $2
         LEFT JOIN LATERAL (
             SELECT storage_path, cdn_url, source_url
             FROM product_photos WHERE product_id = p.id
             ORDER BY is_hero DESC, sort_order LIMIT 1
         ) ph ON TRUE
         LEFT JOIN price_rules pr
             ON pr.product_id = p.id AND pr.rental_days = $3 AND pr.rule_set_id = $4
         WHERE p.is_active = TRUE
           AND ($5::text IS NULL OR EXISTS (
               SELECT 1 FROM family_filter_categories ffc
               JOIN vehicle_categories fvc ON fvc.id = ffc.category_id
               WHERE ffc.family_id = pf.id AND fvc.code = $5))
           AND ($6::boolean IS NOT TRUE OR EXISTS (
               SELECT 1 FROM fleet_items fi WHERE fi.product_id = p.id AND fi.status = 'available'))
         ORDER BY pf.brand, pf.model_name, p.color_name, p.variant`,
        [language, DEFAULT_LANG, PREVIEW_DAYS, ruleSetId, category ?? null, available === true]
    );

    const data = rows.map((r) => ({
        id: r.id,
        slug: r.slug,
        name: displayName(r.title, r.brand, r.model_name, r.color_name, r.variant, r.equipment_variant),
        family: { code: r.family_code, name: familyName(r.brand, r.model_name) },
        color: r.color_name,
        variant: variantLabel(r.variant),
        category: { code: r.category_code, name: r.category_name },
        // hero-фото карточки: storage_path (+ опц. cdn override, + source_url для fallback).
        // URL с размером собирает фронт (resolvePhotoUrl). null → фронт решает placeholder/иконку.
        hero: (r.ph_path || r.ph_cdn || r.ph_src)
            ? { storage_path: r.ph_path, cdn_url: r.ph_cdn, source_url: r.ph_src }
            : null,
        archived_color: r.archived_color,
        print_name: r.print_name,
        need_photos: r.need_photos,
        updated_at: r.updated_at, // для sitemap lastmod
        is_bookable: r.is_bookable,
        // basis:'total' — сумма за весь период rental_days (30 дней), НЕ за
        // сутки. Фронт сам локализует "от 2500k / месяц" или "2500k за 30 дней".
        price_preview: r.preview_price == null
            ? null
            : { price_idr: Number(r.preview_price), rental_days: PREVIEW_DAYS, basis: 'total', currency: CURRENCY },
    }));

    return { data, meta: { count: data.length, language, currency: CURRENCY, category: category ?? null } };
}

// =====================================================================
// GET /api/products/:idOrSlug
// =====================================================================
export async function getProduct({ idOrSlug, lang } = {}) {
    const language = await resolveLanguage(lang);
    const ruleSetId = await getActiveRuleSetId();
    const byUuid = UUID_RE.test(idOrSlug);

    const { rows } = await pool.query(
        `SELECT
            p.id, p.slug, p.color_name, p.variant, p.equipment_variant, p.is_bookable,
            p.archived_color, p.print_name, p.need_photos,
            pf.id AS family_id, pf.code AS family_code, pf.brand, pf.model_name,
            vc.code AS category_code, vc.name AS category_name,
            COALESCE(t.title, ten.title) AS title,
            COALESCE(t.description, ten.description) AS description
         FROM products p
         JOIN product_families pf ON pf.id = p.family_id
         JOIN vehicle_categories vc ON vc.id = pf.category_id
         LEFT JOIN product_translations t   ON t.product_id   = p.id AND t.language_code   = $2
         LEFT JOIN product_translations ten ON ten.product_id = p.id AND ten.language_code = $3
         WHERE p.is_active = TRUE AND (${byUuid ? 'p.id = $1::uuid' : 'p.slug = $1'})`,
        [idOrSlug, language, DEFAULT_LANG]
    );
    if (rows.length === 0) return null;
    const r = rows[0];

    const [photos, specs, pricing, insurance] = await Promise.all([
        pool.query(
            `SELECT storage_path, cdn_url, source_url, is_hero, sort_order
             FROM product_photos WHERE product_id = $1 ORDER BY sort_order`,
            [r.id]
        ),
        // Specs — на уровне Family (одинаковы для всех цветов). Отдаём сырые
        // {key, value, source, sort_order}; label/unit/локализация КПП — на фронте (i18n).
        pool.query(
            `SELECT spec_key, spec_value, source, sort_order
             FROM family_specs WHERE family_id = $1 ORDER BY sort_order, spec_key`,
            [r.family_id]
        ),
        pool.query(
            `SELECT rental_days, price_idr FROM price_rules
             WHERE product_id = $1 AND rule_set_id = $2 ORDER BY rental_days`,
            [r.id, ruleSetId]
        ),
        pool.query(
            `SELECT kind, driver_exp, coverage_idr, monthly_idr, bali_only
             FROM insurance_plans WHERE rule_set_id = $1 ORDER BY kind, driver_exp`,
            [ruleSetId]
        ),
    ]);

    const theftRow = insurance.rows.find((i) => i.kind === 'theft');
    const data = {
        id: r.id,
        slug: r.slug,
        name: displayName(r.title, r.brand, r.model_name, r.color_name, r.variant, r.equipment_variant),
        description: r.description ?? null,
        family: { code: r.family_code, name: familyName(r.brand, r.model_name) },
        color: r.color_name,
        variant: variantLabel(r.variant),
        category: { code: r.category_code, name: r.category_name },
        is_bookable: r.is_bookable,
        archived_color: r.archived_color,
        print_name: r.print_name,
        need_photos: r.need_photos,
        photos: photos.rows.map((p) => ({
            storage_path: p.storage_path,
            cdn_url: p.cdn_url,
            source_url: p.source_url,
            is_hero: p.is_hero,
            sort_order: p.sort_order,
        })),
        specs: specs.rows.map((s) => ({
            key: s.spec_key,
            value: s.spec_value,
            source: s.source,
            sort_order: s.sort_order,
        })),
        pricing: {
            currency: CURRENCY,
            // Прямая таблица 1-30 дней (ТЗ п.6.1.1, без интерполяции).
            days: pricing.rows.map((d) => ({ rental_days: d.rental_days, price_idr: Number(d.price_idr) })),
            // >30 дней считается в приложении как price(30)/30 × N (CLAUDE.md §3.4).
            over_30_days_rule: 'price(30) / 30 × N',
        },
        insurance: {
            currency: CURRENCY,
            theft: theftRow
                ? { monthly_idr: Number(theftRow.monthly_idr), bali_only: theftRow.bali_only }
                : null,
            damage: insurance.rows
                .filter((i) => i.kind === 'damage')
                .map((i) => ({
                    driver_exp: i.driver_exp,
                    coverage_idr: i.coverage_idr == null ? null : Number(i.coverage_idr),
                    monthly_idr: Number(i.monthly_idr),
                })),
        },
    };

    return { data, meta: { language, currency: CURRENCY } };
}

// =====================================================================
// GET /api/families — линейки для фильтрации каталога
// =====================================================================
export async function listFamilies({ lang } = {}) {
    const language = await resolveLanguage(lang);

    const { rows } = await pool.query(
        `SELECT pf.code, pf.brand, pf.model_name,
                vc.code AS category_code, vc.name AS category_name,
                COUNT(p.id) FILTER (WHERE p.is_active) AS product_count
         FROM product_families pf
         JOIN vehicle_categories vc ON vc.id = pf.category_id
         LEFT JOIN products p ON p.family_id = pf.id
         WHERE pf.is_active = TRUE
         GROUP BY pf.id, pf.code, pf.brand, pf.model_name, vc.code, vc.name, vc.sort_order, pf.model_name
         ORDER BY vc.sort_order, pf.brand, pf.model_name`,
        []
    );

    const data = rows.map((r) => ({
        code: r.code,
        name: familyName(r.brand, r.model_name),
        brand: r.brand,
        model_name: r.model_name,
        category: { code: r.category_code, name: r.category_name },
        product_count: Number(r.product_count),
    }));

    return { data, meta: { count: data.length, language } };
}

// =====================================================================
// GET /api/categories — категории для чипов фильтра каталога.
// Счётчик продуктов — через family_filter_categories (M2M): модель,
// состоящая в нескольких категориях (TVS Ronin), считается в каждой.
// Возвращаем только непустые категории.
// =====================================================================
export async function listCategories({ lang } = {}) {
    const language = await resolveLanguage(lang);
    const { rows } = await pool.query(
        `SELECT vc.code, vc.name, vc.sort_order,
                COUNT(DISTINCT p.id) AS product_count
         FROM vehicle_categories vc
         JOIN family_filter_categories ffc ON ffc.category_id = vc.id
         JOIN product_families pf ON pf.id = ffc.family_id AND pf.is_active = TRUE
         JOIN products p ON p.family_id = pf.id AND p.is_active = TRUE
         GROUP BY vc.id, vc.code, vc.name, vc.sort_order
         HAVING COUNT(DISTINCT p.id) > 0
         ORDER BY vc.sort_order`
    );
    const data = rows.map((r) => ({
        code: r.code,
        name: r.name,
        product_count: Number(r.product_count),
    }));
    return { data, meta: { count: data.length, language } };
}
