-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 02_catalog_fleet.sql
-- Product Family → Product → Fleet Item · Replacement Matrix · Specs · i18n
-- =====================================================================
-- ТЗ п.3.1 — самое важное правило проекта. Трёхуровневая модель.
-- =====================================================================

-- ---------------------------------------------------------------------
-- VEHICLE CATEGORIES — справочник категорий (база знаний п.5.2)
-- Выделено в таблицу, а не enum: категории и их взаимозаменяемость —
-- бизнес-конфигурация, меняется без миграции (Configuration First).
-- ---------------------------------------------------------------------
CREATE TABLE vehicle_categories (
    id          SMALLSERIAL PRIMARY KEY,
    code        TEXT UNIQUE NOT NULL,   -- scooter_160, maxi_scooter, touring, naked_classic, sport
    name        TEXT NOT NULL,
    sort_order  SMALLINT NOT NULL DEFAULT 0
);
COMMENT ON TABLE vehicle_categories IS 'База знаний п.5.2: scooter_160 (PCX/Nmax/ADV/Vario взаимозаменяемы), maxi_scooter (Xmax), touring (Vstrom/Versys), naked_classic (XSR/Ronin), sport (ZX25R/CBR250). Прямая взаимозаменяемость внутри категории — через эту таблицу; межкатегорийные апгрейды — через replacement_matrix.';

INSERT INTO vehicle_categories (code, name, sort_order) VALUES
    ('scooter_160', 'Scooter 160cc', 1),
    ('maxi_scooter', 'Maxi Scooter', 2),
    ('touring', 'Touring / Enduro', 3),
    ('naked_classic', 'Naked / Classic', 4),
    ('sport', 'Sport', 5);

-- ---------------------------------------------------------------------
-- PRODUCT FAMILY — линейка модели (Honda ADV)
-- ---------------------------------------------------------------------
CREATE TABLE product_families (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id   UUID NOT NULL REFERENCES companies(id),
    category_id  SMALLINT NOT NULL REFERENCES vehicle_categories(id),
    code         TEXT NOT NULL,            -- honda_adv, yamaha_nmax
    brand        TEXT NOT NULL,
    model_name   TEXT NOT NULL,
    engine_cc    SMALLINT,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (company_id, code)
);
COMMENT ON TABLE product_families IS 'ТЗ п.3.1: уровень нужен для агрегатной аналитики "все Honda ADV" одним запросом, без ручного сложения по цветам.';

-- ---------------------------------------------------------------------
-- PRODUCT — модель+цвет, то что бронирует клиент
-- ---------------------------------------------------------------------
CREATE TABLE products (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id         UUID NOT NULL REFERENCES product_families(id) ON DELETE RESTRICT,
    color_name        TEXT NOT NULL,
    slug              TEXT NOT NULL,
    internal_name     TEXT NOT NULL,           -- "Имя байка для клиента" из CRM
    cover_photo_url   TEXT,
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,
    is_bookable       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (family_id, color_name)
);
COMMENT ON TABLE products IS 'ТЗ п.3.1: модель+цвет. Ровно один Product = одна карточка на сайте. Свои фото/цена/характеристики. CRM работает с тем же Product, без преобразований сайт↔CRM.';

CREATE UNIQUE INDEX uq_products_slug ON products(slug);

CREATE TABLE product_translations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id      UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    language_code   TEXT NOT NULL REFERENCES languages(code),
    title           TEXT NOT NULL,
    description     TEXT,
    seo_title       TEXT,
    seo_description TEXT,
    url_path        TEXT,                 -- локализованный путь (ТЗ п.4.9.3)
    UNIQUE (product_id, language_code)
);

-- Характеристики (ТЗ: у Product свои характеристики, локализуемые п.4.9.3)
CREATE TABLE product_specs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id  UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    spec_key    TEXT NOT NULL,            -- engine_cc, seat_height_mm, fuel_tank_l
    spec_value  TEXT NOT NULL,
    sort_order  SMALLINT NOT NULL DEFAULT 0
);

