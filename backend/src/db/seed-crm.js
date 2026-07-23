import path from 'node:path';
import { fileURLToPath } from 'node:url';
import ExcelJS from 'exceljs';
import { pool } from './pool.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SOURCE_PATH = path.join(__dirname, '..', '..', 'seed-data', 'crm-source.xlsx');
const COMPANY_CODE = 'mdb_bali';
const RULE_SET_LABEL = 'v1';

// ---------------------------------------------------------------------
// Бизнес-правила сопоставления CRM → схема (см. план, согласованный с
// Дмитрием 2026-06-29). Эти соответствия не выводятся из данных, поэтому
// зафиксированы здесь явно, а не угадываются эвристикой по строкам.
// ---------------------------------------------------------------------

// brand+model -> { code, brand, model_name, category_code }
// Порядок важен: первое совпадение в названии CRM побеждает.
const FAMILY_RULES = [
    { match: /road sync|^\s*\d+\.?\s*adv\b|^\s*\d+\.\s*adv\b/i, code: null }, // обрабатывается ниже по приоритету конкретных моделей
];

const FAMILY_DEFS = [
    { code: 'honda_adv', brand: 'Honda', model_name: 'ADV', category: 'honda_adv160', test: (n) => /\badv\b/i.test(n) },
    { code: 'honda_pcx', brand: 'Honda', model_name: 'PCX', category: 'honda_pcx160', test: (n) => /\bpcx\b/i.test(n) || /рсх/i.test(n) },
    { code: 'honda_vario', brand: 'Honda', model_name: 'Vario', category: 'honda_vario160', test: (n) => /\bvario\b/i.test(n) },
    { code: 'honda_cb150x', brand: 'Honda', model_name: 'CB150X', category: 'touring', test: (n) => /\bcb\s?150\s?x\b|\bcx150x\b/i.test(n) },
    { code: 'honda_cbr250rr', brand: 'Honda', model_name: 'CBR250RR', category: 'sport', test: (n) => /\bcbr\s?250/i.test(n) },
    { code: 'suzuki_vstrom250', brand: 'Suzuki', model_name: 'V-Strom 250', category: 'touring', test: (n) => /\bvstrom\b/i.test(n) },
    { code: 'morbidelli_c252v', brand: 'Morbidelli', model_name: 'C252V', category: 'cruiser', test: (n) => /\bc252v\b|\bmorbidelli\b/i.test(n) },
    { code: 'yamaha_nmax', brand: 'Yamaha', model_name: 'Nmax', category: 'yamaha_nmax155', test: (n) => /\bnmax\b/i.test(n) },
    { code: 'yamaha_xmax', brand: 'Yamaha', model_name: 'Xmax', category: 'yamaha_xmax250', test: (n) => /\bxmax\b/i.test(n) },
    { code: 'yamaha_xsr', brand: 'Yamaha', model_name: 'XSR', category: 'naked_classic', test: (n) => /\bxsr\b/i.test(n) },
    { code: 'yamaha_mt25', brand: 'Yamaha', model_name: 'MT-25', category: 'sport', test: (n) => /mt\s?25/i.test(n) || /мт\s?25/i.test(n) },
    { code: 'kawasaki_versys', brand: 'Kawasaki', model_name: 'Versys', category: 'touring', test: (n) => /\bversys\b/i.test(n) },
    { code: 'kawasaki_zx25r', brand: 'Kawasaki', model_name: 'ZX-25R', category: 'sport', test: (n) => /\bzx\s?25\s?r\b/i.test(n) },
    { code: 'tvs_ronin225', brand: 'TVS', model_name: 'Ronin 225', category: 'naked_classic', test: (n) => /\bronin\b/i.test(n) },
];

// Модели, у которых ABS физически есть всегда (CRM это часто не пишет явно).
const FORCED_ABS_FAMILY_CODES = new Set([
    'yamaha_xmax', 'suzuki_vstrom250', 'morbidelli_c252v', 'tvs_ronin225',
    'honda_cbr250rr', 'kawasaki_zx25r',
]);
const FORCED_ABS_NAME_TEST = (n) => /road sync/i.test(n);

// ---------------------------------------------------------------------
// Исправления ошибок в исходной CRM (источник — xlsx, его править нельзя:
// не в git, содержит перс.данные). Решения согласованы с Дмитрием 2026-06-29
// по итогам аудита ценовых коллизий.
// ---------------------------------------------------------------------
// Байк #46: в имени "PCX CBS Pink" (верно), но колонка тормозов ошибочно ABS.
// Имя — источник истины: тормоза CBS. После исправления попадает в CBS-продукт.
const BRAKE_OVERRIDES = { 46: 'CBS' };
// Байк #41: ошибочно записан как цвет "Green"; фактически "Light green" —
// отдельный цвет, отдельный продукт (этим снимается мнимая ценовая коллизия).
const COLOR_OVERRIDES = { 41: 'Light green' };

