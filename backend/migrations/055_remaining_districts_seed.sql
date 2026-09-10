-- Seed: 8 оставшихся районных страниц (EN), дополняют Canggu (052+054).
--
-- Что реально проверено/источник:
-- - Модели в "Which Bike Fits" — реальный product_families (см. 054, тот же
--   текст переиспользован на всех 9 страницах, флот один на весь остров).
-- - Delivery — единая ставка по СРОКУ аренды (delivery_fee_rules,
--   003_pricing_warehouse.sql), не по району — тот же текст, что в Canggu.
-- - Popular Locations — курировано из "Отчёт для блога — маршруты и
--   локации (2026)" (реальные ссылки на Google Maps из чата "Котики на
--   мотиках"), без фото (ТЗ). Denpasar/Sanur/Seminyak — слабое покрытие в
--   исходном чате (см. итоговый отчёт сессии), меньше точек, чем у
--   остальных районов — это не ошибка курации, это реальный объём данных.
-- - Getting Around — общий, проверяемый характер района (рельеф/трафик,
--   широко известные факты о Бали), БЕЗ точных часов пик/улиц — те
--   заблокированы отсутствующим файлом districts-data-remaining-8.md
--   (см. TODO-параграф в каждом блоке).
-- - Distances table — НЕ заполнена (тот же блокер), фронтенд рендерит
--   "pending" вместо таблицы (dict.location_page.distances_pending).
-- - Route — тот же TODO, что в Canggu (анкета водителям не отправлена).

INSERT INTO location_pages (id, company_id, slug, is_active) VALUES
    ('a10c0000-0000-4000-8000-000000000002', '37005782-1dec-4f77-9673-f4c85eac9d89', 'seminyak', TRUE),
    ('a10c0000-0000-4000-8000-000000000003', '37005782-1dec-4f77-9673-f4c85eac9d89', 'ubud', TRUE),
    ('a10c0000-0000-4000-8000-000000000004', '37005782-1dec-4f77-9673-f4c85eac9d89', 'uluwatu', TRUE),
    ('a10c0000-0000-4000-8000-000000000005', '37005782-1dec-4f77-9673-f4c85eac9d89', 'jimbaran', TRUE),
    ('a10c0000-0000-4000-8000-000000000006', '37005782-1dec-4f77-9673-f4c85eac9d89', 'sanur', TRUE),
    ('a10c0000-0000-4000-8000-000000000007', '37005782-1dec-4f77-9673-f4c85eac9d89', 'kuta', TRUE),
    ('a10c0000-0000-4000-8000-000000000008', '37005782-1dec-4f77-9673-f4c85eac9d89', 'nusa-dua', TRUE),
    ('a10c0000-0000-4000-8000-000000000009', '37005782-1dec-4f77-9673-f4c85eac9d89', 'denpasar', TRUE);

-- Общий "Which Bike Fits" — идентичен на всех 8 (тот же реальный флот, см.
-- 054_canggu_fixes.sql для комментария об источнике).
-- Общий Route TODO — идентичен на всех 9.
-- Все INSERT ниже используют один и тот же WHICH_BIKE/ROUTE текст напрямую
-- (без psql-переменных — миграция должна работать и через простой psql -f).

