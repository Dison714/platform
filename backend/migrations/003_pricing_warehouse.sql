-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 03_pricing_warehouse.sql
-- Rule Sets (versioning) · Price Rules · Delivery · Insurance · Equipment · Warehouse
-- =====================================================================
-- Rental Engine — сердце Platform (ТЗ п.6). Версионирование (п.6.7):
-- все тарифные сущности привязаны к rule_sets с valid_from/valid_to, чтобы
-- старые Booking воспроизводились по правилам момента бронирования.
-- =====================================================================

-- ---------------------------------------------------------------------
-- RULE SETS — единая версионируемая обёртка для ВСЕХ тарифов (ТЗ п.6.7)
-- Один rule_set покрывает price/delivery/insurance согласованно — чтобы
-- Booking фиксировал ровно одну версию всех правил.
-- ---------------------------------------------------------------------
CREATE TABLE pricing_rule_sets (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id    UUID NOT NULL REFERENCES companies(id),
    label         TEXT NOT NULL,           -- 'v1', '2026.1'
    valid_from    DATE NOT NULL,
    valid_to      DATE,                    -- NULL = активная
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (company_id, label)
);
COMMENT ON TABLE pricing_rule_sets IS 'ТЗ п.6.7: версионирование бизнес-логики. Booking хранит pricing_rule_set_id на момент создания — старые расчёты воспроизводятся по тогдашним правилам. Единый набор покрывает цены/доставку/страховку согласованно.';

-- ---------------------------------------------------------------------
-- PRICE RULES — цена по дням 1-30 на Product (ТЗ п.6.1.1)
-- >30 дней: price(30)/30 × N — в коде приложения, не в БД (решение D1).
-- Источник сидирования: лист "Prices by Day".
-- ---------------------------------------------------------------------
CREATE TABLE price_rules (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_set_id   UUID NOT NULL REFERENCES pricing_rule_sets(id) ON DELETE CASCADE,
    product_id    UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    rental_days   SMALLINT NOT NULL CHECK (rental_days BETWEEN 1 AND 30),
    price_idr     BIGINT NOT NULL,
    UNIQUE (rule_set_id, product_id, rental_days)
);
COMMENT ON TABLE price_rules IS 'ТЗ п.6.1.1: прямая таблица цена(дни) 1-30, без интерполяции. >30 = price(30)/30×N в приложении. Сид из листа "Prices by Day" текущей CRM (решение D1).';

CREATE INDEX idx_price_rules_lookup ON price_rules(rule_set_id, product_id, rental_days);

-- ---------------------------------------------------------------------
-- DELIVERY FEE RULES (ТЗ п.6.2)
-- ---------------------------------------------------------------------
CREATE TABLE delivery_fee_rules (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_set_id       UUID NOT NULL REFERENCES pricing_rule_sets(id) ON DELETE CASCADE,
    min_days          SMALLINT NOT NULL,
    max_days          SMALLINT,                  -- NULL = без верха
    fee_idr           BIGINT NOT NULL,           -- 0 = бесплатно
    manager_approval  BOOLEAN NOT NULL DEFAULT FALSE,
    note              TEXT
);
COMMENT ON TABLE delivery_fee_rules IS 'Доставка по СРОКУ аренды (решение Дмитрия, переопределяет ТЗ п.6.2): <7 дней — 150k; 7-14 дней — 100k; свыше 14 — бесплатно. manager_approval зарезервирован под удалённые районы (будущий by_distance). Сидируется в seed-crm.js рядом с ценами.';

-- ---------------------------------------------------------------------
-- INSURANCE PLANS (ТЗ п.6.3)
-- ---------------------------------------------------------------------
CREATE TABLE insurance_plans (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_set_id      UUID NOT NULL REFERENCES pricing_rule_sets(id) ON DELETE CASCADE,
    kind             insurance_kind NOT NULL,
    driver_exp       driver_experience,         -- NULL для theft
    coverage_idr     BIGINT,                    -- NULL для theft
    monthly_idr      BIGINT NOT NULL,
    bali_only        BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (rule_set_id, kind, driver_exp, coverage_idr)
);
COMMENT ON TABLE insurance_plans IS 'ТЗ п.6.3. Theft: 400k/мес, bali_only=TRUE, единый тариф. Damage: 1500k/4500k покрытие × experienced/inexperienced. Категория водителя (п.6.3.3): возраст<33 ИЛИ малый стаж = inexperienced; порог в system_config.';