const isRoadSync = (bikeName) => /road sync/i.test(bikeName);

// variant Product'а внутри одного цвета (миграция 011). Road Sync — отдельная
// комплектация (дороже). ABS/CBS разделяют продукт ТОЛЬКО там, где для одного
// цвета сосуществуют обе версии (тогда у них разные цены) — определяется по
// данным (mixedBrakeColors), а не списком, поэтому одноваринтные цвета не
// дробятся. Family при этом остаётся общей.
function resolveVariant(bike, mixedBrakeColors) {
    if (bike.isRoadSync) return 'Road Sync';
    const colorKey = `${bike.familyDef.code}::${bike.color}`;
    if (mixedBrakeColors.has(colorKey)) return bike.hasAbs ? 'ABS' : 'CBS';
    return '';
}

// Цена продукта = ценовой вектор, общий для наибольшего числа его байков;
// при равенстве берём больший (по дню 30). Это и сохраняет цену ABS/Road Sync
// версий после разнесения, и реализует решение "год не влияет на каталог —
// берём максимум" для Nmax pink-blue, и гасит ошибочную цену #46 как редкий
// выброс внутри CBS-группы. Один прозрачный механизм без хардкода цен.
function pickPriceVector(vectors) {
    const groups = new Map();
    for (const v of vectors) {
        const key = v.map((x) => (x == null ? '' : x)).join(',');
        if (!groups.has(key)) groups.set(key, { vec: v, count: 0 });
        groups.get(key).count++;
    }
    const ranked = [...groups.values()].sort(
        (a, b) => b.count - a.count || (Number(b.vec[29] ?? 0) - Number(a.vec[29] ?? 0))
    );
    return ranked[0].vec;
}

