-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 027_partner_identity.sql  (Photos chunk, Step 2B)
-- A partner-owned bike can legitimately share family+color+variant with an
-- owned bike (e.g. Yamaha Xmax Grey exists both in our fleet #14 and in the
-- partner "Викины" pool). Add partner_bike to the Product identity so the two
-- do not collide on the unique key.
-- =====================================================================

DROP INDEX products_identity_key;
CREATE UNIQUE INDEX products_identity_key ON products
    (family_id, color_name, variant, COALESCE(equipment_variant, ''), COALESCE(print_name, ''), partner_bike);
