-- Seed: Canggu location page, EN only (dev test — DIST-1 of 9 districts).
-- Content source: "Районы/scooter-rental-canggu-EN-draft.md" (as-is).
-- Delivery numbers below use the REAL 3-tier delivery_fee_rules (<7d
-- 150k / 7-14d 100k / 15+d free — see 003_pricing_warehouse.sql), not the
-- draft's simplified 2-tier framing (free 7d+ / 150k flat under 7d) — the
-- draft predates/ignores the mid-tier. Flagged to Дмитрий for confirmation
-- alongside the delivery-zone TODO already in the draft; not silently
-- invented (CLAUDE.md §8).
INSERT INTO location_pages (id, company_id, slug, is_active)
VALUES ('a10c0000-0000-4000-8000-000000000001', '37005782-1dec-4f77-9673-f4c85eac9d89', 'canggu', TRUE);

INSERT INTO location_page_translations (
    location_page_id, language_code, seo_title, seo_description, h1, intro,
    delivery_summary, delivery_html, getting_around_html, distances,
    which_bike_html, route_html, photos_note, faq, cta_text
) VALUES (
    'a10c0000-0000-4000-8000-000000000001', 'en',
    'Scooter Rental Canggu, Bali — Free Delivery & Best Bikes | BikeBaliRent',
    'Scooter & motorbike rental in Canggu with fast delivery to Berawa, Batu Bolong, Pererenan and Echo Beach. Free delivery on weekly rentals, transparent pricing, 60+ bikes.',
    'Scooter & Motorbike Rental in Canggu',
    'Canggu is our busiest delivery area — surf breaks, coworking spaces and beach clubs packed into a few square kilometres, with almost every villa and guesthouse reachable by scooter in minutes. We deliver anywhere in Canggu — Berawa, Batu Bolong, Echo Beach, Pererenan, Tibubeneng — and set you up with a bike that matches how far you actually plan to ride.',
    'Free delivery on rentals of 15+ days · Rp 100,000 for 7–14 days · Rp 150,000 flat under a week — anywhere in Canggu.',
    $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Canggu.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Canggu.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p class="loc-todo">[TODO — Дмитрий: подтвердить — зона доставки одинаковая для всего Canggu (включая Pererenan/Echo Beach на севере) или там другая логика? В одном из источников эти районы упоминаются как "дальше на север" от основного Canggu.]</p>
<p class="loc-todo">[TODO — Дмитрий: часы работы доставки (можно ли ночью/рано утром?) — не знаю, не пишу]</p>$html$,
    $html$<p>Canggu's roads were built for a fishing village, not for the number of scooters, cars and delivery vans now using them every day. Expect real congestion during <strong>8–10am and 4–7pm</strong>, especially on Jalan Raya Canggu, around Kerobokan, and on the Canggu Shortcut connecting Berawa to Batu Bolong — a narrow route that can bottleneck badly at peak times.</p>
<p>A scooter is still the fastest way to get around: you can filter through slow traffic and park in spots a car simply can't reach. Parking gets tight right at sunset near the main beach clubs (Batu Bolong / Old Man's, Berawa / Finns) — arrive a little early if you're heading there for sunset.</p>$html$,
    $json$[
      {"destination": "Ngurah Rai Airport (DPS)", "distance": "~17–20 km", "light": "~30 min", "peak": "up to 60 min"},
      {"destination": "Seminyak", "distance": "~8–10 km", "light": "~20 min", "peak": "35–60 min"},
      {"destination": "Uluwatu", "distance": "~30–35 km", "light": "~45–60 min", "peak": "1.5+ hours"},
      {"destination": "Ubud", "distance": "~28–35 km", "light": "~60–90 min", "peak": "2+ hours"}
    ]$json$::jsonb,
    $html$<ul>
<li><strong>Staying local</strong> (cafés, coworking, the beach, short hops around Berawa/Batu Bolong/Pererenan): a <strong>Honda Scoopy</strong> or <strong>Honda PCX 160</strong> is easy to park and plenty for flat coastal roads.</li>
<li><strong>Planning day trips to Ubud or Uluwatu</strong> from a Canggu base: a <strong>Yamaha NMAX 155</strong> or <strong>Honda ADV 160</strong> — more stable at highway speed and better suited to the Bukit's hills.</li>
</ul>
<p class="loc-todo">[Draft — сверить с общей матрицей "модель × характер" ниже]</p>$html$,
    '[TODO — заблокировано анкетой водителям (Hari/Stefan/Saiban), которую ещё не отправили. Реальный маршрут, кафе и точки по дороге — только с их слов, не придумываю.]',
    '[TODO — реальные фото доставки/клиентов в Canggu, у нас пока нет готового набора под этот район]',
    $json$[
      {"q": "Do you deliver anywhere in Canggu, including Pererenan and Echo Beach?", "a": "Yes — delivery covers all of Canggu. Free from 15 days, Rp 100,000 for 7–14 days, Rp 150,000 flat fee under a week."},
      {"q": "Is there a minimum rental period?", "a": "No minimum — the delivery fee is the only thing that changes with rental length."},
      {"q": "Do I need an international driving permit to ride in Canggu?", "a": "Yes, alongside your home license — see our full guide:", "link": {"label": "Riding in Bali Without a License: The Real Risks", "href": "/en/blog/riding-in-bali-without-a-license-the-real-risks"}},
      {"q": "Is a scooter enough, or should I rent something bigger?", "a": "Depends on your plans — see \"Which Bike Fits Canggu Best\" above. If you're mostly staying in Canggu, a scooter is plenty; day trips to Ubud/Uluwatu are more comfortable on an NMAX or ADV."},
      {"q": "What's your policy on deposit and damage?", "a": "See our Deposit & Safety guide:", "link": {"label": "Deposit & Safety articles", "href": "/en/blog#deposit-safety"}}
    ]$json$::jsonb,
    'Ready to book? WhatsApp us your dates and pickup spot in Canggu, and we''ll confirm your bike and delivery time.'
);