-- ============================== SEMINYAK ==============================
INSERT INTO location_page_translations (
    location_page_id, language_code, seo_title, seo_description, h1, intro,
    delivery_summary, delivery_html, delivery_disclaimer, getting_around_html, distances,
    which_bike_html, route_html, popular_locations, faq, cta_text
) VALUES (
    'a10c0000-0000-4000-8000-000000000002', 'en',
    'Scooter Rental Seminyak, Bali — Free Delivery & Best Bikes | BikeBaliRent',
    'Scooter & motorbike rental in Seminyak with fast delivery to Petitenget, Oberoi and Kerobokan. Free delivery on weekly rentals, transparent pricing, 60+ bikes.',
    'Scooter & Motorbike Rental in Seminyak',
    'Seminyak is Bali''s upscale beach-club-and-boutique strip — a tight grid of designer shops, spas and restaurants between the Oberoi and the coast, with Petitenget and Kerobokan blending into it on the north side. Most villas and hotels sit a short, flat ride from the beach, and a scooter is the easiest way to move between sunset spots without hunting for parking. We deliver anywhere in Seminyak — Oberoi, Petitenget, Kerobokan, Basangkasa — and set you up with a bike that matches how far you actually plan to ride.',
    'Free delivery on rentals of 15+ days · Rp 100,000 for 7–14 days · Rp 150,000 flat under a week — anywhere in Seminyak.',
    $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Seminyak.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Seminyak.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$,
    'Prices above cover typical addresses in Seminyak. Very remote or hard-to-find locations may need manager confirmation before booking — we''ll flag this on WhatsApp once you send your pickup address.',
    $html$<p>Seminyak's streets are flat and walkable in parts, but Jalan Kayu Aya (Oberoi) and Jalan Laksmana (Petitenget) get seriously congested in the late afternoon as beach-club traffic builds, with delivery scooters and cars competing for the same narrow lanes. A scooter still beats sitting in that traffic — you can filter through and park closer to the beach entrances than any car.</p>
<p class="loc-todo">[TODO — заблокировано отсутствующим файлом districts-data-remaining-8.md: точные часы пик и маршруты объезда для Seminyak ещё не подтверждены.]</p>$html$,
    NULL,
    $html$<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong>Honda PCX 160</strong> or <strong>Yamaha Nmax 155</strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong>Honda ADV 160</strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong>Yamaha Xmax 250</strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong>Suzuki V-Strom 250</strong> or <strong>Kawasaki Versys</strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>$html$,
    '[TODO — заблокировано анкетой водителям (Hari/Stefan/Saiban), которую ещё не отправили. Реальный маршрут, кафе и точки по дороге — только с их слов, не придумываю.]',
    $json$[
      {"name": "Camplung Tanduk, Seminyak (beachfront)", "href": "https://maps.app.goo.gl/rLHWu4F4Qb6BLj2w6"},
      {"name": "The Forge (sports pub, Petitenget)", "href": "https://maps.app.goo.gl/toVXUirCmrogAs1u7"},
      {"name": "Kerobokan warung (Eastern European menu)", "href": "https://maps.app.goo.gl/6yPzjAWGL5sTW6aRA"}
    ]$json$::jsonb,
    $json$[
      {"q": "Do you deliver anywhere in Seminyak, including Petitenget and Kerobokan?", "a": "Yes — delivery covers all of Seminyak. Free from 15 days, Rp 100,000 for 7–14 days, Rp 150,000 flat fee under a week."},
      {"q": "Is there a minimum rental period?", "a": "No minimum — the delivery fee is the only thing that changes with rental length."},
      {"q": "Do I need an international driving permit to ride in Seminyak?", "a": "Yes, alongside your home license — see our full guide:", "link": {"label": "Riding in Bali Without a License: The Real Risks", "href": "/en/blog/riding-in-bali-without-a-license-the-real-risks"}},
      {"q": "Is a scooter enough, or should I rent something bigger?", "a": "Depends on your plans — see \"Which Bike Fits Seminyak Best\" above. For local riding a scooter is plenty; longer trips across Bali are more comfortable on an Xmax, V-Strom, or Versys."},
      {"q": "What's your policy on deposit and damage?", "a": "See our Deposit & Safety guide:", "link": {"label": "Deposit & Safety articles", "href": "/en/blog#deposit-safety"}}
    ]$json$::jsonb,
    'Ready to book? WhatsApp us your dates and pickup spot in Seminyak, and we''ll confirm your bike and delivery time.'
);

