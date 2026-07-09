-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 026_product_photos_storage.sql  (Photos chunk, Step 2A)
-- Extends the existing product_photos table for local-then-CDN storage.
-- Existing columns: id, product_id, source_url, cdn_url, sort_order, created_at.
--   source_url = Drive file id (provenance / re-import)
--   cdn_url    = absolute CDN URL override (populated after R2 migration)
-- Render precedence: cdn_url ?? PHOTO_BASE_URL + '/' + storage_path ?? source_url
-- =====================================================================

ALTER TABLE product_photos
    ADD COLUMN storage_path TEXT,                        -- relative path within our storage: '<slug>/hero/01.webp'
    ADD COLUMN is_hero      BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN product_photos.storage_path IS 'Relative path within our storage (no base). Base comes from env PHOTO_BASE_URL; a→b migration = change env only.';
COMMENT ON COLUMN product_photos.is_hero IS 'Manually-flagged hero photo. Fallback at render: min(sort_order), then first.';

-- At most one hero per product.
CREATE UNIQUE INDEX product_photos_one_hero ON product_photos (product_id) WHERE is_hero;
