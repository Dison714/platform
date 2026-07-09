-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 19_equipment_addon_group.sql
-- Группа доп-оборудования для клиентского UI и правила «2 шлема»
-- =====================================================================

-- addon_group отделяет шлемы (модель «2 слота, потолок 2») от багажника и
-- прочего — чтобы и фронт (рендер слотов), и бэкенд (guard ≤2 шлема) работали
-- по данным, а не по именам кодов. Цены НЕ трогаем — они уже верные.
ALTER TABLE equipment_types ADD COLUMN addon_group TEXT;
COMMENT ON COLUMN equipment_types.addon_group IS 'Группа клиентского допа: helmet (шлемы, правило 2 слота/потолок 2) | topcase (багажник) | other. NULL — не клиентский доп. Отдаётся в /api/equipment.';

UPDATE equipment_types SET addon_group = 'helmet'
    WHERE code IN ('helmet_biasa', 'helmet_kyt_hf', 'helmet_kyt_ff');
UPDATE equipment_types SET addon_group = 'topcase'
    WHERE code = 'shad_box';
UPDATE equipment_types SET addon_group = 'other'
    WHERE code IN ('phone_holder', 'raincoat');
