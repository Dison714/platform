-- =====================================================================
-- 071_replacement_group_mt25_sport.sql
-- yamaha_mt25 в sport_replacement_pool (070 сознательно оставила его без
-- группы — уточнено Дмитрием, MT-25 всё же участвует в межмодельной замене
-- со спортбайками).
-- =====================================================================

UPDATE product_families
SET replacement_group_id = (SELECT id FROM replacement_groups WHERE code = 'sport_replacement_pool')
WHERE code = 'yamaha_mt25';
