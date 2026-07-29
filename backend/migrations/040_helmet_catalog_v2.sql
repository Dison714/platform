-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 040_helmet_catalog_v2.sql
-- Явная фиксация выбора шлема по слотам (Слот 1/2) + 2 новых SKU
-- =====================================================================

-- Согласовано с Дмитрием: KYT half face (обычный сток) становится
-- бесплатным — наравне с helmet_biasa, просто другой физический тип шлема.
-- Платными остаются: KYT full face (сток) и два новых SKU ниже.
UPDATE equipment_types SET rental_price_idr = 0 WHERE code = 'helmet_kyt_hf';

INSERT INTO equipment_types (code, name, tracks_units, charge_basis, rental_price_idr, deposit_deduction_idr, deduction_note, is_customer_addon, addon_group) VALUES
    ('helmet_kyt_hf_new', 'Helm KYT half face baru', TRUE, 'per_rental', 150000, 500000, 'вариант 450k — см. админку', TRUE, 'helmet'),
    ('helmet_kyt_ff_new', 'Helm KYT full face baru', TRUE, 'per_rental', 200000, 600000, 'вариант 550k; 2 шт = 250k', TRUE, 'helmet');

COMMENT ON COLUMN equipment_types.rental_price_idr IS 'Тариф клиенту. Шлемы (addon_group=helmet): helmet_biasa и helmet_kyt_hf — бесплатные (0), helmet_kyt_ff/helmet_kyt_hf_new/helmet_kyt_ff_new — платные. Итого 5 SKU в группе helmet, слот на сайте фиксирует явный выбор по каждому из 2 слотов независимо от цены (включая бесплатный).';

INSERT INTO equipment_type_translations (equipment_type_id, language_code, name)
SELECT et.id, v.lang, v.name
FROM equipment_types et
JOIN (VALUES
    ('helmet_kyt_hf_new', 'en', 'KYT half-face helmet (new)'),
    ('helmet_kyt_hf_new', 'ru', 'Шлем KYT (открытый), новый'),
    ('helmet_kyt_ff_new', 'en', 'KYT full-face helmet (new)'),
    ('helmet_kyt_ff_new', 'ru', 'Шлем KYT (закрытый), новый')
) AS v(code, lang, name) ON v.code = et.code;