-- ================================ UBUD ================================
INSERT INTO location_page_translations (
    location_page_id, language_code, seo_title, seo_description, h1, intro,
    delivery_summary, delivery_html, delivery_disclaimer, getting_around_html, distances,
    which_bike_html, route_html, popular_locations, faq, cta_text
) VALUES (
    'a10c0000-0000-4000-8000-000000000003', 'en',
    'Scooter Rental Ubud, Bali — Free Delivery & Best Bikes | BikeBaliRent',
    'Scooter & motorbike rental in Ubud with fast delivery to central Ubud, Penestanan, Campuhan and Tegallalang. Free delivery on weekly rentals, transparent pricing, 60+ bikes.',
    'Scooter & Motorbike Rental in Ubud',
    'Ubud is Bali''s cultural and creative heart — rice terraces, temples and art studios spread across rolling, genuinely hilly terrain rather than the south''s flat coastline. Traffic on the main Jalan Raya Ubud strip can be dense around the market and Monkey Forest, but a scooter still gets you to the rice-terrace roads and quiet backstreets a car can''t reach. We deliver anywhere in Ubud — central Ubud, Penestanan, Campuhan, Tegallalang — and set you up with a bike suited to Ubud''s hills, not just flat cruising.',
    'Free delivery on rentals of 15+ days · Rp 100,000 for 7–14 days · Rp 150,000 flat under a week — anywhere in Ubud.',
    $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Ubud.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Ubud.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$,
    'Prices above cover typical addresses in Ubud. Very remote or hard-to-find locations may need manager confirmation before booking — we''ll flag this on WhatsApp once you send your pickup address.',
    $html$<p>Ubud's main artery, Jalan Raya Ubud, backs up around the market and Monkey Forest Road especially at midday and early evening — one of the more congested single streets in Bali outside the south. Away from that strip, the roads through the rice terraces and Campuhan Ridge are quieter but genuinely hilly, so a scooter with a bit more power (ADV or Xmax) rides easier than a small city scooter.</p>
<p class="loc-todo">[TODO — заблокировано отсутствующим файлом districts-data-remaining-8.md: точные часы пик и маршруты объезда для Ubud ещё не подтверждены.]</p>$html$,
    NULL,
    $html$<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong>Honda PCX 160</strong> or <strong>Yamaha Nmax 155</strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong>Honda ADV 160</strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong>Yamaha Xmax 250</strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong>Suzuki V-Strom 250</strong> or <strong>Kawasaki Versys</strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>$html$,
    '[TODO — заблокировано анкетой водителям (Hari/Stefan/Saiban), которую ещё не отправили. Реальный маршрут, кафе и точки по дороге — только с их слов, не придумываю.]',
    $json$[
      {"name": "Sacred Monkey Forest Sanctuary", "href": "https://maps.app.goo.gl/dLYAPeyHacwiv7ac9"},
      {"name": "Alas Harum Bali (Tegalalang rice-terrace swings)", "href": "https://maps.app.goo.gl/Fm6WpyGqUfnYH93v5"},
      {"name": "Tegenungan Waterfall", "href": "https://maps.app.goo.gl/MuAxrUZfjpgD633YA"},
      {"name": "Goa Gajah (Elephant Cave)", "href": "https://maps.app.goo.gl/DAUg6wzr9hS5bSca8"},
      {"name": "Sebatu Holy Water Spring", "href": "https://maps.app.goo.gl/aGCSeSbiftPJnJ2w8"},
      {"name": "Sayan Point (valley view)", "href": "https://maps.app.goo.gl/1pc8mhitFknFhEHx9"},
      {"name": "Lemuria – The Lost City (night market)", "href": "https://maps.app.goo.gl/r2jkzJExA9g8bwLz8"},
      {"name": "Ubud Artists' Trail (breakfast, rice-field view)", "href": "https://maps.app.goo.gl/n7BauQP1KP5UPP8h9"}
    ]$json$::jsonb,
    $json$[
      {"q": "Do you deliver anywhere in Ubud, including Penestanan and Tegallalang?", "a": "Yes — delivery covers all of Ubud. Free from 15 days, Rp 100,000 for 7–14 days, Rp 150,000 flat fee under a week."},
      {"q": "Is there a minimum rental period?", "a": "No minimum — the delivery fee is the only thing that changes with rental length."},
      {"q": "Do I need an international driving permit to ride in Ubud?", "a": "Yes, alongside your home license — see our full guide:", "link": {"label": "Riding in Bali Without a License: The Real Risks", "href": "/en/blog/riding-in-bali-without-a-license-the-real-risks"}},
      {"q": "Is a scooter enough, or should I rent something bigger?", "a": "Depends on your plans — see \"Which Bike Fits Ubud Best\" above. Ubud's hills favor a bit more power than a flat-coast city scooter, especially if you're heading further out to the rice terraces."},
      {"q": "What's your policy on deposit and damage?", "a": "See our Deposit & Safety guide:", "link": {"label": "Deposit & Safety articles", "href": "/en/blog#deposit-safety"}}
    ]$json$::jsonb,
    'Ready to book? WhatsApp us your dates and pickup spot in Ubud, and we''ll confirm your bike and delivery time.'
);

