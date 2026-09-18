-- District page hero photo — one per district, shared across all 11
-- locales (same pattern as articles.featured_image_url, not per-translation:
-- a landscape/beach photo of Canggu doesn't change by language). Lives on
-- location_pages (the per-district row), not location_page_translations.
--
-- photos_note (location_page_translations) is a different, unrelated field —
-- a dead internal TODO note nulled out in 059_fix_district_todo_leaks.sql,
-- never a photo URL. Not reused here.
ALTER TABLE location_pages ADD COLUMN hero_image_url TEXT;
COMMENT ON COLUMN location_pages.hero_image_url IS 'District hero photo (R2 districts/<slug>.jpg) — one per district, rendered on the location page hero block, all locales.';