function slugify(s) {
    return String(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
}

function resolveFamily(bikeName) {
    const def = FAMILY_DEFS.find((d) => d.test(bikeName));
    if (!def) throw new Error(`Не удалось определить модель для "${bikeName}"`);
    return def;
}

function resolveHasAbs(bikeName, familyDef, crmBrakeValue) {
    if (FORCED_ABS_FAMILY_CODES.has(familyDef.code) || FORCED_ABS_NAME_TEST(bikeName)) return true;
    const v = String(crmBrakeValue ?? '').trim().toLowerCase();
    if (v === 'abs') return true;
    if (v === 'cbs' || v === 'no') return false;
    throw new Error(`Не удалось определить ABS/CBS для "${bikeName}" (значение CRM: "${crmBrakeValue}")`);
}

// Нормализация цвета: убираем дубли пробелов/регистр не трогаем — цвет
// показывается клиенту как есть из CRM.
function normalizeColor(color) {
    return String(color).trim().replace(/\s+/g, ' ');
}

function cellValue(cell) {
    const v = cell.value;
    if (v == null) return null;
    if (typeof v === 'object') {
        if ('result' in v) return v.result;
        if ('text' in v) return v.text;
    }
    return v;
}

function rowValues(row, count) {
    const out = [];
    for (let i = 1; i <= count; i++) out.push(cellValue(row.getCell(i)));
    return out;
}

// ---------------------------------------------------------------------
// WAREHOUSE категории — по ключевым словам в названии позиции (Equip sheet)
// ---------------------------------------------------------------------
function resolveWarehouseCategory(name) {
    const n = name.toLowerCase();
    if (/oli|масл/.test(n) && !/rantai|filter/.test(n)) return 'oil';
    if (/kampas rem|колодк/.test(n)) return 'brake_pads';
    if (/ban (depan|belakang)|колес/.test(n)) return 'tires';
    if (/filter udara|воздушн.*фильтр/.test(n)) return 'filters';
    if (/v-belt/.test(n)) return 'transmission';
    if (/grips|грипс/.test(n)) return 'cosmetic';
    if (/battery|аккумулятор/.test(n)) return 'battery';
    if (/minyak rem/.test(n)) return 'brake_fluid';
    if (/phone holder|держател/.test(n)) return 'accessories';
    return 'other';
}

function resolveWarehouseBrand(name) {
    if (/yamaha/i.test(name)) return 'Yamaha';
    if (/honda/i.test(name)) return 'Honda';
    if (/kawasaki/i.test(name)) return 'Kawasaki';
    if (/suzuki/i.test(name)) return 'Suzuki';
    return null;
}

async function loadWorkbook() {
    const wb = new ExcelJS.Workbook();
    await wb.xlsx.readFile(SOURCE_PATH);
    return wb;
}

async function getCompanyId(client) {
    const { rows } = await client.query('SELECT id FROM companies WHERE code = $1', [COMPANY_CODE]);
    if (rows.length === 0) throw new Error(`Компания ${COMPANY_CODE} не найдена — примени миграции`);
    return rows[0].id;
}

async function getOrCreateRuleSet(client, companyId) {
    const existing = await client.query(
        'SELECT id FROM pricing_rule_sets WHERE company_id = $1 AND label = $2',
        [companyId, RULE_SET_LABEL]
    );
    if (existing.rows.length > 0) return existing.rows[0].id;
    const { rows } = await client.query(
        `INSERT INTO pricing_rule_sets (company_id, label, valid_from) VALUES ($1, $2, CURRENT_DATE) RETURNING id`,
        [companyId, RULE_SET_LABEL]
    );
    return rows[0].id;
}

async function getCategoryIds(client) {
    const { rows } = await client.query('SELECT id, code FROM vehicle_categories');
    return new Map(rows.map((r) => [r.code, r.id]));
}

// Каталог/цены/оборудование целиком производны от CRM и пока не имеют ни
// bookings, ни rentals. Поскольку продукты ре-партиционируются по variant
// (ABS/CBS/Road Sync), чистим прежний каталог в FK-безопасном порядке и
// пересобираем — иначе остались бы осиротевшие продукты со старыми ценами.
async function resetCatalog(client, companyId) {
    await client.query('DELETE FROM equipment_units');          // FK → fleet_items
    await client.query('DELETE FROM price_rules');              // FK → products
    await client.query('DELETE FROM fleet_items WHERE company_id = $1', [companyId]); // FK → products
    await client.query(
        'DELETE FROM products WHERE family_id IN (SELECT id FROM product_families WHERE company_id = $1)',
        [companyId]
    );
    await client.query('DELETE FROM product_families WHERE company_id = $1', [companyId]);
}

// ---------------------------------------------------------------------
// 1. FAMILIES + PRODUCTS + FLEET ITEMS — из "Prices by Day" (структура)
//    и "Summary" (юр./операционные поля), сопоставлены по номеру байка (1-56).
//    Продукт = family + цвет + variant (ABS/CBS/Road Sync, миграция 011).
//    Два прохода: сперва собираем все байки, чтобы (а) знать, для каких
//    цветов сосуществуют ABS и CBS, (б) выбрать цену продукта по всем его
//    байкам, а не по первому встреченному.
// ---------------------------------------------------------------------
async function seedFleetAndProducts(client, wb, companyId, categoryIds) {
    const pricesWs = wb.getWorksheet('Prices by Day');
    const summaryWs = wb.getWorksheet('Summary');

    await resetCatalog(client, companyId);

    // --- Проход 1: разобрать строки в записи байков ---
    const bikes = [];
    for (let r = 3; r <= pricesWs.rowCount; r++) {
        const row = pricesWs.getRow(r);
        const [num, bikeName, plate, , brake, color] = rowValues(row, 7);
        if (num == null || bikeName == null) continue;
        const n = Number(num);
        if (n < 1 || n > 56) continue;

        const familyDef = resolveFamily(bikeName);
        const brakeValue = BRAKE_OVERRIDES[n] ?? brake;
        const hasAbs = resolveHasAbs(bikeName, familyDef, brakeValue);
        const colorName = COLOR_OVERRIDES[n] ?? normalizeColor(color);
        const dayPrices = rowValues(row, 36).slice(6, 36); // дни 1..30

        bikes.push({ num: n, bikeName, plate, familyDef, hasAbs, color: colorName, dayPrices, isRoadSync: isRoadSync(bikeName) });
    }

    // Цвета, у которых для одной модели есть и ABS, и CBS байки — только их
    // продукт разделяется по тормозам.
    const brakeByColor = new Map();
    for (const b of bikes) {
        const key = `${b.familyDef.code}::${b.color}`;
        if (!brakeByColor.has(key)) brakeByColor.set(key, new Set());
        brakeByColor.get(key).add(b.hasAbs);
    }
    const mixedBrakeColors = new Set(
        [...brakeByColor.entries()].filter(([, set]) => set.size > 1).map(([k]) => k)
    );

    // --- Проход 2: сгруппировать байки в продукты по family+color+variant ---
    const groups = new Map(); // productKey -> { familyDef, color, variant, bikes:[] }
    for (const b of bikes) {
        b.variant = resolveVariant(b, mixedBrakeColors);
        const productKey = `${b.familyDef.code}::${b.color}::${b.variant}`;
        if (!groups.has(productKey)) {
            groups.set(productKey, { familyDef: b.familyDef, color: b.color, variant: b.variant, bikes: [] });
        }
        groups.get(productKey).bikes.push(b);
    }

    // --- Создать families ---
    const familyIdByCode = new Map();
    for (const b of bikes) {
        if (familyIdByCode.has(b.familyDef.code)) continue;
        const categoryId = categoryIds.get(b.familyDef.category);
        if (!categoryId) throw new Error(`Неизвестная категория ${b.familyDef.category}`);
        const { rows } = await client.query(
            `INSERT INTO product_families (company_id, category_id, code, brand, model_name)
             VALUES ($1, $2, $3, $4, $5)
             ON CONFLICT (company_id, code) DO UPDATE SET brand = EXCLUDED.brand
             RETURNING id`,
            [companyId, categoryId, b.familyDef.code, b.familyDef.brand, b.familyDef.model_name]
        );
        familyIdByCode.set(b.familyDef.code, rows[0].id);
    }

    // --- Создать products + price_rules, запомнить product_id по номеру байка ---
    const ruleSetId = await getOrCreateRuleSet(client, companyId);
    const productIdByBikeNum = new Map();
    for (const g of groups.values()) {
        const familyId = familyIdByCode.get(g.familyDef.code);
        const slug = slugify(`${g.familyDef.code}-${g.color}-${g.variant}`);
        const internalName = `${g.familyDef.model_name} ${g.color}${g.variant ? ` ${g.variant}` : ''}`;
        const { rows } = await client.query(
            `INSERT INTO products (family_id, color_name, variant, slug, internal_name)
             VALUES ($1, $2, $3, $4, $5)
             ON CONFLICT (family_id, color_name, variant) DO UPDATE SET internal_name = EXCLUDED.internal_name
             RETURNING id`,
            [familyId, g.color, g.variant, slug, internalName]
        );
        const productId = rows[0].id;

        const priceVector = pickPriceVector(g.bikes.map((b) => b.dayPrices));
        for (let day = 1; day <= 30; day++) {
            const price = priceVector[day - 1];
            if (price == null) continue;
            await client.query(
                `INSERT INTO price_rules (rule_set_id, product_id, rental_days, price_idr)
                 VALUES ($1, $2, $3, $4)
                 ON CONFLICT (rule_set_id, product_id, rental_days) DO UPDATE SET price_idr = EXCLUDED.price_idr`,
                [ruleSetId, productId, day, Math.round(Number(price) * 1000)]
            );
        }
        for (const b of g.bikes) productIdByBikeNum.set(b.num, productId);
    }

    // --- Создать fleet_items (юр./операционные поля из Summary) ---
    let fleetCount = 0;
    for (const b of bikes) {
        const productId = productIdByBikeNum.get(b.num);
        // Summary: заголовок=row2, данные с row4 → строка байка = num+3.
        const summaryRow = summaryWs.getRow(b.num + 3);
        const sv = rowValues(summaryRow, 41);
        const [
            , , purchaseDate, harga, owner, , , ownershipType, , plateNum, odo, , , ,
            rentUntil, , , , , , , comment, , , vin, , , , stnkUntil, , , phone,
            gpsImei, gpsUntil, simImei, activatedAt, email, bpkb,
        ] = sv;

        await client.query(
            `INSERT INTO fleet_items (
                company_id, product_id, internal_number, license_plate, vin, has_abs,
                stnk_expiry, bpkb_held_by, owner_name, ownership_type,
                purchase_date, purchase_price_idr, current_odo_km, rent_until_date,
                phone_number, gps_imei, gps_active_until, gps_sim_imei, sim_activated_at,
                linked_email, notes
            ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21)
            ON CONFLICT (company_id, internal_number) DO NOTHING`,
            [
                companyId, productId, b.num, b.plate ?? plateNum ?? `UNKNOWN-${b.num}`, vin ?? null, b.hasAbs,
                toDate(stnkUntil), bpkb != null ? String(bpkb) : null, owner ?? null, ownershipType ?? null,
                toDate(purchaseDate), harga != null ? Math.round(Math.abs(Number(harga)) * 1000) : null,
                odo != null ? Math.round(Number(odo)) : 0, toDate(rentUntil),
                phone ?? null, gpsImei != null ? String(gpsImei) : null, toDate(gpsUntil),
                simImei != null ? String(simImei) : null, toDate(activatedAt),
                email ?? null, comment ?? null,
            ]
        );
        fleetCount++;
    }

    return { familyCount: familyIdByCode.size, productCount: groups.size, fleetCount };
}

function toDate(v) {
    if (v == null) return null;
    if (v instanceof Date) return v;
    return null; // текстовые значения типа "Tahun 1" не являются датой — не угадываем
}

// ---------------------------------------------------------------------
// 2. WAREHOUSE ITEMS — лист "Equip" (расходники по остаткам)
// ---------------------------------------------------------------------
async function seedWarehouseItems(client, wb, companyId) {
    const ws = wb.getWorksheet('Equip');
    let count = 0;
    let seq = 0;
    for (let r = 3; r <= ws.rowCount; r++) {
        const row = ws.getRow(r);
        const [, , name, , stock] = rowValues(row, 5);
        if (name == null) continue;
        seq++;
        const code = `equip-${seq}-${String(name).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '')}`.slice(0, 60);
        await client.query(
            `INSERT INTO warehouse_items (company_id, code, name, category, compatible_brand, current_stock)
             VALUES ($1, $2, $3, $4, $5, $6)
             ON CONFLICT (company_id, code) DO UPDATE SET current_stock = EXCLUDED.current_stock`,
            [companyId, code, String(name), resolveWarehouseCategory(String(name)), resolveWarehouseBrand(String(name)), Number(stock) || 0]
        );
        count++;
    }
    return count;
}

// ---------------------------------------------------------------------
// 3. EQUIPMENT UNITS — листы "Helms" (KYT half/full face) и "Box" (SHAD).
//    Только остатки по типам, без привязки к fleet_items/клиентам: в CRM
//    имя байка на шлеме — временная пометка "кому сейчас выдан", не
//    постоянная структура. Связь шлем↔байк↔клиент возникает на уровне
//    Rental в момент выдачи (отдельная задача), не в сидинге каталога.
// ---------------------------------------------------------------------
async function getEquipmentTypeIds(client) {
    const { rows } = await client.query('SELECT id, code FROM equipment_types');
    return new Map(rows.map((r) => [r.code, r.id]));
}

// units: [{ status, fleetItemId, notes }]. Эти юниты целиком производные от
// CRM-листа (без fleet/rental связи — её ещё не существует для шлемов/боксов,
// а для креплений связь временная и будет уточнена руками после старта),
// поэтому при пересидинге безопасно пересчитать с нуля, а не накапливать
// дубли при изменении логики подсчёта.
async function insertUnitsDetailed(client, typeId, units) {
    await client.query('DELETE FROM equipment_units WHERE type_id = $1', [typeId]);
    let i = 0;
    for (const u of units) {
        i++;
        const unitNumber = String(i).padStart(3, '0');
        await client.query(
            `INSERT INTO equipment_units (type_id, unit_number, status, fleet_item_id, notes)
             VALUES ($1, $2, $3, $4, $5)
             ON CONFLICT (type_id, unit_number) DO NOTHING`,
            [typeId, unitNumber, u.status, u.fleetItemId ?? null, u.notes ?? null]
        );
    }
}

// Лист "Helms": секции отмечены маркерами "Half face"/"Full face" в столбце
// Helm; ниже идёт исторический список "Продал"/"Халффейс"/"Фуллфейс" —
// это пересданные/проданные позиции прошлых периодов, не текущий остаток,
// поэтому подсчёт останавливается на первом таком маркере.
async function seedHelmets(client, wb) {
    const ws = wb.getWorksheet('Helms');
    const typeIds = await getEquipmentTypeIds(client);
    const unitsByCode = { helmet_kyt_hf: [], helmet_kyt_ff: [] };
    let currentType = null;

    for (let r = 1; r <= ws.rowCount; r++) {
        const row = ws.getRow(r);
        const col2 = cellValue(row.getCell(2));
        const marker = String(col2 ?? '').trim();

        if (/^half face$/i.test(marker)) { currentType = 'helmet_kyt_hf'; continue; }
        if (/^full face$/i.test(marker)) { currentType = 'helmet_kyt_ff'; continue; }
        if (/продал|итого|total|халффейс|фуллфейс/i.test(marker)) { currentType = null; continue; }

        if (currentType && col2 != null) unitsByCode[currentType].push({ status: 'available', notes: null });
    }

    const counts = {};
    for (const [code, units] of Object.entries(unitsByCode)) {
        const typeId = typeIds.get(code);
        if (!typeId) throw new Error(`equipment_types.${code} не найден — проверь миграцию 003`);
        await insertUnitsDetailed(client, typeId, units);
        counts[code] = units.length;
    }
    return counts;
}

// Лист "Biasa": обычные (не KYT) шлемы — отдельный лист от "Helms". Тот же
// паттерн остатка: маркер "Total" отделяет текущий склад от исторического
// списка проданных/пересданных позиций ниже. Описание шлема из колонки
// "Helm" (напр. "Honda standart", "Белый MDS Magnum XL") кладём в notes —
// колонку "Motorbike" (временная пометка текущего держателя) не используем,
// как и для KYT.
async function seedBasicHelmets(client, wb) {
    const ws = wb.getWorksheet('Biasa');
    const typeIds = await getEquipmentTypeIds(client);
    const typeId = typeIds.get('helmet_biasa');
    if (!typeId) throw new Error('equipment_types.helmet_biasa не найден — проверь миграцию 003');

    const units = [];
    for (let r = 1; r <= ws.rowCount; r++) {
        const row = ws.getRow(r);
        const num = cellValue(row.getCell(1));
        const name = cellValue(row.getCell(2));
        const marker = String(name ?? '').trim();
        if (/^total$/i.test(marker)) break;
        if (typeof num !== 'number') continue;
        units.push({ status: 'available', notes: name != null ? String(name) : null });
    }
    await insertUnitsDetailed(client, typeId, units);
    return units.length;
}

// Лист "Box": кроме самих боксов (BOX SHAD.../Side box...) на листе вперемешку
// идут крепления (Bracket/Breket/Baseplate/Backrest — расходные кронштейны,
// не equipment_units) и, после маркера "Total"/"Продано", исторический список
// уже проданных позиций. Считаем только реальные кейсы (название содержит
// "box") до первого стоп-маркера; крепления вне схемы equipment_types —
// не сидируются.
async function seedShadBoxes(client, wb) {
    const ws = wb.getWorksheet('Box');
    const typeIds = await getEquipmentTypeIds(client);
    const typeId = typeIds.get('shad_box');
    if (!typeId) throw new Error('equipment_types.shad_box не найден — проверь миграцию 003');

    const units = [];
    for (let r = 1; r <= ws.rowCount; r++) {
        const row = ws.getRow(r);
        const num = cellValue(row.getCell(1));
        const name = cellValue(row.getCell(2));
        const marker = String(name ?? '').trim();
        if (/^total$/i.test(marker) || /продал|продано|итого/i.test(marker)) break;
        if (typeof num !== 'number' || name == null) continue;
        if (!/box/i.test(marker)) continue;
        units.push({ status: 'available', notes: null });
    }
    // Спец-случай (согласовано с Дмитрием 2026-06-29): строка "BOX SHAD
    // 33+Baseplate33" (Motorbike=Gudang) — без порядкового №, не вписывается
    // в обычный нумерованный формат, поэтому не попадает в цикл выше. Считаем
    // как один бокс 33L; встроенный в неё baseplate учтён отдельно в
    // seedMountingHardware.
    units.push({ status: 'available', notes: 'BOX SHAD 33+Baseplate33 (Gudang)' });

    await insertUnitsDetailed(client, typeId, units);
    return units.length;
}

// Лист "Box": крепления (Bracket/Breket/Baseplate/Backrest) вперемешку с
// самими SHAD-боксами (см. seedShadBoxes выше) и, после маркера
// "Total"/"Продано", историческим списком уже проданных позиций по старой
// нумерации — её не считаем. Подтип крепления подходит только своей модели
// байка, поэтому каждый код — отдельный equipment_type (миграция 010).
//
// Статус определяем по колонке "Motorbike": в отличие от шлемов, крепление
// стоит на байке полупостоянно, поэтому это надёжный признак:
//   "Gudang"/"Gudang. Новый"        -> available (склад)
//   "16.Nmax Keyless Black..."      -> installed, fleet_item_id по номеру 16
//                                      (та же конвенция "№.модель", что везде в CRM)
//   что-то иное (напр. "Викин Nmax",
//   имя человека без номера байка)  -> available без привязки, текст в notes
//                                      (согласовано с Дмитрием 2026-06-29 —
//                                      не угадывать, актуализировать позже руками)
const MOUNTING_DEFS = [
    { code: 'bracket_nmax', test: (n) => /bracket\s*nmax|breket\s*nmax/i.test(n) },
    { code: 'bracket_adv160', test: (n) => /bracket\s*adv\s?160/i.test(n) },
    { code: 'bracket_mt25', test: (n) => /bracket\s*mt\s?25/i.test(n) },
    { code: 'bracket_xsr', test: (n) => /bracket\s*[хx]sr/i.test(n) },
    { code: 'bracket_pcx160', test: (n) => /bracket\s*pcx\s?160/i.test(n) },
    { code: 'bracket_xmax', test: (n) => /bracket\s*xmax/i.test(n) || /bracket\s*хмах/i.test(n) },
    { code: 'backrest', test: (n) => /backrest/i.test(n) },
    { code: 'baseplate', test: (n) => /baseplate/i.test(n) },
];

async function seedMountingHardware(client, wb, companyId) {
    const ws = wb.getWorksheet('Box');
    const typeIds = await getEquipmentTypeIds(client);
    const { rows: fleetRows } = await client.query(
        'SELECT id, internal_number FROM fleet_items WHERE company_id = $1',
        [companyId]
    );
    const fleetByNumber = new Map(fleetRows.map((r) => [r.internal_number, r.id]));

    const unitsByCode = new Map();
    const push = (code, unit) => {
        if (!unitsByCode.has(code)) unitsByCode.set(code, []);
        unitsByCode.get(code).push(unit);
    };

    for (let r = 1; r <= ws.rowCount; r++) {
        const row = ws.getRow(r);
        const name = cellValue(row.getCell(2));
        const purchaseDate = cellValue(row.getCell(4));
        const motorbike = cellValue(row.getCell(5));
        const marker = String(name ?? '').trim();

        if (/^total$/i.test(marker) || /продал|продано|итого/i.test(marker)) break;
        if (name == null) continue;
        if (/box/i.test(marker)) continue; // SHAD-боксы (включая спец-случай "+Baseplate33") — отдельная функция
        if (!(purchaseDate instanceof Date)) continue; // строка-подытог категории (напр. "Bracket Nmax" + count), не юнит

        const def = MOUNTING_DEFS.find((d) => d.test(marker));
        if (!def) continue;

        const mb = String(motorbike ?? '').trim();
        const fleetMatch = mb.match(/^(\d+)\./);
        let unit;
        if (fleetMatch) {
            const fleetId = fleetByNumber.get(Number(fleetMatch[1]));
            if (!fleetId) throw new Error(`Крепление "${marker}": байк №${fleetMatch[1]} не найден среди fleet_items`);
            unit = { status: 'installed', fleetItemId: fleetId, notes: null };
        } else if (/^gudang/i.test(mb)) {
            unit = { status: 'available', fleetItemId: null, notes: null };
        } else {
            unit = { status: 'available', fleetItemId: null, notes: mb || null };
        }
        push(def.code, unit);
    }

    // Спец-случай (согласовано с Дмитрием 2026-06-29): baseplate, встроенный
    // в строку "BOX SHAD 33+Baseplate33" (Gudang) — учитываем отдельной
    // единицей склада, бокс сам по себе учтён в seedShadBoxes.
    push('baseplate', { status: 'available', fleetItemId: null, notes: 'встроен в SHAD box 33L (Gudang)' });

    const counts = {};
    for (const [code, units] of unitsByCode.entries()) {
        const typeId = typeIds.get(code);
        if (!typeId) throw new Error(`equipment_types.${code} не найден — проверь миграцию 010`);
        await insertUnitsDetailed(client, typeId, units);
        counts[code] = units.length;
    }
    return counts;
}

// ---------------------------------------------------------------------
// 4. INSURANCE PLANS — фиксированные тарифы из CLAUDE.md §4 (в CRM нет
//    отдельного листа со страховыми тарифами).
// ---------------------------------------------------------------------
async function seedInsurancePlans(client, ruleSetId) {
    // Чистим перед заливкой и пересобираем — единообразно с каталогом
    // (resetCatalog). ON CONFLICT здесь не работает как дедуп: у theft поля
    // driver_exp/coverage_idr = NULL, а NULL ≠ NULL в unique-индексе, поэтому
    // каждый прогон плодил бы новую строку theft. Строки полностью производны
    // от CLAUDE.md §4 и не имеют ещё связей (bookings/rentals), пересоздать
    // безопасно.
    await client.query('DELETE FROM insurance_plans WHERE rule_set_id = $1', [ruleSetId]);
    // Damage — матрица 2×2: уровень покрытия (1500k/4500k) × категория водителя
    // (experienced/inexperienced). monthly_idr — реальные помесячные тарифы
    // (согласованы с Дмитрием): покрытие НЕ равно цене (была ранняя заглушка).
    await client.query(
        `INSERT INTO insurance_plans (rule_set_id, kind, driver_exp, coverage_idr, monthly_idr, bali_only)
         VALUES
            ($1, 'theft',  NULL,            NULL,    400000,  TRUE),
            ($1, 'damage', 'experienced',   1500000, 500000,  FALSE),
            ($1, 'damage', 'experienced',   4500000, 750000,  FALSE),
            ($1, 'damage', 'inexperienced', 1500000, 700000,  FALSE),
            ($1, 'damage', 'inexperienced', 4500000, 1500000, FALSE)`,
        [ruleSetId]
    );
}

// ---------------------------------------------------------------------
// 6. DEPOSIT RULES — исключения из базового депозита (база — в system_config
//    standard_deposit_idr=1 000 000). ZX25R и Morbidelli при аренде <7 дней
//    (max_rental_days=6) — депозит 2 млн. Привязка к family_id (FK), не строкой.
// ---------------------------------------------------------------------
// Членство family в категориях фильтра каталога (M2M, миграция 017). Каждая
// модель — в своей первичной категории; TVS Ronin дополнительно в Neo-Retro
// Roadster (виден под обоими фильтрами). Идемпотентно.
async function seedFamilyFilterCategories(client, companyId) {
    await client.query(
        `DELETE FROM family_filter_categories
         WHERE family_id IN (SELECT id FROM product_families WHERE company_id = $1)`,
        [companyId]
    );
    // первичная категория каждой family
    await client.query(
        `INSERT INTO family_filter_categories (family_id, category_id)
         SELECT id, category_id FROM product_families WHERE company_id = $1`,
        [companyId]
    );
    // доп. членство: TVS Ronin → Neo-Retro Roadster (остаётся и в Naked/Classic)
    await client.query(
        `INSERT INTO family_filter_categories (family_id, category_id)
         SELECT pf.id, vc.id
         FROM product_families pf, vehicle_categories vc
         WHERE pf.company_id = $1 AND pf.code = 'tvs_ronin225' AND vc.code = 'neo_retro_roadster'
         ON CONFLICT DO NOTHING`,
        [companyId]
    );
    // доп. членство: Yamaha MT-25 → Naked/Classic (остаётся и в Sport, решение владельца)
    await client.query(
        `INSERT INTO family_filter_categories (family_id, category_id)
         SELECT pf.id, vc.id
         FROM product_families pf, vehicle_categories vc
         WHERE pf.company_id = $1 AND pf.code = 'yamaha_mt25' AND vc.code = 'naked_classic'
         ON CONFLICT DO NOTHING`,
        [companyId]
    );
}

// Группа взаимозаменяемости для будущей Replacement Matrix (миграция 029,
// CLAUDE.md §3.1) — независимо от фильтров каталога (family_filter_categories
// выше). Идемпотентно (UPDATE по фиксированному списку кодов).
async function seedReplacementGroups(client, companyId) {
    await client.query(
        `UPDATE product_families
         SET replacement_group_id = (SELECT id FROM replacement_groups WHERE code = 'scooter_econ_160')
         WHERE company_id = $1 AND code IN ('honda_adv', 'honda_pcx', 'honda_vario', 'yamaha_nmax')`,
        [companyId]
    );
}

async function seedDepositRules(client, companyId) {
    await client.query('DELETE FROM deposit_rules WHERE company_id = $1', [companyId]);
    const { rows } = await client.query(
        `SELECT id, code FROM product_families
         WHERE company_id = $1 AND code IN ('kawasaki_zx25r', 'morbidelli_c252v')`,
        [companyId]
    );
    const idByCode = new Map(rows.map((r) => [r.code, r.id]));
    for (const code of ['kawasaki_zx25r', 'morbidelli_c252v']) {
        const familyId = idByCode.get(code);
        if (!familyId) throw new Error(`Family ${code} не найдена для deposit_rules`);
        await client.query(
            `INSERT INTO deposit_rules (company_id, family_id, max_rental_days, deposit_idr, priority, note)
             VALUES ($1, $2, 6, 2000000, 10, $3)`,
            [companyId, familyId, `${code}: депозит 2 млн при аренде <7 дней`]
        );
    }
}

// ---------------------------------------------------------------------
// 5. DELIVERY FEE RULES — тарифы доставки по СРОКУ аренды (config, версия
//    в rule_set). Значения согласованы с Дмитрием: <7 дней — 150k;
//    7-14 — 100k; свыше 14 — бесплатно. Идемпотентно (DELETE + insert).
// ---------------------------------------------------------------------
async function seedDeliveryFeeRules(client, ruleSetId) {
    await client.query('DELETE FROM delivery_fee_rules WHERE rule_set_id = $1', [ruleSetId]);
    await client.query(
        `INSERT INTO delivery_fee_rules (rule_set_id, min_days, max_days, fee_idr, note)
         VALUES
            ($1, 1, 6, 150000, 'до недели (<7 дней)'),
            ($1, 7, 14, 100000, '7-14 дней'),
            ($1, 15, NULL, 0, 'свыше 14 дней — бесплатно')`,
        [ruleSetId]
    );
}

async function main() {
    const client = await pool.connect();
    try {
        const wb = await loadWorkbook();
        const companyId = await getCompanyId(client);
        const categoryIds = await getCategoryIds(client);
        const ruleSetId = await getOrCreateRuleSet(client, companyId);

        await client.query('BEGIN');

        const fleetStats = await seedFleetAndProducts(client, wb, companyId, categoryIds);
        console.log(`Families: ${fleetStats.familyCount}, Products: ${fleetStats.productCount}, Fleet items: ${fleetStats.fleetCount}`);

        await seedFamilyFilterCategories(client, companyId);
        console.log('Family filter categories seeded.');

        await seedReplacementGroups(client, companyId);
        console.log('Replacement groups seeded.');

        const warehouseCount = await seedWarehouseItems(client, wb, companyId);
        console.log(`Warehouse items: ${warehouseCount}`);

        const helmetCounts = await seedHelmets(client, wb);
        console.log(`Equipment units — helmets: HF ${helmetCounts.helmet_kyt_hf}, FF ${helmetCounts.helmet_kyt_ff}`);

        const boxCount = await seedShadBoxes(client, wb);
        console.log(`Equipment units — SHAD boxes: ${boxCount}`);

        const basicHelmetCount = await seedBasicHelmets(client, wb);
        console.log(`Equipment units — helmet_biasa: ${basicHelmetCount}`);

        const mountingCounts = await seedMountingHardware(client, wb, companyId);
        console.log('Equipment units — mounting hardware:', mountingCounts);

        await seedInsurancePlans(client, ruleSetId);
        console.log('Insurance plans seeded.');

        await seedDeliveryFeeRules(client, ruleSetId);
        console.log('Delivery fee rules seeded.');

        await seedDepositRules(client, companyId);
        console.log('Deposit rules seeded.');

        await client.query('COMMIT');
        console.log('CRM seed complete.');
    } catch (err) {
        await client.query('ROLLBACK');
        throw err;
    } finally {
        client.release();
        await pool.end();
    }
}

main().catch((err) => {
    console.error(err);
    process.exit(1);
});