-- ============================== ULUWATU ==============================
INSERT INTO location_page_translations (
    location_page_id, language_code, seo_title, seo_description, h1, intro,
    delivery_summary, delivery_html, delivery_disclaimer, getting_around_html, distances,
    which_bike_html, route_html, popular_locations, faq, cta_text
) VALUES (
    'a10c0000-0000-4000-8000-000000000004', 'en',
    'Scooter Rental Uluwatu, Bali — Free Delivery & Best Bikes | BikeBaliRent',
    'Scooter & motorbike rental in Uluwatu with fast delivery to Pecatu, Bingin, Balangan and Padang Padang. Free delivery on weekly rentals, transparent pricing, 60+ bikes.',
    'Scooter & Motorbike Rental in Uluwatu',
    'Uluwatu sits on Bali''s southern limestone cliffs — surf breaks, clifftop warungs and the Uluwatu temple road, spread out further than the flatter districts to the north. Roads here climb and wind along the Bukit, and distances between beaches (Padang Padang, Bingin, Balangan, Melasti) are longer than they look on a map. We deliver anywhere on the Bukit around Uluwatu — Pecatu, Bingin, Balangan, Padang Padang — and set you up with a bike that can handle the hills, not just the beach roads.',
    'Free delivery on rentals of 15+ days · Rp 100,000 for 7–14 days · Rp 150,000 flat under a week — anywhere in Uluwatu.',
    $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Uluwatu.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Uluwatu.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$,
    'Prices above cover typical addresses in Uluwatu. Very remote or hard-to-find locations may need manager confirmation before booking — we''ll flag this on WhatsApp once you send your pickup address.',
    $html$<p>The roads across the Bukit peninsula around Uluwatu are hillier and more spread out than anywhere else on this list — getting from one beach to the next (Padang Padang, Bingin, Balangan) often means a genuine climb, not a flat cruise. Traffic itself is lighter than Canggu or Seminyak, but the terrain means a scooter with more torque handles it more comfortably.</p>
<p class="loc-todo">[TODO — заблокировано отсутствующим файлом districts-data-remaining-8.md: точные часы пик и маршруты объезда для Uluwatu ещё не подтверждены.]</p>$html$,
    NULL,
    $html$<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong>Honda PCX 160</strong> or <strong>Yamaha Nmax 155</strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong>Honda ADV 160</strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong>Yamaha Xmax 250</strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong>Suzuki V-Strom 250</strong> or <strong>Kawasaki Versys</strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>$html$,
    '[TODO — заблокировано анкетой водителям (Hari/Stefan/Saiban), которую ещё не отправили. Реальный маршрут, кафе и точки по дороге — только с их слов, не придумываю.]',
    $json$[
      {"name": "Melasti Beach", "href": "https://maps.app.goo.gl/NeCTGq2NRkigWa9d9"},
      {"name": "Balangan Beach", "href": "https://maps.app.goo.gl/UNWpNiU45pSdqzyx9"},
      {"name": "Nyang Nyang Beach", "href": "https://maps.app.goo.gl/KA499nTtwrxtHM5w7"},
      {"name": "Alam Paragliding Uluwatu", "href": "https://maps.app.goo.gl/NxpZMg5Je3PRkt3v8"},
      {"name": "Laptop-friendly café, Uluwatu", "href": "https://maps.app.goo.gl/f6Jj6KdvtfNy8bVD6"},
      {"name": "Clifftop burger spot & viewpoint", "href": "https://maps.app.goo.gl/oxmSAhcZXiLG84mh7"},
      {"name": "Pecatu (Uluwatu temple road)", "href": "https://maps.app.goo.gl/3sqQPgCcmm4ZX5Wq9"}
    ]$json$::jsonb,
    $json$[
      {"q": "Do you deliver anywhere around Uluwatu, including Bingin and Balangan?", "a": "Yes — delivery covers all of the Uluwatu area. Free from 15 days, Rp 100,000 for 7–14 days, Rp 150,000 flat fee under a week."},
      {"q": "Is there a minimum rental period?", "a": "No minimum — the delivery fee is the only thing that changes with rental length."},
      {"q": "Do I need an international driving permit to ride in Uluwatu?", "a": "Yes, alongside your home license — see our full guide:", "link": {"label": "Riding in Bali Without a License: The Real Risks", "href": "/en/blog/riding-in-bali-without-a-license-the-real-risks"}},
      {"q": "Is a scooter enough, or should I rent something bigger?", "a": "Depends on your plans — see \"Which Bike Fits Uluwatu Best\" above. The Bukit's hills favor a bit more power than a flat-coast city scooter."},
      {"q": "What's your policy on deposit and damage?", "a": "See our Deposit & Safety guide:", "link": {"label": "Deposit & Safety articles", "href": "/en/blog#deposit-safety"}}
    ]$json$::jsonb,
    'Ready to book? WhatsApp us your dates and pickup spot around Uluwatu, and we''ll confirm your bike and delivery time.'
);

-- ============================== JIMBARAN ==============================
INSERT INTO location_page_translations (
    location_page_id, language_code, seo_title, seo_description, h1, intro,
    delivery_summary, delivery_html, delivery_disclaimer, getting_around_html, distances,
    which_bike_html, route_html, popular_locations, faq, cta_text
) VALUES (
    'a10c0000-0000-4000-8000-000000000005', 'en',
    'Scooter Rental Jimbaran, Bali — Free Delivery & Best Bikes | BikeBaliRent',
    'Scooter & motorbike rental in Jimbaran with fast delivery across the bay and toward GWK. Free delivery on weekly rentals, transparent pricing, 60+ bikes.',
    'Scooter & Motorbike Rental in Jimbaran',
    'Jimbaran is Bali''s classic sunset-seafood bay — a curved beach lined with grilled-fish warungs, sitting between the airport and the Bukit cliffs. It''s quieter and more spread out than the busier south, with the GWK cultural park and Bukit access roads nearby. We deliver anywhere in Jimbaran — the bay, the roads toward Ungasan, and the GWK area — and set you up with a bike that matches how far you plan to ride toward the Bukit or the airport.',
    'Free delivery on rentals of 15+ days · Rp 100,000 for 7–14 days · Rp 150,000 flat under a week — anywhere in Jimbaran.',
    $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Jimbaran.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Jimbaran.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$,
    'Prices above cover typical addresses in Jimbaran. Very remote or hard-to-find locations may need manager confirmation before booking — we''ll flag this on WhatsApp once you send your pickup address.',
    $html$<p>Jimbaran itself is fairly relaxed compared to the south's surf hubs, with the bay road and the GWK access road as the main arteries — traffic builds mainly around sunset when the seafood warungs fill up. A scooter is the easy way to move along the bay or up toward GWK and the Bukit without hunting for parking.</p>
<p class="loc-todo">[TODO — заблокировано отсутствующим файлом districts-data-remaining-8.md: точные часы пик и маршруты объезда для Jimbaran ещё не подтверждены.]</p>$html$,
    NULL,
    $html$<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong>Honda PCX 160</strong> or <strong>Yamaha Nmax 155</strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong>Honda ADV 160</strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong>Yamaha Xmax 250</strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong>Suzuki V-Strom 250</strong> or <strong>Kawasaki Versys</strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>$html$,
    '[TODO — заблокировано анкетой водителям (Hari/Stefan/Saiban), которую ещё не отправили. Реальный маршрут, кафе и точки по дороге — только с их слов, не придумываю.]',
    $json$[
      {"name": "Rock Bar Bali", "href": "https://maps.app.goo.gl/ubFBuLch9axeBHE18"},
      {"name": "GWK Cultural Park (Garuda Wisnu Kencana)", "href": "https://maps.app.goo.gl/Nv1VtMQDhLJDpzud6"},
      {"name": "Jimbaran sunset spot near Intercontinental", "href": "https://maps.app.goo.gl/S8RBjYvb9pTMnLj2A"},
      {"name": "Wanderlust Spa, Jimbaran", "href": "https://maps.app.goo.gl/Ez3KdNdUJMdtbRQk9"},
      {"name": "Cube (bar), Jimbaran", "href": "https://maps.app.goo.gl/dpXLQHUXD5BK9yaz7"},
      {"name": "Jimbaran seafood warung", "href": "https://maps.app.goo.gl/hva6FA3TzX6Umhu28"}
    ]$json$::jsonb,
    $json$[
      {"q": "Do you deliver anywhere in Jimbaran, including toward GWK?", "a": "Yes — delivery covers all of Jimbaran. Free from 15 days, Rp 100,000 for 7–14 days, Rp 150,000 flat fee under a week."},
      {"q": "Is there a minimum rental period?", "a": "No minimum — the delivery fee is the only thing that changes with rental length."},
      {"q": "Do I need an international driving permit to ride in Jimbaran?", "a": "Yes, alongside your home license — see our full guide:", "link": {"label": "Riding in Bali Without a License: The Real Risks", "href": "/en/blog/riding-in-bali-without-a-license-the-real-risks"}},
      {"q": "Is a scooter enough, or should I rent something bigger?", "a": "Depends on your plans — see \"Which Bike Fits Jimbaran Best\" above. For the bay itself a scooter is plenty; heading up toward the Bukit or GWK is easier with more power."},
      {"q": "What's your policy on deposit and damage?", "a": "See our Deposit & Safety guide:", "link": {"label": "Deposit & Safety articles", "href": "/en/blog#deposit-safety"}}
    ]$json$::jsonb,
    'Ready to book? WhatsApp us your dates and pickup spot in Jimbaran, and we''ll confirm your bike and delivery time.'
);

