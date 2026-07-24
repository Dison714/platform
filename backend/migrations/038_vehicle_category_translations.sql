-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 038_vehicle_category_translations.sql
-- Переводы названий категорий фильтра каталога — зеркало
-- product_translations / equipment_type_translations (тот же пилот
-- архитектуры переводов на сущность, ТЗ п.4.9.4). vehicle_categories.name
-- остаётся fallback. Заменяет текущий dict.cat-оверлей на фронте
-- (frontend/src/i18n/dictionaries/*.json) — тот перевод и жил не в БД,
-- и покрывал только часть кодов category/family, используемых в фильтре.
-- =====================================================================

CREATE TABLE vehicle_category_translations (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id   SMALLINT NOT NULL REFERENCES vehicle_categories(id) ON DELETE CASCADE,
    language_code TEXT NOT NULL REFERENCES languages(code),
    name          TEXT NOT NULL,
    UNIQUE (category_id, language_code)
);
COMMENT ON TABLE vehicle_category_translations IS 'Локализованные названия категорий фильтра каталога (ТЗ п.4.9.4, зеркало product_translations). Резолв: COALESCE(перевод[lang] → перевод[en] → vehicle_categories.name), тем же паттерном что и listProducts/getProduct в catalog.js.';
