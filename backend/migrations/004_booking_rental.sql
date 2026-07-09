-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 04_booking_rental.sql
-- Customers · Bookings · Rentals · Events · Deposit Deductions
-- =====================================================================
-- ТЗ п.6.8: Booking ≠ Rental. Продление = Event (п.6.8.1).
-- Цепочка: Booking → Rental → Events → Return.
-- =====================================================================

-- ---------------------------------------------------------------------
-- CUSTOMERS
-- ---------------------------------------------------------------------
CREATE TABLE customers (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id               UUID NOT NULL REFERENCES companies(id),
    full_name                TEXT NOT NULL,
    phone                    TEXT,
    whatsapp                 TEXT,
    telegram_username        TEXT,
    telegram_id              BIGINT,
    email                    TEXT,
    nationality              TEXT,
    date_of_birth            DATE,            -- для driver_experience (п.6.3.3)
    license_years            SMALLINT,        -- стаж, для driver_experience
    passport_photo_url       TEXT,
    is_blacklisted           BOOLEAN NOT NULL DEFAULT FALSE,
    blacklist_reason         TEXT,
    rented_before_ok         BOOLEAN NOT NULL DEFAULT FALSE,  -- повторная аренда без депозита (база знаний п.12.1)
    notes                    TEXT,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE customers IS 'is_blacklisted = лист "Чёрный список" текущей CRM. rented_before_ok управляет правилом депозита (база знаний п.12.1: повторная аренда без проблем → без депозита).';

CREATE INDEX idx_customers_tg ON customers(telegram_id) WHERE telegram_id IS NOT NULL;
CREATE INDEX idx_customers_phone ON customers(phone) WHERE phone IS NOT NULL;
CREATE INDEX idx_customers_name_trgm ON customers USING gin (full_name gin_trgm_ops);

CREATE TABLE customer_documents (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id   UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    doc_type      TEXT NOT NULL,           -- passport, license
    file_url      TEXT NOT NULL,
    uploaded_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- BOOKING — коммерческая сущность до выдачи (ТЗ п.6.8)
-- ---------------------------------------------------------------------
CREATE TABLE bookings (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id            UUID NOT NULL REFERENCES companies(id),
    source                record_source NOT NULL,
    status                booking_status NOT NULL DEFAULT 'created',
    customer_id           UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    product_id            UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,   -- запрошенный
    rule_set_id           UUID NOT NULL REFERENCES pricing_rule_sets(id),             -- фиксирует версию (п.6.7)
    assigned_fleet_item   UUID REFERENCES fleet_items(id),
    assigned_driver       UUID REFERENCES users(id),
    start_date            DATE NOT NULL,
    end_date              DATE NOT NULL,
    rental_days           SMALLINT NOT NULL,
    delivery_lat          NUMERIC(10,7),
    delivery_lng          NUMERIC(10,7),
    delivery_address      TEXT,
    base_price_idr        BIGINT NOT NULL,
    delivery_fee_idr      BIGINT NOT NULL DEFAULT 0,
    is_replacement        BOOLEAN NOT NULL DEFAULT FALSE,
    replacement_reason    TEXT,           -- ТЗ п.7.3: AI объясняет замену
    cancellation_reason   TEXT,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE bookings IS 'ТЗ п.6.8: жизненный цикл created→ai_processing→confirmed→awaiting_payment→paid→driver_assigned→fleet_item_assigned→fulfilled. source различает website/telegram_bot/manual — боты пишут наравне с сайтом (D3).';
COMMENT ON COLUMN bookings.replacement_reason IS 'ТЗ п.7.3: AI должен объяснять решение о замене ("ADV unavailable, PCX has similar riding position...").';

CREATE INDEX idx_bookings_customer ON bookings(customer_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_dates ON bookings(start_date, end_date);

CREATE TABLE booking_status_history (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id    UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    from_status   booking_status,
    to_status     booking_status NOT NULL,
    changed_by    UUID REFERENCES users(id),
    note          TEXT,
    changed_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- RENTAL — создаётся при выдаче (ТЗ п.6.8)
-- ---------------------------------------------------------------------
CREATE TABLE rentals (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id               UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    customer_id              UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    fleet_item_id            UUID NOT NULL REFERENCES fleet_items(id) ON DELETE RESTRICT,
    driver_id                UUID REFERENCES users(id),
    status                   rental_status NOT NULL DEFAULT 'active',
    contract_url             TEXT,
    contract_signed_at       TIMESTAMPTZ,
    start_date               DATE NOT NULL,
    end_date                 DATE NOT NULL,    -- обновляется Extension Event (п.6.8.1)
    returned_date            DATE,
    deposit_amount_idr       BIGINT NOT NULL DEFAULT 0,
    deposit_currency         currency_code NOT NULL DEFAULT 'IDR',
    deposit_returned_idr     BIGINT,
    odo_delivery_km          INTEGER,
    odo_return_km            INTEGER,
    fuel_delivery_pct        SMALLINT,
    fuel_return_pct          SMALLINT,
    delivery_photos          JSONB NOT NULL DEFAULT '[]',
    delivery_video_url       TEXT,
    return_photos            JSONB NOT NULL DEFAULT '[]',
    return_video_url         TEXT,
    damage_notes             TEXT,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE rentals IS 'ТЗ п.6.8: создаётся ТОЛЬКО при фактической передаче байка. end_date меняется Extension Event-ами (п.6.8.1), не пересоздаёт Rental. Цепочка Booking→Rental→Events→Return.';

CREATE INDEX idx_rentals_customer ON rentals(customer_id);
CREATE INDEX idx_rentals_fleet ON rentals(fleet_item_id);
CREATE INDEX idx_rentals_active ON rentals(status) WHERE status = 'active';
CREATE INDEX idx_rentals_end ON rentals(end_date) WHERE status = 'active';

-- Защита от двойного бронирования одного Fleet Item на пересекающиеся даты
-- (btree_gist подключён в 01). Активные аренды одного байка не должны
-- перекрываться по датам.
ALTER TABLE rentals ADD CONSTRAINT no_overlapping_active_rentals
    EXCLUDE USING gist (
        fleet_item_id WITH =,
        daterange(start_date, COALESCE(returned_date, end_date), '[]') WITH &&
    ) WHERE (status = 'active');
COMMENT ON CONSTRAINT no_overlapping_active_rentals ON rentals IS 'БД-уровневая гарантия: один физический байк не может быть выдан двум клиентам на пересекающиеся даты. Защищает от гонок при параллельной записи ботом и сайтом.';

CREATE TABLE rental_equipment (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rental_id       UUID NOT NULL REFERENCES rentals(id) ON DELETE CASCADE,
    type_id         UUID NOT NULL REFERENCES equipment_types(id),
    unit_id         UUID REFERENCES equipment_units(id),     -- если tracks_units
    quantity        SMALLINT NOT NULL DEFAULT 1,
    price_idr       BIGINT NOT NULL DEFAULT 0,
    returned_at     TIMESTAMPTZ,
    return_note     TEXT
);

CREATE TABLE rental_insurance (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rental_id       UUID NOT NULL REFERENCES rentals(id) ON DELETE CASCADE,
    plan_id         UUID NOT NULL REFERENCES insurance_plans(id),
    months          SMALLINT NOT NULL,
    total_idr       BIGINT NOT NULL,
    started_at      DATE NOT NULL,
    ended_at        DATE
);

-- ---------------------------------------------------------------------
-- EVENT LOG — generic event-driven (ТЗ п.11)
-- ---------------------------------------------------------------------
CREATE TABLE event_types (
    code        TEXT PRIMARY KEY,
    description TEXT NOT NULL
);

INSERT INTO event_types (code, description) VALUES
    ('booking_created','Бронь создана'),
    ('booking_confirmed','Бронь подтверждена'),
    ('payment_received','Оплата получена'),
    ('bike_assigned','Назначен байк'),
    ('driver_assigned','Назначен водитель'),
    ('deposit_received','Депозит получен'),
    ('bike_delivered','Байк выдан'),
    ('rental_extended','Продление аренды'),
    ('bike_swapped','Смена байка (tukar motor)'),
    ('damage_reported','Зафиксировано повреждение'),
    ('bike_returned','Байк возвращён'),
    ('deposit_returned','Депозит возвращён'),
    ('inspection_completed','Осмотр завершён'),
    ('review_requested','Запрошен отзыв');

CREATE TABLE events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code       TEXT NOT NULL REFERENCES event_types(code),
    source          record_source NOT NULL,
    booking_id      UUID REFERENCES bookings(id),
    rental_id       UUID REFERENCES rentals(id),
    fleet_item_id   UUID REFERENCES fleet_items(id),
    customer_id     UUID REFERENCES customers(id),
    actor_user_id   UUID REFERENCES users(id),     -- NULL = системное/AI
    payload         JSONB NOT NULL DEFAULT '{}',
    occurred_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE events IS 'ТЗ п.11 Event Driven. Extension Event payload: {"extra_days":5,"extra_amount_idr":1500000,"new_end_date":"2026-07-15"}. Приложение обновляет rentals.end_date; событие — источник истины истории.';

CREATE INDEX idx_events_rental ON events(rental_id) WHERE rental_id IS NOT NULL;
CREATE INDEX idx_events_booking ON events(booking_id) WHERE booking_id IS NOT NULL;
CREATE INDEX idx_events_fleet ON events(fleet_item_id) WHERE fleet_item_id IS NOT NULL;
CREATE INDEX idx_events_type_time ON events(type_code, occurred_at);

-- ---------------------------------------------------------------------
-- DEPOSIT DEDUCTIONS (ТЗ п.6.8.2)
-- ---------------------------------------------------------------------
CREATE TABLE deposit_deductions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rental_id           UUID NOT NULL REFERENCES rentals(id) ON DELETE CASCADE,
    equipment_type_id   UUID REFERENCES equipment_types(id),
    fleet_item_id       UUID REFERENCES fleet_items(id),
    amount_idr          BIGINT NOT NULL,
    reason              TEXT NOT NULL,
    individually_assessed BOOLEAN NOT NULL DEFAULT FALSE,
    created_by          UUID REFERENCES users(id),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (equipment_type_id IS NOT NULL OR fleet_item_id IS NOT NULL)
);
COMMENT ON TABLE deposit_deductions IS 'ТЗ п.6.8.2: тариф по оборудованию из equipment_types.deposit_deduction_idr; повреждение байка (fleet_item_id, без equipment_type_id) — individually_assessed=TRUE, сумма вручную.';