-- ================================ SANUR ================================
INSERT INTO location_page_translations (
    location_page_id, language_code, seo_title, seo_description, h1, intro,
    delivery_summary, delivery_html, delivery_disclaimer, getting_around_html, distances,
    which_bike_html, route_html, popular_locations, faq, cta_text
) VALUES (
    'a10c0000-0000-4000-8000-000000000006', 'en',
    'Scooter Rental Sanur, Bali — Free Delivery & Best Bikes | BikeBaliRent',
    'Scooter & motorbike rental in Sanur with fast delivery along the beachfront and harbor area. Free delivery on weekly rentals, transparent pricing, 60+ bikes.',
    'Scooter & Motorbike Rental in Sanur',
    'Sanur is Bali''s calmest beach town — a long paved beachfront promenade, shallow water and a slower pace than the busier south, popular with families and the fast-boat crowd heading to Nusa Penida and the Gilis. Streets are flatter and less congested than the south''s surf hubs, making it an easy place to start riding. We deliver anywhere in Sanur — the beachfront, the harbor area, and inland toward Denpasar — and set you up with a bike that matches your plans, whether that''s the promenade or a day trip further afield.',
    'Free delivery on rentals of 15+ days · Rp 100,000 for 7–14 days · Rp 150,000 flat under a week — anywhere in Sanur.',
    $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Sanur.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Sanur.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$,
    'Prices above cover typical addresses in Sanur. Very remote or hard-to-find locations may need manager confirmation before booking — we''ll flag this on WhatsApp once you send your pickup address.',
    $html$<p>Sanur is one of the calmer districts to ride in — the beachfront promenade is relaxed and scooter-friendly, and the inland streets toward Denpasar carry more traffic than the coast itself but nothing like Kuta or Seminyak's peak-hour crush. It's a comfortable place to get used to riding in Bali before heading further afield.</p>
<p class="loc-todo">[TODO — заблокировано отсутствующим файлом districts-data-remaining-8.md: точные часы пик и маршруты объезда для Sanur ещё не подтверждены.]</p>$html$,
    NULL,
    $html$<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong>Honda PCX 160</strong> or <strong>Yamaha Nmax 155</strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong>Honda ADV 160</strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong>Yamaha Xmax 250</strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong>Suzuki V-Strom 250</strong> or <strong>Kawasaki Versys</strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>$html$,
    '[TODO — заблокировано анкетой водителям (Hari/Stefan/Saiban), которую ещё не отправили. Реальный маршрут, кафе и точки по дороге — только с их слов, не придумываю.]',
    $json$[
      {"name": "Kevala Ceramics Production", "href": "https://maps.app.goo.gl/EZe9hfEB8y42SvKn8"},
      {"name": "Kevala Studio (ceramics workshops)", "href": "https://maps.app.goo.gl/YVL9FubhneYACsQe8"},
      {"name": "Quiet beach near Sanur harbor", "href": "https://maps.app.goo.gl/qNZCd6fqCyDtFxabA"},
      {"name": "Sanur fastboat port (to Nusa Penida)", "href": "https://maps.app.goo.gl/BtTjYws8TCPvXk4X7"},
      {"name": "Mertasari Beach", "href": "https://maps.app.goo.gl/ohuQy15h3eDFu8ubA"}
    ]$json$::jsonb,
    $json$[
      {"q": "Do you deliver anywhere in Sanur, including the harbor area?", "a": "Yes — delivery covers all of Sanur. Free from 15 days, Rp 100,000 for 7–14 days, Rp 150,000 flat fee under a week."},
      {"q": "Is there a minimum rental period?", "a": "No minimum — the delivery fee is the only thing that changes with rental length."},
      {"q": "Do I need an international driving permit to ride in Sanur?", "a": "Yes, alongside your home license — see our full guide:", "link": {"label": "Riding in Bali Without a License: The Real Risks", "href": "/en/blog/riding-in-bali-without-a-license-the-real-risks"}},
      {"q": "Is a scooter enough, or should I rent something bigger?", "a": "Depends on your plans — see \"Which Bike Fits Sanur Best\" above. Sanur itself is flat and easy on a city scooter; day trips further afield are more comfortable on an Xmax, V-Strom, or Versys."},
      {"q": "What's your policy on deposit and damage?", "a": "See our Deposit & Safety guide:", "link": {"label": "Deposit & Safety articles", "href": "/en/blog#deposit-safety"}}
    ]$json$::jsonb,
    'Ready to book? WhatsApp us your dates and pickup spot in Sanur, and we''ll confirm your bike and delivery time.'
);

