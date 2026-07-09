-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 12_delivery.sql
-- Доставка по сроку аренды + теневой сбор статистики по локации
-- =====================================================================

-- Режим расчёта доставки — развилка на будущее (ТЗ п.6.2). Сейчас только
-- 'by_duration' (по сроку аренды). Позже 'by_distance' будет считать
-- расстояние ПО ДОРОГАМ через Google Distance API (НЕ по прямой) — ядро
-- расчёта вынесено в сервис, переключение режима = смена этого конфига,
-- без переписывания. Сами тарифы по сроку — в delivery_fee_rules (config,
-- версионируется rule_set'ом; сидируется в seed-crm.js рядом с ценами).
INSERT INTO system_config (company_id, key, value, description)
SELECT id, k.key, k.value::jsonb, k.descr
FROM companies, (VALUES
    ('delivery_mode', '"by_duration"', 'Режим расчёта доставки: by_duration (сейчас) | by_distance (позже, по дорогам через Google Distance API)'),
    ('delivery_base_coords', 'null', 'Координаты базы для shadow-расчёта расстояния: {"lat":..,"lng":..}. null = shadow-расстояние отключено (ссылка всё равно сохраняется водителю).'),
    ('delivery_shadow_km_zones', '[]', 'Гипотетические зоны by_distance для shadow-статистики: [{"max_km":N,"fee_idr":N,"zone":"..."}]. Пусто = зона/цена по км не считаются.')
) AS k(key, value, descr);

-- Сырая ссылка на локацию клиента (Google Maps) — для передачи водителю
-- (куда ехать). Калькулятор её НЕ парсит и на цену доставки НЕ влияет
-- (доставка считается по сроку). Парсинг координат — только в shadow-режиме.
ALTER TABLE bookings ADD COLUMN location_link TEXT;
COMMENT ON COLUMN bookings.location_link IS 'Сырая ссылка Google Maps от клиента, передаётся водителю. Калькулятор не парсит; на цену не влияет (доставка по сроку). Координаты при необходимости — delivery_lat/lng (заполняются вручную или будущим by_distance).';

-- ---------------------------------------------------------------------
-- DELIVERY SHADOW STATS — теневой сбор статистики (shadow mode)
-- ---------------------------------------------------------------------
-- Проверка гипотезы «можно ли перейти на расчёт доставки по расстоянию»
-- ДО реального перехода. Пишется в фоне при поступлении location_link;
-- НЕ влияет на цену клиента (та считается по сроку) и не блокирует ответ.
-- Ошибка разворота/парсинга ссылки фиксируется как fail, не всплывает клиенту.
CREATE TABLE delivery_shadow_stats (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id      UUID NOT NULL REFERENCES companies(id),
    booking_id      UUID REFERENCES bookings(id) ON DELETE SET NULL,  -- NULL для расчёта-квоты вне заявки
    location_link   TEXT NOT NULL,
    expand_success  BOOLEAN NOT NULL,          -- удалось ли развернуть ссылку и извлечь координаты
    expand_error    TEXT,                      -- причина при fail (network_timeout, coords_not_found, ...)
    extracted_lat   NUMERIC(10,7),
    extracted_lng   NUMERIC(10,7),
    distance_km     NUMERIC(8,3),              -- ПО ПРЯМОЙ от базы (shadow-прокси; by_distance потом считает по дорогам)
    distance_zone   TEXT,                      -- расчётная зона по км (если заданы delivery_shadow_km_zones)
    shadow_fee_idr  BIGINT,                    -- гипотетическая цена по км
    actual_fee_idr  BIGINT NOT NULL,           -- фактическая цена по сроку, которую заплатил клиент (для сравнения)
    rental_days     SMALLINT,
    delivery_mode   TEXT NOT NULL,             -- активный режим на момент записи
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE delivery_shadow_stats IS 'Shadow mode (ТЗ: гипотеза by_distance). Сравнение фактической цены по сроку с гипотетической по км для анализа перед переходом на расчёт по расстоянию. Расстояние здесь — по прямой (haversine), реальный by_distance будет считать по дорогам.';

CREATE INDEX idx_delivery_shadow_created ON delivery_shadow_stats(company_id, created_at);
