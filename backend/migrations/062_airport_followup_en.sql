-- Follow-up to 061 (task from 2026-09-12, after live review of the
-- Airport page): EN side of items 1/2/4 — items 3/5 are frontend-only
-- (page.js + dictionaries + globals.css), no data change needed.
--
-- Item 1: replaced the "wait 1.5-3 hours, that's normal" framing (both in
-- delivery_html and the FAQ arrivals answer) with copy that asks the
-- customer to plan realistically instead of normalizing a long wait.
-- Item 2: added an "Airport pick up location" button (Google Maps link)
-- right after the meeting-point paragraph in delivery_html.
-- Item 4: which_bike_html set to NULL (page.js now hides that section's
-- heading too when the field is empty, same fix as getting_around_html
-- from the previous session) — replaced with a one-line "we deliver any
-- bike from our fleet" note + full-catalog button, appended to
-- delivery_html instead of living in its own section. faq[3] (the
-- "is a scooter enough" answer) had its now-dangling "see Which Bike
-- Fits above" reference removed since that section no longer exists.
UPDATE location_page_translations lpt SET
    delivery_html = '<ul>
<li>Free delivery on rentals of <strong>7 days or longer (1 week)</strong>.</li>
<li>Shorter rentals: flat delivery fee of <strong>Rp 150,000</strong>.</li>
<li>Exact time and meeting point confirmed by WhatsApp after booking.</li>
</ul>
<p>We can deliver at almost any time — evening and night deliveries outside regular hours are available for an extra fee and must be arranged in advance.</p>
<p>Please plan realistically for how long it takes to clear the terminal — factoring in baggage claim, passport control and customs. That way our driver won''t end up waiting too long for you.</p>
<p>We don''t wait right at the exit — it''s high-traffic and a long wait there can mean a fine. We''ll meet you 1–3 minutes'' walk from the exit, at the bike parking area.</p>
<p><a class="btn-cta loc-cta-btn loc-cta-outline" href="https://maps.app.goo.gl/3cmkLZEnQ1zisxPA8?g_st=atm" target="_blank" rel="noopener noreferrer">Airport pick up location</a></p>
<div class="loc-see-all-row"><p class="loc-see-all-note" style="margin:0">We can deliver any bike from our fleet to the airport.</p><a class="btn-cta loc-cta-btn" href="/en/bikes">Browse all bikes</a></div>',
    which_bike_html = NULL,
    faq = '[{"a":"Yes — we meet you 1–3 minutes'' walk from the arrivals exit, at the bike parking area. Please plan realistically for how long it takes to clear the terminal — factoring in baggage claim, passport control and customs. That way our driver won''t end up waiting too long for you.","q":"Do you meet arrivals at Ngurah Rai Airport?"},{"a":"No minimum — the delivery fee is the only thing that changes with rental length.","q":"Is there a minimum rental period?"},{"a":"Yes, alongside your home license — see our full guide:","q":"Do I need an international driving permit to ride around Bali on a rented bike?","link":{"href":"/en/blog/riding-in-bali-without-a-license-the-real-risks","label":"Riding in Bali Without a License: The Real Risks"}},{"a":"Depends on your onward plans around Bali: a scooter for the city, an ADV or Xmax for longer trips, a touring bike if there''s two of you with luggage. Want something bigger? We''re happy to suggest other options:","q":"Which bike should I pick if I''ve just landed?","link":{"href":"/en/bikes?group=motorcycle","label":"Motorcycles"}},{"a":"See our Deposit & Safety guide:","q":"What''s your policy on deposit and damage?","link":{"href":"/en/blog#deposit-safety","label":"Deposit & Safety articles"}}]'::jsonb,
    updated_at = now()
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'airport' AND lpt.language_code = 'en';
