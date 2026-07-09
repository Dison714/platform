-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 21_booking_locale.sql
-- Язык заявки: на нём собирается уведомление менеджеру (целиком).
-- =====================================================================

ALTER TABLE bookings ADD COLUMN locale TEXT NOT NULL DEFAULT 'en' REFERENCES languages(code);
COMMENT ON COLUMN bookings.locale IS 'Язык клиента на момент заявки (ru/en). Уведомление менеджеру строится целиком на этом языке (шапка, подписи, оборудование, страховка).';
