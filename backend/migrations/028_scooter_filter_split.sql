-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 28_scooter_filter_split.sql
-- Каталог: разбивка фильтров "Scooter 160cc" + "Maxi Scooter" на 5
-- модельных фильтров; MT-25 доп. видим в Naked/Classic; Cruiser — новый
-- лейбл. Решение владельца.
-- =====================================================================

-- ⚠️ Осознанно меняет решение CLAUDE.md §3.1: scooter_160 документировался
-- как группа прямой взаимозаменяемости (PCX/Nmax/ADV/Vario). После этой
-- миграции у каждой модели — своя категория (нужно для фильтра каталога),
-- группы взаимозаменяемости для них больше нет на уровне vehicle_categories.
-- Когда будет строиться логика замены байка (Rental lifecycle) — для этих
-- 5 моделей взаимозаменяемость нужно будет задать явно через
-- replacement_matrix (граф), а не через общую категорию. CLAUDE.md §3.1
-- обновлён отдельно.
COMMENT ON TABLE vehicle_categories IS 'Категории каталога: часть — модельные фильтры (одна категория = одна модель, напр. honda_adv160), часть — группы взаимозаменяемости (touring/naked_classic/sport/cruiser/neo_retro_roadster — используются и как фильтр, и как группа для будущей логики замены байка, CLAUDE.md §3.1). Межкатегорийные апгрейды — через replacement_matrix.';

-- Новые категории-фильтры по модели (замена scooter_160/maxi_scooter).
INSERT INTO vehicle_categories (code, name, sort_order) VALUES
    ('honda_adv160',   'Honda ADV 160',   1),
    ('honda_pcx160',   'Honda PCX 160',   2),
    ('honda_vario160', 'Honda Vario 160', 3),
    ('yamaha_nmax155', 'Yamaha Nmax 155', 4),
    ('yamaha_xmax250', 'Yamaha Xmax 250', 5);

-- Освобождаем sort_order 1-5 под новые категории, переставляем остальные следом.
UPDATE vehicle_categories SET sort_order = 6  WHERE code = 'touring';
UPDATE vehicle_categories SET sort_order = 7  WHERE code = 'naked_classic';
UPDATE vehicle_categories SET sort_order = 8  WHERE code = 'sport';
UPDATE vehicle_categories SET sort_order = 9  WHERE code = 'cruiser';
UPDATE vehicle_categories SET sort_order = 10 WHERE code = 'neo_retro_roadster';

-- Первичная категория (бейдж карточки) для 5 скутеров — на новую персональную.
UPDATE product_families SET category_id = (SELECT id FROM vehicle_categories WHERE code = 'honda_adv160')
    WHERE code = 'honda_adv';
UPDATE product_families SET category_id = (SELECT id FROM vehicle_categories WHERE code = 'honda_pcx160')
    WHERE code = 'honda_pcx';
UPDATE product_families SET category_id = (SELECT id FROM vehicle_categories WHERE code = 'honda_vario160')
    WHERE code = 'honda_vario';
UPDATE product_families SET category_id = (SELECT id FROM vehicle_categories WHERE code = 'yamaha_nmax155')
    WHERE code = 'yamaha_nmax';
UPDATE product_families SET category_id = (SELECT id FROM vehicle_categories WHERE code = 'yamaha_xmax250')
    WHERE code = 'yamaha_xmax';

-- Членство в фильтрах (family_filter_categories) — синхронизируем со старой
-- на новую первичную категорию.
DELETE FROM family_filter_categories
    WHERE category_id IN (SELECT id FROM vehicle_categories WHERE code IN ('scooter_160', 'maxi_scooter'));

INSERT INTO family_filter_categories (family_id, category_id)
    SELECT id, category_id FROM product_families
    WHERE code IN ('honda_adv', 'honda_pcx', 'honda_vario', 'yamaha_nmax', 'yamaha_xmax');

-- MT-25: двойное членство — category_id остаётся Sport (бейдж не меняем),
-- доп. видим в Naked/Classic (тот же паттерн, что TVS Ronin → Neo-Retro
-- Roadster в 017_category_membership.sql).
INSERT INTO family_filter_categories (family_id, category_id)
    SELECT pf.id, vc.id
    FROM product_families pf, vehicle_categories vc
    WHERE pf.code = 'yamaha_mt25' AND vc.code = 'naked_classic'
    ON CONFLICT DO NOTHING;

-- Старые категории больше не используются (все ссылки перенесены выше).
DELETE FROM vehicle_categories WHERE code IN ('scooter_160', 'maxi_scooter');

-- Cruiser — расширенный лейбл (решение владельца, оба языка; en/ru лейблы
-- фильтра также обновлены в frontend/src/i18n/dictionaries/{en,ru}.json).
UPDATE vehicle_categories SET name = 'Cruiser / Bobber / Chopper' WHERE code = 'cruiser';
