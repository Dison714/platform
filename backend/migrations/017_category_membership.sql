-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 17_category_membership.sql
-- Множественное членство family в категориях каталога (для фильтра)
-- =====================================================================

-- Новая категория для TVS Ronin (решение владельца). sort_order рядом с
-- остальными; имя — ярлык фильтра на сайте.
INSERT INTO vehicle_categories (code, name, sort_order) VALUES
    ('neo_retro_roadster', 'Neo-Retro Roadster', 7);

-- Членство family в категориях ФИЛЬТРА каталога (M2M). Одна модель может
-- показываться под несколькими категориями (TVS Ronin — и Naked/Classic, и
-- Neo-Retro). Это ОТДЕЛЬНО от product_families.category_id — та остаётся
-- «первичной» категорией (ярлык на карточке + взаимозаменяемость, CLAUDE.md
-- §3.1). Здесь — только про то, под какими фильтрами модель видна.
-- Заполняется в seed-crm.js (после создания families): первичная категория
-- каждой family + доп. членства. На свежей БД на момент миграции families ещё нет.
CREATE TABLE family_filter_categories (
    family_id   UUID NOT NULL REFERENCES product_families(id) ON DELETE CASCADE,
    category_id SMALLINT NOT NULL REFERENCES vehicle_categories(id) ON DELETE CASCADE,
    PRIMARY KEY (family_id, category_id)
);
COMMENT ON TABLE family_filter_categories IS 'Членство модели в категориях фильтра каталога (M2M). Включает первичную категорию (product_families.category_id) + доп. ярлыки. Пример: TVS Ronin виден и в Naked/Classic, и в Neo-Retro Roadster.';
