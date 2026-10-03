-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA
-- 074_seo_collector.sql
-- SEO-сборщик (репозиторий mdb-seo-monitoring, этап 1): GSC Search Analytics,
-- GSC URL Inspection, GSC Sitemaps, GA4, реестр URL из sitemap, журнал запусков
-- и журнал алертов. Те же правила, что у 050_seo_performance_snapshots:
-- таблицы пишет внешний cron-контейнер, не бэкенд платформы.
--
-- Решения:
--  * Все таблицы с префиксом seo_, без company_id — это данные одного сайта
--    (ресурс GSC sc-domain:bikebalirent.com, property GA4 475714547), а не
--    доменные сущности платформы. Второй сайт/компания = второй ресурс; тогда
--    добавляется колонка site в PK, а не миграция существующих данных.
--  * Фактовые таблицы — upsert по естественному ключу (идемпотентный
--    перезалив последних дней). История проверок индексации — наоборот,
--    append-only (одна строка на проверку), поэтому bigserial + сырой JSON.
--  * Итоги GSC по дням хранятся отдельно (seo_gsc_daily), а не суммой по
--    запросам: скрытые (анонимизированные) запросы не попадают в разрез
--    «запрос», и сумма не сходится с итогом.
--  * ctr в долях (0..1), как отдаёт API. position — средняя позиция API.
-- =====================================================================

-- ---------- GSC Search Analytics (type=web, dataState=final) ----------

