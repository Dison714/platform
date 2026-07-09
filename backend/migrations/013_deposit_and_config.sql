-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 13_deposit_and_config.sql
-- Депозит (config + правило-исключение по модели) + конфиг shadow-доставки
-- =====================================================================

-- ---------------------------------------------------------------------
-- DEPOSIT RULES — исключения из базового депозита (system_config
-- 'standard_deposit_idr' = 1 000 000). Базовая сумма остаётся в config;
-- здесь только переопределения по МОДЕЛИ и СРОКУ. Привязка к семейству —
-- по FK family_id (UUID), а не по строковому имени: надёжно при ребрендинге.
-- Пример: Kawasaki ZX25R и Morbidelli при аренде <7 дней — депозит 2 млн.
-- ---------------------------------------------------------------------
CREATE TABLE deposit_rules (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id      UUID NOT NULL REFERENCES companies(id),
    family_id       UUID REFERENCES product_families(id) ON DELETE CASCADE,  -- NULL = любая модель
    max_rental_days SMALLINT,        -- правило действует при rental_days <= max (NULL = любой срок)
    deposit_idr     BIGINT NOT NULL,
    priority        SMALLINT NOT NULL DEFAULT 0,  -- выше = специфичнее (выбираем первое по убыванию)
    note            TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE deposit_rules IS 'Исключения из базового депозита (system_config.standard_deposit_idr). Привязка к модели через family_id (FK, не строка). Сидируется в seed-crm.js после создания families. Депозит возвращаемый, не входит в "к оплате".';

CREATE INDEX idx_deposit_rules_lookup ON deposit_rules(company_id, family_id);

-- ---------------------------------------------------------------------
-- КОНФИГ shadow-доставки (значения для MDB Bali). Только статистика —
-- на цену клиента не влияет (доставка считается по сроку).
-- ---------------------------------------------------------------------
-- Координаты базы для расчёта расстояния по прямой в shadow-режиме.
UPDATE system_config
SET value = '{"lat":-8.672194,"lng":115.175500}'::jsonb
WHERE key = 'delivery_base_coords';

-- Гипотетические зоны by_distance (на будущее, для накопления статистики).
-- fee_idr = null: цены по км пока не заданы, копим только распределение зон.
-- max_km = null у последней зоны = ">30 км" (без верхней границы).
UPDATE system_config
SET value = '[
    {"max_km": 12,   "zone": "0-12km",  "fee_idr": null},
    {"max_km": 20,   "zone": "12-20km", "fee_idr": null},
    {"max_km": 30,   "zone": "20-30km", "fee_idr": null},
    {"max_km": null, "zone": "30km+",   "fee_idr": null}
]'::jsonb
WHERE key = 'delivery_shadow_km_zones';
