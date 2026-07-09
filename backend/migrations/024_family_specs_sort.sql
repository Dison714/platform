-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 24_family_specs_sort.sql
-- Card display order for specs (agreed):
-- engine → power → top_speed → fuel_consumption → fuel_tank → transmission
--   → seat_height → seats → curb_weight
-- =====================================================================

UPDATE family_specs SET sort_order = CASE spec_key
    WHEN 'engine_cc'        THEN 1
    WHEN 'power'            THEN 2
    WHEN 'top_speed'        THEN 3
    WHEN 'fuel_consumption' THEN 4
    WHEN 'fuel_tank'        THEN 5
    WHEN 'transmission'     THEN 6
    WHEN 'seat_height'      THEN 7
    WHEN 'seats'            THEN 8
    WHEN 'curb_weight'      THEN 9
    ELSE sort_order
END;
