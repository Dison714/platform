-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 06_finance_notifications.sql
-- Finance Journal · Exchange Rates · Notification Service
-- =====================================================================
-- Finance — журнал, не итоги (ТЗ п.10). Notification Service — абстракция
-- канала (ТЗ п.15.3): Booking → Notification → WhatsApp/Telegram/Email/Push.
-- =====================================================================

CREATE TABLE finance_categories (
    code        TEXT PRIMARY KEY,        -- rental_payment, delivery, taxi, fuel, wash, repair, salary, ...
    direction   finance_direction NOT NULL,
    name        TEXT NOT NULL
);

INSERT INTO finance_categories (code, direction, name) VALUES
    ('rental_payment','income','Оплата аренды'),
    ('deposit_received','income','Депозит получен'),
    ('deposit_returned','expense','Депозит возвращён'),
    ('deposit_deduction','income','Удержание из депозита'),
    ('delivery_fee','income','Плата за доставку'),
    ('extension_payment','income','Оплата продления'),
    ('insurance_payment','income','Оплата страховки'),
    ('equipment_payment','income','Оплата оборудования'),
    ('taxi','expense','Такси (Gojek/Grab)'),
    ('fuel','expense','Топливо'),
    ('wash','expense','Мойка'),
    ('repair','expense','Ремонт'),
    ('spare_part','expense','Запчасти'),
    ('salary','expense','Зарплата'),
    ('investment','expense','Инвестиция в байк'),
    ('other_income','income','Прочий доход'),
    ('other_expense','expense','Прочий расход');

CREATE TABLE finance_transactions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id          UUID NOT NULL REFERENCES companies(id),
    category_code       TEXT NOT NULL REFERENCES finance_categories(code),
    amount_idr          BIGINT NOT NULL,        -- всегда в базовой валюте; знак по category.direction
    currency_original   currency_code NOT NULL DEFAULT 'IDR',
    amount_original     BIGINT,
    exchange_rate       NUMERIC(14,4),
    rental_id           UUID REFERENCES rentals(id),
    booking_id          UUID REFERENCES bookings(id),
    fleet_item_id       UUID REFERENCES fleet_items(id),
    driver_id           UUID REFERENCES users(id),
    deposit_deduction_id UUID REFERENCES deposit_deductions(id),
    event_id            UUID REFERENCES events(id),
    description         TEXT,
    recorded_by         UUID REFERENCES users(id),
    occurred_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE finance_transactions IS 'ТЗ п.10: журнал операций. Итоги (доход/расход/прибыль) — агрегация по category_code/датам, НЕ хранятся. Доход/расход определяется finance_categories.direction.';

CREATE INDEX idx_fin_cat_time ON finance_transactions(category_code, occurred_at);
CREATE INDEX idx_fin_rental ON finance_transactions(rental_id) WHERE rental_id IS NOT NULL;
CREATE INDEX idx_fin_driver ON finance_transactions(driver_id) WHERE driver_id IS NOT NULL;

CREATE TABLE exchange_rates (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_currency currency_code NOT NULL,
    to_currency   currency_code NOT NULL DEFAULT 'IDR',
    rate          NUMERIC(14,4) NOT NULL,
    rate_date     DATE NOT NULL,
    UNIQUE (from_currency, to_currency, rate_date)
);

-- ---------------------------------------------------------------------
-- NOTIFICATION SERVICE — абстракция канала (ТЗ п.15.3)
-- Booking/Rental не привязаны к WhatsApp напрямую — общаются через это.
-- ---------------------------------------------------------------------
CREATE TYPE notification_channel AS ENUM ('whatsapp','telegram','email','push','sms');
CREATE TYPE notification_status AS ENUM ('queued','sent','delivered','failed');

CREATE TABLE notifications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id      UUID NOT NULL REFERENCES companies(id),
    channel         notification_channel NOT NULL,
    status          notification_status NOT NULL DEFAULT 'queued',
    recipient_customer UUID REFERENCES customers(id),
    recipient_user  UUID REFERENCES users(id),
    template_code   TEXT,                   -- ссылка на шаблон (клиентские шаблоны RU/EN)
    language_code   TEXT REFERENCES languages(code),
    payload         JSONB NOT NULL DEFAULT '{}',
    booking_id      UUID REFERENCES bookings(id),
    rental_id       UUID REFERENCES rentals(id),
    sent_at         TIMESTAMPTZ,
    error           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE notifications IS 'ТЗ п.15.3: канал не зашит в бизнес-логику. Booking → Notification Service → WhatsApp/Telegram/Email/Push/SMS. Заменить канал можно без изменения логики бронирований.';

CREATE INDEX idx_notif_status ON notifications(status) WHERE status IN ('queued','failed');
