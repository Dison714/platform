-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 30_price_matching.sql
-- Матчинг цен: 37 products без price_rules получают цену "донора" —
-- уже оценённого продукта той же Family (тот же цвет+вариант, либо, где
-- у модели несколько ценовых тиров и точного совпадения нет, — дешёвый
-- тир, решение владельца). Правило: перекрашенный байк = та же цена.
-- =====================================================================

INSERT INTO price_rules (rule_set_id, product_id, rental_days, price_idr)
SELECT pr.rule_set_id, tgt.id, pr.rental_days, pr.price_idr
FROM price_rules pr
JOIN products donor ON donor.id = pr.product_id
JOIN (VALUES
    -- Honda ADV: тот же цвет (box/bracket — доп. оборудование, White — безвариантный тир)
    ('honda-adv-total-black',         'honda-adv-total-black-box'),
    ('honda-adv-turquoise',           'honda-adv-turquoise-bracket'),
    ('honda-adv-turquoise',           'honda-adv-turquoise-box'),
    ('honda-adv-turquoise',           'honda-adv-white'),
    ('honda-adv-turquoise-road-sync', 'honda-adv-brown-road-sync'),
    -- Honda CB150X: единая цена у модели
    ('honda-cb150x-total-black',      'honda-cb150x-brown'),
    ('honda-cb150x-total-black',      'honda-cb150x-green'),
    -- Honda PCX: базовый тир (Orange) для box + Red/Silver (решение владельца);
    -- ABS/CBS — тот же цвет+вариант уже оценён
    ('honda-pcx-orange',              'honda-pcx-orange-box'),
    ('honda-pcx-orange',              'honda-pcx-red'),
    ('honda-pcx-orange',              'honda-pcx-silver'),
    ('honda-pcx-purple-abs',          'honda-pcx-black-abs-sticker-custom'),
    ('honda-pcx-pink-blue-cbs',       'honda-pcx-pink-blue-cbs-anime'),
    -- Kawasaki Versys: единая цена у модели
    ('kawasaki-versys-black',         'kawasaki-versys-black-no-boxes'),
    -- Suzuki V-Strom 250: единая цена у модели
    ('suzuki-vstrom250-black',        'suzuki-vstrom250-black-crashbar'),
    ('suzuki-vstrom250-black',        'suzuki-vstrom250-total-black-all-boxes'),
    -- Yamaha MT-25: единая цена у модели
    ('yamaha-mt25-black',             'yamaha-mt25-black-box'),
    ('yamaha-mt25-black',             'yamaha-mt25-black-red-box'),
    -- Yamaha Nmax: тот же цвет (sky pink/box/blue sky — доп. описание) +
    -- дешёвый тир 500к/день (решение владельца) для цветов без совпадения
    ('yamaha-nmax-chameleon',         'yamaha-nmax-chameleon-sky-pink'),
    ('yamaha-nmax-green',             'yamaha-nmax-green-box'),
    ('yamaha-nmax-pink-blue',         'yamaha-nmax-pink-blue-blue-sky'),
    ('yamaha-nmax-green',             'yamaha-nmax-black'),
    ('yamaha-nmax-green',             'yamaha-nmax-blue'),
    ('yamaha-nmax-green',             'yamaha-nmax-dark-green'),
    ('yamaha-nmax-green',             'yamaha-nmax-neo-blue-partner'),
    ('yamaha-nmax-green',             'yamaha-nmax-neo-s-black-partner'),
    ('yamaha-nmax-green',             'yamaha-nmax-neo-s-white-partner'),
    ('yamaha-nmax-green',             'yamaha-nmax-red'),
    -- Yamaha Xmax: тот же цвет (Grey/Green Blue Wheels) + дешёвый тир
    -- 900к/день (решение владельца) для цветов без совпадения
    ('yamaha-xmax-grey',              'yamaha-xmax-grey-partner'),
    ('yamaha-xmax-green-blue-wheels', 'yamaha-xmax-green-blue'),
    ('yamaha-xmax-silver',            'yamaha-xmax-black-partner'),
    ('yamaha-xmax-silver',            'yamaha-xmax-cartoon-partner'),
    ('yamaha-xmax-silver',            'yamaha-xmax-dark-green-partner'),
    ('yamaha-xmax-silver',            'yamaha-xmax-green'),
    ('yamaha-xmax-silver',            'yamaha-xmax-pink'),
    ('yamaha-xmax-silver',            'yamaha-xmax-red-partner'),
    -- Yamaha XSR: единая цена у модели
    ('yamaha-xsr-black',              'yamaha-xsr-black-bracket'),
    ('yamaha-xsr-black',              'yamaha-xsr-black-box')
) AS m(donor_slug, target_slug) ON donor.slug = m.donor_slug
JOIN products tgt ON tgt.slug = m.target_slug;
