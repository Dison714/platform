-- Применение districts-data-remaining-8.md (прислан Дмитрием в чате
-- 2026-09-10, на диске не появлялся, потому вставлен вручную).
--
-- Что реально меняем:
-- 1. delivery_disclaimer — точный подтверждённый текст Дмитрия на всех 9
--    (заменяет мою перефразировку из 056 — та потеряла смысл "уточняйте
--    у оператора", за что и был замечен баг).
-- 2. Delivery-пороги для 8 районов (НЕ Canggu — тот использует отдельную,
--    уже верную 3-ступенчатую схему из delivery_fee_rules, в этом файле
--    Canggu не описан) — из таблицы файла, 2-ступенчатая схема (free
--    from N / иначе 150k flat), другая по каждому району. ВАЖНО: это НЕ
--    то же самое, что delivery_fee_rules (единая по всему острову,
--    duration-only, без района) — реальный quote-движок (backend/src/
--    services/delivery.js) пока не умеет считать по району, только по
--    сроку. Дисклеймер "уточняйте у оператора" — не декоративная фраза,
--    а фактическая защита от этого расхождения, пока движок не обновлён.
--    Флагаю это отдельно в отчёте, не блокирую публикацию (Дмитрий
--    подтвердил цифры явно).
-- 3. Fleet base — единый склад в Kerobokan, полный каталог на любой
--    район, без деления по локациям. "Ближе всего" — честно только для
--    Canggu/Seminyak (реально в нескольких минутах от Kerobokan).
-- 4. intro + FAQ Q1 на 8 районах — убраны выдуманные подрайоны
--    (Petitenget/Kerobokan для Seminyak и т.п.) — подтверждены только для
--    Canggu, для остальных инструкция явно запрещает выдумывать.
-- 5. Getting Around TODO — переформулирован: блокер не "нет файла" (файл
--    есть), а "анкета водителям не отправлена" — та же причина, что у
--    блока Route, содержательно точнее.

-- ---- 1. Disclaimer (все 9, точный текст Дмитрия) ----
UPDATE location_page_translations
SET delivery_disclaimer = 'Prices above are approximate — please confirm the exact delivery cost for your dates and timing with our team.'
WHERE language_code = 'en';

-- ---- 2+3. Delivery-пороги + fleet base (8 районов, НЕ Canggu) ----
UPDATE location_page_translations lpt SET
    delivery_summary = 'Free delivery on rentals of 3 days or longer · Rp 150,000 flat delivery fee for shorter stays — anywhere in Seminyak.',
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>3 days or longer</strong>.</li>
<li>Shorter rentals: flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Seminyak.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
<li>We deliver from our depot in Kerobokan, just minutes from Seminyak — the full catalog is available, no location-based inventory split.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'seminyak' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_summary = 'Free delivery on rentals of 30 days (1 month) or longer · Rp 150,000 flat delivery fee for shorter stays — anywhere in Ubud.',
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>30 days (1 month) or longer</strong>.</li>
<li>Shorter rentals: flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Ubud.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
<li>We deliver from a single depot in Kerobokan — the same full catalog is available for Ubud, no location-based inventory split.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'ubud' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_summary = 'Free delivery on rentals of 14 days (2 weeks) or longer · Rp 150,000 flat delivery fee for shorter stays — anywhere around Uluwatu.',
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>14 days (2 weeks) or longer</strong>.</li>
<li>Shorter rentals: flat delivery fee of <strong>Rp 150,000</strong>, anywhere around Uluwatu.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
<li>We deliver from a single depot in Kerobokan — the same full catalog is available for Uluwatu, no location-based inventory split.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'uluwatu' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_summary = 'Free delivery on rentals of 14 days (2 weeks) or longer · Rp 150,000 flat delivery fee for shorter stays — anywhere in Jimbaran.',
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>14 days (2 weeks) or longer</strong>.</li>
<li>Shorter rentals: flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Jimbaran.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
<li>We deliver from a single depot in Kerobokan — the same full catalog is available for Jimbaran, no location-based inventory split.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'jimbaran' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_summary = 'Free delivery on rentals of 7 days (1 week) or longer · Rp 150,000 flat delivery fee for shorter stays — anywhere in Sanur.',
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>7 days (1 week) or longer</strong>.</li>
<li>Shorter rentals: flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Sanur.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
<li>We deliver from a single depot in Kerobokan — the same full catalog is available for Sanur, no location-based inventory split.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'sanur' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_summary = 'Free delivery on rentals of 7 days (1 week) or longer · Rp 150,000 flat delivery fee for shorter stays — anywhere in Kuta.',
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>7 days (1 week) or longer</strong>.</li>
<li>Shorter rentals: flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Kuta.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
<li>We deliver from a single depot in Kerobokan — the same full catalog is available for Kuta, no location-based inventory split.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'kuta' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_summary = 'Free delivery on rentals of 14 days (2 weeks) or longer · Rp 150,000 flat delivery fee for shorter stays — anywhere in Nusa Dua.',
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>14 days (2 weeks) or longer</strong>.</li>
<li>Shorter rentals: flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Nusa Dua.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
<li>We deliver from a single depot in Kerobokan — the same full catalog is available for Nusa Dua, no location-based inventory split.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'nusa-dua' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_summary = 'Free delivery on rentals of 7 days (1 week) or longer · Rp 150,000 flat delivery fee for shorter stays — anywhere in Denpasar.',
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>7 days (1 week) or longer</strong>.</li>
<li>Shorter rentals: flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Denpasar.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
<li>We deliver from a single depot in Kerobokan — the same full catalog is available for Denpasar, no location-based inventory split.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'denpasar' AND lpt.language_code = 'en';

-- Canggu: fleet-base bullet allowed too (реально в нескольких минутах от
-- Kerobokan) — добавлена в существующий delivery_html, пороги не трогаем
-- (уже верно взяты из delivery_fee_rules, этот файл Canggu не описывает).
UPDATE location_page_translations lpt SET
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Canggu.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Canggu.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
<li>We deliver from our depot in Kerobokan, just minutes from Canggu — the full catalog is available, no location-based inventory split.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: подтвердить — зона доставки одинаковая для всего Canggu (включая Pererenan/Echo Beach на севере) или там другая логика? В одном из источников эти районы упоминаются как "дальше на север" от основного Canggu.]</p>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'canggu' AND lpt.language_code = 'en';

