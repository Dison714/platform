-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 16_equipment_addon_flag.sql
-- Какое оборудование клиент может выбрать как доп (чекбоксы на сайте)
-- =====================================================================

-- Не всё оборудование — клиентский доп: крепления (bracket/baseplate/backrest)
-- ставятся на байк как монтажная фурнитура, visor/cloth — части/расходники.
-- Флаг отделяет то, что показывается клиенту в калькуляторе, от внутреннего.
-- Config-driven: менеджер может включить/выключить позицию без кода.
ALTER TABLE equipment_types ADD COLUMN is_customer_addon BOOLEAN NOT NULL DEFAULT FALSE;
COMMENT ON COLUMN equipment_types.is_customer_addon IS 'TRUE = клиент может добавить как доп на сайте (GET /api/equipment). FALSE = внутреннее (крепления, расходники, части).';

-- Клиентские допы: шлемы (KYT hf/ff, базовый), SHAD-бокс — платные/основные;
-- дождевик и держатель телефона — бесплатные доп-опции. Остальное (крепления,
-- visor, тряпка, сумка для шлема) — не клиентский выбор.
UPDATE equipment_types SET is_customer_addon = TRUE
WHERE code IN (
    'helmet_kyt_hf', 'helmet_kyt_ff', 'helmet_biasa', 'shad_box',
    'raincoat', 'phone_holder'
);