-- ================================ KUTA ================================
INSERT INTO location_page_translations (
    location_page_id, language_code, seo_title, seo_description, h1, intro,
    delivery_summary, delivery_html, delivery_disclaimer, getting_around_html, distances,
    which_bike_html, route_html, popular_locations, faq, cta_text
) VALUES (
    'a10c0000-0000-4000-8000-000000000007', 'en',
    'Scooter Rental Kuta, Bali — Free Delivery & Best Bikes | BikeBaliRent',
    'Scooter & motorbike rental in Kuta with fast delivery to Legian, Tuban and Kuta Beach — closest district to the airport. Free delivery on weekly rentals, transparent pricing, 60+ bikes.',
    'Scooter & Motorbike Rental in Kuta',
    'Kuta is Bali''s original tourist strip — Kuta Beach, Legian''s nightlife and shopping, all dense and walkable but often gridlocked with traffic, especially near Jalan Legian and the Beachwalk mall. A scooter is still the fastest way to cut through it, and Kuta is the closest of these 9 districts to Ngurah Rai Airport. We deliver anywhere in Kuta — Kuta Beach, Legian, Tuban — and set you up with a bike that matches how far you plan to ride beyond the strip.',
    'Free delivery on rentals of 15+ days · Rp 100,000 for 7–14 days · Rp 150,000 flat under a week — anywhere in Kuta.',
    $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Kuta.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Kuta.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$,
    'Prices above cover typical addresses in Kuta. Very remote or hard-to-find locations may need manager confirmation before booking — we''ll flag this on WhatsApp once you send your pickup address.',
    $html$<p>Kuta and Legian are some of the most congested streets in Bali — Jalan Legian and the roads around Beachwalk mall back up for most of the afternoon and evening, made worse by the density of foot traffic, taxis and delivery scooters. A scooter still cuts through faster than a car, and Kuta's proximity to the airport makes it convenient for early arrivals or late departures.</p>
<p class="loc-todo">[TODO — заблокировано отсутствующим файлом districts-data-remaining-8.md: точные часы пик и маршруты объезда для Kuta ещё не подтверждены.]</p>$html$,
    NULL,
    $html$<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong>Honda PCX 160</strong> or <strong>Yamaha Nmax 155</strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong>Honda ADV 160</strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong>Yamaha Xmax 250</strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong>Suzuki V-Strom 250</strong> or <strong>Kawasaki Versys</strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>$html$,
    '[TODO — заблокировано анкетой водителям (Hari/Stefan/Saiban), которую ещё не отправили. Реальный маршрут, кафе и точки по дороге — только с их слов, не придумываю.]',
    $json$[
      {"name": "% Arabica Bali, Kuta Beachwalk", "href": "https://maps.app.goo.gl/DCgbvfBePLLY1qJw5"},
      {"name": "Rio Corner, Legian Food Court", "href": "https://maps.app.goo.gl/9LbNNnDBFGBr5zS47"},
      {"name": "Jalan Legian", "href": "https://maps.app.goo.gl/4XUv7QDLz6x3PqhT7"},
      {"name": "Handmade market street, Kuta", "href": "https://maps.app.goo.gl/A1Woz9kZuK1qYbEf7"},
      {"name": "Massage near Beachwalk, Kuta", "href": "https://maps.app.goo.gl/FC3fccDzAxPgss3T9"}
    ]$json$::jsonb,
    $json$[
      {"q": "Do you deliver anywhere in Kuta, including Legian and Tuban?", "a": "Yes — delivery covers all of Kuta. Free from 15 days, Rp 100,000 for 7–14 days, Rp 150,000 flat fee under a week."},
      {"q": "Is there a minimum rental period?", "a": "No minimum — the delivery fee is the only thing that changes with rental length."},
      {"q": "Do I need an international driving permit to ride in Kuta?", "a": "Yes, alongside your home license — see our full guide:", "link": {"label": "Riding in Bali Without a License: The Real Risks", "href": "/en/blog/riding-in-bali-without-a-license-the-real-risks"}},
      {"q": "Is a scooter enough, or should I rent something bigger?", "a": "Depends on your plans — see \"Which Bike Fits Kuta Best\" above. For the strip itself a scooter is plenty; longer trips across Bali are more comfortable on an Xmax, V-Strom, or Versys."},
      {"q": "What's your policy on deposit and damage?", "a": "See our Deposit & Safety guide:", "link": {"label": "Deposit & Safety articles", "href": "/en/blog#deposit-safety"}}
    ]$json$::jsonb,
    'Ready to book? WhatsApp us your dates and pickup spot in Kuta, and we''ll confirm your bike and delivery time.'
);

