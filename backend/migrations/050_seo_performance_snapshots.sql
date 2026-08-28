-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA
-- 050_seo_performance_snapshots.sql
-- Core Web Vitals мониторинг (PageSpeed Insights API) — история замеров
-- по URL/языку/стратегии (mobile/desktop). Append-only лог, без UPDATE —
-- поэтому без updated_at/триггера.
-- =====================================================================

CREATE TABLE seo_performance_snapshots (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id         UUID NOT NULL REFERENCES companies(id),
    url                TEXT NOT NULL,
    strategy           TEXT NOT NULL CHECK (strategy IN ('mobile', 'desktop')),
    language           TEXT,
    performance_score  NUMERIC,
    lcp_ms             INTEGER,
    cls                NUMERIC,
    inp_ms             INTEGER,
    ttfb_ms            INTEGER,
    fcp_ms             INTEGER,
    checked_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE seo_performance_snapshots IS 'Снимки Core Web Vitals с PageSpeed Insights API (runPagespeed), пишутся внешним cron-скриптом из отдельного репозитория (не в периметре Coolify-автодеплоя платформы). MVP: strategy=mobile, 3 языка главной + одна карточка модели.';

CREATE INDEX idx_seo_performance_snapshots_url_checked_at ON seo_performance_snapshots (url, checked_at DESC);
