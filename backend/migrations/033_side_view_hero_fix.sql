-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 33_side_view_hero_fix.sql
-- Исправляет 032: часть выбранных "боковых" фото на самом деле были
-- 3/4 спереди/сзади — мелкая сетка контрольного листа (220px) путала их
-- с профилем при похожей общей композиции (байк по диагонали, топкейс).
-- Владелец указал на honda-adv-total-black-box/turquoise-box/pcx-green;
-- остальные 4 найдены при пересборке сеток крупнее (380px) и повторной
-- проверке всех 75 (yamaha-xsr-black, suzuki-vstrom250-total-black-
-- all-boxes — та же ошибка; honda-adv-pink-purple-abs, honda-pcx-
-- purple-abs — чище профиль, не ошибка "перед/зад").
-- =====================================================================

UPDATE product_photos pp
SET is_hero = FALSE
FROM products p
WHERE p.slug IN (
    'honda-adv-total-black-box', 'honda-adv-turquoise-box', 'honda-pcx-green',
    'yamaha-xsr-black', 'suzuki-vstrom250-total-black-all-boxes',
    'honda-adv-pink-purple-abs', 'honda-pcx-purple-abs'
)
AND pp.product_id = p.id
AND pp.is_hero = TRUE;

UPDATE product_photos pp
SET is_hero = TRUE
FROM products p,
(VALUES
    ('honda-adv-total-black-box', 1),
    ('honda-adv-turquoise-box', 1),
    ('honda-pcx-green', 2),
    ('yamaha-xsr-black', 4),
    ('suzuki-vstrom250-total-black-all-boxes', 1),
    ('honda-adv-pink-purple-abs', 1),
    ('honda-pcx-purple-abs', 3)
) AS v(slug, chosen_sort_order)
WHERE p.slug = v.slug
  AND pp.product_id = p.id
  AND pp.sort_order = v.chosen_sort_order;