-- ---- 4. intro + FAQ Q1 (8 районов) — убраны невыдуманные подрайоны ----
UPDATE location_page_translations lpt SET
    intro = 'Seminyak is Bali''s upscale beach-club-and-boutique strip — a tight grid of designer shops, spas and restaurants between the Oberoi and the coast. Most villas and hotels sit a short, flat ride from the beach, and a scooter is the easiest way to move between sunset spots without hunting for parking. We deliver anywhere in Seminyak and set you up with a bike that matches how far you actually plan to ride.',
    faq = jsonb_set(faq, '{0}', '{"q": "Do you deliver anywhere in Seminyak?", "a": "Yes — delivery covers all of Seminyak. Free from 3 days, Rp 150,000 flat fee for shorter stays."}'::jsonb)
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'seminyak' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    intro = 'Ubud is Bali''s cultural and creative heart — rice terraces, temples and art studios spread across rolling, genuinely hilly terrain rather than the south''s flat coastline. Traffic on the main Jalan Raya Ubud strip can be dense around the market and Monkey Forest, but a scooter still gets you to the rice-terrace roads and quiet backstreets a car can''t reach. We deliver anywhere in Ubud and set you up with a bike suited to Ubud''s hills, not just flat cruising.',
    faq = jsonb_set(faq, '{0}', '{"q": "Do you deliver anywhere in Ubud?", "a": "Yes — delivery covers all of Ubud. Free from 30 days (1 month), Rp 150,000 flat fee for shorter stays."}'::jsonb)
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'ubud' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    intro = 'Uluwatu sits on Bali''s southern limestone cliffs — surf breaks, clifftop warungs and the Uluwatu temple road, spread out further than the flatter districts to the north. Roads here climb and wind along the Bukit, and distances between beaches are longer than they look on a map. We deliver anywhere around Uluwatu and set you up with a bike that can handle the hills, not just the beach roads.',
    faq = jsonb_set(faq, '{0}', '{"q": "Do you deliver anywhere around Uluwatu?", "a": "Yes — delivery covers the Uluwatu area. Free from 14 days (2 weeks), Rp 150,000 flat fee for shorter stays."}'::jsonb)
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'uluwatu' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    intro = 'Jimbaran is Bali''s classic sunset-seafood bay — a curved beach lined with grilled-fish warungs, sitting between the airport and the Bukit cliffs. It''s quieter and more spread out than the busier south, with the GWK cultural park and Bukit access roads nearby. We deliver anywhere in Jimbaran and set you up with a bike that matches how far you plan to ride toward the Bukit or the airport.',
    faq = jsonb_set(faq, '{0}', '{"q": "Do you deliver anywhere in Jimbaran?", "a": "Yes — delivery covers all of Jimbaran. Free from 14 days (2 weeks), Rp 150,000 flat fee for shorter stays."}'::jsonb)
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'jimbaran' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    intro = 'Sanur is Bali''s calmest beach town — a long paved beachfront promenade, shallow water and a slower pace than the busier south, popular with families and the fast-boat crowd heading to Nusa Penida and the Gilis. Streets are flatter and less congested than the south''s surf hubs, making it an easy place to start riding. We deliver anywhere in Sanur and set you up with a bike that matches your plans, whether that''s the promenade or a day trip further afield.',
    faq = jsonb_set(faq, '{0}', '{"q": "Do you deliver anywhere in Sanur?", "a": "Yes — delivery covers all of Sanur. Free from 7 days (1 week), Rp 150,000 flat fee for shorter stays."}'::jsonb)
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'sanur' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    intro = 'Kuta is Bali''s original tourist strip — Kuta Beach, Legian''s nightlife and shopping, all dense and walkable but often gridlocked with traffic, especially near Jalan Legian and the Beachwalk mall. A scooter is still the fastest way to cut through it, and Kuta is the closest of these 9 districts to Ngurah Rai Airport. We deliver anywhere in Kuta and set you up with a bike that matches how far you plan to ride beyond the strip.',
    faq = jsonb_set(faq, '{0}', '{"q": "Do you deliver anywhere in Kuta?", "a": "Yes — delivery covers all of Kuta. Free from 7 days (1 week), Rp 150,000 flat fee for shorter stays."}'::jsonb)
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'kuta' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    intro = 'Nusa Dua is Bali''s gated resort district — wide, quiet roads, manicured grounds and calm beaches, a deliberate contrast to the crowds further north. It''s more spread out than it looks from inside a resort, and a scooter is the practical way to reach the beach, the boat harbor or the Bukit beyond the enclave. We deliver anywhere in Nusa Dua and set you up with a bike that matches your plans, whether that''s the promenade or a trip further into Bali.',
    faq = jsonb_set(faq, '{0}', '{"q": "Do you deliver anywhere in Nusa Dua?", "a": "Yes — delivery covers all of Nusa Dua. Free from 14 days (2 weeks), Rp 150,000 flat fee for shorter stays."}'::jsonb)
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'nusa-dua' AND lpt.language_code = 'en';