CREATE TABLE product_spec_translations (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    spec_id       UUID NOT NULL REFERENCES product_specs(id) ON DELETE CASCADE,
    language_code TEXT NOT NULL REFERENCES languages(code),
    label         TEXT NOT NULL,
    UNIQUE (spec_id, language_code)
);

-- Фотогалерея Product (ТЗ п.15.2: Drive → import → S3/R2 → CDN)
CREATE TABLE product_photos (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id   UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    source_url   TEXT,                    -- исходник на Google Drive
    cdn_url      TEXT,                    -- после импорта в S3/R2 + CDN
    sort_order   SMALLINT NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE product_photos IS 'ТЗ п.15.2: Google Drive — источник, не рабочее хранилище. source_url (Drive) импортируется в cdn_url (S3/R2 за CDN). Folder ID источника байков известен в memory.';

-- ---------------------------------------------------------------------
-- FLEET ITEM — физический байк. Юр.данные = поля (решение D2).
-- ---------------------------------------------------------------------
CREATE TABLE fleet_items (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id          UUID NOT NULL REFERENCES companies(id),
    product_id          UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    internal_number     INTEGER NOT NULL,        -- 1..56 из текущей CRM
    license_plate       TEXT NOT NULL,           -- #DK6434KBG
    vin                 TEXT,
    status              fleet_status NOT NULL DEFAULT 'available',
    -- юридические/регистрационные (решение D2: поля, без отдельной таблицы/истории)
    stnk_expiry         DATE,                    -- из формата MM.YY
    bpkb_held_by        TEXT,
    owner_name          TEXT,                    -- 'Я'/'Рясный'/'Мехряк' из CRM
    ownership_type      TEXT,                    -- MDB / Agreement / Локал
    -- эксплуатация
    purchase_date       DATE,
    purchase_price_idr  BIGINT,
    current_odo_km      INTEGER NOT NULL DEFAULT 0,
    last_service_km     INTEGER,
    last_service_date   DATE,
    rent_until_date     DATE,
    -- телематика
    phone_number        TEXT,
    gps_imei            TEXT,
    gps_active_until    DATE,
    gps_sim_imei        TEXT,
    sim_activated_at    DATE,
    linked_email        TEXT,
    -- свободные заметки (как "Комментарий" в CRM)
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (company_id, internal_number),
    UNIQUE (company_id, license_plate)
);
COMMENT ON TABLE fleet_items IS 'Физический байк (ТЗ п.3.1). Решение D2: STNK/BPKB/GPS/VIN/email — поля без отдельной таблицы документов и истории продлений на v1.0. История при необходимости — через generic events.';
COMMENT ON COLUMN fleet_items.internal_number IS 'Сохраняет нумерацию 1-56 из Google Sheets CRM для миграции и человеческого общения ("байк №25").';

CREATE INDEX idx_fleet_product ON fleet_items(product_id);
CREATE INDEX idx_fleet_status ON fleet_items(status);
CREATE INDEX idx_fleet_rent_until ON fleet_items(rent_until_date) WHERE rent_until_date IS NOT NULL;
CREATE INDEX idx_fleet_stnk ON fleet_items(stnk_expiry) WHERE stnk_expiry IS NOT NULL;

-- ---------------------------------------------------------------------
-- REPLACEMENT MATRIX — направленный граф (ТЗ п.6.5.1)
-- ---------------------------------------------------------------------
CREATE TABLE replacement_matrix (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_family UUID NOT NULL REFERENCES product_families(id) ON DELETE CASCADE,
    to_family   UUID NOT NULL REFERENCES product_families(id) ON DELETE CASCADE,
    priority    SMALLINT NOT NULL DEFAULT 1,
    note        TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (from_family <> to_family),
    UNIQUE (from_family, to_family)
);
COMMENT ON TABLE replacement_matrix IS 'ТЗ п.6.5.1: простой направленный граф, НЕ полная матрица совместимости. Шаг 3 цепочки замены (после "тот же Product" и "другой цвет той же Family"). Расширяется менеджером по реальным кейсам. Пример: ADV → XMAX → PCX → NMAX.';
