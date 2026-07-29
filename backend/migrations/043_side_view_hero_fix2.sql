-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 043_side_view_hero_fix2.sql
-- Продолжение 032/033: ещё 7 products, где выбранное "боковое" фото на
-- самом деле было 3/4 спереди/сзади (проверено визуально через живой
-- рендер каталога, не по сетке миниатюр). Список — из отчёта Дмитрия по
-- CB150X (несколько юнитов, не только часть) + PCX Red/Silver/Sticker LV
-- + Nmax Chameleon + Xmax Cartoon.
-- =====================================================================

UPDATE product_photos pp
SET is_hero = FALSE
FROM products p
WHERE p.slug IN (
    'honda-cb150x-brown', 'honda-cb150x-green',
    'honda-pcx-red', 'honda-pcx-silver', 'honda-pcx-black-abs-sticker-custom',
    'yamaha-nmax-chameleon', 'yamaha-xmax-cartoon-partner'
)
AND pp.product_id = p.id
AND pp.is_hero = TRUE;

UPDATE product_photos pp
SET is_hero = TRUE
FROM products p,
(VALUES
    ('honda-cb150x-brown', 1),
    ('honda-cb150x-green', 4),
    ('honda-pcx-red', 5),
    ('honda-pcx-silver', 3),
    ('honda-pcx-black-abs-sticker-custom', 2),
    ('yamaha-nmax-chameleon', 2),
    ('yamaha-xmax-cartoon-partner', 3)
) AS v(slug, chosen_sort_order)
WHERE p.slug = v.slug
  AND pp.product_id = p.id
  AND pp.sort_order = v.chosen_sort_order;

-- honda-cb150x-black и honda-cb150x-black-box уже были на чистом профиле
-- (проверено визуально) — не трогаем.

-- Перепутанные названия (Дмитрий подтвердил): при переименовании в
-- прошлой сессии color_name у этих двух products поменялись местами.
-- yamaha-nmax-pink-blue — сплошной розовый байк без принта → должен
-- называться "Pink Blue". yamaha-nmax-pink-blue-blue-sky — синий с
-- звёздно-небесным принтом → должен называться "Print Blue Sky".
UPDATE products SET color_name = 'Print Blue Sky' WHERE slug = 'yamaha-nmax-pink-blue-blue-sky';
UPDATE products SET color_name = 'Pink Blue' WHERE slug = 'yamaha-nmax-pink-blue';