CREATE TABLE seo_gsc_daily (
    date         DATE PRIMARY KEY,
    clicks       INTEGER NOT NULL,
    impressions  INTEGER NOT NULL,
    ctr          NUMERIC NOT NULL,
    position     NUMERIC NOT NULL,
    fetched_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE seo_gsc_daily IS 'Итоги GSC по дням (dimension=date), получены отдельным запросом, НЕ суммой других срезов.';

CREATE TABLE seo_gsc_page_daily (
    date         DATE NOT NULL,
    page         TEXT NOT NULL,
    clicks       INTEGER NOT NULL,
    impressions  INTEGER NOT NULL,
    ctr          NUMERIC NOT NULL,
    position     NUMERIC NOT NULL,
    fetched_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (date, page)
);
CREATE INDEX idx_seo_gsc_page_daily_page ON seo_gsc_page_daily (page, date DESC);

CREATE TABLE seo_gsc_query_page_daily (
    date         DATE NOT NULL,
    page         TEXT NOT NULL,
    query        TEXT NOT NULL,
    clicks       INTEGER NOT NULL,
    impressions  INTEGER NOT NULL,
    ctr          NUMERIC NOT NULL,
    position     NUMERIC NOT NULL,
    fetched_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (date, page, query)
);
CREATE INDEX idx_seo_gsc_query_page_daily_query ON seo_gsc_query_page_daily (query, date DESC);
CREATE INDEX idx_seo_gsc_query_page_daily_page ON seo_gsc_query_page_daily (page, date DESC);
COMMENT ON TABLE seo_gsc_query_page_daily IS 'GSC дата × страница × запрос. Скрытые запросы в разрез не попадают — суммы не сходятся с seo_gsc_page_daily, это ожидаемо.';

CREATE TABLE seo_gsc_country_daily (
    date         DATE NOT NULL,
    country      TEXT NOT NULL,          -- ISO-3166-1 alpha-3 в нижнем регистре, как отдаёт API
    clicks       INTEGER NOT NULL,
    impressions  INTEGER NOT NULL,
    ctr          NUMERIC NOT NULL,
    position     NUMERIC NOT NULL,
    fetched_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (date, country)
);

CREATE TABLE seo_gsc_device_daily (
    date         DATE NOT NULL,
    device       TEXT NOT NULL,          -- DESKTOP | MOBILE | TABLET
    clicks       INTEGER NOT NULL,
    impressions  INTEGER NOT NULL,
    ctr          NUMERIC NOT NULL,
    position     NUMERIC NOT NULL,
    fetched_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (date, device)
);

-- ---------- Реестр URL из живого sitemap.xml ----------

CREATE TABLE seo_sitemap_urls (
    url          TEXT PRIMARY KEY,
    first_seen   DATE NOT NULL DEFAULT CURRENT_DATE,   -- первый день, когда URL увидели в sitemap
    last_seen    DATE NOT NULL DEFAULT CURRENT_DATE,   -- последний день, когда он там был
    lastmod      TIMESTAMPTZ,
    template     TEXT,
    locale       TEXT,
    category     TEXT                                  -- категория статьи блога, иначе NULL
);
CREATE INDEX idx_seo_sitemap_urls_last_seen ON seo_sitemap_urls (last_seen);
COMMENT ON TABLE seo_sitemap_urls IS 'Реестр URL из sitemap.xml. first_seen нужен правилам «в sitemap 7+ дней» и приоритету URL Inspection (новые < 30 дней). Для URL, существовавших до первого запуска сборщика, first_seen = дата первого запуска (реальная дата неизвестна).';

-- ---------- GSC URL Inspection: история проверок ----------

CREATE TABLE seo_url_inspections (
    id                BIGSERIAL PRIMARY KEY,
    url               TEXT NOT NULL,
    checked_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    verdict           TEXT,              -- PASS | NEUTRAL | FAIL | PARTIAL | VERDICT_UNSPECIFIED
    coverage_state    TEXT,
    robots_txt_state  TEXT,
    indexing_state    TEXT,
    page_fetch_state  TEXT,
    last_crawl_time   TIMESTAMPTZ,
    google_canonical  TEXT,
    user_canonical    TEXT,
    crawled_as        TEXT,
    referring_urls    JSONB,
    sitemaps          JSONB,
    template          TEXT,
    locale            TEXT,
    category          TEXT,
    error             TEXT,              -- ошибка API (тогда поля выше NULL)
    raw               JSONB              -- сырой ответ API целиком
);
CREATE INDEX idx_seo_url_inspections_url_checked ON seo_url_inspections (url, checked_at DESC);
CREATE INDEX idx_seo_url_inspections_checked ON seo_url_inspections (checked_at DESC);
COMMENT ON TABLE seo_url_inspections IS 'Append-only: одна строка на каждую проверку URL (URL Inspection API). Текущий статус URL = последняя строка по checked_at.';

-- ---------- GSC Sitemaps ----------

CREATE TABLE seo_sitemap_status (
    id                BIGSERIAL PRIMARY KEY,
    checked_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    path              TEXT NOT NULL,
    is_pending        BOOLEAN,
    is_sitemaps_index BOOLEAN,
    last_submitted    TIMESTAMPTZ,
    last_downloaded   TIMESTAMPTZ,     -- «дата последней обработки»
    errors            INTEGER,
    warnings          INTEGER,
    submitted_urls    INTEGER,         -- сумма contents[].submitted (web)
    indexed_urls      INTEGER,         -- сумма contents[].indexed; API его больше не заполняет, обычно NULL/0
    raw               JSONB
);
CREATE INDEX idx_seo_sitemap_status_path_checked ON seo_sitemap_status (path, checked_at DESC);

-- ---------- GA4 (property 475714547) ----------

CREATE TABLE seo_ga4_channel_device (
    date               DATE NOT NULL,
    channel            TEXT NOT NULL,       -- sessionDefaultChannelGroup
    device             TEXT NOT NULL,       -- deviceCategory
    sessions           INTEGER NOT NULL,
    engaged_sessions   INTEGER NOT NULL,
    engagement_seconds NUMERIC NOT NULL,    -- userEngagementDuration
    page_views         INTEGER NOT NULL,
    key_events         NUMERIC NOT NULL,
    fetched_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (date, channel, device)
);

CREATE TABLE seo_ga4_landing_channel (
    date               DATE NOT NULL,
    landing_page       TEXT NOT NULL,
    channel            TEXT NOT NULL,
    sessions           INTEGER NOT NULL,
    engaged_sessions   INTEGER NOT NULL,
    engagement_seconds NUMERIC NOT NULL,
    page_views         INTEGER NOT NULL,
    key_events         NUMERIC NOT NULL,
    fetched_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (date, landing_page, channel)
);
CREATE INDEX idx_seo_ga4_landing_channel_page ON seo_ga4_landing_channel (landing_page, date DESC);

CREATE TABLE seo_ga4_geo (
    date               DATE NOT NULL,
    channel            TEXT NOT NULL,
    country            TEXT NOT NULL,
    city               TEXT NOT NULL,       -- '(not set)' как отдаёт GA4; Singapore исключается при чтении, не при записи
    sessions           INTEGER NOT NULL,
    engaged_sessions   INTEGER NOT NULL,
    engagement_seconds NUMERIC NOT NULL,
    page_views         INTEGER NOT NULL,
    key_events         NUMERIC NOT NULL,
    fetched_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (date, channel, country, city)
);

CREATE TABLE seo_ga4_events (
    date         DATE NOT NULL,
    event_name   TEXT NOT NULL,
    channel      TEXT NOT NULL,
    event_count  INTEGER NOT NULL,
    key_events   NUMERIC NOT NULL,
    fetched_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (date, event_name, channel)
);

-- ---------- Журнал запусков сборщиков и журнал алертов ----------

CREATE TABLE seo_collector_runs (
    id            BIGSERIAL PRIMARY KEY,
    module        TEXT NOT NULL,
    started_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    finished_at   TIMESTAMPTZ,
    status        TEXT NOT NULL DEFAULT 'running' CHECK (status IN ('running', 'ok', 'failed', 'skipped')),
    rows_written  INTEGER,
    detail        JSONB,               -- квота, диапазон дат, режим (dry-run/backfill)
    error         TEXT
);
CREATE INDEX idx_seo_collector_runs_module_started ON seo_collector_runs (module, started_at DESC);

CREATE TABLE seo_alert_log (
    id            BIGSERIAL PRIMARY KEY,
    rule          TEXT NOT NULL,       -- П1..П5 или psi_*, ...
    alert_key     TEXT NOT NULL,       -- ключ дедупликации (правило + группа)
    state_hash    TEXT NOT NULL,       -- отпечаток состояния: изменился → повторяем
    summary       TEXT,
    payload       JSONB,
    sent_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_seo_alert_log_key_sent ON seo_alert_log (alert_key, sent_at DESC);
COMMENT ON TABLE seo_alert_log IS 'Дедупликация алертов: повтор того же alert_key только при смене state_hash или раз в 7 дней.';
