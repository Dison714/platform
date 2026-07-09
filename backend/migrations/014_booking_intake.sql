-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 14_booking_intake.sql
-- Booking v1: снимок расчёта на момент заявки + конфиг эскалации менеджеру
-- =====================================================================

-- Снимок расчёта (Rental Engine) на момент создания заявки — фиксирует цену
-- по правилам активного rule_set (ТЗ п.6.7). base_price_idr/delivery_fee_idr
-- уже есть в bookings; здесь добавляем итог и полную разбивку (страховка/
-- оборудование/депозит/входные параметры) для аудита и показа менеджеру.
ALTER TABLE bookings ADD COLUMN total_payable_idr BIGINT;
ALTER TABLE bookings ADD COLUMN quote_snapshot JSONB;
COMMENT ON COLUMN bookings.quote_snapshot IS 'Снимок расчёта /api/quote на момент заявки: breakdown (base/delivery/insurance/equipment), deposit, входные параметры. Сервер пересчитывает цену сам, фронту не доверяет.';
COMMENT ON COLUMN bookings.total_payable_idr IS 'Итог "к оплате" (без депозита) на момент заявки. Депозит — в quote_snapshot, возвращаемый, не входит в итог.';

-- Telegram chat ID менеджера для эскалации новых заявок (config, не хардкод).
INSERT INTO system_config (company_id, key, value, description)
SELECT id, 'manager_telegram_chat_id', '335443597', 'Telegram chat ID менеджера для эскалации заявок (@Dima_finance). Токен бота — в env TELEGRAM_BOT_TOKEN.'
FROM companies;
