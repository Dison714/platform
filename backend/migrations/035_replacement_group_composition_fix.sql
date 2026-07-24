-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 035_replacement_group_composition_fix.sql
-- Коррекция состава replacement_group (Блок 029): Vario → Xmax.
-- =====================================================================
-- Миграция 029 включила в scooter_econ_160 Honda ADV/PCX/Vario + Yamaha
-- Nmax — по факту это неверный состав. По ТЗ п.6.5 (граф замены
-- ADV → XMAX → PCX → NMAX) и подтверждению владельца, эти четыре модели
-- взаимозаменяемы симметрично: Honda ADV, Yamaha Xmax, Honda PCX,
-- Yamaha Nmax. Vario остаётся в каталоге и в своих фильтрах
-- (family_filter_categories, миграция 028) — только выходит из группы
-- функциональной взаимозаменяемости. Согласуется с уже существующим
-- правилом CLAUDE.md §4 «Xmax — нормальный апгрейд, не крайний вариант».
--
-- Переименование code/name: состав больше не «4×160cc эконом-скутера»
-- (3×160cc + 1×250cc maxi-scooter), scooter_econ_160 перестал буквально
-- описывать группу — переименован в scooter_replacement_pool.
-- =====================================================================

UPDATE replacement_groups
SET code = 'scooter_replacement_pool',
    name = 'Скутеры — основной пул замены'
WHERE code = 'scooter_econ_160';

UPDATE product_families
SET replacement_group_id = NULL
WHERE code = 'honda_vario';

UPDATE product_families
SET replacement_group_id = (SELECT id FROM replacement_groups WHERE code = 'scooter_replacement_pool')
WHERE code = 'yamaha_xmax';
