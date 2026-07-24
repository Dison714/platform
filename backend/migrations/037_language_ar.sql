-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 037_language_ar.sql
-- Арабский добавлен в Phase 1 решением от 23.07.2026 (RTL, вместе с
-- de/fr/es/it/ja, которые уже были в сиде 001_foundation.sql).
-- =====================================================================

INSERT INTO languages (code, name, launch_phase, sort_order) VALUES
    ('ar', 'Arabic', 1, 16);
