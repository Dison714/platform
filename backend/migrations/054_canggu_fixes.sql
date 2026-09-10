-- Правки Canggu (052_location_pages_seed.sql) по итогам аудита реального
-- каталога перед 9-районным релизом:
-- 1. "Which Bike Fits" называл несуществующую модель "Honda Scoopy" — в
--    product_families такой модели нет вообще (проверено прямым SELECT).
--    Реальные семейства сверены по БД: honda_adv160/honda_pcx160/
--    honda_vario160/yamaha_nmax155/yamaha_xmax250 (скутеры) + touring
--    (Suzuki V-Strom 250, Kawasaki Versys, Honda CB150X, Kawasaki
--    D-Tracker 250) — заменено на реальную матрицу "город/холмы/дальние
--    поездки/пассажир+багаж", переиспользуется теми же 4 категориями на
--    всех 9 районных страницах (055).
-- 2. Добавлен delivery_disclaimer (053) — пояснение про ориентировочность
--    цены для труднодоступных точек, отражает реальное поле
--    delivery_fee_rules.manager_approval (003_pricing_warehouse.sql,
--    "зарезервирован под удалённые районы"), не выдуманное правило.
-- 3. Добавлен popular_locations (053) — курировано из "Отчёт для блога —
--    маршруты и локации (2026)" (реальные ссылки на Google Maps из чата
--    "Котики на мотиках"), без фото (ТЗ).
UPDATE location_page_translations SET
    which_bike_html = $html$<ul>
<li><strong>City riding</strong> (cafés, coworking, short hops around Berawa/Batu Bolong/Pererenan): a <strong>Honda PCX 160</strong> or <strong>Yamaha Nmax 155</strong> — fully automatic, easy to park, plenty for flat coastal roads.</li>
<li><strong>Hills / light adventure</strong> riding inland: a <strong>Honda ADV 160</strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> to Ubud or Uluwatu from a Canggu base: a <strong>Yamaha Xmax 250</strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong>Suzuki V-Strom 250</strong> or <strong>Kawasaki Versys</strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>$html$,
    delivery_disclaimer = 'Prices above cover typical addresses in Canggu. Very remote or hard-to-find locations may need manager confirmation before booking — we''ll flag this on WhatsApp once you send your pickup address.',
    popular_locations = $json$[
      {"name": "BGS Bali Canggu (coffee)", "href": "https://maps.app.goo.gl/ufKYEUMjnLRZN36Q8"},
      {"name": "OXO The Factory (coworking/events)", "href": "https://maps.app.goo.gl/MmrCA9j7kDEFcgAq6"},
      {"name": "Hungry Bird (breakfast)", "href": "https://maps.app.goo.gl/sgsYmZtdrznQKjn36"},
      {"name": "Artisan Pererenan (breakfast)", "href": "https://maps.app.goo.gl/8ce3YtaAG7JtBEcd7"},
      {"name": "DoDo Pizza", "href": "https://maps.app.goo.gl/nuCcaPCZxwX3hUbe6"},
      {"name": "Georgian café, Canggu", "href": "https://maps.app.goo.gl/xWx8wjVfsW44uGjw5"},
      {"name": "Beachside cheesecake café", "href": "https://maps.app.goo.gl/f5YU4AwbaAhSEf277"},
      {"name": "Usha cake shop, Umalas", "href": "https://maps.app.goo.gl/gqrVQDyxkPHBhita9"},
      {"name": "\"7am\" café, Umalas", "href": "https://maps.app.goo.gl/ZLJ8W8KZpENX8WnAA"}
    ]$json$::jsonb
WHERE location_page_id = 'a10c0000-0000-4000-8000-000000000001' AND language_code = 'en';
