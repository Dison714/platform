-- Task items 3/4/6 (2026-09-10 session), EN side. Items 3/4/6 for the 10
-- non-EN languages went through the normal i18n pipeline
-- (backend/scripts/i18n_location_pages/*.mjs + apply_location_i18n.mjs);
-- EN lives directly in 052/055's seed SQL (not that pipeline), so this
-- migration is EN's equivalent — same content, generated from the verified
-- local dev DB state (backend/scripts/gen_location_i18n_sync.mjs pattern),
-- not hand-retyped.
--
-- Item 3: bike model names in which_bike_html (shared across all 9
-- districts) now link to the matching product-family catalog view
-- (/bikes?category=<code> for the 4 scooter families, which each have
-- their own dedicated vehicle_categories row; /bikes?group=motorcycle&
-- model=<product_families.code> for the 4 motorcycle families, which
-- share a category with another family and need the model filter
-- instead — see ModelFilter.jsx / CategoryFilter.jsx).
--
-- Item 4: FAQ item 4 ("is a scooter enough, or something bigger?") gets an
-- appended "want something bigger?" sentence plus a link to the
-- motorcycle-group catalog view, same {href,label} pattern already used by
-- the IDP and Deposit FAQ items.
--
-- Item 6 (canggu + seminyak only, baked into their which_bike_html here):
-- cafe-racer/sport-model callout block (XSR, Ronin), same link scheme.

UPDATE location_page_translations lpt SET
    which_bike_html = '<ul>
<li><strong>City riding</strong> (cafés, coworking, short hops around Berawa/Batu Bolong/Pererenan): a <strong><a href="/en/bikes?category=honda_pcx160">Honda PCX 160</a></strong> or <strong><a href="/en/bikes?category=yamaha_nmax155">Yamaha Nmax 155</a></strong> — fully automatic, easy to park, plenty for flat coastal roads.</li>
<li><strong>Hills / light adventure</strong> riding inland: a <strong><a href="/en/bikes?category=honda_adv160">Honda ADV 160</a></strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> to Ubud or Uluwatu from a Canggu base: a <strong><a href="/en/bikes?category=yamaha_xmax250">Yamaha Xmax 250</a></strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong><a href="/en/bikes?group=motorcycle&amp;model=suzuki_vstrom250">Suzuki V-Strom 250</a></strong> or <strong><a href="/en/bikes?group=motorcycle&amp;model=kawasaki_versys">Kawasaki Versys</a></strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>
<p>Want to arrive in style, not just arrive? Cafe racers — <strong><a href="/en/bikes?group=motorcycle&amp;model=yamaha_xsr">XSR</a></strong> and <strong><a href="/en/bikes?group=motorcycle&amp;model=tvs_ronin225">Ronin</a></strong> — and sport models fit right into Canggu and Seminyak: nimble in traffic, striking on the beachfront and outside your favorite café. If style matters as much as comfort, this is your pick.</p>',
    faq = '[{"a":"Yes — delivery covers all of Canggu. Free from 15 days, Rp 100,000 for 7–14 days, Rp 150,000 flat fee under a week.","q":"Do you deliver anywhere in Canggu, including Pererenan and Echo Beach?"},{"a":"No minimum — the delivery fee is the only thing that changes with rental length.","q":"Is there a minimum rental period?"},{"a":"Yes, alongside your home license — see our full guide:","q":"Do I need an international driving permit to ride in Canggu?","link":{"href":"/en/blog/riding-in-bali-without-a-license-the-real-risks","label":"Riding in Bali Without a License: The Real Risks"}},{"a":"Depends on your plans — see \"Which Bike Fits Canggu Best\" above. If you''re mostly staying in Canggu, a scooter is plenty; day trips to Ubud/Uluwatu are more comfortable on an NMAX or ADV. Want something bigger? We''re happy to suggest other options:","q":"Is a scooter enough, or should I rent something bigger?","link":{"href":"/en/bikes?group=motorcycle","label":"Motorcycles"}},{"a":"See our Deposit & Safety guide:","q":"What''s your policy on deposit and damage?","link":{"href":"/en/blog#deposit-safety","label":"Deposit & Safety articles"}}]'::jsonb,
    updated_at = now()
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'canggu' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    which_bike_html = '<ul>
<li><strong>City riding</strong> (offices, markets, short local hops): a <strong><a href="/en/bikes?category=honda_pcx160">Honda PCX 160</a></strong> or <strong><a href="/en/bikes?category=yamaha_nmax155">Yamaha Nmax 155</a></strong> — fully automatic, easy to park, plenty for flat city roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong><a href="/en/bikes?category=honda_adv160">Honda ADV 160</a></strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong><a href="/en/bikes?category=yamaha_xmax250">Yamaha Xmax 250</a></strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong><a href="/en/bikes?group=motorcycle&amp;model=suzuki_vstrom250">Suzuki V-Strom 250</a></strong> or <strong><a href="/en/bikes?group=motorcycle&amp;model=kawasaki_versys">Kawasaki Versys</a></strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>',
    faq = '[{"a":"Yes — delivery covers all of Denpasar. Free from 7 days (1 week), Rp 150,000 flat fee for shorter stays.","q":"Do you deliver anywhere in Denpasar?"},{"a":"No minimum — the delivery fee is the only thing that changes with rental length.","q":"Is there a minimum rental period?"},{"a":"Yes, alongside your home license — see our full guide:","q":"Do I need an international driving permit to ride in Denpasar?","link":{"href":"/en/blog/riding-in-bali-without-a-license-the-real-risks","label":"Riding in Bali Without a License: The Real Risks"}},{"a":"Depends on your plans — see \"Which Bike Fits Denpasar Best\" above. For city riding a scooter is plenty; longer trips across Bali are more comfortable on an Xmax, V-Strom, or Versys. Want something bigger? We''re happy to suggest other options:","q":"Is a scooter enough, or should I rent something bigger?","link":{"href":"/en/bikes?group=motorcycle","label":"Motorcycles"}},{"a":"See our Deposit & Safety guide:","q":"What''s your policy on deposit and damage?","link":{"href":"/en/blog#deposit-safety","label":"Deposit & Safety articles"}}]'::jsonb,
    updated_at = now()
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'denpasar' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    which_bike_html = '<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong><a href="/en/bikes?category=honda_pcx160">Honda PCX 160</a></strong> or <strong><a href="/en/bikes?category=yamaha_nmax155">Yamaha Nmax 155</a></strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong><a href="/en/bikes?category=honda_adv160">Honda ADV 160</a></strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong><a href="/en/bikes?category=yamaha_xmax250">Yamaha Xmax 250</a></strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong><a href="/en/bikes?group=motorcycle&amp;model=suzuki_vstrom250">Suzuki V-Strom 250</a></strong> or <strong><a href="/en/bikes?group=motorcycle&amp;model=kawasaki_versys">Kawasaki Versys</a></strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>',
    faq = '[{"a":"Yes — delivery covers all of Jimbaran. Free from 14 days (2 weeks), Rp 150,000 flat fee for shorter stays.","q":"Do you deliver anywhere in Jimbaran?"},{"a":"No minimum — the delivery fee is the only thing that changes with rental length.","q":"Is there a minimum rental period?"},{"a":"Yes, alongside your home license — see our full guide:","q":"Do I need an international driving permit to ride in Jimbaran?","link":{"href":"/en/blog/riding-in-bali-without-a-license-the-real-risks","label":"Riding in Bali Without a License: The Real Risks"}},{"a":"Depends on your plans — see \"Which Bike Fits Jimbaran Best\" above. For the bay itself a scooter is plenty; heading up toward the Bukit or GWK is easier with more power. Want something bigger? We''re happy to suggest other options:","q":"Is a scooter enough, or should I rent something bigger?","link":{"href":"/en/bikes?group=motorcycle","label":"Motorcycles"}},{"a":"See our Deposit & Safety guide:","q":"What''s your policy on deposit and damage?","link":{"href":"/en/blog#deposit-safety","label":"Deposit & Safety articles"}}]'::jsonb,
    updated_at = now()
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'jimbaran' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    which_bike_html = '<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong><a href="/en/bikes?category=honda_pcx160">Honda PCX 160</a></strong> or <strong><a href="/en/bikes?category=yamaha_nmax155">Yamaha Nmax 155</a></strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong><a href="/en/bikes?category=honda_adv160">Honda ADV 160</a></strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong><a href="/en/bikes?category=yamaha_xmax250">Yamaha Xmax 250</a></strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong><a href="/en/bikes?group=motorcycle&amp;model=suzuki_vstrom250">Suzuki V-Strom 250</a></strong> or <strong><a href="/en/bikes?group=motorcycle&amp;model=kawasaki_versys">Kawasaki Versys</a></strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>',
    faq = '[{"a":"Yes — delivery covers all of Kuta. Free from 7 days (1 week), Rp 150,000 flat fee for shorter stays.","q":"Do you deliver anywhere in Kuta?"},{"a":"No minimum — the delivery fee is the only thing that changes with rental length.","q":"Is there a minimum rental period?"},{"a":"Yes, alongside your home license — see our full guide:","q":"Do I need an international driving permit to ride in Kuta?","link":{"href":"/en/blog/riding-in-bali-without-a-license-the-real-risks","label":"Riding in Bali Without a License: The Real Risks"}},{"a":"Depends on your plans — see \"Which Bike Fits Kuta Best\" above. For the strip itself a scooter is plenty; longer trips across Bali are more comfortable on an Xmax, V-Strom, or Versys. Want something bigger? We''re happy to suggest other options:","q":"Is a scooter enough, or should I rent something bigger?","link":{"href":"/en/bikes?group=motorcycle","label":"Motorcycles"}},{"a":"See our Deposit & Safety guide:","q":"What''s your policy on deposit and damage?","link":{"href":"/en/blog#deposit-safety","label":"Deposit & Safety articles"}}]'::jsonb,
    updated_at = now()
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'kuta' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    which_bike_html = '<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong><a href="/en/bikes?category=honda_pcx160">Honda PCX 160</a></strong> or <strong><a href="/en/bikes?category=yamaha_nmax155">Yamaha Nmax 155</a></strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong><a href="/en/bikes?category=honda_adv160">Honda ADV 160</a></strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong><a href="/en/bikes?category=yamaha_xmax250">Yamaha Xmax 250</a></strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong><a href="/en/bikes?group=motorcycle&amp;model=suzuki_vstrom250">Suzuki V-Strom 250</a></strong> or <strong><a href="/en/bikes?group=motorcycle&amp;model=kawasaki_versys">Kawasaki Versys</a></strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>',
    faq = '[{"a":"Yes — delivery covers all of Nusa Dua. Free from 14 days (2 weeks), Rp 150,000 flat fee for shorter stays.","q":"Do you deliver anywhere in Nusa Dua?"},{"a":"No minimum — the delivery fee is the only thing that changes with rental length.","q":"Is there a minimum rental period?"},{"a":"Yes, alongside your home license — see our full guide:","q":"Do I need an international driving permit to ride in Nusa Dua?","link":{"href":"/en/blog/riding-in-bali-without-a-license-the-real-risks","label":"Riding in Bali Without a License: The Real Risks"}},{"a":"Depends on your plans — see \"Which Bike Fits Nusa Dua Best\" above. Inside the enclave a scooter is plenty; longer trips across Bali are more comfortable on an Xmax, V-Strom, or Versys. Want something bigger? We''re happy to suggest other options:","q":"Is a scooter enough, or should I rent something bigger?","link":{"href":"/en/bikes?group=motorcycle","label":"Motorcycles"}},{"a":"See our Deposit & Safety guide:","q":"What''s your policy on deposit and damage?","link":{"href":"/en/blog#deposit-safety","label":"Deposit & Safety articles"}}]'::jsonb,
    updated_at = now()
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'nusa-dua' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    which_bike_html = '<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong><a href="/en/bikes?category=honda_pcx160">Honda PCX 160</a></strong> or <strong><a href="/en/bikes?category=yamaha_nmax155">Yamaha Nmax 155</a></strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong><a href="/en/bikes?category=honda_adv160">Honda ADV 160</a></strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong><a href="/en/bikes?category=yamaha_xmax250">Yamaha Xmax 250</a></strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong><a href="/en/bikes?group=motorcycle&amp;model=suzuki_vstrom250">Suzuki V-Strom 250</a></strong> or <strong><a href="/en/bikes?group=motorcycle&amp;model=kawasaki_versys">Kawasaki Versys</a></strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>',
    faq = '[{"a":"Yes — delivery covers all of Sanur. Free from 7 days (1 week), Rp 150,000 flat fee for shorter stays.","q":"Do you deliver anywhere in Sanur?"},{"a":"No minimum — the delivery fee is the only thing that changes with rental length.","q":"Is there a minimum rental period?"},{"a":"Yes, alongside your home license — see our full guide:","q":"Do I need an international driving permit to ride in Sanur?","link":{"href":"/en/blog/riding-in-bali-without-a-license-the-real-risks","label":"Riding in Bali Without a License: The Real Risks"}},{"a":"Depends on your plans — see \"Which Bike Fits Sanur Best\" above. Sanur itself is flat and easy on a city scooter; day trips further afield are more comfortable on an Xmax, V-Strom, or Versys. Want something bigger? We''re happy to suggest other options:","q":"Is a scooter enough, or should I rent something bigger?","link":{"href":"/en/bikes?group=motorcycle","label":"Motorcycles"}},{"a":"See our Deposit & Safety guide:","q":"What''s your policy on deposit and damage?","link":{"href":"/en/blog#deposit-safety","label":"Deposit & Safety articles"}}]'::jsonb,
    updated_at = now()
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'sanur' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    which_bike_html = '<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong><a href="/en/bikes?category=honda_pcx160">Honda PCX 160</a></strong> or <strong><a href="/en/bikes?category=yamaha_nmax155">Yamaha Nmax 155</a></strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong><a href="/en/bikes?category=honda_adv160">Honda ADV 160</a></strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong><a href="/en/bikes?category=yamaha_xmax250">Yamaha Xmax 250</a></strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong><a href="/en/bikes?group=motorcycle&amp;model=suzuki_vstrom250">Suzuki V-Strom 250</a></strong> or <strong><a href="/en/bikes?group=motorcycle&amp;model=kawasaki_versys">Kawasaki Versys</a></strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>
<p>Want to arrive in style, not just arrive? Cafe racers — <strong><a href="/en/bikes?group=motorcycle&amp;model=yamaha_xsr">XSR</a></strong> and <strong><a href="/en/bikes?group=motorcycle&amp;model=tvs_ronin225">Ronin</a></strong> — and sport models fit right into Canggu and Seminyak: nimble in traffic, striking on the beachfront and outside your favorite café. If style matters as much as comfort, this is your pick.</p>',
    faq = '[{"a":"Yes — delivery covers all of Seminyak. Free from 3 days, Rp 150,000 flat fee for shorter stays.","q":"Do you deliver anywhere in Seminyak?"},{"a":"No minimum — the delivery fee is the only thing that changes with rental length.","q":"Is there a minimum rental period?"},{"a":"Yes, alongside your home license — see our full guide:","q":"Do I need an international driving permit to ride in Seminyak?","link":{"href":"/en/blog/riding-in-bali-without-a-license-the-real-risks","label":"Riding in Bali Without a License: The Real Risks"}},{"a":"Depends on your plans — see \"Which Bike Fits Seminyak Best\" above. For local riding a scooter is plenty; longer trips across Bali are more comfortable on an Xmax, V-Strom, or Versys. Want something bigger? We''re happy to suggest other options:","q":"Is a scooter enough, or should I rent something bigger?","link":{"href":"/en/bikes?group=motorcycle","label":"Motorcycles"}},{"a":"See our Deposit & Safety guide:","q":"What''s your policy on deposit and damage?","link":{"href":"/en/blog#deposit-safety","label":"Deposit & Safety articles"}}]'::jsonb,
    updated_at = now()
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'seminyak' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    which_bike_html = '<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong><a href="/en/bikes?category=honda_pcx160">Honda PCX 160</a></strong> or <strong><a href="/en/bikes?category=yamaha_nmax155">Yamaha Nmax 155</a></strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong><a href="/en/bikes?category=honda_adv160">Honda ADV 160</a></strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong><a href="/en/bikes?category=yamaha_xmax250">Yamaha Xmax 250</a></strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong><a href="/en/bikes?group=motorcycle&amp;model=suzuki_vstrom250">Suzuki V-Strom 250</a></strong> or <strong><a href="/en/bikes?group=motorcycle&amp;model=kawasaki_versys">Kawasaki Versys</a></strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>',
    faq = '[{"a":"Yes — delivery covers all of Ubud. Free from 30 days (1 month), Rp 150,000 flat fee for shorter stays.","q":"Do you deliver anywhere in Ubud?"},{"a":"No minimum — the delivery fee is the only thing that changes with rental length.","q":"Is there a minimum rental period?"},{"a":"Yes, alongside your home license — see our full guide:","q":"Do I need an international driving permit to ride in Ubud?","link":{"href":"/en/blog/riding-in-bali-without-a-license-the-real-risks","label":"Riding in Bali Without a License: The Real Risks"}},{"a":"Depends on your plans — see \"Which Bike Fits Ubud Best\" above. Ubud''s hills favor a bit more power than a flat-coast city scooter, especially if you''re heading further out to the rice terraces. Want something bigger? We''re happy to suggest other options:","q":"Is a scooter enough, or should I rent something bigger?","link":{"href":"/en/bikes?group=motorcycle","label":"Motorcycles"}},{"a":"See our Deposit & Safety guide:","q":"What''s your policy on deposit and damage?","link":{"href":"/en/blog#deposit-safety","label":"Deposit & Safety articles"}}]'::jsonb,
    updated_at = now()
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'ubud' AND lpt.language_code = 'en';

UPDATE location_page_translations lpt SET
    which_bike_html = '<ul>
<li><strong>City riding</strong> (cafés, shops, short local hops): a <strong><a href="/en/bikes?category=honda_pcx160">Honda PCX 160</a></strong> or <strong><a href="/en/bikes?category=yamaha_nmax155">Yamaha Nmax 155</a></strong> — fully automatic, easy to park, plenty for flat local roads.</li>
<li><strong>Hills / light adventure</strong> riding: a <strong><a href="/en/bikes?category=honda_adv160">Honda ADV 160</a></strong> — higher ground clearance, still automatic, more confident on inclines than a city scooter.</li>
<li><strong>Long day trips</strong> across Bali: a <strong><a href="/en/bikes?category=yamaha_xmax250">Yamaha Xmax 250</a></strong> — bigger engine, more stable at highway speed, comfortable over longer distances.</li>
<li><strong>Passenger + luggage</strong> / multi-day touring: a <strong><a href="/en/bikes?group=motorcycle&amp;model=suzuki_vstrom250">Suzuki V-Strom 250</a></strong> or <strong><a href="/en/bikes?group=motorcycle&amp;model=kawasaki_versys">Kawasaki Versys</a></strong> — manual touring bikes built for two-up riding with gear, best for riders with more experience.</li>
</ul>',
    faq = '[{"a":"Yes — delivery covers the Uluwatu area. Free from 14 days (2 weeks), Rp 150,000 flat fee for shorter stays.","q":"Do you deliver anywhere around Uluwatu?"},{"a":"No minimum — the delivery fee is the only thing that changes with rental length.","q":"Is there a minimum rental period?"},{"a":"Yes, alongside your home license — see our full guide:","q":"Do I need an international driving permit to ride in Uluwatu?","link":{"href":"/en/blog/riding-in-bali-without-a-license-the-real-risks","label":"Riding in Bali Without a License: The Real Risks"}},{"a":"Depends on your plans — see \"Which Bike Fits Uluwatu Best\" above. The Bukit''s hills favor a bit more power than a flat-coast city scooter. Want something bigger? We''re happy to suggest other options:","q":"Is a scooter enough, or should I rent something bigger?","link":{"href":"/en/bikes?group=motorcycle","label":"Motorcycles"}},{"a":"See our Deposit & Safety guide:","q":"What''s your policy on deposit and damage?","link":{"href":"/en/blog#deposit-safety","label":"Deposit & Safety articles"}}]'::jsonb,
    updated_at = now()
FROM location_pages lp
WHERE lp.id = lpt.location_page_id AND lp.slug = 'uluwatu' AND lpt.language_code = 'en';
