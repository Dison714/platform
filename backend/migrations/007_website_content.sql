-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 07_website_content.sql
-- Pages · Articles · FAQ · Landing Pages (все с переводами) · Analytics
-- =====================================================================
-- Phase 1 (v1.0): только Website (ТЗ п.19.1). Контент принадлежит CMS,
-- не коду (ТЗ п.4.8). Переводы — отдельная таблица на сущность (п.4.9.4).
-- =====================================================================

CREATE TABLE pages (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id  UUID NOT NULL REFERENCES companies(id),
    code        TEXT NOT NULL,            -- home, about, calculator, contacts
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (company_id, code)
);

CREATE TABLE page_translations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    page_id         UUID NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
    language_code   TEXT NOT NULL REFERENCES languages(code),
    title           TEXT NOT NULL,
    content_html    TEXT,
    seo_title       TEXT,
    seo_description TEXT,
    url_path        TEXT NOT NULL,
    structured_data JSONB,                 -- Schema.org (ТЗ п.4.4)
    UNIQUE (page_id, language_code),
    UNIQUE (language_code, url_path)
);

CREATE TABLE articles (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id      UUID NOT NULL REFERENCES companies(id),
    cover_image_url TEXT,
    published_at    TIMESTAMPTZ,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_by      UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE article_translations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    article_id      UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    language_code   TEXT NOT NULL REFERENCES languages(code),
    title           TEXT NOT NULL,
    excerpt         TEXT,
    content_html    TEXT NOT NULL,
    seo_title       TEXT,
    seo_description TEXT,
    url_path        TEXT NOT NULL,
    UNIQUE (article_id, language_code),
    UNIQUE (language_code, url_path)
);

CREATE TABLE faqs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id  UUID NOT NULL REFERENCES companies(id),
    category    TEXT,                    -- booking, insurance, deposit, documents
    sort_order  SMALLINT NOT NULL DEFAULT 0,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE faq_translations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    faq_id          UUID NOT NULL REFERENCES faqs(id) ON DELETE CASCADE,
    language_code   TEXT NOT NULL REFERENCES languages(code),
    question        TEXT NOT NULL,
    answer          TEXT NOT NULL,
    UNIQUE (faq_id, language_code)
);

CREATE TABLE landing_pages (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id      UUID NOT NULL REFERENCES companies(id),
    code            TEXT NOT NULL,
    utm_source      TEXT,
    utm_campaign    TEXT,
    featured_products UUID[],              -- какие Products показывать
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (company_id, code)
);
COMMENT ON TABLE landing_pages IS 'ТЗ п.4.7: лендинги внутри сайта, тот же каталог/цены/данные, не отдельный сайт. featured_products — какие карточки выводить.';

CREATE TABLE landing_page_translations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    landing_page_id UUID NOT NULL REFERENCES landing_pages(id) ON DELETE CASCADE,
    language_code   TEXT NOT NULL REFERENCES languages(code),
    headline        TEXT NOT NULL,
    content_html    TEXT,
    seo_title       TEXT,
    seo_description TEXT,
    url_path        TEXT NOT NULL,
    UNIQUE (landing_page_id, language_code),
    UNIQUE (language_code, url_path)
);

-- ---------------------------------------------------------------------
-- ANALYTICS — события для внутренних бизнес-метрик (ТЗ п.4.6, п.17)
-- ---------------------------------------------------------------------
CREATE TABLE web_events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id      UUID NOT NULL REFERENCES companies(id),
    event_code      TEXT NOT NULL,           -- booking_started, booking_completed, whatsapp_click,
                                              -- calculator_used, insurance_selected, equipment_added, review_submitted
    session_id      TEXT,
    customer_id     UUID REFERENCES customers(id),
    booking_id      UUID REFERENCES bookings(id),
    utm_source      TEXT,
    utm_campaign    TEXT,
    metadata        JSONB NOT NULL DEFAULT '{}',
    occurred_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE web_events IS 'ТЗ п.4.6/п.17: минимум для внутренних метрик (конверсия калькулятора, доля отказов страховки/оборудования, число замен). Полная веб-аналитика — Google Analytics, не дублируется.';

CREATE INDEX idx_web_events ON web_events(event_code, occurred_at);
