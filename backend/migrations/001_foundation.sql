-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 01_foundation.sql
-- Extensions · Enums · Auth/Roles · Languages · System Config · Companies
-- =====================================================================
-- Platform строится полной с первого дня (ТЗ п.19). Этот файл — фундамент.
-- Включает multi-company якорь (ТЗ п.13: "Platform — это не Bike Bali"):
-- companies заложена сразу, чтобы при добавлении второй страны/бизнеса не
-- мигрировать схему. На v1.0 — одна строка (PT. Modern Development Bali).
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- fuzzy-поиск по клиентам/байкам
CREATE EXTENSION IF NOT EXISTS "btree_gist"; -- для exclusion-констрейнтов аренды (защита от двойного бронирования Fleet Item)

-- ---------------------------------------------------------------------
-- ENUMS
-- ---------------------------------------------------------------------
CREATE TYPE record_source AS ENUM (
    'website', 'telegram_bot', 'whatsapp_bot', 'manual', 'import', 'api'
);

CREATE TYPE booking_status AS ENUM (
    'created', 'ai_processing', 'confirmed', 'awaiting_payment',
    'paid', 'driver_assigned', 'fleet_item_assigned', 'fulfilled',
    'cancelled', 'expired'
);

CREATE TYPE rental_status AS ENUM ('active', 'returned', 'closed');

CREATE TYPE fleet_status AS ENUM (
    'available', 'prepared', 'reserved', 'rented',
    'maintenance', 'repair', 'retired'
);

CREATE TYPE driver_experience AS ENUM ('experienced', 'inexperienced');

CREATE TYPE insurance_kind AS ENUM ('theft', 'damage');

CREATE TYPE charge_basis AS ENUM ('per_rental', 'per_month');

CREATE TYPE currency_code AS ENUM ('IDR', 'USD', 'EUR', 'AUD', 'RUB');

CREATE TYPE task_status AS ENUM (
    'pending', 'acknowledged', 'in_progress', 'completed', 'cancelled'
);

CREATE TYPE task_priority AS ENUM (
    'delivery', 'urgent', 'planned', 'deferred'
);

CREATE TYPE finance_direction AS ENUM ('income', 'expense');

