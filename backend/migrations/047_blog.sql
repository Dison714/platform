-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA
-- 047_blog.sql
-- Блог: article_categories → articles → article_translations,
-- article_category_translations (ТЗ п.4.15, pillar+cluster).
-- =====================================================================
-- Заменяет мёртвый прототип articles/article_translations из 007_website_
-- content.sql: та пара не имела category_id/is_pillar/status/slug (ТЗ
-- п.4.15 тогда ещё не было написано), ни разу не использовалась ни одним
-- route/service на бэкенде и ни одной страницей на фронте, в обеих
-- таблицах 0 строк на dev БД — просто ранний scaffold без потребителей.
-- Дропаем и создаём заново по актуальной спецификации, а не ALTER —
-- пересекающихся по смыслу полей почти нет (city старой таблицы: cover_
-- image_url/created_by/is_active — ни одно не входит в новую форму).
-- =====================================================================

DROP TABLE IF EXISTS article_translations;
DROP TABLE IF EXISTS articles;

CREATE TYPE article_status AS ENUM ('draft', 'published');

-- ---------------------------------------------------------------------
-- ARTICLE CATEGORIES — тематическая категория блога (хаб pillar+cluster)
-- ---------------------------------------------------------------------
CREATE TABLE article_categories (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug          TEXT NOT NULL UNIQUE,   -- стабильный, для миграций/ссылок в коде, не показывается клиенту напрямую
    display_order SMALLINT NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE article_categories IS 'ТЗ п.4.15: тематическая категория блога (deposit-safety, legal, bike-models, routes, digital-nomads). slug стабильный (ключ для сидов/кода), локализованный URL-slug — в article_category_translations.';

-- ---------------------------------------------------------------------
-- ARTICLES — статья блога
-- ---------------------------------------------------------------------
CREATE TABLE articles (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug                     TEXT NOT NULL UNIQUE,   -- стабильный, как article_categories.slug
    category_id              UUID NOT NULL REFERENCES article_categories(id),
    is_pillar                BOOLEAN NOT NULL DEFAULT FALSE,
    related_product_family_id UUID REFERENCES product_families(id),
    status                   article_status NOT NULL DEFAULT 'draft',
    published_at             TIMESTAMPTZ,
    author                   TEXT,
    featured_image_url       TEXT,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE articles IS 'ТЗ п.4.15: is_pillar — хаб-статья категории (одна на категорию по конвенции, не enforced в БД — редакционное решение). related_product_family_id — опциональная связь с моделью байка (гайды по моделям, п.3.1), без отдельной таблицы связей.';

CREATE INDEX idx_articles_slug ON articles(slug);
CREATE INDEX idx_articles_category_id ON articles(category_id);

CREATE TRIGGER trg_articles_upd BEFORE UPDATE ON articles FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------
-- ARTICLE TRANSLATIONS (ТЗ п.4.9.4 — отдельная таблица перевода на сущность)
-- ---------------------------------------------------------------------
CREATE TABLE article_translations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    article_id      UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    language_code   TEXT NOT NULL REFERENCES languages(code),
    title           TEXT NOT NULL,
    slug            TEXT NOT NULL,          -- локализованный URL-slug (п.4.9.3), не путать с articles.slug
    excerpt         TEXT,
    content         TEXT,
    seo_title       TEXT,
    seo_description TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (article_id, language_code),
    UNIQUE (language_code, slug)
);
COMMENT ON TABLE article_translations IS 'ТЗ п.4.15/п.4.9.3: каждая языковая версия — отдельная страница со своим slug/meta, резолв по (language_code, slug), не JS-переключатель.';

CREATE INDEX idx_article_translations_article_lang ON article_translations(article_id, language_code);
CREATE INDEX idx_article_translations_slug ON article_translations(slug);

CREATE TRIGGER trg_article_translations_upd BEFORE UPDATE ON article_translations FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------
-- ARTICLE CATEGORY TRANSLATIONS
-- ---------------------------------------------------------------------
CREATE TABLE article_category_translations (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id   UUID NOT NULL REFERENCES article_categories(id) ON DELETE CASCADE,
    language_code TEXT NOT NULL REFERENCES languages(code),
    name          TEXT NOT NULL,
    slug          TEXT NOT NULL,           -- локализованный URL-slug категории-хаба
    description   TEXT,                    -- вступление на странице-хабе категории
    UNIQUE (category_id, language_code),
    UNIQUE (language_code, slug)
);
COMMENT ON TABLE article_category_translations IS 'ТЗ п.4.15: description используется как вступление на странице-хабе категории.';

CREATE INDEX idx_article_category_translations_category_lang ON article_category_translations(category_id, language_code);
CREATE INDEX idx_article_category_translations_slug ON article_category_translations(slug);
