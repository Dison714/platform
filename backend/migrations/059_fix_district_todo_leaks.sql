-- CRITICAL FIX: internal review [TODO] markers were leaking into the live
-- render of all 9 district pages, all 11 languages (Дмитрий screenshot,
-- 2026-09-10 session). Root cause: 052/055 seeded delivery_html and
-- getting_around_html with literal "<p class="loc-todo">[TODO — ...]</p>"
-- placeholder paragraphs, and page.js renders both fields raw via
-- dangerouslySetInnerHTML — nothing ever stripped them before go-live. The
-- 10 non-EN i18n source files (backend/scripts/i18n_location_pages/*.mjs)
-- carried the SAME UNTRANSLATED RUSSIAN TODO TEXT verbatim in every
-- language (never actually translated — they were meant to be removed
-- before seeding, not translated) — fixed there directly and re-applied
-- via apply_location_i18n.mjs; this migration is the EN-side equivalent
-- (EN lives directly in 052/055 SQL, not in the i18n pipeline).
--
-- What changes, all 9 districts, language_code = 'en':
--  - delivery_html: hours-TODO paragraph -> final copy (task item 7, same
--    wording used for every language/district).
--  - delivery_html (canggu only): zone-TODO paragraph -> final copy (task
--    item 8, Canggu-specific, confirmed by Дмитрий 2026-09-10 — delivery
--    zone is uniform across Canggu incl. Pererenan/Echo Beach, no special
--    logic).
--  - getting_around_html (8 non-Canggu districts): peak-hours/route TODO
--    paragraph (blocked on a driver survey that was never sent, per
--    055's header comment) removed entirely, not replaced — task item 5.
--    Canggu's getting_around_html never had this paragraph, untouched.
--  - photos_note (canggu only): TODO placeholder -> NULL. Not rendered by
--    page.js (dead field, confirmed — no reference in
--    frontend/src/app/[locale]/[locationSlug]/page.js), so not part of the
--    actual leak, but same "no placeholder text in a public content
--    column" principle applies (item 0.3) — cleaned while here.
--
-- Unlike 052/055's fixed-slug seed INSERTs, this is a plain UPDATE set —
-- matches the 058_hide_empty_sections.sql precedent for a post-seed data
-- fix (058 only covered route_html and only for 'en'; this migration is
-- the belated fix for delivery_html/getting_around_html/photos_note, all
-- 9 districts, still only 'en' — the other 10 languages are fixed via
-- apply_location_i18n.mjs, not SQL, since that's their normal pipeline).

UPDATE location_page_translations lpt SET
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Canggu.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Canggu.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p>The delivery zone in Canggu is the same across the whole area, including Pererenan and Echo Beach to the north — there are no special restrictions.</p>
<p>We can deliver at almost any time — evening and night deliveries outside regular hours are available for an extra fee and must be arranged in advance.</p>$html$,
    photos_note = NULL
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'canggu' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Seminyak.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Seminyak.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p>We can deliver at almost any time — evening and night deliveries outside regular hours are available for an extra fee and must be arranged in advance.</p>$html$,
    getting_around_html = $html$<p>Seminyak's streets are flat and walkable in parts, but Jalan Kayu Aya (Oberoi) and Jalan Laksmana (Petitenget) get seriously congested in the late afternoon as beach-club traffic builds, with delivery scooters and cars competing for the same narrow lanes. A scooter still beats sitting in that traffic — you can filter through and park closer to the beach entrances than any car.</p>$html$
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'seminyak' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Ubud.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Ubud.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p>We can deliver at almost any time — evening and night deliveries outside regular hours are available for an extra fee and must be arranged in advance.</p>$html$,
    getting_around_html = $html$<p>Ubud's main artery, Jalan Raya Ubud, backs up around the market and Monkey Forest Road especially at midday and early evening — one of the more congested single streets in Bali outside the south. Away from that strip, the roads through the rice terraces and Campuhan Ridge are quieter but genuinely hilly, so a scooter with a bit more power (ADV or Xmax) rides easier than a small city scooter.</p>$html$
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'ubud' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Uluwatu.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Uluwatu.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p>We can deliver at almost any time — evening and night deliveries outside regular hours are available for an extra fee and must be arranged in advance.</p>$html$,
    getting_around_html = $html$<p>The roads across the Bukit peninsula around Uluwatu are hillier and more spread out than anywhere else on this list — getting from one beach to the next (Padang Padang, Bingin, Balangan) often means a genuine climb, not a flat cruise. Traffic itself is lighter than Canggu or Seminyak, but the terrain means a scooter with more torque handles it more comfortably.</p>$html$
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'uluwatu' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Jimbaran.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Jimbaran.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p>We can deliver at almost any time — evening and night deliveries outside regular hours are available for an extra fee and must be arranged in advance.</p>$html$,
    getting_around_html = $html$<p>Jimbaran itself is fairly relaxed compared to the south's surf hubs, with the bay road and the GWK access road as the main arteries — traffic builds mainly around sunset when the seafood warungs fill up. A scooter is the easy way to move along the bay or up toward GWK and the Bukit without hunting for parking.</p>$html$
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'jimbaran' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Sanur.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Sanur.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p>We can deliver at almost any time — evening and night deliveries outside regular hours are available for an extra fee and must be arranged in advance.</p>$html$,
    getting_around_html = $html$<p>Sanur is one of the calmer districts to ride in — the beachfront promenade is relaxed and scooter-friendly, and the inland streets toward Denpasar carry more traffic than the coast itself but nothing like Kuta or Seminyak's peak-hour crush. It's a comfortable place to get used to riding in Bali before heading further afield.</p>$html$
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'sanur' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Kuta.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Kuta.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p>We can deliver at almost any time — evening and night deliveries outside regular hours are available for an extra fee and must be arranged in advance.</p>$html$,
    getting_around_html = $html$<p>Kuta and Legian are some of the most congested streets in Bali — Jalan Legian and the roads around Beachwalk mall back up for most of the afternoon and evening, made worse by the density of foot traffic, taxis and delivery scooters. A scooter still cuts through faster than a car, and Kuta's proximity to the airport makes it convenient for early arrivals or late departures.</p>$html$
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'kuta' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Nusa Dua.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Nusa Dua.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p>We can deliver at almost any time — evening and night deliveries outside regular hours are available for an extra fee and must be arranged in advance.</p>$html$,
    getting_around_html = $html$<p>Inside the ITDC resort enclave, roads are wide, quiet and well maintained — genuinely the easiest riding on this list. Traffic picks up mainly where Nusa Dua's main gate meets the road toward Benoa and the rest of Bali, and that stretch can bottleneck around commuting hours.</p>$html$
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'nusa-dua' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    delivery_html = $html$<ul>
<li>Free delivery on rentals of <strong>15 days or longer</strong>.</li>
<li><strong>7–14 days:</strong> flat delivery fee of Rp 100,000, anywhere in Denpasar.</li>
<li>Shorter rentals (under 7 days): flat delivery fee of <strong>Rp 150,000</strong>, anywhere in Denpasar.</li>
<li>Delivery time and exact meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p>We can deliver at almost any time — evening and night deliveries outside regular hours are available for an extra fee and must be arranged in advance.</p>$html$,
    getting_around_html = $html$<p>Denpasar carries the heaviest, most city-like traffic of any district on this list — the main arteries are genuinely congested for most of the working day, closer to a regional capital's rush hour than a beach town's afternoon bottleneck. A scooter is less optional here than anywhere else — filtering through slow traffic is often the only realistic way to move quickly.</p>$html$
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'denpasar' AND lpt.language_code = 'en';
