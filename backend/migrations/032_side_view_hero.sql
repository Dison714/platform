-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 32_side_view_hero.sql
-- Главное фото (thumb/hero) карточки — выбрано визуально по каждому
-- product (просмотр галерей, Блок 1). Раньше is_hero везде FALSE →
-- thumb брался по sort_order=1 (произвольный кадр съёмки). Теперь —
-- явный кадр "сбоку" (профиль байка), где такой был в галерее; для 4
-- products без чистого профиля — наименее плохой вариант (решение
-- владельца, не гадать дальше руками).
-- =====================================================================

UPDATE product_photos pp
SET is_hero = TRUE
FROM products p,
(VALUES
    ('honda-adv-brown-road-sync', 1),
    ('honda-adv-chameleon-abs', 2),
    ('honda-adv-chameleon-cbs', 1),
    ('honda-adv-cream', 1),
    ('honda-adv-pink-purple-abs', 2),
    ('honda-adv-total-black-box', 3),
    ('honda-adv-total-black', 6),
    ('honda-adv-turquoise-box', 5),
    ('honda-adv-turquoise-bracket', 1),
    ('honda-adv-turquoise-road-sync', 1),
    ('honda-adv-turquoise', 1),
    ('honda-adv-white', 7),
    ('honda-cb150x-black', 2),
    ('honda-cb150x-brown', 2),
    ('honda-cb150x-green', 2),
    ('honda-cb150x-total-black', 2),
    ('honda-cbr250rr-white-blue', 1),
    ('honda-pcx-black-abs-sticker-custom', 1),
    ('honda-pcx-green', 1),
    ('honda-pcx-orange-box', 6),
    ('honda-pcx-orange', 1),
    ('honda-pcx-pink-blue-abs', 1),
    ('honda-pcx-pink-blue-cbs-anime', 1),
    ('honda-pcx-pink-blue-cbs', 4),
    ('honda-pcx-purple-abs', 5),
    ('honda-pcx-purple-cbs', 4),
    ('honda-pcx-red', 3),
    ('honda-pcx-silver', 1),
    ('honda-pcx-yellow-green', 1),
    ('kawasaki-versys-black-no-boxes', 1),
    ('kawasaki-versys-black', 2),
    ('kawasaki-zx25r-biru', 3),
    ('morbidelli-c252v-black', 1),
    ('suzuki-vstrom250-black-crashbar', 1),
    ('suzuki-vstrom250-black', 2),
    ('suzuki-vstrom250-total-black-all-boxes', 4),
    ('suzuki-vstrom250-total-black', 5),
    ('tvs-ronin225-total-black', 7),
    ('yamaha-mt25-black-box', 1),
    ('yamaha-mt25-black-red-box', 2),
    ('yamaha-mt25-black-red', 2),
    ('yamaha-mt25-black', 1),
    ('yamaha-mt25-chameleon', 1),
    ('yamaha-nmax-black', 3),
    ('yamaha-nmax-blue', 5),
    ('yamaha-nmax-chameleon-sky-pink', 1),
    ('yamaha-nmax-chameleon', 5),
    ('yamaha-nmax-dark-green', 3),
    ('yamaha-nmax-green-box', 1),
    ('yamaha-nmax-green', 1),
    ('yamaha-nmax-light-green', 1),
    ('yamaha-nmax-neo-blue-partner', 1),
    ('yamaha-nmax-neo-s-black-partner', 2),
    ('yamaha-nmax-neo-s-white-partner', 2),
    ('yamaha-nmax-pink-blue-blue-sky', 2),
    ('yamaha-nmax-pink-blue', 2),
    ('yamaha-nmax-pink-purple', 2),
    ('yamaha-nmax-purple', 1),
    ('yamaha-nmax-red', 1),
    ('yamaha-xmax-black-partner', 2),
    ('yamaha-xmax-cartoon-partner', 1),
    ('yamaha-xmax-chameleon', 1),
    ('yamaha-xmax-dark-green-partner', 3),
    ('yamaha-xmax-green-blue-wheels', 1),
    ('yamaha-xmax-green-blue', 7),
    ('yamaha-xmax-green', 3),
    ('yamaha-xmax-grey-partner', 4),
    ('yamaha-xmax-grey', 3),
    ('yamaha-xmax-pink', 1),
    ('yamaha-xmax-red-partner', 1),
    ('yamaha-xmax-silver', 1),
    ('yamaha-xsr-black-box', 1),
    ('yamaha-xsr-black-bracket', 1),
    ('yamaha-xsr-black', 5),
    ('yamaha-xsr-total-black', 1)
) AS v(slug, chosen_sort_order)
WHERE p.slug = v.slug
  AND pp.product_id = p.id
  AND pp.sort_order = v.chosen_sort_order;
