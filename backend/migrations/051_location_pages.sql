-- Location landing pages (SEO district pages, e.g. /scooter-rental-canggu).
-- NOT article_translations (single markdown blob per locale) — this page
-- type needs independently editable/translatable blocks (Delivery /
-- Getting Around / Distances / Which Bike Fits / Route / Photos / FAQ /
-- CTA), so each block is its own column rather than one content_html field.
-- Also NOT landing_pages/landing_page_translations (007_website_content.sql)
-- — that pair is for UTM-campaign landers (single content_html blob, keyed
-- by utm code), a different concept from an indexable per-district SEO page.
CREATE TABLE location_pages (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id  UUID NOT NULL REFERENCES companies(id),
    slug        TEXT NOT NULL,              -- 'canggu' -> /scooter-rental-canggu
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (company_id, slug)
);
COMMENT ON TABLE location_pages IS 'SEO-районные страницы (scooter-rental-<district>) — не блог-пост, не UTM-лендинг. Один ряд на район.';

CREATE TABLE location_page_translations (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_page_id      UUID NOT NULL REFERENCES location_pages(id) ON DELETE CASCADE,
    language_code         TEXT NOT NULL REFERENCES languages(code),
    seo_title             TEXT,
    seo_description       TEXT,
    h1                    TEXT NOT NULL,
    intro                 TEXT NOT NULL,     -- above-the-fold lede paragraph
    delivery_summary      TEXT NOT NULL,     -- short one-line hero stat (price+terms)
    delivery_html         TEXT,              -- Delivery section body
    getting_around_html   TEXT,              -- Getting Around section body
    distances             JSONB,             -- [{destination, distance, light, peak}]
    which_bike_html       TEXT,              -- Which Bike Fits section body
    route_html            TEXT,              -- Popular Route section (nullable — TODO placeholder text lives here until real content exists)
    photos_note           TEXT,              -- Photos section (nullable — TODO placeholder until real photos exist)
    faq                   JSONB,             -- [{q, a, link: {label, href}?}] — shape matches FaqAccordion props directly
    cta_text              TEXT,              -- bottom CTA block copy
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (location_page_id, language_code)
);
COMMENT ON TABLE location_page_translations IS 'Блочная структура, отдельные переводимые поля на блок (не единый HTML-блоб, как у article_translations.content) — п.3.8 CLAUDE.md, ключ (location_page_id, language_code) по образцу article_translations.';

CREATE TRIGGER trg_location_pages_upd BEFORE UPDATE ON location_pages FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_location_page_translations_upd BEFORE UPDATE ON location_page_translations FOR EACH ROW EXECUTE FUNCTION set_updated_at();
