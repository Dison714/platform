-- =====================================================================
-- 064_vstrom_fuel_tank_fix.sql
-- Suzuki V-Strom 250 fuel_tank was seeded as 17.3L (en.wikipedia.org,
-- global-market spec) in 023_family_specs_seed.sql. Dmitry confirmed the
-- Indonesia-market fleet unit actually has a 12L tank — 17.3 was wrong for
-- our bikes. Fixed as a new migration rather than editing 023 in place
-- (established project convention: see 033/043/056/059 for the same
-- fix-forward pattern on other already-applied migrations).
-- Idempotent — safe to re-run.
-- =====================================================================

UPDATE family_specs fs
SET spec_value = '12',
    source = 'fleet spec (Dmitry, confirmed 2026-09; overrides en.wikipedia.org global-market 17.3L)'
FROM product_families pf
WHERE fs.family_id = pf.id
  AND pf.code = 'suzuki_vstrom250'
  AND fs.spec_key = 'fuel_tank';