-- ---------------------------------------------------------------------
-- EQUIPMENT (ТЗ п.6.4) — типы + индивидуальные экземпляры (решение D5)
-- ---------------------------------------------------------------------
CREATE TABLE equipment_types (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code                 TEXT UNIQUE NOT NULL,
    name                 TEXT NOT NULL,
    tracks_units         BOOLEAN NOT NULL DEFAULT FALSE,   -- TRUE → есть equipment_units
    charge_basis         charge_basis NOT NULL DEFAULT 'per_rental',
    rental_price_idr     BIGINT NOT NULL DEFAULT 0,        -- тариф клиенту
    purchase_price_idr   BIGINT,                            -- себестоимость (Finance)
    deposit_deduction_idr BIGINT,                           -- списание при утере/повреждении (п.6.8.2)
    deduction_note       TEXT,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE equipment_types IS 'ТЗ п.6.4.1: тариф клиенту (rental_price_idr) отдельно от deposit_deduction_idr (списание, п.6.8.2). charge_basis = per_rental/per_month настраивается на тип (п.6.4.2). tracks_units=TRUE для шлемов/SHAD (решение D5).';

INSERT INTO equipment_types (code, name, tracks_units, charge_basis, rental_price_idr, deposit_deduction_idr, deduction_note) VALUES
    ('helmet_biasa','Helm biasa', TRUE, 'per_rental', 0, 200000, NULL),
    ('helmet_kyt_hf','Helm KYT half face', TRUE, 'per_rental', 150000, 500000, 'вариант 450k — см. админку'),
    ('helmet_kyt_ff','Helm KYT full face', TRUE, 'per_rental', 150000, 600000, 'вариант 550k; 2 шт = 250k'),
    ('raincoat','Jas hujan', FALSE, 'per_rental', 0, 100000, 'испорчен или утерян'),
    ('cloth','Lap (тряпка)', FALSE, 'per_rental', 0, 30000, 'испорчен или утерян'),
    ('helmet_bag','Tas helm', FALSE, 'per_rental', 0, 50000, 'испорчен или утерян'),
    ('visor_kyt','Visor KYT', TRUE, 'per_rental', 0, 150000, 'много царапин / 1 крупная'),
    ('visor_biasa','Visor helm biasa', TRUE, 'per_rental', 0, 50000, 'новые царапины'),
    ('phone_holder','Dudukan telepon', FALSE, 'per_rental', 0, 150000, 'испорчен или утерян'),
    ('shad_box','SHAD топкейс', TRUE, 'per_rental', 200000, NULL, 'доп. задний багажник; 200k за весь срок');

CREATE TYPE equipment_unit_status AS ENUM ('available','with_client','maintenance','lost','retired');

CREATE TABLE equipment_units (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type_id       UUID NOT NULL REFERENCES equipment_types(id) ON DELETE RESTRICT,
    unit_number   TEXT NOT NULL,                 -- стикер-номер шлема / номер SHAD
    status        equipment_unit_status NOT NULL DEFAULT 'available',
    fleet_item_id UUID REFERENCES fleet_items(id),  -- если закреплён (SHAD на bracket)
    notes         TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (type_id, unit_number)
);
COMMENT ON TABLE equipment_units IS 'Индивидуальные экземпляры с номерами: шлемы (стикер-номер), SHAD-боксы (база знаний разделы "Шлемы", "PASANG KOTAK SHAD"). Решение D5 — отдельно от warehouse_items (расходники по остаткам).';

-- ---------------------------------------------------------------------
-- WAREHOUSE — расходники по остаткам (решение D5)
-- ---------------------------------------------------------------------
CREATE TABLE warehouse_items (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id      UUID NOT NULL REFERENCES companies(id),
    code            TEXT NOT NULL,
    name            TEXT NOT NULL,
    category        TEXT,                  -- oil, brake_pads, tires, filters, cosmetic, helmet_parts
    compatible_brand TEXT,
    unit            TEXT NOT NULL DEFAULT 'pcs',
    thread_ref      TEXT,                  -- # топика в чате склада (база знаний: каждая позиция = тред)
    current_stock   INTEGER NOT NULL DEFAULT 0,
    min_stock_alert INTEGER NOT NULL DEFAULT 0,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (company_id, code)
);
COMMENT ON TABLE warehouse_items IS 'Расходники по остаткам (масла, колодки, шины, запчасти). База знаний "СКЛАД (GUDANG)". current_stock — кэш, источник истины — stock_movements. thread_ref хранит # топика чата склада для совместимости с текущим процессом.';

CREATE TYPE stock_move_type AS ENUM ('received','used','adjustment','lost');

CREATE TABLE stock_movements (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_item_id UUID NOT NULL REFERENCES warehouse_items(id) ON DELETE RESTRICT,
    move_type       stock_move_type NOT NULL,
    qty_change      INTEGER NOT NULL,
    fleet_item_id   UUID REFERENCES fleet_items(id),
    driver_task_id  UUID,                  -- FK добавляется в 05 после driver_tasks
    performed_by    UUID REFERENCES users(id),
    note            TEXT,
    photo_url       TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE stock_movements IS 'Журнал движений склада. Формат базы знаний: "Ganti oli PCX pink DK6480KBI. Total sisa = 5 btl". photo_url — фото обязательно при использовании.';

CREATE INDEX idx_stock_mov_item ON stock_movements(warehouse_item_id);