-- ============================== NUSA DUA ==============================
INSERT INTO location_page_translations (
    location_page_id, language_code, seo_title, seo_description, h1, intro,
    delivery_summary, delivery_html, delivery_disclaimer, getting_around_html, distances,
    which_bike_html, route_html, popular_locations, faq, cta_text
) VALUES (
    'a10c0000-0000-4000-8000-000000000008', 'en',
    'Scooter Rental Nusa Dua, Bali — Free Delivery & Best Bikes | BikeBaliRent',
    'Scooter & motorbike rental in Nusa Dua with fast delivery across the ITDC resort area and Benoa. Free delivery on weekly rentals, transparent pricing, 60+ bikes.',
    'Scooter & Motorbike Rental in Nusa Dua',
    'Nusa Dua is Bali''s gated resort district — wide, quiet roads, manicured grounds and calm beaches, a deliberate contrast to the crowds further north. It''s more spread out than it looks from inside a resort, and a scooter is the practical way to reach Geger Beach, the Benoa boat harbor or the Bukit beyond the enclave. We deliver anywhere in Nusa Dua — the ITDC resort area, Benoa, and Bualu — and set you up with a bike that matches your plans, whether that''s the promenade or a trip further into Bali.',
    'Free delivery on rentals of 15+ days · Rp 100,000 for 7–14 days · Rp 150,000 flat under a week — anywhere in Nusa Dua.',
    $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Nusa Dua.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Nusa Dua.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$,
    'Prices above cover typical addresses in Nusa Dua. Very remote or hard-to-find locations may need manager confirmation before booking — we''ll flag this on WhatsApp once you send your pickup address.',
    $html$<p>Inside the ITDC resort enclave, roads are wide, quiet and well maintained — genuinely the easiest riding on this list. Traffic picks up mainly where Nusa Dua's main gate meets the road toward Benoa and the rest of Bali, and that stretch can bottleneck around commuting hours.</p>
<p class="loc-todo">[TODO — заблокировано отсутствующим файлом districts-data-remaining-8.md: точные часы пик и маршруты объезда для Nusa Dua ещё не подтверждены.]</p>$html$,
    NULL,
    $html$<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong>Honda PCX 160</strong> or <strong>Yamaha Nmax 155</strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong>Honda ADV 160</strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong>Yamaha Xmax 250</strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong>Suzuki V-Strom 250</strong> or <strong>Kawasaki Versys</strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>$html$,
    '[TODO — заблокировано анкетой водителям (Hari/Stefan/Saiban), которую ещё не отправили. Реальный маршрут, кафе и точки по дороге — только с их слов, не придумываю.]',
    $json$[
      {"name": "Geger Beach", "href": "https://maps.app.goo.gl/9mEdZfRrcge287c48"},
      {"name": "Brook (rooftop restaurant/bar)", "href": "https://maps.app.goo.gl/MveHFvRiTsBvZEsM7"},
      {"name": "Nusa Dua Beach", "href": "https://maps.app.goo.gl/Ux6icNfxYV1rnYLw9"},
      {"name": "New Nusa Dua boat port", "href": "https://maps.app.goo.gl/xjbp4umWo5m65aor9"},
      {"name": "Bike rental near Nusa Dua promenade", "href": "https://maps.app.goo.gl/YGtEY1M6Z1P7UkHE6"},
      {"name": "The Community, Benoa (BBQ venue)", "href": "https://maps.app.goo.gl/ugo5i6PDEskkvtBX9"}
    ]$json$::jsonb,
    $json$[
      {"q": "Do you deliver anywhere in Nusa Dua, including Benoa?", "a": "Yes — delivery covers all of Nusa Dua. Free from 15 days, Rp 100,000 for 7–14 days, Rp 150,000 flat fee under a week."},
      {"q": "Is there a minimum rental period?", "a": "No minimum — the delivery fee is the only thing that changes with rental length."},
      {"q": "Do I need an international driving permit to ride in Nusa Dua?", "a": "Yes, alongside your home license — see our full guide:", "link": {"label": "Riding in Bali Without a License: The Real Risks", "href": "/en/blog/riding-in-bali-without-a-license-the-real-risks"}},
      {"q": "Is a scooter enough, or should I rent something bigger?", "a": "Depends on your plans — see \"Which Bike Fits Nusa Dua Best\" above. Inside the enclave a scooter is plenty; longer trips across Bali are more comfortable on an Xmax, V-Strom, or Versys."},
      {"q": "What's your policy on deposit and damage?", "a": "See our Deposit & Safety guide:", "link": {"label": "Deposit & Safety articles", "href": "/en/blog#deposit-safety"}}
    ]$json$::jsonb,
    'Ready to book? WhatsApp us your dates and pickup spot in Nusa Dua, and we''ll confirm your bike and delivery time.'
);

