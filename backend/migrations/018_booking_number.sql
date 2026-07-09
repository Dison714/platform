-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 18_booking_number.sql
-- Короткий человекочитаемый номер заявки (BR-00001) для менеджеров/CRM
-- =====================================================================

-- Монотонный номер в дополнение к uuid id. В уведомлениях/UI показывается как
-- "BR-00001" (формат — в приложении). Менеджеры называют его клиенту вслух,
-- пригодится для CRM Phase 2. На свежей (боевой) БД первая заявка = BR-00001;
-- на dev-БД существующие тестовые строки получат начальные номера (неважно).
CREATE SEQUENCE booking_number_seq START 1;

ALTER TABLE bookings
    ADD COLUMN booking_number BIGINT NOT NULL DEFAULT nextval('booking_number_seq');
ALTER SEQUENCE booking_number_seq OWNED BY bookings.booking_number;
ALTER TABLE bookings ADD CONSTRAINT bookings_booking_number_key UNIQUE (booking_number);

COMMENT ON COLUMN bookings.booking_number IS 'Монотонный короткий номер заявки. Показывается как BR-00001 (формат в приложении). Для людей/CRM, в отличие от uuid id.';
