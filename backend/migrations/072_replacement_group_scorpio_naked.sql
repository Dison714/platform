-- =====================================================================
-- 072_replacement_group_scorpio_naked.sql
-- yamaha_scorpio225 в naked_classic_replacement_pool (код подтверждён:
-- SELECT code, brand, model_name FROM product_families WHERE brand =
-- 'Yamaha' AND model_name ILIKE '%Scorpio%' -> yamaha_scorpio225).
-- =====================================================================

UPDATE product_families
SET replacement_group_id = (SELECT id FROM replacement_groups WHERE code = 'naked_classic_replacement_pool')
WHERE code = 'yamaha_scorpio225';