-- ============================== DENPASAR ==============================
INSERT INTO location_page_translations (
    location_page_id, language_code, seo_title, seo_description, h1, intro,
    delivery_summary, delivery_html, delivery_disclaimer, getting_around_html, distances,
    which_bike_html, route_html, popular_locations, faq, cta_text
) VALUES (
    'a10c0000-0000-4000-8000-000000000009', 'en',
    'Scooter Rental Denpasar, Bali — Free Delivery & Best Bikes | BikeBaliRent',
    'Scooter & motorbike rental in Denpasar with fast delivery across Bali''s capital city. Free delivery on weekly rentals, transparent pricing, 60+ bikes.',
    'Scooter & Motorbike Rental in Denpasar',
    'Denpasar is Bali''s capital and biggest city — government offices, local markets and the island''s real day-to-day life, less geared toward tourists than the beach districts but central for anyone needing to get across Bali quickly. Traffic is genuinely city-level dense on the main arteries, and a scooter is the practical way to move fast. We deliver anywhere in Denpasar and set you up with a bike that matches how far you plan to ride.',
    'Free delivery on rentals of 15+ days · Rp 100,000 for 7–14 days · Rp 150,000 flat under a week — anywhere in Denpasar.',
    $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Denpasar.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Denpasar.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$,
    'Prices above cover typical addresses in Denpasar. Very remote or hard-to-find locations may need manager confirmation before booking — we''ll flag this on WhatsApp once you send your pickup address.',
    $html$<p>Denpasar carries the heaviest, most city-like traffic of any district on this list — the main arteries are genuinely congested for most of the working day, closer to a regional capital's rush hour than a beach town's afternoon bottleneck. A scooter is less optional here than anywhere else — filtering through slow traffic is often the only realistic way to move quickly.</p>
<p class="loc-todo">[TODO — заблокировано отсутствующим файлом districts-data-remaining-8.md: точные часы пик и маршруты объезда для Denpasar ещё не подтверждены.]</p>$html$,
    NULL,
    $html$<ul>
<li><strong>City riding</strong> (offices, markets, short local hops): a <strong>Honda PCX 160</strong> or <strong>Yamaha Nmax 155</strong> — fully automatic, easy to park, plenty for flat city roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong>Honda ADV 160</strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong>Yamaha Xmax 250</strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong>Suzuki V-Strom 250</strong> or <strong>Kawasaki Versys</strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>$html$,
    '[TODO — заблокировано анкетой водителям (Hari/Stefan/Saiban), которую ещё не отправили. Реальный маршрут, кафе и точки по дороге — только с их слов, не придумываю.]',
    $json$[
      {"name": "Puputan Square (Lapangan Puputan Badung)", "href": "https://maps.app.goo.gl/TN3AkoMe8A9GYHxh8"}
    ]$json$::jsonb,
    $json$[
      {"q": "Do you deliver anywhere in Denpasar?", "a": "Yes — delivery covers all of Denpasar. Free from 15 days, Rp 100,000 for 7–14 days, Rp 150,000 flat fee under a week."},
      {"q": "Is there a minimum rental period?", "a": "No minimum — the delivery fee is the only thing that changes with rental length."},
      {"q": "Do I need an international driving permit to ride in Denpasar?", "a": "Yes, alongside your home license — see our full guide:", "link": {"label": "Riding in Bali Without a License: The Real Risks", "href": "/en/blog/riding-in-bali-without-a-license-the-real-risks"}},
      {"q": "Is a scooter enough, or should I rent something bigger?", "a": "Depends on your plans — see \"Which Bike Fits Denpasar Best\" above. For city riding a scooter is plenty; longer trips across Bali are more comfortable on an Xmax, V-Strom, or Versys."},
      {"q": "What's your policy on deposit and damage?", "a": "See our Deposit & Safety guide:", "link": {"label": "Deposit & Safety articles", "href": "/en/blog#deposit-safety"}}
    ]$json$::jsonb,
    'Ready to book? WhatsApp us your dates and pickup spot in Denpasar, and we''ll confirm your bike and delivery time.'
);
