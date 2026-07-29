-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 044_nmax_name_photo_fixes.sql
-- Правки по итогам ревью 043 от Дмитрия:
--  1. "Chameleon" лишний в названии Nmax Print Sky Pink — убрать.
--  2. Print Blue Sky: название уже содержит "Print Blue Sky", отдельный
--     красный бейдж "Print: Blue Sky" — дублирование, убрать.
--  3. Nmax Pink Blue и Nmax Print Blue Sky (043 менял только color_name,
--     hero-фото не проверялся) — тоже были не в профиль, исправлено.
-- =====================================================================

UPDATE products SET color_name = 'Print Sky Pink' WHERE slug = 'yamaha-nmax-chameleon-sky-pink';

UPDATE products SET print_name = NULL WHERE slug = 'yamaha-nmax-pink-blue-blue-sky';

UPDATE product_photos pp
SET is_hero = FALSE
FROM products p
WHERE p.slug IN ('yamaha-nmax-pink-blue', 'yamaha-nmax-pink-blue-blue-sky')
AND pp.product_id = p.id
AND pp.is_hero = TRUE;

UPDATE product_photos pp
SET is_hero = TRUE
FROM products p,
(VALUES
    ('yamaha-nmax-pink-blue', 1),
    ('yamaha-nmax-pink-blue-blue-sky', 3)
) AS v(slug, chosen_sort_order)
WHERE p.slug = v.slug
  AND pp.product_id = p.id
  AND pp.sort_order = v.chosen_sort_order;