-- Denpasar intro/FAQ уже были общими (без выдуманных подрайонов) — только
-- обновляем FAQ Q1 под новые пороги доставки.
UPDATE location_page_translations lpt SET
    faq = jsonb_set(faq, '{0}', '{"q": "Do you deliver anywhere in Denpasar?", "a": "Yes — delivery covers all of Denpasar. Free from 7 days (1 week), Rp 150,000 flat fee for shorter stays."}'::jsonb)
FROM location_pages lp WHERE lpt.location_page_id = lp.id AND lp.slug = 'denpasar' AND lpt.language_code = 'en';

-- ---- 5. Getting Around TODO wording (8 районов) — точнее про причину ----
UPDATE location_page_translations lpt
SET getting_around_html = regexp_replace(
    getting_around_html,
    '<p class="loc-todo">\[TODO — заблокировано отсутствующим файлом districts-data-remaining-8\.md: точные часы пик и маршруты объезда для [^]]+ ещё не подтверждены\.\]</p>',
    '<p class="loc-todo">[TODO — заблокировано анкетой водителям (Hari/Stefan/Saiban), которую ещё не отправили: точные часы пик и маршруты объезда подтвердим их словами, не придумываю.]</p>'
)
FROM location_pages lp
WHERE lpt.location_page_id = lp.id AND lp.slug != 'canggu' AND lpt.language_code = 'en';
