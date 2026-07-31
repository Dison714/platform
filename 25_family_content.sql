-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 25_family_content.sql
-- Long-form marketing content per Family (intro + key benefits + expert
-- tips + FAQ) — separate translations table (CLAUDE.md §3.8), not folded
-- into family_specs (that table is language-neutral numbers/codes; this
-- is prose). Rendered as one HTML block at the bottom of the product
-- page, below the booking calculator. Same across all colors of a
-- family, same as family_specs.
--
-- English-first: getProduct COALESCEs to the 'en' row when a locale's
-- translation is missing, same pattern as product_translations.description.
-- =====================================================================

CREATE TABLE family_content_translations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id       UUID NOT NULL REFERENCES product_families(id) ON DELETE CASCADE,
    language_code   TEXT NOT NULL REFERENCES languages(code),
    content_html    TEXT NOT NULL,   -- safe static HTML: h3/p/ul/li only, no scripts/attrs
    source          TEXT,            -- audit: where the underlying facts came from (like family_specs.source)
    UNIQUE (family_id, language_code)
);
COMMENT ON TABLE family_content_translations IS 'Long-form marketing content per Family (intro + key benefits + expert tips + FAQ), rendered as one HTML block below the booking calculator on the product page. English-first; other locales fall back to en until translated (see catalog.js getProduct).';
