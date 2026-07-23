-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 31_keeway_road_falcon.sql
-- Новый байк: Keeway Road Falcon 250 (решение владельца). Байк в заказе,
-- физически ещё не приехал — заводим только каталожную часть (family,
-- product, фильтр, цена, фото/видео); fleet_item (VIN/STNK/номер) — позже
-- в CRM, когда байк прибудет и будет физически зарегистрирован.
-- Категория фильтра — Cruiser/Bobber/Chopper (тот же стиль, что Morbidelli
-- C252V — круглая фара, посадка, широкий руль); цена — та же, что у
-- Morbidelli (решение владельца).
-- =====================================================================

-- company_id ищем по code, не хардкодим UUID — тот же класс бага, что был
-- разобран в инциденте с orphaned FK при сидинге (companies.id расходится
-- между локальной и серверной средой, code — нет).
INSERT INTO product_families (company_id, category_id, code, brand, model_name)
SELECT c.id, vc.id, 'keeway_roadfalcon250', 'Keeway', 'Road Falcon 250'
FROM companies c, vehicle_categories vc
WHERE c.code = 'mdb_bali' AND vc.code = 'cruiser';

INSERT INTO family_filter_categories (family_id, category_id)
SELECT pf.id, vc.id
FROM product_families pf, vehicle_categories vc
WHERE pf.code = 'keeway_roadfalcon250' AND vc.code = 'cruiser';

INSERT INTO products (family_id, color_name, slug, internal_name)
SELECT pf.id, 'Black', 'keeway-road-falcon-250-black', 'Road Falcon 250 Black'
FROM product_families pf WHERE pf.code = 'keeway_roadfalcon250';

-- Цена — та же, что у Morbidelli C252V (решение владельца, тот же
-- стилистический класс).
INSERT INTO price_rules (rule_set_id, product_id, rental_days, price_idr)
SELECT pr.rule_set_id, tgt.id, pr.rental_days, pr.price_idr
FROM price_rules pr
JOIN products donor ON donor.id = pr.product_id AND donor.slug = 'morbidelli-c252v-black'
JOIN products tgt ON tgt.slug = 'keeway-road-falcon-250-black';