-- ---------------------------------------------------------------------
-- COMPANIES — multi-company якорь (ТЗ п.13.1, п.13.2)
-- ---------------------------------------------------------------------
CREATE TABLE companies (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code            TEXT UNIQUE NOT NULL,          -- 'mdb_bali'
    legal_name      TEXT NOT NULL,                 -- 'PT. Modern Development Bali'
    country_code    TEXT NOT NULL DEFAULT 'ID',    -- ISO-3166
    base_currency   currency_code NOT NULL DEFAULT 'IDR',
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE companies IS 'ТЗ п.13.1: ядро не зависит от Bike Bali. Большинство доменных таблиц несут company_id, чтобы новая страна/бизнес = новая строка + данные, без миграции схемы. v1.0 — одна компания.';

-- id захардкожен (не gen_random_uuid()): миграция прогоняется независимо на
-- dev и на prod, и до этой правки давала на каждой стороне свой случайный
-- UUID для одной и той же по смыслу компании — company_id расходился между
-- средами и ломал gen_catalog_sync.mjs (FK-constraint на product_families).
-- Устранено 2026-08-15, id зафиксирован по значению, уже живущему на проде.
INSERT INTO companies (id, code, legal_name, country_code, base_currency)
VALUES ('37005782-1dec-4f77-9673-f4c85eac9d89', 'mdb_bali', 'PT. Modern Development Bali', 'ID', 'IDR');

-- ---------------------------------------------------------------------
-- AUTH / ROLES
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id         UUID NOT NULL REFERENCES companies(id),
    full_name          TEXT NOT NULL,
    email              TEXT UNIQUE,
    phone              TEXT,
    telegram_id        BIGINT UNIQUE,
    is_service_account BOOLEAN NOT NULL DEFAULT FALSE,
    is_active          BOOLEAN NOT NULL DEFAULT TRUE,
    password_hash      TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON COLUMN users.is_service_account IS 'TRUE для ботов (MDB_drivers_bot, MDB_tugas_approver_bot, Bali_Rent_Manager_bot). Решение D3: боты пишут в Platform DB через API уже на v1.0/v1.1.';

CREATE TABLE roles (
    id          SMALLSERIAL PRIMARY KEY,
    code        TEXT UNIQUE NOT NULL,   -- owner, manager, driver, bot_driver_ops, bot_client_ai
    name        TEXT NOT NULL,
    description TEXT
);

INSERT INTO roles (code, name) VALUES
    ('owner', 'Owner'),
    ('manager', 'Manager'),
    ('driver', 'Driver'),
    ('bot_driver_ops', 'Driver-ops bot'),
    ('bot_client_ai', 'Client-facing AI bot');

CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id SMALLINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE api_clients (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name         TEXT NOT NULL,
    api_key_hash TEXT NOT NULL,
    scopes       TEXT[] NOT NULL DEFAULT '{}',
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    last_used_at TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE api_clients IS 'Учётные данные ботов/внешних сервисов для Platform API. Каждый Telegram-бот получит запись здесь при миграции на запись в Platform DB.';

-- ---------------------------------------------------------------------
-- LANGUAGES (ТЗ п.4.9) — добавление языка = строка + переводы, без кода
-- ---------------------------------------------------------------------
CREATE TABLE languages (
    code         TEXT PRIMARY KEY,    -- en, ru, de, ...
    name         TEXT NOT NULL,
    launch_phase SMALLINT NOT NULL DEFAULT 1,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order   SMALLINT NOT NULL DEFAULT 0
);

INSERT INTO languages (code, name, launch_phase, sort_order) VALUES
    ('en','English',1,1), ('ru','Russian',1,2), ('de','German',1,3),
    ('fr','French',1,4), ('es','Spanish',1,5), ('it','Italian',1,6),
    ('ja','Japanese',1,7), ('nl','Dutch',2,8), ('pt','Portuguese',2,9),
    ('pl','Polish',2,10), ('cs','Czech',3,11), ('sk','Slovak',3,12),
    ('ko','Korean',3,13), ('zh-Hans','Chinese Simplified',3,14),
    ('zh-Hant','Chinese Traditional',3,15);

-- ---------------------------------------------------------------------
-- SYSTEM CONFIG — скалярные бизнес-константы (Configuration First, п.12)
-- ---------------------------------------------------------------------
CREATE TABLE system_config (
    company_id  UUID NOT NULL REFERENCES companies(id),
    key         TEXT NOT NULL,
    value       JSONB NOT NULL,
    description TEXT,
    updated_by  UUID REFERENCES users(id),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (company_id, key)
);
COMMENT ON TABLE system_config IS 'Скалярные бизнес-константы на компанию, редактируемые менеджером. company_id в ключе — разные значения для разных стран без изменения схемы.';

INSERT INTO system_config (company_id, key, value, description)
SELECT id, k.key, k.value::jsonb, k.descr
FROM companies, (VALUES
    ('standard_deposit_idr', '1000000', 'Стандартный депозит при первой аренде, IDR'),
    ('deposit_credit_min_months', '4', 'Аренда от N мес — депозит в оплату при условиях'),
    ('maintenance_km_client', '{"min":2900,"max":3100}', 'Порог ТО по пробегу: байк у клиента'),
    ('maintenance_km_inhouse', '{"min":2300,"max":2500}', 'Порог ТО по пробегу: байк в парке'),
    ('rental_reminder_days_before', '1', 'За сколько дней напоминать об окончании аренды'),
    ('stnk_pickup_window_days', '{"min":7,"max":90}', 'Окно отвоза STNK на продление'),
    ('gps_sim_alert_days_before', '30', 'За сколько дней предупреждать об истечении GPS/SIM'),
    ('battery_discharge_fee_idr', '150000', 'Компенсация за разряд аккумулятора'),
    ('driver_callout_fee_idr', '150000', 'Выезд водителя по инциденту'),
    ('cancel_after_delivery_fee_idr', '200000', 'Отмена после доставки'),
    ('driver_inexperienced_age_max', '33', 'Возраст: до этого — неопытный водитель (п.6.3.3)')
) AS k(key, value, descr);
COMMENT ON COLUMN companies.base_currency IS 'Multi-currency готовность (ТЗ п.13): новая страна задаёт свою базовую валюту.';
