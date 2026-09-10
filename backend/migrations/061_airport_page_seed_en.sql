-- New 10th district page: Airport (task item 1, 2026-09-10 session).
-- Structure adapted from the other 9 districts per Дмитрий's instruction
-- (Route/Distances/Popular Locations as-is don't make sense for an
-- airport pickup page) and confirmed by screenshot before publishing:
--   - getting_around_html: NULL (no "traffic patterns in the district"
--     content applies — nothing to say, so the section is hidden, not a
--     placeholder; see also the page.js fix in the same session that
--     stopped the section heading rendering when content is NULL).
--   - distances: repurposed as "drive time FROM the airport TO the other
--     5 nearest districts" instead of the usual "from this district to
--     elsewhere" — same schema, no new code — Дмитрий confirmed keeping
--     this instead of dropping the section (2026-09-10, AskUserQuestion).
--   - delivery_html carries the actual airport-specific content: arrival
--     delivery-hours note (same copy as the other 9), expected terminal
--     wait time, and where the meeting point actually is (not at the
--     exit itself).
--   - popular_locations: NULL — nothing analogous to "cafes near this
--     district" applies to an airport pickup page.
--   - FAQ item 3 (international driving permit) uses a bespoke question
--     (d.faqIdpQOverride in the i18n pipeline) instead of the templated
--     "ride {prep} {district}" one, which reads as nonsense for an
--     airport ("ride at the airport?").
-- EN lives directly in migration SQL (not the i18n pipeline, see 052/055);
-- the other 10 languages went through backend/scripts/i18n_location_pages/
-- airport entries + apply_location_i18n.mjs, synced to prod the same way
-- as the rest of this session's content (gen_location_i18n_sync.mjs).
INSERT INTO location_pages (company_id, slug, is_active) VALUES
    ('37005782-1dec-4f77-9673-f4c85eac9d89', 'airport', TRUE)
ON CONFLICT (company_id, slug) DO NOTHING;

INSERT INTO location_page_translations (
    location_page_id, language_code, seo_title, seo_description, h1, intro,
    delivery_summary, delivery_html, delivery_disclaimer, getting_around_html, distances,
    which_bike_html, route_html, popular_locations, faq, cta_text
) VALUES (
    (SELECT id FROM location_pages WHERE company_id = '37005782-1dec-4f77-9673-f4c85eac9d89' AND slug = 'airport'),
    'en', 'Scooter Rental at Bali Airport (DPS) — We Meet You on Arrival | BikeBaliRent', 'Scooter & motorbike rental with delivery to Ngurah Rai Airport (DPS), Bali. We meet you 1–3 minutes from the arrivals exit, transparent pricing, 60+ bikes.', 'Scooter & Motorbike Rental with Airport Delivery', 'Just landed in Bali and want to ride straight away? We''ll meet you a couple of minutes from the arrivals exit and hand over your bike before you''d even get a taxi sorted. Airport delivery is available almost any time, and we''ll set you up with a bike that matches your onward plans around Bali.',
    'Free delivery on rentals of 7+ days (1 week) · Rp 150,000 flat for shorter rentals — to the airport terminal.', '<ul>
<li>Free delivery on rentals of <strong>7 days or longer (1 week)</strong>.</li>
<li>Shorter rentals: flat delivery fee of <strong>Rp 150,000</strong>.</li>
<li>Exact time and meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p>We can deliver at almost any time — evening and night deliveries outside regular hours are available for an extra fee and must be arranged in advance.</p>
<p>Give yourself a bit of buffer clearing the terminal — waiting 1.5 to 3 hours for a customer isn''t unusual, so don''t worry if it takes a while.</p>
<p>We don''t wait right at the exit — it''s high-traffic and a long wait there can mean a fine. We''ll meet you 1–3 minutes'' walk from the exit, at the bike parking area.</p>', 'Prices above are approximate — please confirm the exact delivery cost for your dates and time with our team.', NULL,
    '[{"peak":"20 min","light":"~10 min","distance":"~3–5 km","destination":"Kuta"},{"peak":"45 min","light":"~25 min","distance":"~12–15 km","destination":"Seminyak"},{"peak":"up to 60 min","light":"~30 min","distance":"~17–20 km","destination":"Canggu"},{"peak":"1+ hour","light":"~35–45 min","distance":"~20–25 km","destination":"Uluwatu"},{"peak":"2+ hours","light":"~70–90 min","distance":"~35–40 km","destination":"Ubud"}]'::jsonb, '<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong><a href="/en/bikes?category=honda_pcx160">Honda PCX 160</a></strong> or <strong><a href="/en/bikes?category=yamaha_nmax155">Yamaha Nmax 155</a></strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong><a href="/en/bikes?category=honda_adv160">Honda ADV 160</a></strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong><a href="/en/bikes?category=yamaha_xmax250">Yamaha Xmax 250</a></strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong><a href="/en/bikes?group=motorcycle&amp;model=suzuki_vstrom250">Suzuki V-Strom 250</a></strong> or <strong><a href="/en/bikes?group=motorcycle&amp;model=kawasaki_versys">Kawasaki Versys</a></strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>', NULL, NULL,
    '[{"a":"Yes — we meet you 1–3 minutes'' walk from the arrivals exit, at the bike parking area. Give yourself a little buffer after landing — waiting 1.5 to 3 hours for a customer isn''t unusual, so don''t worry if it takes a while.","q":"Do you meet arrivals at Ngurah Rai Airport?"},{"a":"No minimum — the delivery fee is the only thing that changes with rental length.","q":"Is there a minimum rental period?"},{"a":"Yes, alongside your home license — see our full guide:","q":"Do I need an international driving permit to ride around Bali on a rented bike?","link":{"href":"/en/blog/riding-in-bali-without-a-license-the-real-risks","label":"Riding in Bali Without a License: The Real Risks"}},{"a":"Depends on your onward plans around Bali — see \"Which Bike Fits\" above: a scooter for the city, an ADV or Xmax for longer trips, a touring bike if there''s two of you with luggage. Want something bigger? We''re happy to suggest other options:","q":"Which bike should I pick if I''ve just landed?","link":{"href":"/en/bikes?group=motorcycle","label":"Motorcycles"}},{"a":"See our Deposit & Safety guide:","q":"What''s your policy on deposit and damage?","link":{"href":"/en/blog#deposit-safety","label":"Deposit & Safety articles"}}]'::jsonb, 'Ready to book? WhatsApp us your dates and pickup spot at the airport, and we''ll confirm your bike and delivery time.'
)
ON CONFLICT (location_page_id, language_code) DO UPDATE SET
    seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    h1 = EXCLUDED.h1, intro = EXCLUDED.intro,
    delivery_summary = EXCLUDED.delivery_summary, delivery_html = EXCLUDED.delivery_html,
    delivery_disclaimer = EXCLUDED.delivery_disclaimer, getting_around_html = EXCLUDED.getting_around_html,
    distances = EXCLUDED.distances, which_bike_html = EXCLUDED.which_bike_html,
    route_html = EXCLUDED.route_html, popular_locations = EXCLUDED.popular_locations,
    faq = EXCLUDED.faq, cta_text = EXCLUDED.cta_text, updated_at = now();
