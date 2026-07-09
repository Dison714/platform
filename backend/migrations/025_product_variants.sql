-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 025_product_variants.sql  (Photos chunk, Step 2A)
-- Extends the Product identity so equipment kits and print series are
-- distinct Products, plus flags for archived colours, partner bikes and
-- products still awaiting photos.
-- =====================================================================

-- A3: equipment kit as part of Product identity (NULL = base, no extra kit).
-- TEXT + CHECK (not an enum): the value participates in a COALESCE unique index,
-- and enum::text casts are not IMMUTABLE, so they cannot live in an index expression.
ALTER TABLE products
    ADD COLUMN equipment_variant TEXT
        CHECK (equipment_variant IN ('box','bracket','crashbar','all_boxes','no_boxes')), -- NULL = base (no extra kit)
    ADD COLUMN print_name        TEXT,                          -- NULL = not a print series; else series name (identity + display)
    ADD COLUMN archived_color    BOOLEAN NOT NULL DEFAULT FALSE, -- A2: rare/archived colour, still published
    ADD COLUMN partner_bike      BOOLEAN NOT NULL DEFAULT FALSE, -- A4: partner-owned (Викины); internal only, not shown on card
    ADD COLUMN need_photos       BOOLEAN NOT NULL DEFAULT FALSE; -- known to have no photos yet (explicit, not inferred)

COMMENT ON COLUMN products.equipment_variant IS 'Equipment kit variant that makes this a distinct Product; NULL = base bike.';
COMMENT ON COLUMN products.print_name IS 'Print/sticker series name; NULL = not a print series. Doubles as display badge.';
COMMENT ON COLUMN products.archived_color IS 'Rare/archived colour — published with a "rare colour" badge.';
COMMENT ON COLUMN products.partner_bike IS 'Partner-owned bike (no fleet item). Internal/analytics only; not rendered on card.';
COMMENT ON COLUMN products.need_photos IS 'Explicit flag: this Product is knowingly awaiting photos (no folder in Drive).';

-- Product identity now: family + color + variant + equipment_variant + print_name.
-- Plain UNIQUE would let duplicates through because NULL <> NULL in SQL
-- (same trap hit earlier with insurance_plans) — so make it NULL-safe via COALESCE.
ALTER TABLE products DROP CONSTRAINT products_family_color_variant_key;   -- was: UNIQUE (family_id, color_name, variant)
CREATE UNIQUE INDEX products_identity_key ON products
    (family_id, color_name, variant, COALESCE(equipment_variant, ''), COALESCE(print_name, ''));
