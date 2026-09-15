-- bike_models_sync.sql — generated 2026-09-15
-- Syncs article_categories.slug = 'bike-models' (15 articles x 11 languages = 165 translations).
-- Idempotent (INSERT ... ON CONFLICT DO UPDATE), safe to re-run.
-- Does NOT touch deposit-safety/legal/routes/digital-nomads categories, or the other 5
-- unrelated bike-models draft stubs (Vario/Scoopy/Forza-comparison/custom-bikes/model-guide).
-- Upsert key: articles.slug (stable business key). 3 of the 15 slugs below already exist as
-- empty en-only draft stubs (honda-adv-review, yamaha-nmax-review,
-- yamaha-xsr-155-review-retro-style) and are intentionally reused/updated in place.
BEGIN;

-- articles: 15 rows (status -> 'published', published_at stamped fresh via COALESCE)
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'honda-pcx160-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'honda_pcx'), 'published', now(), 1
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'honda-adv-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'honda_adv'), 'published', now(), 2
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'yamaha-nmax-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'yamaha_nmax'), 'published', now(), 3
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'yamaha-xmax250-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'yamaha_xmax'), 'published', now(), 4
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'yamaha-mt25-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'yamaha_mt25'), 'published', now(), 5
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'kawasaki-ninja-zx-25r-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'kawasaki_zx25r'), 'published', now(), 6
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'yamaha-xsr-155-review-retro-style', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'yamaha_xsr'), 'published', now(), 7
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'kawasaki-versys-x250-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'kawasaki_versys'), 'published', now(), 8
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'suzuki-v-strom-250-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'suzuki_vstrom250'), 'published', now(), 9
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'tvs-ronin-225-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'tvs_ronin225'), 'published', now(), 10
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'keeway-road-falcon-250-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'keeway_roadfalcon250'), 'published', now(), 11
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'morbidelli-c252v-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'morbidelli_c252v'), 'published', now(), 12
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'honda-cbr250rr-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'honda_cbr250rr'), 'published', now(), 13
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'honda-cb150x-review', ac.id, FALSE, (SELECT id FROM product_families WHERE code = 'honda_cb150x'), 'published', now(), 14
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status, published_at, display_order)
  SELECT 'pcx160-vs-adv160-vs-nmax-how-to-choose', ac.id, FALSE, NULL, 'published', now(), 15
  FROM article_categories ac WHERE ac.slug = 'bike-models'
  ON CONFLICT (slug) DO UPDATE SET
    related_product_family_id = EXCLUDED.related_product_family_id,
    status = 'published',
    display_order = EXCLUDED.display_order,
    published_at = COALESCE(articles.published_at, now());

-- article_translations: 15 articles x 11 languages
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Honda PCX160 — Comfort and Storage for Everyday Riding', 'honda-pcx160-review', 'Honda PCX160 is the most versatile choice for anyone who wants a comfortable scooter without compromising on storage. It''s the model most often chosen by couples and travelers with a suitcase.', 'Honda PCX160 is the most versatile choice for anyone who wants a comfortable scooter without compromising on storage space. It''s the model most often chosen by couples and travelers with a suitcase or a big bag. [View the Honda PCX160 in our catalog](/en/bikes?category=honda_pcx160).

**Specs:**
- Engine: 156.9cc, liquid-cooled, eSP+
- Power: about 15.8 hp at 8,500 rpm
- Transmission: CVT automatic, no gear shifting
- Seat height: ~764mm — comfortable for almost any height
- Tank: 8.1 L
- Under-seat storage: ~30 L — fits a full-face helmet with room to spare
- Smart key, LED lighting, powerful USB charging, digital instrument panel
- We offer a wide range of custom colors beyond the standard lineup

**Add-ons:** the PCX160 can be fitted with a 44 L SHAD rear top box — handy if the under-seat storage isn''t enough. Read more about add-on gear in our article ["Rental Extras Worth Adding: Helmets and the Comfort Box"](/en/blog/rental-extras-worth-adding-helmets-and-the-comfort-box).

**What owners say:** real-world fuel economy in reviews runs about 40-50 km/l, which makes getting around the island practically free. The model''s reputation for reliability is almost legendary — on forums, the PCX gets compared to a lawnmower: it starts and runs for years without surprises. One practical detail for renters: the smart key is convenient, but replacing a lost one runs around 1,000,000 IDR, so it''s worth holding onto — read more about how it works in our article ["How to Start and Use Your Rental Scooter''s Smart Key"](/en/blog/how-to-start-and-use-your-rental-scooters-smart-key). With a passenger on board, the acceleration reserve for overtaking drops noticeably — not an issue in town, but worth keeping in mind on the highway.

**Where it shines on Bali:** holds the asphalt confidently thanks to the 14-inch front wheel — comfortable in Canggu, Seminyak, Sanur, and for everyday rides around Denpasar.', 'Honda PCX160 — Comfort and Storage for Everyday Riding', 'Specs, fuel economy, owner reviews and add-ons for the Honda PCX160 rental in Bali — where it excels and who should book it.'
  FROM articles a WHERE a.slug = 'honda-pcx160-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Honda ADV160 — For Rough Roads and Longer Rides', 'honda-adv-review', 'Honda ADV160 shares its reliable engine with the PCX160, but wears a different body: taller stance, more ground clearance, and a more confident feel on broken asphalt and dirt roads.', 'Honda ADV160 has the same reliable engine as the PCX160, but in a different body: taller stance, more ground clearance, and a more confident feel on cracked asphalt and dirt sections. [View the Honda ADV160 in our catalog](/en/bikes?category=honda_adv160).

**Specs:**
- Engine: 156.9cc, liquid-cooled, eSP+ (same as the PCX160)
- Power: about 15.8 hp
- Transmission: CVT automatic
- Seat height: ~795mm — taller than the city scooters, better suited to taller riders and anyone who prefers a higher seating position
- Ground clearance: ~165mm — noticeably more than standard
- Under-seat storage: ~30 L — fits a full-face helmet with room to spare
- Adjustable windscreen — 2 positions: raised (aggressive) and lowered (city)
- Semi-digital instrument panel, powerful USB charging, smart key
- We offer a wide range of custom colors beyond the standard lineup

**Add-ons:** just like the PCX160, it can be fitted with a 44 L SHAD rear top box. More details in our article ["Rental Extras Worth Adding: Helmets and the Comfort Box"](/en/blog/rental-extras-worth-adding-helmets-and-the-comfort-box).

**What owners say:** fuel efficiency is another strong point of this engine: reviews put real-world consumption at around 34-38 km/l — you rarely need to stop for fuel even with spirited riding. And despite sharing its engine with the PCX160, the ADV160 is actually one of the more dynamic bikes in the PCX-Nmax-ADV lineup — just a different tune. The extra ground clearance genuinely helps on dirt and broken surfaces, but owners are honest about the limits: this is city-adventure styling, not a real enduro — on big rocks and serious rough terrain, the clearance still isn''t enough.

**Where it shines on Bali:** Ubud and the surrounding area (rice terraces, side roads), Munduk and its waterfalls, the hilly stretches around Uluwatu and Bukit — the terrain and road quality vary there, and the ADV160 forgives more than a city scooter would, but true off-road riding still isn''t its strong suit.', 'Honda ADV160 — For Rough Roads and Longer Rides', 'Specs, fuel economy and owner reviews for the Honda ADV160 rental in Bali — where its city-adventure styling really shows its strengths.'
  FROM articles a WHERE a.slug = 'honda-adv-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Yamaha Nmax — New (Gen 2), Neo (Gen 3) and Turbo', 'yamaha-nmax-review', 'The Nmax in our fleet isn''t one single model — it''s several generations and trims under one name: New, Neo, and Turbo. Here''s what actually sets them apart.', '"Nmax" in our fleet isn''t one single model — it covers several generations and trims under one name. New and Neo share the same engine and transmission, just different generations of the lineup (Gen 2 and Gen 3). Turbo is a different story, with different electronic transmission tuning. [View the Yamaha Nmax in our catalog](/en/bikes?category=yamaha_nmax155).

**Nmax New (Gen 2):**
- Engine: 155cc, Blue Core, VVA, SOHC 4-valve
- Power: ~15 hp at 8,000 rpm
- Transmission: classic roller-type CVT
- Weight: ~132 kg
- Tank: 7.1 L

**Nmax Neo (Gen 3):**
- Same 155cc Blue Core VVA engine as the New, in displacement and design — the difference is visual, a generation and trim change, not what''s under the hood
- Power: ~15 hp at 8,000 rpm
- Transmission: classic CVT
- Weight: ~130 kg
- Two versions: Neo (base) and Neo S (adds the Smart Key system)

**Nmax "Turbo":**
- Same-displacement engine as the New/Neo
- Main difference — YECVT (Yamaha Electric CVT): essentially the same CVT layout, but electronically controlled instead of purely mechanical rollers. It''s more about the ride feel and electronic settings than a fundamentally different transmission
- Two riding modes, T-Mode/S-Mode, plus virtual "gears" via Y-Shift (Low/Medium/High) — simulating gear changes like a car
- Weight: ~133-135 kg depending on the version
- Three versions: Turbo (base), Turbo Tech Max (TFT display, USB-C port, special seat), Turbo Tech Max Ultimate (top trim)
- Important note: "Turbo" in the name refers to the electronics and responsiveness, not a literal turbocharger on the engine
- We offer a wide range of custom colors beyond the standard lineup

**What owners say:** the engine (in any generation) gets called "unkillable" in reviews — reliability is one of the lineup''s strong points across the board. Fuel economy is another strength — the same efficient 155cc engine shared with the rest of the family (PCX160, ADV160) keeps consumption comfortably low on real trips, so you rarely need to refuel. One interesting quirk about storage: the claimed capacity numbers look generous, but the shape of the compartment means a full-face helmet doesn''t always fit. On the plus side, there''s a separate compartment under the left leg shield for a phone and wallet. In Bali rental reviews, riders particularly praise the pulling power on climbs ("tanjakan") and the soft suspension for longer trips — for example, out to Uluwatu. Several tourist guides call out the ABS and wide tubeless tires as a real plus specifically because of frequent tropical downpours and sudden obstacles on the road, like dogs — the brakes don''t lock up the wheel in a panic stop.

**Where it shines on Bali:** confident both in city traffic (Canggu, Seminyak) and on medium-length highway trips, including rides out to Uluwatu — good stability through corners and in the rain. This applies equally across all versions — the geometry and riding position barely differ between them.', 'Yamaha Nmax — New (Gen 2), Neo (Gen 3) and Turbo', 'Yamaha Nmax rental in Bali: what really separates the New, Neo and Turbo trims, plus full specs and real owner reviews.'
  FROM articles a WHERE a.slug = 'yamaha-nmax-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Yamaha XMAX250 — Connected and Tech Max: Same Mechanics, Different Trim Level', 'yamaha-xmax250-review', 'Yamaha XMAX250 is the most powerful scooter in our lineup, equally at home on long rides and around town. Our fleet has both Connected and Tech Max versions with identical mechanics.', 'Yamaha XMAX250 is the most powerful scooter in the lineup. Plenty of riders love this big machine, and while everyone agrees it''s great for long distances, for many there''s nothing better for short trips around town either. In our fleet, the model comes in two versions — Connected and Tech Max — and here''s the key thing to understand: mechanically it''s the same bike, the difference is purely in the trim. [View the Yamaha XMAX250 in our catalog](/en/bikes?category=yamaha_xmax250).

**Specs (identical for Connected and Tech Max — the engine and chassis are the same):**
- Engine: 250cc, single-cylinder, liquid-cooled, SOHC 4-valve, Blue Core, one-piece forged crankshaft
- Power: 16.8 kW at 7,000 rpm
- Torque: 24.3 Nm at 5,500 rpm
- Transmission: CVT automatic
- Seat height: 795mm
- Weight: ~181 kg
- Tank: 13 L
- Under-seat storage: 44.9 L — a lot of space, genuinely fits two full-face helmets plus your gear. One thing to know: you sometimes need to turn a full-face helmet a certain way to fit it in properly
- ABS, traction control (TCS), Emergency Stop Signal (hazard lights flash automatically under hard braking), smart key with Answer Back System (a signal to help find the bike in a parking lot), phone charging socket
- The windscreen on the Connected is fixed, non-adjustable. Adjustability is a Tech Max exclusive (see below)
- Yamaha Indonesia warranty — 5 years / 50,000 km on the frame, fuel system components, cylinder and piston

**The Y-Connect app — worth explaining separately to renters:**

The XMAX Connected supports connecting to an app:

📱 Download it here:
https://apps.apple.com/app/id1495921872
https://apps.apple.com/app/id1585591110

What the connection gives you:
• Answering incoming calls from the handlebar
• Skipping music tracks from the handlebar
• Navigation
• Handy smartphone integration

**Connected vs Tech Max — what''s different:**

The biggest and most expensive difference is the seat. On the Tech Max it isn''t just "different stitching" — it''s a separately engineered seat made by MBK (a French brand owned by Yamaha that specializes in European scooters), the so-called "Comfort Seat." Inside is high-density foam with side bolsters designed specifically for multi-hour rides: the seat holds your position and reduces lower-back fatigue on long stretches, not just softer padding. On top is eco-leather with suede inserts and gold stitching, plus a chrome accent. Owners in reviews consistently name the seat, not the color or badging, as the main reason to pay extra for the Tech Max.

The rest of the differences are real too, but rank below the seat in price and impact:
- Exclusive color (Magma Black on earlier models, Ceramic Grey from 2025)
- Under-seat storage lid in eco-leather with suede and gold stitching (matching the seat)
- Aluminum footpegs, chrome trim, special Tech Max badging and grip texture
- The 2025 Tech Max introduced the only functional (not just cosmetic) difference — an Electric Adjustable Screen you can operate even while riding to quickly dial in your preference, plus an updated TFT instrument panel; the Connected''s windscreen, as noted above, has no adjustment at all

The price difference on the Indonesian market is around 5,000,000 IDR for the Tech Max version, and most of that goes straight into the seat.

**What owners say:** the engine pulls comfortably up to 100-110 km/h, and starts to run out of breath beyond that — this isn''t a bike built for outright acceleration, it''s built for a steady cruising pace. Indonesia''s XMAX owners'' club ran the new model''s first group tour right here on Bali back in 2017 — the route was Denpasar → Ubud → Kintamani → Besakih → Klungkung → Gianyar → the Ida Bagus Mantra toll road and back; riders tested the traction control on the winding stretches around Ubud and Kintamani, and hit 140 km/h on the straight section of the Ida Bagus Mantra toll road.

Named routes for the XMAX250 on Bali that riders themselves recommend: the south coast — Canggu → Uluwatu (via Jalan Bali Cliff) → Pandawa Beach → GWK; the mountain route — Denpasar → Ubud → Kintamani → Lake Batur → Munduk; the east — Sanur → Candidasa → Sidemen → Virgin Beach. Detailed routes and map points are in our blog articles "Bukit Peninsula by Bike," "Kintamani: Sunrise at Mount Batur," and "East Bali by Bike" (which also covers Virgin Beach) — coming soon.

**Who it''s for:** day trips or multi-day rides around the island, where you want power in reserve for overtaking and climbs, plus comfort on long highway stretches. It''s also a strong pick for everyday riding — one of the most popular bikes with both tourists and long-term Bali residents.

**Where it shines on Bali:** routes beyond the south of the island — Kintamani and Mount Batur, Amed, Lovina, Sidemen, the east coast. That said, it''s a matter of taste — plenty of riders enjoy cruising this big tour-adventure machine even through Canggu traffic, and there''s no shortage of them.', 'Yamaha XMAX250 — Connected and Tech Max: Same Mechanics, Different Trim Level', 'Yamaha XMAX250 rental in Bali: Connected vs Tech Max differences, full specs, the Y-Connect app, and the best island routes.'
  FROM articles a WHERE a.slug = 'yamaha-xmax250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Yamaha MT-25 — Gen 2 and Gen 3: Different Looks, Same Engine', 'yamaha-mt25-review', 'Yamaha MT-25 is a compact streetfighter for riders who want to feel real acceleration and throttle response. Our fleet has both Gen 2 and Gen 3 bikes after the 2025 redesign.', 'Yamaha MT-25 is a compact streetfighter for riders who want to feel real acceleration and throttle response, not just get from A to B. This bike genuinely has character — plenty of professionals and enthusiasts rank it among their favorite bikes in the category, whether for the dynamics, the riding position, or the looks. A manual gearbox and an aggressive riding position are what fundamentally set this model apart from the scooters in our fleet. In 2025, Yamaha Indonesia launched a significant redesign ("Gen 3"), so you may find both the old and new styling sitting side by side in the fleet under the same model name. [View the Yamaha MT-25 in our catalog](/en/bikes?group=motorcycle&model=yamaha_mt25).

**Specs (shared — the engine itself hasn''t changed between generations):**
- Engine: 249.55cc, liquid-cooled, DOHC, parallel-twin, 8-valve
- Power: about 35.5 hp at 12,000 rpm
- Torque: ~22.6 Nm at 10,000 rpm
- Transmission: 6-speed manual
- Seat height: ~780mm
- Tank: ~14 L

**Gen 2 (~2019 update — the most recognizable "classic" MT-25 look):**
- Single front brake disc
- No assist-and-slipper clutch, no ABS
- Weight: ~165-167 kg

**Gen 3 (2025 redesign, positioned by Yamaha as a "Hypernaked" — per Yamaha Indonesia''s official site):**
- A new, more aggressive headlight in the spirit of the MT-07/R-series — angular, "alien-like" styling, unlike the rounder Gen 1 headlight (Gen 2 had already moved away from round, but Gen 3 has its own, even sharper geometry)
- ABS — appearing on the MT-25 for the first time with Gen 3
- Assist-and-slipper clutch — smoother operation on aggressive downshifts
- Y-Connect (Bluetooth app) via a CCU module — the first such technology on an Indonesian-built motorcycle
- Big Bike Switch 3-in-1 — a combined, compact switchgear unit in the style of Yamaha''s larger bikes
- A fully digital instrument panel with a shift timing light
- A charging socket for gadgets
- Weight: ~169 kg — slightly more than the Gen 2, due to the added equipment

**Where it shines on Bali:** Canggu and Seminyak — quick, punchy acceleration in city traffic and evening rides along the beach road, where the bike''s character really comes through.', 'Yamaha MT-25 — Gen 2 and Gen 3: Different Looks, Same Engine', 'Yamaha MT-25 rental in Bali: Gen 2 vs Gen 3 differences, engine specs, and where this streetfighter''s character really shows.'
  FROM articles a WHERE a.slug = 'yamaha-mt25-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Kawasaki Ninja ZX-25R — The Only Production 250cc Sportbike With an Inline-Four', 'kawasaki-ninja-zx-25r-review', 'Kawasaki Ninja ZX-25R is the only production 250cc sportbike with an inline four-cylinder engine — a high-revving character and a factory quick shifter.', 'The Ninja ZX-25R holds a unique spot in the 250cc class: it''s the only production sportbike of this displacement with an inline four-cylinder engine (every competitor runs a single or twin). That''s the source of its distinctive high-revving sound and its appetite for being kept spinning. [View the Kawasaki Ninja ZX-25R in our catalog](/en/bikes?group=motorcycle&model=kawasaki_zx25r).

**Specs:**
- Engine: 249cc, liquid-cooled, DOHC, inline-four — a rare configuration in this class
- Power: about 45 hp (Indonesian, non-Ram Air version) at 15,500 rpm, redline up to 17,000 rpm
- Transmission: 6-speed manual
- Seat height: ~785mm
- Weight: ~183 kg
- Tank: ~15 L
- Full fairing, sportbike riding position
- Factory Quick Shifter — clutchless gear changes, with automatic throttle blip on downshifts

**What owners say:** the sheer novelty of a four-cylinder engine in the 250cc class is such a big deal that Kawasaki once released a dedicated video of this engine''s sound on a dyno — commenters described the note as "angry" and "unhinged" for such a small displacement. Some experienced riders note that the factory quick shifter (with automatic downshift blipping) works brilliantly and turns ordinary Bali-speed riding into genuinely fun riding — you don''t need track speeds to enjoy the shifts. On the downside: riders over 180cm report their legs start to tire from the riding position by the end of the day, and the suspension is tuned for the street, not the track. Peak power only arrives at 15,500 rpm, so anyone used to riding at low revs will find the bike feels flat until you rev it out.

**Who it''s for:** confident riders who want maximum thrills out of the 250cc class and don''t mind keeping the revs up — this isn''t a bike for relaxed, low-rev cruising.

**Where it shines on Bali:** it''s aimed more at the experience and character than any specific route — great in the same places as the MT-25 (town, the beach road), and on the world-class Mandalika circuit on neighboring Lombok. Not every rental company allows that kind of trip, but with us it''s possible. This is the most demanding bike in the fleet — not for a first-ever motorcycle experience, and not ideal for tall riders on an all-day ride.', 'Kawasaki Ninja ZX-25R — The Only Production 250cc Sportbike With an Inline-Four', 'Kawasaki Ninja ZX-25R rental in Bali: a rare inline-four 250cc engine, factory quick shifter, and who this sportbike is really for.'
  FROM articles a WHERE a.slug = 'kawasaki-ninja-zx-25r-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Yamaha XSR155 — a Café Racer With Retro Character', 'yamaha-xsr-155-review-retro-style', 'Yamaha XSR155 is a neo-retro bike with a round headlight, low handlebar, and café-racer riding position, built on the family 155cc engine tuned for extra power with a manual gearbox.', 'Yamaha XSR155 is a neo-retro bike: round headlight, low handlebar, café-racer riding position. It shares the same family 155cc engine as the scooters in the lineup, but tuned for more power in the manual version. [View the Yamaha XSR155 in our catalog](/en/bikes?group=motorcycle&model=yamaha_xsr).

**Specs:**
- Engine: 155cc, liquid-cooled, SOHC, VVA — the same base as the Nmax155, tuned differently for the manual gearbox
- Power: about 19.3 hp at 10,000 rpm
- Transmission: 6-speed manual
- Seat height: ~815mm — a low café-racer riding position
- Weight: ~131-134 kg
- Tank: ~10 L

**What owners say:** the XSR155 borrows its chassis from the R15 sportbike, which makes it light and very responsive to ride. With a gentle throttle hand, real-world fuel economy reaches up to ~50 km/l. One thing worth knowing if you''re planning to ride two-up: the rear seat is small and firm, and many versions don''t have a proper passenger grab handle. One real Bali renter left a telling review of this exact model: despite its modest 155cc displacement, the bike "rides tough" on Bali''s roads, is well-tuned for its price point, and holds the local asphalt confidently enough that, in his words, it would give even a Yamaha R3 a run for its money through the same corners — the rental company took the bike on a three-hour ride out to Amed, and it didn''t let him down.

**Who it''s for:** riders who want the style and character of a motorcycle without excessive power — a comfortable step up from a scooter to a manual-geared bike.

**Where it shines on Bali:** Canggu and Seminyak — the bike''s retro looks fit the neighborhood''s vibe perfectly; but going by reviews, it handles longer, more winding routes like the ride to Amed just as well.', 'Yamaha XSR155 — a Café Racer With Retro Character', 'Yamaha XSR155 rental in Bali: full specs, owner reviews, and who this neo-retro bike with a manual gearbox is really for.'
  FROM articles a WHERE a.slug = 'yamaha-xsr-155-review-retro-style'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Kawasaki Versys-X 250 — Touring With Range to Spare for Dirt Roads', 'kawasaki-versys-x250-review', 'Kawasaki Versys-X 250 is an enduro-tourer with a tall stance, long-travel suspension, and a bigger tank, built for riders who want to explore the island''s side roads.', 'Kawasaki Versys-X 250 is an enduro-tourer: tall stance, long-travel suspension, a bigger tank. It''s built for riders planning to do more than stick to the asphalt — for exploring the island''s side roads. [View the Kawasaki Versys-X 250 in our catalog](/en/bikes?group=motorcycle&model=kawasaki_versys).

**Specs:**
- Engine: 249cc, liquid-cooled, DOHC, parallel-twin
- Power: about 27 hp at 9,700 rpm
- Transmission: 6-speed manual
- Seat height: ~845mm — noticeably taller than the rest of the fleet
- Weight: ~184 kg
- Tank: ~17 L — one of the largest in the fleet, for extended range
- Windscreen, enduro-style footpegs, riding position suited to standing and sitting on longer rides

**What owners say:** real-world fuel economy at a relaxed pace up to 105 km/h runs about 27-30 km/l (independently confirmed by Bali rental operators too — around 3-4 L/100km), which with a 17-liter tank gives a very solid range between fill-ups. Off-road capability isn''t just marketing: in one early test ride the bike confidently powered through thick mud without the suspension bottoming out once. The stock seat is firm out of the box and needs some breaking in. The bike feels most comfortable in the 80-110 km/h range. Real Bali renters report it handled the ride out to a remote mountain village without issue, and that the manual-gearbox version performed great on a rainy trip to the north of the island. Ready-made routes recommended by the rental operators themselves: south Bali — Ubud — Kintamani; the mountain roads of the north; the east coast out to Amed and Tulamben.

**Who it''s for:** multi-day island touring, and anyone who wants confidence on dirt or broken roads. Detailed routes are in our blog articles: "East Bali by Bike," "Kintamani: Sunrise at Mount Batur," "Bedugul — Munduk — Lovina."

**Where it shines on Bali:** longer routes — Kintamani, the north and east of the island (including Amed and Tulamben), side roads off the main tourist routes.', 'Kawasaki Versys-X 250 — Touring With Range to Spare for Dirt Roads', 'Kawasaki Versys-X 250 rental in Bali: full specs, range, owner reviews, and the best routes for enduro-style touring.'
  FROM articles a WHERE a.slug = 'kawasaki-versys-x250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Suzuki V-Strom 250 — Touring Built Around Comfort and Wind Protection', 'suzuki-v-strom-250-review', 'Suzuki V-Strom 250 is an adventure-tourer built for long-distance comfort: a wide windscreen, upright riding position, and soft, fatigue-free suspension.', 'Suzuki V-Strom 250 is an adventure-tourer focused on comfort over long distances: a wide windscreen, an upright riding position, and a soft suspension for long stretches without fatigue. [View the Suzuki V-Strom 250 in our catalog](/en/bikes?group=motorcycle&model=suzuki_vstrom250).

**Specs:**
- Engine: 248cc, liquid-cooled, DOHC, parallel-twin
- Power: about 25 hp at 8,000 rpm
- Transmission: 6-speed manual
- Seat height: ~800-835mm depending on the version
- Tank: 12 L

**What owners say:** in reviews, the engine gets compared to a sewing machine — smooth, quiet, economical, and reliable. Across the board, people praise the well-padded seat and the "big bike" riding position, paired with handling that''s far lighter than a big bike''s. Real-world fuel economy runs from 32 to 48 km/l. One of the best examples of it in use on Bali: a renter took a V-Strom for 40+ days and rode it all the way to Flores island and back. A practical lesson from another Bali renter: the stock rear rack turned out unreliable for strapping down bags on the road — the rental company switched them to a Versys with proper side panniers instead; the takeaway is that if you''re carrying luggage, panniers are far more secure than bungee cords on a rack. Renters specifically recommend heading toward Sidemen, Mount Batur, and the roads around Bali''s easternmost point, noting that traffic is really only an issue in Uluwatu, Canggu, and Ubud — beyond that, it''s rice terraces, jungle, and ocean views.

**Who it''s for:** riders looking first and foremost for comfort on long rides rather than a sporty character. Detailed routes are in our blog articles: "East Bali by Bike," "Sekumpul and the Waterfalls of Central North Bali," "Bali''s Volcanoes by Bike."

**Where it shines on Bali:** the same niche as the Versys-X250 — long-distance routes, Sidemen, Mount Batur, the east coast. If you''re planning to bring a lot of luggage, just let us know and we''ll add side panniers to your bike.', 'Suzuki V-Strom 250 — Touring Built Around Comfort and Wind Protection', 'Suzuki V-Strom 250 rental in Bali: full specs, real-world fuel economy, and renter reviews from long-distance rides around the island.'
  FROM articles a WHERE a.slug = 'suzuki-v-strom-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'TVS Ronin 225 — Neo-Retro on the Edge of a Scrambler', 'tvs-ronin-225-review', 'TVS Ronin 225 is a modern classic with scrambler touches: a round LED headlight, a tall handlebar position, and confidence both in the city and on dirt turnoffs.', 'TVS Ronin 225 is a modern classic with scrambler touches: a round LED headlight, a tall handlebar position, and versatile geometry that feels equally confident in the city and on dirt turnoffs from the main road. All versions come with ABS. [View the TVS Ronin 225 in our catalog](/en/bikes?group=motorcycle&model=tvs_ronin225).

**Specs:**
- Engine: 225.9cc, oil-cooled, single-cylinder, SOHC, 4-valve
- Power: about 20.4 hp at 7,750 rpm
- Torque: ~19.9 Nm at 3,750 rpm — pulls from low in the rev range, no need to rev it out
- Transmission: 5-speed manual
- Seat height: ~795mm
- Weight: ~159 kg
- Tank: ~14 L
- ABS on all versions (single-channel on the base version, dual-channel on higher trims)

**Reliability:** TVS is a brand with a very long history in India (building two-wheelers since the 1980s), and the Ronin itself, though a relatively young model (launched in 2022), has already built up a strong reliability reputation over its years on the road: owner reviews with 10,000+ km on the odometer describe the engine as still running with reference-level smoothness, the gold USD forks showing high wear resistance, and the build staying free of play and rattling even after a year of active riding on varied surfaces. In independent owner ratings, the Ronin''s reliability and cost-of-ownership scores are consistently among the best in its class.

**What owners say:** the engine starts with a chesty, slightly raspy note typical of retro bikes. Strong low-end torque makes the bike especially comfortable in dense city traffic. Real-world fuel economy in reviews runs 35-45 km/l. The suspension is softly tuned and absorbs city bumps well. Some versions offer riding modes, including one tuned for rain — useful given Bali''s climate. Reviewers regularly point to strong dynamics and looks as one of the model''s biggest strengths.

**Who it''s for:** riders who want a versatile everyday motorcycle — without the strain of a sportbike, but with confidence to spare on dirt turnoffs.

**Where it shines on Bali:** just as at home in Canggu/Seminyak thanks to its neo-retro looks as it is on the dirt side roads out to the rice terraces.', 'TVS Ronin 225 — Neo-Retro on the Edge of a Scrambler', 'TVS Ronin 225 rental in Bali: full specs, reliability, and owner reviews of this neo-retro bike with scrambler character.'
  FROM articles a WHERE a.slug = 'tvs-ronin-225-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Keeway Road Falcon 250 — a Classic Cruiser at an Entry-Level Price', 'keeway-road-falcon-250-review', 'Keeway Road Falcon 250 is a classic cruiser with a long silhouette and a low seat, at an entry-level price. It''s brand new to the market, launched in 2026.', 'Keeway Road Falcon 250 has a long silhouette, a low seat, understated black styling, and a character borrowed from big American cruisers, all built on a compact 250cc base. The model is brand new to the market — launched in 2026 — so there''s practically no user or Bali rental reviews yet. [View the Keeway Road Falcon 250 in our catalog](/en/bikes?group=motorcycle&model=keeway_roadfalcon250).

**Specs:**
- Engine: 248cc, parallel-twin, 4-stroke, 4-valve, SOHC, liquid-cooled
- Power: about 24.6 hp at 8,000 rpm
- Torque: ~23.4 Nm at 6,500 rpm
- Transmission: 6-speed manual with slipper clutch
- Seat height: ~698mm — one of the lowest in the fleet
- Ground clearance: ~186mm
- Tank: 14 L
- Brakes: 300mm front disc (2-piston caliper), 260mm rear
- 5-inch TFT display, built-in Bluetooth speaker — a rare option for this class
- Navigation displays directly on the instrument panel — like the XMAX250, this model doesn''t need a phone mount at all

**What owners say:** the model draws direct comparisons to Harley-Davidson-style bikes and to the Honda Rebel — the distinctive "tank hump" up front and the overall silhouette are a deliberate nod to big American cruisers, and the Indonesian press has run direct comparison reviews of the Road Falcon against the Honda Rebel. The built-in Bluetooth speaker on the handlebar is a rarity for a cruiser in this class. The slipper clutch smooths out downshifts — useful on Bali''s hilly stretches. Reviewers also note it''s a surprisingly maneuverable bike with a tight turning radius — not what you''d expect from a long cruiser silhouette, but noticeable in practice.

**Who it''s for:** riders who want the classic cruiser look and a relaxed riding position — especially comfortable for shorter riders thanks to the very low seat.

**Where it shines on Bali:** relaxed coastal routes — Sanur, Nusa Dua — but not only that: our customers have also taken it to spots usually reserved for classic touring-enduros like the Versys and V-Strom, so it handles longer routes along Bali''s north coast too, despite the cruiser looks.', 'Keeway Road Falcon 250 — a Classic Cruiser at an Entry-Level Price', 'Keeway Road Falcon 250 rental in Bali: full specs, a comparison with the Honda Rebel, and who this cruiser is really for.'
  FROM articles a WHERE a.slug = 'keeway-road-falcon-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Morbidelli C252V — a V-Twin Cruiser With an Italian Name', 'morbidelli-c252v-review', 'Morbidelli C252V is the second cruiser in our fleet, but with a genuine V-twin engine instead of a parallel-twin, and belt drive instead of a chain.', 'The second cruiser in our fleet, but a fundamentally different character from the Road Falcon: the Morbidelli runs a genuine V-twin engine instead of a parallel-twin, giving it a different, deeper "bassy" sound and vibration that plenty of cruiser riders count as part of the appeal. The Morbidelli name is Italian, with a real racing pedigree (championship titles in the 125cc and 250cc Grand Prix classes back in the 1970s) — the rights to it have belonged since 2024 to the same group that owns Keeway, so this isn''t a name coincidence, it''s an officially revived brand on a new technical base. [View the Morbidelli C252V in our catalog](/en/bikes?group=motorcycle&model=morbidelli_c252v).

**Specs:**
- Engine: 249cc, V-twin, 4-stroke, 8-valve, SOHC, liquid-cooled
- Power: about 25.5 hp at 9,000 rpm
- Torque: 25 Nm at 5,500 rpm
- Transmission: 6-speed manual with slipper clutch
- Drive: belt drive — a rarity for the class. In practice, that means no chain lubing or tensioning, and no rust from the rain
- Seat height: 690mm — one of the lowest in the fleet
- Weight: ~200 kg
- Tank: 15.5 L
- Ground clearance: 173mm
- Brakes: 320mm front disc (4-piston caliper), 260mm rear (2-piston); dual-channel Bosch ABS and traction control as standard
- Front: inverted (USD) fork, 37mm, 115mm travel; rear: twin shocks with 5-step preload adjustment
- Claimed top speed — 125 km/h

**What owners say:** the model is very new to the market, so there isn''t years of ownership history yet, but early press test rides highlight surprisingly light handling for a cruiser with such a long wheelbase — the turning radius doesn''t give away the bike''s size. The V-twin engine is described as visually striking (visible beneath the tank, with faux cooling fins and chrome trim) and noticeably deeper-sounding than a typical 250cc parallel-twin.

**Who it''s for:** riders who specifically want V-twin cruiser character (not a parallel-twin like the Road Falcon) — more pronounced vibration and a bassier engine note, plus a belt instead of a chain — no lubing or tensioning, no rust in the rain.

**Where it shines on Bali:** the same niche as the Road Falcon — relaxed coastal routes, Sanur, Nusa Dua; the belt drive and low seat make it especially comfortable for anyone who wants a relaxed cruiser style without worrying about a chain.', 'Morbidelli C252V — a V-Twin Cruiser With an Italian Name', 'Morbidelli C252V rental in Bali: V-twin engine, belt drive, full specs, and how this cruiser differs from the Road Falcon.'
  FROM articles a WHERE a.slug = 'morbidelli-c252v-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Honda CBR250RR — Full Fairing and the Most Track-Focused Sportbike in the Fleet', 'honda-cbr250rr-review', 'Honda CBR250RR is the only fully-faired sportbike in our fleet, in the top-spec version with a quick shifter and ABS — one of the technological leaders of Indonesia''s 250cc class.', 'The only fully-faired sportbike in the fleet (unlike the "naked" MT-25 and ZX-25R streetfighters) — the Honda CBR250RR has been considered one of the technological leaders of the 250cc class in Indonesia ever since its 2016 debut. [View the Honda CBR250RR in our catalog](/en/bikes?group=motorcycle&model=honda_cbr250rr).

**Specs (the top-spec SP Quick Shifter with ABS — the version in our fleet):**
- Engine: 249.7cc, liquid-cooled, DOHC, parallel-twin, 8-valve, with top-spec upgrades (lightened crankshaft, new valve springs, revised head)
- Power: ~41 hp at 13,000 rpm
- Torque: ~25 Nm at 11,000 rpm
- Transmission: 6-speed manual
- Seat height: ~790mm
- Weight: ~168 kg
- ABS, full LED lighting, digital instrument panel, throttle-by-wire (electronic throttle, no cable)
- Quick shifter with 4 configurable modes (up+down, up only, down only, off) — clutchless gear changes
- Assist-and-slipper clutch
- Inverted (USD) front fork, SFF-Big Piston type
- 3 riding modes: Comfort, Sport, Sport+
- Claimed 0-200m in 8.65 seconds, top speed up to 172 km/h

**What owners say:** the CBR250RR is consistently mentioned as one of the most tech-loaded bikes in Indonesia''s 250cc class — the quick-shifter version delivers genuinely track-like feel, rare for this engine size.

**Who it''s for:** riders who want the full sportbike experience — fairing, an aggressive "on the tank" riding position, and MotoGP-style quick-shifter technology.

**Where it shines on Bali:** like the ZX-25R — the city, the beach road, for the experience and the character rather than any one route; and given its track pedigree, it really comes alive on the Mandalika circuit on Lombok.', 'Honda CBR250RR — Full Fairing and the Most Track-Focused Sportbike in the Fleet', 'Honda CBR250RR rental in Bali: the top-spec quick-shifter version, full specs, and who the complete sportbike experience suits.'
  FROM articles a WHERE a.slug = 'honda-cbr250rr-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'Honda CB150X — Affordable Adventure Looks on a 150cc Base', 'honda-cb150x-review', 'Honda CB150X is an affordable way into adventure styling on a 150cc engine, with running gear that punches above its class and the lightest weight of any motorcycle in our fleet.', 'The CB150X isn''t the same thing as the 250cc Versys-X250 and V-Strom250: it''s a budget entry into adventure styling on a modest 150cc single-cylinder engine, but with genuinely serious running gear for its class (ground clearance almost matching the CB500X). Thanks to a very light weight for a motorcycle (139 kg), the 150cc engine is more than enough — the bike lifts the front wheel easily and holds confident dynamics across the whole speed range, not just at low speeds like you might expect from a single-cylinder engine and modest displacement. [View the Honda CB150X in our catalog](/en/bikes?group=motorcycle&model=honda_cb150x).

**Specs:**
- Engine: 149.16cc, single-cylinder, liquid-cooled, DOHC 4-valve
- Power: ~15.6 hp at 9,000 rpm
- Torque: ~13.8 Nm at 7,000 rpm
- Transmission: 6-speed manual
- Seat height: 817mm
- Ground clearance: 181mm — almost matching the much bigger CB500X
- Weight: ~139 kg — the lightest motorcycle (not scooter) in the fleet
- Tank: 12 L
- Front: inverted (USD) Showa SFF-BP fork, 37mm; rear: Pro-Link monoshock
- Wavy brake discs front and rear
- Fully digital instrument panel with real-time fuel consumption

**Who it''s for:** riders who want adventure styling and a tall riding position, but aren''t ready for the weight and power of a full 250cc tourer — a good step up from city bikes toward more serious models.

**Where it shines on Bali:** the same logic as the ADV160 — side roads, imperfect asphalt, but by riding position and character this is already a full manual motorcycle, not a scooter.', 'Honda CB150X — Affordable Adventure Looks on a 150cc Base', 'Honda CB150X rental in Bali: full specs, ground clearance, and who this budget-friendly adventure bike is really suited for.'
  FROM articles a WHERE a.slug = 'honda-cb150x-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'en', 'PCX160 vs ADV160 vs Nmax — How to Choose Between the Three', 'pcx160-vs-adv160-vs-nmax-how-to-choose', 'PCX160, ADV160 and Nmax — how to choose between the fleet''s three most popular scooters: the real differences in storage, dynamics, and riding position.', 'Honestly, these three models differ mostly in looks and in what the rider is used to — in short, it comes down to taste. Among the genuinely practical differences, storage capacity tops the list: the Nmax suits riders willing to give up some storage space in exchange for its riding position and dynamics. And on pure dynamics, there''s a running joke on our team: if you actually want that "Turbo" responsiveness, grab the ADV instead — it subjectively feels punchier than the model that actually has "Turbo" in its name.

Ideally, before committing to a bike for the long term, ride each one for anywhere from 5 days to a month to really feel the difference. 1-3 days is often not enough to truly get to know a bike.

Model pages: [Honda PCX160](/en/bikes?category=honda_pcx160), [Honda ADV160](/en/bikes?category=honda_adv160), [Yamaha Nmax](/en/bikes?category=yamaha_nmax155).', 'PCX160 vs ADV160 vs Nmax — How to Choose Between the Three', 'A side-by-side comparison of the Honda PCX160, Honda ADV160 and Yamaha Nmax rentals in Bali — which scooter fits your needs best.'
  FROM articles a WHERE a.slug = 'pcx160-vs-adv160-vs-nmax-how-to-choose'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Honda PCX160 — комфорт и вместительность на каждый день', 'obzor-honda-pcx160', 'Honda PCX160 — самый универсальный выбор для тех, кто хочет комфортный скутер без компромиссов по багажнику. Модель, которую чаще всего берут пары и путешественники с чемоданом.', 'Honda PCX160 — самый универсальный выбор для тех, кто хочет комфортный скутер без компромиссов по багажнику. Это модель, которую чаще всего берут пары и те, кто путешествует с чемоданом или большой сумкой. [Смотреть Honda PCX160 в каталоге](/ru/bikes?category=honda_pcx160).

**Характеристики:**
- Двигатель: 156,9 см³, жидкостное охлаждение, eSP+
- Мощность: около 15,8 л.с. при 8500 об/мин
- Коробка: вариатор (CVT), без переключений
- Высота по седлу: ~764 мм — комфортно почти при любом росте
- Бак: 8,1 л
- Багажник под седлом: ~30 л — влезает полнолицевой шлем и ещё остаётся место под другие вещи
- Смарт-ключ, LED-освещение, мощная USB-зарядка, цифровая приборная панель
- У нас вы найдёте широкий выбор кастомных цветов, отличных от стандартных

**Допы:** на PCX160 можно поставить задний топ-бокс SHAD на 44 л — удобно для тех, кому мало подседельного багажника. Подробнее про доп-оснащение — в нашей статье [«Дополнительные опции при аренде: шлемы и удобный бокс»](/ru/blog/dopolnitelnye-optsii-pri-arende-shlemy-i-udobnyy-boks).

**Что говорят владельцы:** реальный расход топлива в отзывах — около 40-50 км/л, что делает поездки по острову практически бесплатными. Репутация у модели почти легендарная по надёжности — на форумах PCX сравнивают с газонокосилкой: заводится и едет годами без сюрпризов. Отдельная практичная деталь для арендаторов: смарт-ключ удобен, но его восстановление при потере обойдётся примерно в 1 млн рупий, так что ключ лучше не терять — подробнее о том, как он работает, в нашей статье [«Как завести байк и пользоваться ключом-брелоком»](/ru/blog/kak-zavesti-bayk-i-polzovatsya-klyuchom-brelokom). С пассажиром на скорости запас разгона для обгона заметно снижается — не проблема в городе, но стоит учитывать на трассе.

**Где на Бали хорошо себя показывает:** уверенно держит асфальт благодаря переднему 14-дюймовому колесу — комфортно в Чангу, Семиньяке, Санура, для повседневных поездок по Денпасару.', 'Honda PCX160 — комфорт и вместительность на каждый день', 'Характеристики, расход топлива, отзывы владельцев и допы для Honda PCX160 в аренде на Бали — куда подходит и кому стоит брать.'
  FROM articles a WHERE a.slug = 'honda-pcx160-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Honda ADV160 — для неровных дорог и дальних вылазок', 'obzor-honda-adv160', 'Honda ADV160 — тот же надёжный двигатель, что у PCX160, но в другом корпусе: выше посадка, больше дорожный просвет, увереннее на разбитом асфальте и грунтовых участках.', 'Honda ADV160 — тот же надёжный двигатель, что у PCX160, но в другом корпусе: выше посадка, больше дорожный просвет, увереннее себя чувствует на разбитом асфальте и грунтовых участках. [Смотреть Honda ADV160 в каталоге](/ru/bikes?category=honda_adv160).

**Характеристики:**
- Двигатель: 156,9 см³, жидкостное охлаждение, eSP+ (тот же, что у PCX160)
- Мощность: около 15,8 л.с.
- Коробка: вариатор (CVT)
- Высота по седлу: ~795 мм — выше, чем у городских скутеров, лучше подходит для более высокого роста и тем, кто любит более высокую посадку
- Дорожный просвет ~165 мм — заметно больше стандартного
- Багажник под седлом: ~30 л — влезает полнолицевой шлем и ещё остаётся место под другие вещи
- Регулируемый визор — 2 положения: поднятое (агрессивное) и опущенное (городское)
- Полудигитальная приборная панель, мощная USB-зарядка, смарт-ключ
- У нас вы найдёте широкий выбор кастомных цветов, отличных от стандартных

**Допы:** так же, как и на PCX160, можно поставить задний топ-бокс SHAD на 44 л. Подробнее — в нашей статье [«Дополнительные опции при аренде: шлемы и удобный бокс»](/ru/blog/dopolnitelnye-optsii-pri-arende-shlemy-i-udobnyy-boks).

**Что говорят владельцы:** экономичность — это второй очень сильный плюс этого двигателя: в отзывах реальный расход держится в районе 34-38 км/л — заправляться приходится редко даже при активной езде. Причём ADV160 — один из самых динамичных байков в линейке PCX-Nmax-ADV, несмотря на то что двигатель у него с PCX160 один и тот же — просто настройки другие. Дорожный просвет реально работает на грунтовых и разбитых участках, но владельцы честно предупреждают: это городской адвенчур-стайлинг, а не настоящий эндуро — на крупных камнях и серьёзных неровностях просвета всё равно не хватит.

**Где на Бали хорошо себя показывает:** Убуд и окрестности (рисовые террасы, боковые дороги), Мундук и водопады, холмистые участки Улувату и Букит — рельеф и качество покрытия там разные, ADV160 прощает больше, чем городской скутер, но по-настоящему серьёзное бездорожье — не его случай.', 'Honda ADV160 — для неровных дорог и дальних вылазок', 'Характеристики, расход топлива и отзывы владельцев Honda ADV160 в аренде на Бали — где раскрывается городской адвенчур-стайлинг.'
  FROM articles a WHERE a.slug = 'honda-adv-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Yamaha Nmax — New (Gen 2), Neo (Gen 3) и Turbo', 'obzor-yamaha-nmax', 'Nmax в парке — не одна модель, а несколько поколений и триммов под одним именем: New, Neo и Turbo. Разбираемся, чем они отличаются на самом деле.', '"Nmax" в парке — не одна модель, а несколько поколений и триммов под одним именем. New и Neo — это одна и та же техника по мотору и трансмиссии, просто разные поколения линейки (Gen 2 и Gen 3). А Turbo — отдельная история с другими электронными настройками трансмиссии. [Смотреть Yamaha Nmax в каталоге](/ru/bikes?category=yamaha_nmax155).

**Nmax New (Gen 2):**
- Двигатель: 155 см³, Blue Core, VVA, SOHC 4 клапана
- Мощность: ~15 л.с. при 8000 об/мин
- Коробка: классический вариатор (CVT) с роликами
- Вес: ~132 кг
- Бак: 7,1 л

**Nmax Neo (Gen 3):**
- Тот же по объёму и конструкции 155-кубовый Blue Core VVA мотор, что и у New — отличается только визуально, поколение линейки и трим, а не начинка
- Мощность: ~15 л.с. при 8000 об/мин
- Коробка: классический вариатор
- Вес: ~130 кг
- Две версии: Neo (база) и Neo S (+ система Smart Key)

**Nmax "Turbo":**
- Тот же по объёму мотор, что у New/Neo
- Главное отличие — YECVT (Yamaha Electric CVT): по сути та же схема вариатора, но с электронным управлением вместо чисто механических роликов. Это больше про маркетинг ощущений и электронные настройки езды, чем про принципиально другую трансмиссию
- Два режима езды T-Mode/S-Mode + виртуальные "передачи" Y-Shift (Low/Medium/High) — имитация переключения передач, как в автомобиле
- Вес: ~133-135 кг в зависимости от версии
- Три версии: Turbo (база), Turbo Tech Max (TFT-дисплей, порт USB-C, особое седло), Turbo Tech Max Ultimate (топовая)
- Важно для текста: "Turbo" в названии — про электронику и ощущение отклика, а не про буквальный турбонаддув двигателя
- У нас вы найдёте широкий выбор кастомных цветов, отличных от стандартных

**Что говорят владельцы:** двигатель (в любом поколении) в отзывах называют "неубиваемым" — надёжность одна из сильных сторон линейки в целом. Экономичность тоже сильная сторона — тот же экономичный 155-кубовый мотор, что и у остальных моделей семейства (PCX160, ADV160), в реальных поездках держит расход в комфортных пределах, заправляться приходится нечасто. Интересный нюанс по багажнику: цифры заявлены немаленькие, но форма ниши такая, что полнолицевой шлем влезает не всегда. Из приятного — под левым подрулевым кожухом есть отдельный отсек для телефона и кошелька. В балийских отзывах арендаторов отдельно хвалят тягу на подъёмах ("tanjakan") и мягкую подвеску для дальних поездок — например, до Улувату. ABS и широкие бескамерные шины в нескольких гайдах для туристов называют отдельным плюсом именно из-за частых тропических ливней и внезапных препятствий на дороге вроде собак — тормоза не блокируют колесо в панике.

**Где на Бали хорошо себя показывает:** уверенно чувствует себя и в городском потоке (Чангу, Семиньяк), и на трассе средней протяжённости, включая поездки до Улувату — хорошая устойчивость на поворотах и в дождь. Актуально для всех версий одинаково — геометрия и посадка между ними почти не отличаются.', 'Yamaha Nmax — New (Gen 2), Neo (Gen 3) и Turbo', 'Yamaha Nmax в аренде на Бали: чем отличаются New, Neo и Turbo, характеристики и реальные отзывы владельцев.'
  FROM articles a WHERE a.slug = 'yamaha-nmax-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Yamaha XMAX250 — Connected и Tech Max: одна механика, разный уровень отделки', 'obzor-yamaha-xmax250', 'Yamaha XMAX250 — самый мощный скутер в линейке, хорош и на дальние расстояния, и в городе. В парке — версии Connected и Tech Max с одинаковой механикой.', 'Yamaha XMAX250 — самый мощный скутер в линейке. Многие очень любят именно этого крупного зверя, и пусть все соглашаются, что он хорош на дальние расстояния — для многих нет ничего лучше и в коротких городских поездках. В парке модель встречается в двух версиях — Connected и Tech Max, — и здесь важно понимать: технически это один и тот же байк, разница только в отделке. [Смотреть Yamaha XMAX250 в каталоге](/ru/bikes?category=yamaha_xmax250).

**Характеристики (одинаковые для Connected и Tech Max — двигатель и ходовая идентичны):**
- Двигатель: 250 см³, одноцилиндровый, жидкостное охлаждение, SOHC 4 клапана, Blue Core, кованый коленвал цельной конструкции (one-piece forged crankshaft)
- Мощность: 16,8 кВт при 7000 об/мин
- Крутящий момент: 24,3 Нм при 5500 об/мин
- Коробка: вариатор (CVT)
- Высота по седлу: 795 мм
- Вес: ~181 кг
- Бак: 13 л
- Багажник под седлом: 44,9 л — очень много, реально влезает два фуллфейс шлема плюс вещи. Важный момент: иногда нужно развернуть полнолицевой шлем определённым образом для правильного размещения
- ABS, трэкшн-контроль (TCS), Emergency Stop Signal (аварийное мигание стоп-сигналом при экстренном торможении), смарт-ключ с Answer Back System (сигнал для поиска байка на парковке), электрогнездо для зарядки телефона
- Лобовое стекло на Connected — фиксированное, без регулировки. Регулировка стекла — эксклюзив Tech Max (см. ниже)
- Гарантия от Yamaha Indonesia — 5 лет / 50 000 км на раму, компоненты топливной системы, цилиндр и поршень

**Приложение Y-Connect — важная деталь, ради которой стоит отдельно объяснять арендатору:**

Для модели XMAX Connected доступно подключение к приложению:

📱 Скачать можно здесь:
https://apps.apple.com/app/id1495921872
https://apps.apple.com/app/id1585591110

Что даёт подключение:
• Приём входящих звонков с руля
• Переключение музыки с руля
• Навигация на русском языке
• Удобная интеграция со смартфоном

**Connected vs Tech Max — в чём разница:**

Самое важное и самое дорогое отличие — сиденье. У Tech Max оно не просто "с другой прострочкой", это отдельно спроектированное седло производства MBK (французского бренда, который принадлежит Yamaha и специализируется именно на европейских скутерах) — так называемое "Comfort Seat". Внутри — пена высокой плотности (high-density foam) и боковые валики-поддержки (bolster) по бокам, спроектированные конкретно под многочасовые поездки: седло держит посадку и снижает усталость поясницы на длинных перегонах, а не просто мягче на ощупь. Сверху — экокожа с замшевыми вставками и прострочкой золотой нитью, плюс хромированная вставка. Владельцы в отзывах отдельно называют именно седло главным поводом доплатить за Tech Max, а не цвет или шильдики.

Остальные отличия — тоже реальные, но по цене и значимости уступают седлу:
- Эксклюзивный цвет (Magma Black на прежних моделях, с 2025 — Ceramic Grey)
- Крышка подседельного кармана из экокожи с замшей и золотой прострочкой (в тон седлу)
- Алюминиевые площадки подножек, хромированная накладка, специальные шильдики и фактура ручек Tech Max
- На модели Tech Max 2025 года появилось единственное функциональное (не только косметическое) отличие — электропривод регулировки лобового стекла (Electric Adjustable Screen), которым можно пользоваться даже на ходу и быстро настроить его по своим ощущениям, плюс обновлённая приборная TFT-панель; у Connected стекло, как сказано выше, вообще без регулировки

Разница в цене на индонезийском рынке — около 5 млн рупий за версию Tech Max, и в первую очередь эти деньги идут именно в седло.

**Что говорят владельцы:** мотор комфортно тянет до 100-110 км/ч, а дальше начинает "задыхаться" — это не байк для разгона, а байк для стабильного крейсерского темпа. Индонезийский клуб владельцев XMAX проводил первый туринг новой модели прямо по Бали ещё в 2017 году — маршрут Денпасар → Убуд → Кинтамани → Бесаких → Клунгкунг → Гианьяр → трасса Ida Bagus Mantra и обратно; на извилистых участках Убуда и Кинтамани участники проверяли работу трэкшн-контроля, а на прямом участке толл-дороги Ida Bagus Mantra разгонялись до 140 км/ч.

Готовые именованные маршруты для XMAX250 на Бали, которые называют сами байкеры: южное побережье — Чангу → Улувату (через Jalan Bali Cliff) → пляж Пандава → GWK; горный маршрут — Денпасар → Убуд → Кинтамани → озеро Батур → Мундук; восточный — Санур → Чандидаса → Сидеман → пляж Virgin. Подробные маршруты и точки на карте — в наших статьях блога «Полуостров Букит на байке», «Кинтамани: рассвет на вулкане Батур» и «Восточный Бали на байке» (там же — Virgin Beach) — скоро опубликуем.

**Кому подойдёт:** для однодневных или многодневных поездок по острову, где важны запас мощности для обгонов и подъёмов, а также комфорт на протяжённых участках трассы. Плюс на повседневную езду — это один из самых востребованных байков и у туристов, и у долгожителей на Бали.

**Где на Бали хорошо себя показывает:** маршруты за пределы юга острова — Кинтамани и вулкан Батур, Амед, Ловина, Сидеман, восточное побережье. Но опять же это дело вкуса — есть те, кто даже в пробках по Чангу кайфует от максимально большого тур-эндуро, и таких энтузиастов далеко не мало.', 'Yamaha XMAX250 — Connected и Tech Max: одна механика, разный уровень отделки', 'Yamaha XMAX250 в аренде на Бали: разница между Connected и Tech Max, характеристики, приложение Y-Connect и маршруты по острову.'
  FROM articles a WHERE a.slug = 'yamaha-xmax250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Yamaha MT-25 — Gen 2 и Gen 3: разный внешний вид, тот же мотор', 'obzor-yamaha-mt-25', 'Yamaha MT-25 — компактный стритфайтер для тех, кто хочет почувствовать разгон и отклик мотоцикла. В парке встречаются байки Gen 2 и Gen 3 после рестайлинга 2025 года.', 'Yamaha MT-25 — компактный стритфайтер для тех, кто хочет почувствовать разгон и отклик мотоцикла, а не просто доехать из точки А в точку Б. Байк реально с характером — очень многие профессионалы и любители отмечают его как один из самых любимых байков в своей категории: и по динамике, и по посадке, и по внешнему виду. Механическая коробка и агрессивная посадка — то, чем эта модель принципиально отличается от скутеров в парке. В 2025 году Yamaha Indonesia выпустила заметный рестайлинг ("Gen 3"), так что в парке могут стоять рядом байки старого и нового вида под одним и тем же названием модели. [Смотреть Yamaha MT-25 в каталоге](/ru/bikes?group=motorcycle&model=yamaha_mt25).

**Характеристики (общие — сам двигатель между поколениями не менялся):**
- Двигатель: 249,55 см³, жидкостное охлаждение, DOHC, параллельная двойка (2 цилиндра), 8 клапанов
- Мощность: около 35,5 л.с. при 12 000 об/мин
- Крутящий момент: ~22,6 Нм при 10 000 об/мин
- Коробка: 6-ступенчатая механика
- Высота по седлу: ~780 мм
- Бак: ~14 л

**Gen 2 (обновление ~2019 года — самый узнаваемый "классический" облик MT-25):**
- Один передний тормозной диск
- Без ассист-слиппер сцепления, без ABS
- Вес: ~165-167 кг

**Gen 3 (рестайлинг 2025 года, Yamaha позиционирует как "Hypernaked" — по официальному сайту Yamaha Indonesia):**
- Новая агрессивная фара в духе линейки MT-07/R-серии — угловатая, "инопланетная" оптика, в отличие от округлой фары Gen 1 (Gen 2 уже отошла от круглой формы, но у Gen 3 своя, ещё более резкая геометрия)
- ABS — впервые появился на MT-25 именно в Gen 3
- Ассист-слиппер сцепление — мягче работает при резких понижениях передач
- Y-Connect (Bluetooth-приложение) через модуль CCU — первая такая технология на мотоцикле индонезийской сборки
- Big Bike Switch 3-in-1 — объединённый компактный блок переключателей в духе "больших" байков Yamaha
- Полностью цифровая приборная панель с индикатором оптимального момента переключения (shift timing light)
- Электрогнездо для зарядки гаджетов
- Вес: ~169 кг — чуть больше, чем у Gen 2, за счёт нового оснащения

**Где на Бали хорошо себя показывает:** Чангу и Семиньяк — короткие резкие ускорения в городском траффике и вечерние покатушки по набережной, где характер байка раскрывается лучше всего.', 'Yamaha MT-25 — Gen 2 и Gen 3: разный внешний вид, тот же мотор', 'Yamaha MT-25 в аренде на Бали: разница между Gen 2 и Gen 3, характеристики двигателя и где раскрывается характер стритфайтера.'
  FROM articles a WHERE a.slug = 'yamaha-mt25-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Kawasaki Ninja ZX-25R — единственный серийный 250-кубовый спортбайк с рядной четвёркой', 'obzor-kawasaki-ninja-zx-25r', 'Kawasaki Ninja ZX-25R — единственный серийный спортбайк 250cc с рядным 4-цилиндровым двигателем. Высокооборотистый характер и заводской квикшифтер.', 'Ninja ZX-25R — уникальная позиция в классе 250cc: это единственный серийный спортбайк такого объёма с рядным 4-цилиндровым двигателем (у всех конкурентов — одно- или двухцилиндровые моторы). Отсюда характерный высокооборотистый звук и требовательность к раскрутке двигателя. [Смотреть Kawasaki Ninja ZX-25R в каталоге](/ru/bikes?group=motorcycle&model=kawasaki_zx25r).

**Характеристики:**
- Двигатель: 249 см³, жидкостное охлаждение, DOHC, рядная четвёрка — редкая конфигурация для класса
- Мощность: около 45 л.с. (индонезийская версия без рам-эйр) при 15 500 об/мин, редлайн — до 17 000 об/мин
- Коробка: 6-ступенчатая механика
- Высота по седлу: ~785 мм
- Вес: ~183 кг
- Бак: ~15 л
- Полный обтекатель, спортбайк-посадка
- Заводской квикшифтер (Quick Shifter) — переключение передач без выжима сцепления, с автоматическим блипом газа на понижение

**Что говорят владельцы:** сам факт 4-цилиндрового мотора в 250-кубовом классе настолько необычен, что Kawasaki в своё время выложила отдельное видео звука этого двигателя на дино-стенде — комментаторы описывали звук как "злой" и "безумный" для такого небольшого объёма. Некоторые опытные райдеры отмечают, что заводской квикшифтер (с автоматическим блипом на понижении) работает отлично и превращает обычные балийские скорости в по-настоящему кайфовую езду — не нужно разгоняться до трека, чтобы получить удовольствие от переключений. Из минусов отмечают: при росте от 180 см к концу дня ноги начинают уставать от посадки, а подвеска настроена под город, не под трек. Пиковая мощность приходит только к 15 500 об/мин, и тому, кто привык ездить на низких оборотах, байк покажется вялым, пока обороты не подняты.

**Кому подойдёт:** уверенным райдерам, которые хотят максимум эмоций от 250-кубового класса и готовы держать высокие обороты — это не байк для спокойной езды на малых оборотах.

**Где на Бали хорошо себя показывает:** нацелен скорее на впечатление и характер, чем на конкретный маршрут — хорош там же, где и MT-25 (город, набережная), и на трассе мирового уровня Мандалика на соседнем острове Ломбок. Далеко не все ренталы разрешают такие выезды, но с нами это возможно. Это самый требовательный байк в парке — не для первого опыта на мотоцикле, и не идеален для высоких райдеров на целый день.', 'Kawasaki Ninja ZX-25R — единственный серийный 250-кубовый спортбайк с рядной четвёркой', 'Kawasaki Ninja ZX-25R в аренде на Бали: редкий рядный 4-цилиндровый мотор 250cc, квикшифтер и кому подойдёт этот спортбайк.'
  FROM articles a WHERE a.slug = 'kawasaki-ninja-zx-25r-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Yamaha XSR155 — кафе-рейсер с ретро-характером', 'obzor-yamaha-xsr155', 'Yamaha XSR155 — неоретро-байк с круглой фарой, низким рулём и посадкой кафе-рейсера на семейном 155-кубовом моторе, настроенном мощнее под механику.', 'Yamaha XSR155 — неоретро-байк: круглая фара, низкий руль, посадка кафе-рейсера. Тот же семейный 155-кубовый мотор, что у скутеров линейки, но в версии для механики настроен мощнее. [Смотреть Yamaha XSR155 в каталоге](/ru/bikes?group=motorcycle&model=yamaha_xsr).

**Характеристики:**
- Двигатель: 155 см³, жидкостное охлаждение, SOHC, VVA — та же база, что у Nmax155, но другая настройка под механику
- Мощность: около 19,3 л.с. при 10 000 об/мин
- Коробка: 6-ступенчатая механика
- Высота по седлу: ~815 мм — низкая посадка кафе-рейсера
- Вес: ~131-134 кг
- Бак: ~10 л

**Что говорят владельцы:** шасси у XSR155 позаимствовано у спортбайка R15, поэтому байк лёгкий и очень отзывчивый в управлении. При аккуратном газе реальный расход доходит до ~50 км/л. Важный момент для тех, кто планирует ездить вдвоём: заднее сиденье компактное и жёсткое, нормальной ручки для пассажира на многих версиях нет. Один из реальных балийских арендаторов оставил показательный отзыв именно об этой модели: несмотря на скромные 155 см³, байк "едет жёстко" на балийских дорогах, отлично настроен под свою цену и держится на местном асфальте настолько уверенно, что, по его словам, дал бы фору даже Yamaha R3 на тех же поворотах — прокатчик привозил байк за три часа езды, в Амед, и он не подвёл.

**Кому подойдёт:** тем, кто хочет стиль и характер мотоцикла, но без избыточной мощности — комфортный переход от скутера к байку с механикой.

**Где на Бали хорошо себя показывает:** Чангу и Семиньяк — ретро-эстетика байка отлично сочетается с атмосферой района; но, судя по отзывам, вполне справляется и с более протяжёнными и извилистыми маршрутами вроде поездки в Амед.', 'Yamaha XSR155 — кафе-рейсер с ретро-характером', 'Yamaha XSR155 в аренде на Бали: характеристики, отзывы владельцев и кому подойдёт этот неоретро-байк с механической коробкой.'
  FROM articles a WHERE a.slug = 'yamaha-xsr-155-review-retro-style'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Kawasaki Versys-X 250 — туринг с запасом на грунтовку', 'obzor-kawasaki-versys-x250', 'Kawasaki Versys-X 250 — эндуро-туринг с высокой посадкой, длинноходной подвеской и увеличенным баком для тех, кто хочет исследовать боковые дороги острова.', 'Kawasaki Versys-X 250 — эндуро-туринг: высокая посадка, длинноходная подвеска, увеличенный бак. Байк для тех, кто планирует не просто доехать по асфальту, а исследовать боковые дороги острова. [Смотреть Kawasaki Versys-X 250 в каталоге](/ru/bikes?group=motorcycle&model=kawasaki_versys).

**Характеристики:**
- Двигатель: 249 см³, жидкостное охлаждение, DOHC, параллельная двойка
- Мощность: около 27 л.с. при 9700 об/мин
- Коробка: 6-ступенчатая механика
- Высота по седлу: ~845 мм — заметно выше остальных моделей в парке
- Вес: ~184 кг
- Бак: ~17 л — один из самых больших в парке, увеличенный запас хода
- Ветровое стекло, эндуро-стойка, позиция для долгой езды стоя/сидя

**Что говорят владельцы:** реальный расход при спокойной езде до 105 км/ч — около 27-30 км/л (независимо подтверждается и балийскими прокатчиками — около 3-4 л на 100 км), что при 17-литровом баке даёт очень солидный запас хода без дозаправок. Бездорожье — не просто маркетинг: в одном из первых тест-драйвов байк уверенно прошёл через густую грязь без единого касания подвеской дна. Штатное сиденье жёсткое на старте и требует "обкатки". Комфортнее всего байк чувствует себя в диапазоне 80-110 км/ч. Реальные балийские арендаторы отмечают, что байк без проблем довозили даже до отдалённой горной деревни, и что версия с ручной коробкой отлично показала себя в дождливую поездку на север острова. Готовые маршруты, которые называют сами прокатчики: юг Бали — Убуд — Кинтамани, горные дороги севера острова, восточное побережье до Амеда и Туламбена.

**Кому подойдёт:** для многодневных маршрутов по острову и тем, кто хочет уверенности на грунтовых или разбитых участках. Подробные маршруты — в статьях блога: «Восточный Бали на байке», «Кинтамани: рассвет на вулкане Батур», «Бедугул — Мундук — Ловина».

**Где на Бали хорошо себя показывает:** дальние маршруты — Кинтамани, север и восток острова (включая Амед и Туламбен), боковые дороги за пределами основных туристических трасс.', 'Kawasaki Versys-X 250 — туринг с запасом на грунтовку', 'Kawasaki Versys-X 250 в аренде на Бали: характеристики, запас хода, отзывы владельцев и лучшие маршруты для эндуро-туринга.'
  FROM articles a WHERE a.slug = 'kawasaki-versys-x250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Suzuki V-Strom 250 — туринг с акцентом на комфорт и ветрозащиту', 'obzor-suzuki-v-strom-250', 'Suzuki V-Strom 250 — адвенчур-туринг с акцентом на комфорт при длительной езде: широкое ветровое стекло, вертикальная посадка, мягкая подвеска.', 'Suzuki V-Strom 250 — адвенчур-туринг с фокусом на комфорт при длительной езде: широкое ветровое стекло, идеальная вертикальная посадка, мягкая подвеска для долгих переездов без усталости. [Смотреть Suzuki V-Strom 250 в каталоге](/ru/bikes?group=motorcycle&model=suzuki_vstrom250).

**Характеристики:**
- Двигатель: 248 см³, жидкостное охлаждение, DOHC, параллельная двойка
- Мощность: около 25 л.с. при 8000 об/мин
- Коробка: 6-ступенчатая механика
- Высота по седлу: ~800-835 мм в зависимости от версии
- Бак: 12 л

**Что говорят владельцы:** мотор в отзывах сравнивают со швейной машинкой — гладкий, тихий, экономичный и надёжный. В плюсах у всех подряд — хорошо набитое седло и посадка "как у большого мотоцикла" при управляемости мотоцикла в разы легче. Расход топлива в реальной езде — от 32 до 48 км/л. Один из самых показательных примеров использования на Бали — арендатор взял V-Strom на 40+ дней и доехал на нём до острова Флорес и обратно. Практичный урок от другого балийского арендатора: штатная задняя решётка для крепления сумок оказалась ненадёжной в дороге — в компании их пересадили на Versys с полноценными кофрами по бокам; вывод — если планируется багаж, кофры удобнее, чем верёвки на решётке. Арендаторы отдельно рекомендуют направление на Сидеман, гору Батур и дороги вокруг самой восточной точки Бали, отмечая, что трафик серьёзно ощущается только в Улувату, Чангу и Убуде — а дальше начинаются рисовые террасы, джунгли и виды на океан.

**Кому подойдёт:** тем, кто в первую очередь ищет комфорт на длинных переездах, а не спортивный характер. Подробные маршруты — в статьях блога: «Восточный Бали на байке», «Секумпул и водопады центрального севера Бали», «Вулканы Бали на байке».

**Где на Бали хорошо себя показывает:** та же ниша, что у Versys-X250 — дальние маршруты, Сидеман, гора Батур, восточное побережье. Если планируется много багажа — просто сообщите нам, и мы добавим вам на байк боковые кофры.', 'Suzuki V-Strom 250 — туринг с акцентом на комфорт и ветрозащиту', 'Suzuki V-Strom 250 в аренде на Бали: характеристики, реальный расход топлива и отзывы арендаторов о дальних поездках по острову.'
  FROM articles a WHERE a.slug = 'suzuki-v-strom-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'TVS Ronin 225 — неоретро на грани скрэмблера', 'obzor-tvs-ronin-225', 'TVS Ronin 225 — модерн-классик со скрэмблерными нотками: круглая LED-фара, высокая посадка руля и уверенность как в городе, так и на грунтовых съездах.', 'TVS Ronin 225 — модерн-классик со скрэмблерными нотками: круглая LED-фара, высокая посадка руля, универсальная геометрия, которая одинаково уверенно чувствует себя и в городе, и на грунтовых съездах с основной дороги. Все версии идут с ABS. [Смотреть TVS Ronin 225 в каталоге](/ru/bikes?group=motorcycle&model=tvs_ronin225).

**Характеристики:**
- Двигатель: 225,9 см³, масляное охлаждение, одноцилиндровый, SOHC, 4 клапана
- Мощность: около 20,4 л.с. при 7750 об/мин
- Крутящий момент: ~19,9 Нм при 3750 об/мин — тянет уже с низов, не нужно раскручивать
- Коробка: 5-ступенчатая механика
- Высота по седлу: ~795 мм
- Вес: ~159 кг
- Бак: ~14 л
- ABS на всех версиях (у базовой — одноканальный, у старших — двухканальный)

**Надёжность:** TVS — бренд с очень долгой историей в Индии (двухколёсный транспорт выпускают с 1980-х), и сам Ronin, хоть и сравнительно свежая модель (с 2022 года), уже успел собрать сильную репутацию по надёжности за прошедшие годы эксплуатации: в отзывах владельцев с пробегом от 10 000 км двигатель описывают как сохраняющий эталонную плавность, золотистые вилки USD показывают высокую износостойкость, а сборка остаётся без люфтов и дребезга даже спустя год активной езды по разным покрытиям. Оценки надёжности и стоимости обслуживания у Ronin в независимых рейтингах владельцев стабильно одни из самых высоких в классе.

**Что говорят владельцы:** двигатель заводится с характерным для ретро-байков грудным звуком с лёгкой хрипотцой. Сильный низовой момент делает байк особенно комфортным в плотном городском трафике. Реальный расход в отзывах — 35-45 км/л. Подвеска настроена мягко — хорошо гасит городские неровности. У части версий есть режимы езды, в том числе адаптированный под дождь — полезно с учётом балийского климата. Отличная динамика и внешний вид — отмечают в отзывах регулярно, как одну из сильных сторон модели.

**Кому подойдёт:** тем, кто хочет универсальный мотоцикл на каждый день — без надрыва спортбайка, но с запасом уверенности на грунтовых участках.

**Где на Бали хорошо себя показывает:** так же хорош в Чангу/Семиньяке за счёт неоретро-образа, как и на боковых грунтовых съездах к рисовым террасам.', 'TVS Ronin 225 — неоретро на грани скрэмблера', 'TVS Ronin 225 в аренде на Бали: характеристики, надёжность и отзывы владельцев о неоретро-байке со скрэмблерным характером.'
  FROM articles a WHERE a.slug = 'tvs-ronin-225-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Keeway Road Falcon 250 — классический круизер по цене входа в класс', 'obzor-keeway-road-falcon-250', 'Keeway Road Falcon 250 — классический круизер с длинным силуэтом и низкой посадкой по цене входа в класс. Новая модель на рынке — вышла в 2026 году.', 'Keeway Road Falcon 250 — длинный силуэт, низкая посадка, сдержанный чёрный цвет и характер, скопированный у больших американских круизеров, но на компактном 250-кубовом основании. Модель совсем новая на рынке — вышла в 2026 году, поэтому пользовательских и балийских рентал-отзывов пока практически нет. [Смотреть Keeway Road Falcon 250 в каталоге](/ru/bikes?group=motorcycle&model=keeway_roadfalcon250).

**Характеристики:**
- Двигатель: 248 см³, параллельная двойка, 4-тактный, 4 клапана, SOHC, жидкостное охлаждение
- Мощность: около 24,6 л.с. при 8000 об/мин
- Крутящий момент: ~23,4 Нм при 6500 об/мин
- Коробка: 6-ступенчатая механика со слиппер-сцеплением
- Высота по седлу: ~698 мм — одна из самых низких посадок в парке
- Дорожный просвет: ~186 мм
- Бак: 14 л
- Тормоза: передний диск 300 мм (2-поршневой суппорт), задний 260 мм
- TFT-дисплей 5 дюймов, встроенная Bluetooth-колонка — редкая опция для этого класса
- Прямой вывод навигации на приборную панель — как и на XMAX250, для этой модели держатель телефона не нужен вовсе

**Что говорят владельцы:** модель напрямую сравнивают с байками стиля Harley-Davidson и с Honda Rebel — характерный "бак-горб" спереди и общий силуэт намеренно отсылают к большим американским круизерам, и в индонезийской прессе есть прямые сравнительные обзоры Road Falcon именно против Honda Rebel. Встроенная Bluetooth-колонка в руле — редкость для круизеров этого класса. Слиппер-сцепление смягчает переключения на пониженные передачи — полезно на холмистых участках Бали. Отдельно отмечают, что это очень манёвренный байк с неожиданно малым радиусом разворота — для длинного круизерного силуэта это не очевидно, но заметно на практике.

**Кому подойдёт:** тем, кто хочет классический образ круизера и расслабленную посадку — особенно удобен для райдеров невысокого роста благодаря очень низкому седлу.

**Где на Бали хорошо себя показывает:** неспешные прибрежные маршруты — Санур, Нуса-Дуа, — но не только: наши клиенты забирались на нём и в локации, обычно предназначенные для классических турэндуро вроде Versys и V-Strom, то есть и дальние маршруты по всему северному побережью Бали байк тоже вытягивает, несмотря на круизерный образ.', 'Keeway Road Falcon 250 — классический круизер по цене входа в класс', 'Keeway Road Falcon 250 в аренде на Бали: характеристики, сравнение с Honda Rebel и кому подойдёт этот круизер.'
  FROM articles a WHERE a.slug = 'keeway-road-falcon-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Morbidelli C252V — V-twin круизер с итальянским именем', 'obzor-morbidelli-c252v', 'Morbidelli C252V — второй круизер в парке, но с настоящим V-образным двухцилиндровым мотором вместо параллельной двойки и ремённым приводом.', 'Второй круизер в парке, но принципиально другой по характеру, чем Road Falcon: у Morbidelli — настоящий V-образный двухцилиндровый мотор вместо параллельной двойки, отсюда другой, более "басовитый" звук и вибрация, которую многие круизерные райдеры считают частью удовольствия. Бренд Morbidelli — итальянское имя с реальной гоночной историей (чемпионские титулы в 125cc и 250cc классах Гран-При в 1970-х), права на которое с 2024 года принадлежат тому же концерну, что владеет Keeway — так что это не однофамилец, а официально возрождённый бренд на новой технической базе. [Смотреть Morbidelli C252V в каталоге](/ru/bikes?group=motorcycle&model=morbidelli_c252v).

**Характеристики:**
- Двигатель: 249 см³, V-образная двойка (V-twin), 4-тактный, 8 клапанов, SOHC, жидкостное охлаждение
- Мощность: около 25,5 л.с. при 9000 об/мин
- Крутящий момент: 25 Нм при 5500 об/мин
- Коробка: 6-ступенчатая механика со слиппер-сцеплением
- Привод: ремень (belt drive) — редкость для класса. На практике это значит: не нужно смазывать и периодически подтягивать, как цепь, и ремень не ржавеет от дождя
- Высота по седлу: 690 мм — одна из самых низких в парке
- Вес: ~200 кг
- Бак: 15,5 л
- Дорожный просвет: 173 мм
- Тормоза: передний диск 320 мм (4-поршневой суппорт), задний 260 мм (2-поршневой); двухканальный ABS Bosch и трэкшн-контроль в стандартной комплектации
- Передняя вилка перевёрнутая (USD) 37 мм, ход 115 мм; сзади — два амортизатора с 5-ступенчатой регулировкой преднатяга
- Максимальная скорость — заявлено 125 км/ч

**Что говорят владельцы:** модель очень свежая на рынке, поэтому многолетней истории эксплуатации ещё нет, но первые тест-райды в прессе отмечают неожиданно лёгкое управление для круизера с таким длинным колёсным базой — разворотный радиус не выдаёт габаритов байка. V-образный мотор описывают как визуально эффектный (заметен под баком, с имитацией рёбер охлаждения и хромированной отделкой) и звучащий заметно глубже типичных 250-кубовых параллельных двоек.

**Кому подойдёт:** тем, кто хочет именно V-twin характер круизера (не параллельную двойку, как у Road Falcon) — более выраженную вибрацию и басовитый звук мотора, плюс ремень вместо цепи — не нужно смазывать и подтягивать, не ржавеет в дождь.

**Где на Бали хорошо себя показывает:** та же ниша, что у Road Falcon — неспешные прибрежные маршруты, Санур, Нуса-Дуа; ремень и низкая посадка делают его особенно удобным для тех, кто хочет расслабленный круизерный стиль без забот о цепи.', 'Morbidelli C252V — V-twin круизер с итальянским именем', 'Morbidelli C252V в аренде на Бали: V-twin мотор, ремённый привод, характеристики и чем круизер отличается от Road Falcon.'
  FROM articles a WHERE a.slug = 'morbidelli-c252v-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Honda CBR250RR — полный обтекатель и самый «трековый» из фейринговых спортбайков парка', 'obzor-honda-cbr250rr', 'Honda CBR250RR — единственный полностью обтекаемый спортбайк в парке, топовая версия с квикшифтером и ABS. Один из технологических лидеров класса 250cc в Индонезии.', 'Единственный полностью обтекаемый спортбайк в парке (в отличие от MT-25 и ZX-25R, которые "голые" нейкед/стритфайтеры) — Honda CBR250RR со дня дебюта в 2016 году считается одним из технологических лидеров класса 250cc в Индонезии. [Смотреть Honda CBR250RR в каталоге](/ru/bikes?group=motorcycle&model=honda_cbr250rr).

**Характеристики (топовая версия SP Quick Shifter с ABS — именно она в парке):**
- Двигатель: 249,7 см³, жидкостное охлаждение, DOHC, параллельная двойка, 8 клапанов, с доработками топовой версии (облегчённый коленвал, новые клапанные пружины, изменённая головка)
- Мощность: ~41 л.с. при 13 000 об/мин
- Крутящий момент: ~25 Нм при 11 000 об/мин
- Коробка: 6-ступенчатая механика
- Высота по седлу: ~790 мм
- Вес: ~168 кг
- ABS, полностью светодиодная оптика, цифровая приборная панель, throttle-by-wire (электронный дроссель без тросика)
- Квикшифтер с 4 настраиваемыми режимами (вверх+вниз, только вверх, только вниз, выключен) — переключение передач без выжима сцепления
- Ассист-слиппер сцепление
- Передняя вилка перевёрнутая (USD) типа SFF-Big Piston
- 3 режима езды: Comfort, Sport, Sport+
- Заявленный разгон 0-200м за 8,65 сек, максимальная скорость до 172 км/ч

**Что говорят владельцы:** CBR250RR стабильно упоминается как один из самых технологически "начинённых" байков в 250-кубовом классе Индонезии — версия с квикшифтером даёт по-настоящему трековые ощущения, редкие для этого объёма двигателя.

**Кому подойдёт:** тем, кто хочет полный спортбайк-опыт — обтекатель, спортивную посадку "лёжа на баке", и технологии уровня MotoGP-квикшифтера.

**Где на Бали хорошо себя показывает:** как и ZX-25R — город, набережная, для впечатлений и характера, а не под конкретный маршрут; с учётом трековой родословной — отлично раскрывается и на трассе Мандалика на Ломбоке.', 'Honda CBR250RR — полный обтекатель и самый «трековый» из фейринговых спортбайков парка', 'Honda CBR250RR в аренде на Бали: топовая версия с квикшифтером, характеристики и кому подойдёт полный спортбайк-опыт.'
  FROM articles a WHERE a.slug = 'honda-cbr250rr-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'Honda CB150X — доступный адвенчур-вид на базе 150-кубового мотора', 'obzor-honda-cb150x', 'Honda CB150X — доступный вход в адвенчур-стилистику на 150-кубовом моторе с серьёзными для класса ходовыми и самым лёгким весом среди мотоциклов парка.', 'CB150X — не то же самое, что 250-кубовые Versys-X250 и V-Strom250: это бюджетный вход в адвенчур-стилистику на скромном 150-кубовом одноцилиндровом моторе, но с по-настоящему серьёзными для класса ходовыми (дорожный просвет почти как у CB500X). Благодаря очень лёгкому весу для мотоцикла (139 кг) 150-кубового мотора здесь более чем достаточно — байк легко поднимает переднее колесо и держит уверенную динамику во всём диапазоне скоростей, а не только на низких, как можно подумать по одному цилиндру и скромному объёму. [Смотреть Honda CB150X в каталоге](/ru/bikes?group=motorcycle&model=honda_cb150x).

**Характеристики:**
- Двигатель: 149,16 см³, одноцилиндровый, жидкостное охлаждение, DOHC 4 клапана
- Мощность: ~15,6 л.с. при 9000 об/мин
- Крутящий момент: ~13,8 Нм при 7000 об/мин
- Коробка: 6-ступенчатая механика
- Высота по седлу: 817 мм
- Дорожный просвет: 181 мм — почти как у гораздо более крупного CB500X
- Вес: ~139 кг — самый лёгкий мотоцикл (не скутер) в парке
- Бак: 12 л
- Передняя вилка перевёрнутая (USD) Showa SFF-BP 37 мм, задний Pro-Link монoshock
- Волнообразные (wavy) тормозные диски спереди и сзади
- Полностью цифровая приборная панель с расходом топлива в реальном времени

**Кому подойдёт:** тем, кто хочет адвенчур-стайлинг и высокую посадку, но не готов к весу и мощности полноценного 250-кубового турера — хорошая ступень для перехода с городских байков на более серьёзные модели.

**Где на Бали хорошо себя показывает:** та же логика, что у ADV160 — боковые дороги, неидеальный асфальт, но по посадке и характеру это уже полноценный мотоцикл с механикой, а не скутер.', 'Honda CB150X — доступный адвенчур-вид на базе 150-кубового мотора', 'Honda CB150X в аренде на Бали: характеристики, дорожный просвет и кому подойдёт бюджетный адвенчур-байк.'
  FROM articles a WHERE a.slug = 'honda-cb150x-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ru', 'PCX160 vs ADV160 vs Nmax — как выбрать между тройкой', 'pcx160-vs-adv160-vs-nmax-kak-vybrat', 'PCX160, ADV160 и Nmax — как выбрать между тремя самыми популярными скутерами парка: в чём разница по багажнику, динамике и посадке.', 'Честно говоря, эти три модели прежде всего отличаются визуально и тем, к чему именно привык райдер — если коротко, это дело вкуса. Из действительно важных практических отличий на первом месте — размер багажника: Nmax подойдёт тому, кто готов пожертвовать частью вместимости багажника ради любви к его посадке и динамике. А по чистой динамике между собой в команде шутят: тем, кому правда нужен "Турбо"-отклик, лучше из этой линейки взять ADV — он субъективно ощущается более резвым, чем модель с "Turbo" в названии.

В идеале, прежде чем выбрать себе байк надолго — поездить на каждом от 5 дней до месяца, чтобы реально прочувствовать разницу. 1-3 дней часто не хватает, чтобы по-настоящему понять байк.

Карточки моделей: [Honda PCX160](/ru/bikes?category=honda_pcx160), [Honda ADV160](/ru/bikes?category=honda_adv160), [Yamaha Nmax](/ru/bikes?category=yamaha_nmax155).', 'PCX160 vs ADV160 vs Nmax — как выбрать между тройкой', 'Сравнение Honda PCX160, Honda ADV160 и Yamaha Nmax в аренде на Бали — какой скутер выбрать под свои задачи.'
  FROM articles a WHERE a.slug = 'pcx160-vs-adv160-vs-nmax-how-to-choose'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Honda PCX160 — Komfort und Stauraum für jeden Tag', 'honda-pcx160-test-komfort-und-stauraum-im-alltag', 'Die Honda PCX160 ist die vielseitigste Wahl für alle, die einen komfortablen Roller ohne Kompromisse beim Stauraum wollen – die Lieblingswahl von Paaren und Reisenden mit Koffer.', 'Die Honda PCX160 ist die vielseitigste Wahl für alle, die einen komfortablen Roller ohne Kompromisse beim Stauraum wollen. Das ist das Modell, das am häufigsten von Paaren und Reisenden mit Koffer oder großer Tasche gebucht wird. [Honda PCX160 im Katalog ansehen](/de/bikes?category=honda_pcx160).

**Technische Daten:**
- Motor: 156,9 cm³, Flüssigkeitskühlung, eSP+
- Leistung: ca. 15,8 PS bei 8500 U/min
- Getriebe: stufenloses CVT-Automatikgetriebe, kein Schalten nötig
- Sitzhöhe: ~764 mm — für fast jede Körpergröße angenehm
- Tank: 8,1 l
- Stauraum unter der Sitzbank: ~30 l — ein Integralhelm passt hinein, und es bleibt noch Platz für weitere Sachen
- Smart Key, LED-Beleuchtung, starkes USB-Ladegerät, digitales Kombiinstrument
- Bei uns finden Sie eine große Auswahl an individuellen Farben, die über die Standardfarben hinausgehen

**Extras:** Auf der PCX160 lässt sich ein SHAD-Topcase mit 44 l Volumen hinten montieren – praktisch für alle, denen der Stauraum unter der Sitzbank nicht reicht. Mehr zu Zusatzausstattung in unserem Artikel [„Sinnvolle Mietextras: Helme und die Komfort-Box"](/de/blog/sinnvolle-mietextras-helme-und-die-komfort-box).

**Was Besitzer sagen:** Der reale Verbrauch liegt laut Erfahrungsberichten bei etwa 40–50 km/l, was Touren über die Insel praktisch zum Nulltarif macht. Der Ruf der Modellreihe in Sachen Zuverlässigkeit ist fast legendär – in Foren wird die PCX mit einem Rasenmäher verglichen: springt an und läuft jahrelang ohne Überraschungen. Ein praktisches Detail für Mieter: Der Smart Key ist bequem, aber ein Ersatz bei Verlust kostet umgerechnet etwa 1 Million Rupiah – also besser gut aufpassen. Wie der Schlüssel funktioniert, erklären wir in unserem Artikel [„Wie man den Smart Key des Mietrollers startet und benutzt"](/de/blog/wie-man-den-smart-key-des-mietrollers-startet-und-benutzt). Mit Sozius sinkt die Beschleunigungsreserve für Überholvorgänge spürbar – in der Stadt kein Problem, auf der Landstraße aber zu bedenken.

**Wo sie sich auf Bali bewährt:** Dank des 14-Zoll-Vorderrads liegt sie sicher auf Asphalt – komfortabel in Canggu, Seminyak, Sanur und für den Alltag in Denpasar.', 'Honda PCX160 — Komfort und Stauraum für jeden Tag', 'Technische Daten, Verbrauch, Erfahrungsberichte und Zubehör für die Honda PCX160 im Mietpark auf Bali – wo sie überzeugt und für wen sie sich eignet.'
  FROM articles a WHERE a.slug = 'honda-pcx160-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Honda ADV160 — für holprige Straßen und weitere Ausflüge', 'honda-adv160-test-fuer-schlechte-strassen-und-ausfluege', 'Die Honda ADV160 hat denselben zuverlässigen Motor wie die PCX160, aber eine andere Karosserie: höhere Sitzposition, mehr Bodenfreiheit und mehr Sicherheit auf holprigem Asphalt und Schotter.', 'Die Honda ADV160 hat denselben zuverlässigen Motor wie die PCX160, aber ein anderes Gehäuse: höhere Sitzposition, mehr Bodenfreiheit und mehr Sicherheit auf holprigem Asphalt und unbefestigten Abschnitten. [Honda ADV160 im Katalog ansehen](/de/bikes?category=honda_adv160).

**Technische Daten:**
- Motor: 156,9 cm³, Flüssigkeitskühlung, eSP+ (derselbe wie bei der PCX160)
- Leistung: ca. 15,8 PS
- Getriebe: stufenloses CVT-Automatikgetriebe
- Sitzhöhe: ~795 mm — höher als bei Stadtrollern, besser geeignet für größere Fahrer und alle, die eine höhere Sitzposition mögen
- Bodenfreiheit ~165 mm — deutlich mehr als üblich
- Stauraum unter der Sitzbank: ~30 l — ein Integralhelm passt hinein, und es bleibt noch Platz für weitere Sachen
- Verstellbarer Windschild — 2 Positionen: hoch (aggressiv) und tief (Stadt)
- Halbdigitales Kombiinstrument, starkes USB-Ladegerät, Smart Key
- Bei uns finden Sie eine große Auswahl an individuellen Farben, die über die Standardfarben hinausgehen

**Extras:** Genau wie bei der PCX160 lässt sich hinten ein SHAD-Topcase mit 44 l montieren. Mehr dazu in unserem Artikel [„Sinnvolle Mietextras: Helme und die Komfort-Box"](/de/blog/sinnvolle-mietextras-helme-und-die-komfort-box).

**Was Besitzer sagen:** Die Sparsamkeit ist der zweite große Pluspunkt dieses Motors: In Erfahrungsberichten liegt der reale Verbrauch bei 34–38 km/l — auch bei zügiger Fahrweise muss man selten tanken. Dabei zählt die ADV160 zu den dynamischsten Bikes in der PCX-Nmax-ADV-Linie, obwohl der Motor derselbe ist wie bei der PCX160 — nur anders abgestimmt. Die Bodenfreiheit macht sich auf Schotter und holprigen Abschnitten wirklich bezahlt, aber Besitzer weisen ehrlich darauf hin: Das ist urbaner Adventure-Look, kein echtes Enduro — bei großen Steinen und wirklich groben Unebenheiten reicht die Freiheit trotzdem nicht.

**Wo sie sich auf Bali bewährt:** Ubud und Umgebung (Reisterrassen, Nebenstraßen), Munduk und die Wasserfälle, die hügeligen Abschnitte um Uluwatu und die Bukit-Halbinsel — Gelände und Straßenqualität variieren dort stark, die ADV160 verzeiht mehr als ein Stadtroller, aber wirklich anspruchsvolles Gelände ist nicht ihr Fall.', 'Honda ADV160 — für holprige Straßen und weitere Ausflüge', 'Technische Daten, Verbrauch und Erfahrungsberichte zur Honda ADV160 auf Bali – wo sich der urbane Adventure-Look wirklich auszahlt.'
  FROM articles a WHERE a.slug = 'honda-adv-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Yamaha Nmax — New (Gen 2), Neo (Gen 3) und Turbo', 'yamaha-nmax-test-new-neo-und-turbo-im-vergleich', 'Die Nmax in unserem Fuhrpark ist nicht nur ein Modell, sondern mehrere Generationen und Ausstattungslinien unter einem Namen: New, Neo und Turbo. Wir erklären, worin sich die drei wirklich unterscheiden.', 'Die „Nmax" in unserem Fuhrpark ist nicht ein Modell, sondern mehrere Generationen und Ausstattungslinien unter demselben Namen. New und Neo haben bei Motor und Getriebe dieselbe Technik, es sind einfach unterschiedliche Generationen der Baureihe (Gen 2 und Gen 3). Die Turbo dagegen ist eine eigene Geschichte mit anderer elektronischer Getriebesteuerung. [Yamaha Nmax im Katalog ansehen](/de/bikes?category=yamaha_nmax155).

**Nmax New (Gen 2):**
- Motor: 155 cm³, Blue Core, VVA, SOHC, 4 Ventile
- Leistung: ~15 PS bei 8000 U/min
- Getriebe: klassisches CVT-Variomatik mit Rollen
- Gewicht: ~132 kg
- Tank: 7,1 l

**Nmax Neo (Gen 3):**
- Derselbe 155er Blue-Core-VVA-Motor wie bei der New in Hubraum und Bauweise — der Unterschied ist rein optisch, es ist eine andere Generation und Ausstattungslinie, nicht andere Technik
- Leistung: ~15 PS bei 8000 U/min
- Getriebe: klassisches Variomatik
- Gewicht: ~130 kg
- Zwei Versionen: Neo (Basis) und Neo S (+ Smart-Key-System)

**Nmax „Turbo":**
- Gleicher Hubraum wie bei New/Neo
- Der Hauptunterschied ist YECVT (Yamaha Electric CVT): im Prinzip dasselbe Variomatik-Prinzip, aber mit elektronischer Steuerung statt rein mechanischer Rollen. Das ist eher Marketing für das Fahrgefühl und elektronische Fahrmodi als eine grundlegend andere Antriebstechnik
- Zwei Fahrmodi T-Mode/S-Mode plus virtuelle „Gänge" Y-Shift (Low/Medium/High) — simuliert das Schalten wie im Auto
- Gewicht: ~133–135 kg je nach Version
- Drei Versionen: Turbo (Basis), Turbo Tech Max (TFT-Display, USB-C-Anschluss, spezielle Sitzbank), Turbo Tech Max Ultimate (Topversion)
- Wichtig zu wissen: „Turbo" im Namen bezieht sich auf Elektronik und Ansprechverhalten, nicht auf einen echten Turbolader
- Bei uns finden Sie eine große Auswahl an individuellen Farben, die über die Standardfarben hinausgehen

**Was Besitzer sagen:** Der Motor (in jeder Generation) gilt in Erfahrungsberichten als „unkaputtbar" — Zuverlässigkeit ist eine der großen Stärken der Baureihe insgesamt. Auch die Sparsamkeit überzeugt: Derselbe wirtschaftliche 155er-Motor wie bei den anderen Modellen der Familie (PCX160, ADV160) hält den Verbrauch im Alltag angenehm niedrig, getankt werden muss selten. Ein interessantes Detail zum Stauraum: Die angegebenen Werte klingen groß, aber wegen der Form der Nische passt ein Integralhelm nicht immer hinein. Positiv: Unter der linken Lenkerverkleidung gibt es ein eigenes Fach für Handy und Geldbörse. In balinesischen Mieter-Bewertungen wird besonders die Steigfähigkeit bei Anstiegen („tanjakan") und das weich abgestimmte Fahrwerk für längere Touren gelobt — etwa bis nach Uluwatu. ABS und breite schlauchlose Reifen werden in mehreren Reiseführern für Touristen als eigenständiger Pluspunkt genannt, gerade wegen der häufigen tropischen Regengüsse und plötzlicher Hindernisse auf der Straße wie Hunde — die Bremsen blockieren das Rad auch in der Panik nicht.

**Wo sie sich auf Bali bewährt:** Souverän sowohl im Stadtverkehr (Canggu, Seminyak) als auch auf mittellangen Strecken, etwa bis nach Uluwatu — gute Stabilität in Kurven und bei Regen. Das gilt für alle Versionen gleichermaßen — Geometrie und Sitzposition unterscheiden sich kaum.', 'Yamaha Nmax — New (Gen 2), Neo (Gen 3) und Turbo', 'Yamaha Nmax mieten auf Bali: Unterschiede zwischen New, Neo und Turbo, technische Daten und echte Erfahrungsberichte.'
  FROM articles a WHERE a.slug = 'yamaha-nmax-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Yamaha XMAX250 — Connected und Tech Max: gleiche Technik, unterschiedliche Ausstattung', 'yamaha-xmax250-test-connected-und-tech-max-im-vergleich', 'Die Yamaha XMAX250 ist der stärkste Roller im Fuhrpark – gut für lange Strecken und für die Stadt. Bei uns stehen die Versionen Connected und Tech Max mit identischer Technik zur Wahl.', 'Die Yamaha XMAX250 ist der stärkste Roller in unserer Flotte. Viele lieben genau dieses große Kraftpaket, und auch wenn sich alle einig sind, dass es auf langen Strecken glänzt — für viele gibt es nichts Besseres auch für kurze Stadtfahrten. Im Fuhrpark gibt es die Versionen Connected und Tech Max, und hier ist wichtig zu verstehen: Technisch ist es dasselbe Bike, der Unterschied liegt nur in der Ausstattung. [Yamaha XMAX250 im Katalog ansehen](/de/bikes?category=yamaha_xmax250).

**Technische Daten (identisch bei Connected und Tech Max — Motor und Fahrwerk sind gleich):**
- Motor: 250 cm³, Einzylinder, Flüssigkeitskühlung, SOHC, 4 Ventile, Blue Core, einteilige geschmiedete Kurbelwelle (one-piece forged crankshaft)
- Leistung: 16,8 kW bei 7000 U/min
- Drehmoment: 24,3 Nm bei 5500 U/min
- Getriebe: stufenloses CVT-Automatikgetriebe
- Sitzhöhe: 795 mm
- Gewicht: ~181 kg
- Tank: 13 l
- Stauraum unter der Sitzbank: 44,9 l — sehr viel, es passen tatsächlich zwei Integralhelme plus Gepäck hinein. Wichtig: Manchmal muss der Integralhelm in einer bestimmten Ausrichtung platziert werden, damit er passt
- ABS, Traktionskontrolle (TCS), Emergency Stop Signal (Warnblinken bei einer Vollbremsung), Smart Key mit Answer Back System (Signalton zum Wiederfinden des Rollers auf dem Parkplatz), Steckdose zum Laden des Handys
- Die Windschutzscheibe der Connected ist fest montiert, ohne Verstellung. Die Verstellbarkeit ist der Tech Max vorbehalten (siehe unten)
- Garantie von Yamaha Indonesia — 5 Jahre / 50.000 km auf Rahmen, Komponenten des Kraftstoffsystems, Zylinder und Kolben

**Die Y-Connect-App — ein Detail, das es sich lohnt, jedem Mieter extra zu erklären:**

Für die XMAX Connected steht eine App-Verbindung zur Verfügung:

📱 Download hier:
https://apps.apple.com/app/id1495921872
https://apps.apple.com/app/id1585591110

Was die Verbindung bringt:
• Anrufe direkt am Lenker annehmen
• Musik über den Lenker steuern
• Navigation auf Deutsch
• Bequeme Smartphone-Integration

**Connected vs. Tech Max — der Unterschied:**

Der wichtigste und teuerste Unterschied ist die Sitzbank. Bei der Tech Max ist es nicht einfach „eine andere Naht", sondern eine eigens entwickelte Sitzbank von MBK (der französischen Marke, die zu Yamaha gehört und sich auf europäische Roller spezialisiert) — die sogenannte „Comfort Seat". Im Inneren steckt hochdichter Schaumstoff (high-density foam) mit seitlichen Stützwülsten (Bolster), die gezielt für stundenlange Fahrten konzipiert sind: Die Sitzbank stützt die Sitzposition und entlastet den unteren Rücken auf langen Etappen, statt nur weicher zu wirken. Der Bezug besteht aus Kunstleder mit Wildlederelementen und goldener Ziernaht, dazu ein verchromtes Element. Besitzer nennen in Erfahrungsberichten genau diese Sitzbank als Hauptgrund, für die Tech Max mehr zu bezahlen — nicht die Farbe oder die Embleme.

Die übrigen Unterschiede sind ebenfalls real, stehen der Sitzbank in Preis und Bedeutung aber nach:
- Exklusive Farbe (Magma Black bei früheren Modellen, seit 2025 Ceramic Grey)
- Abdeckung des Staufachs unter der Sitzbank aus Kunstleder mit Wildlederdetails und goldener Ziernaht (passend zur Sitzbank)
- Aluminium-Trittbretter, verchromte Blende, spezielle Embleme und eine eigene Griff-Struktur bei der Tech Max
- Bei der Tech Max des Modelljahrs 2025 kam der einzige funktionale (nicht nur kosmetische) Unterschied hinzu — die elektrisch verstellbare Windschutzscheibe (Electric Adjustable Screen), die sich sogar während der Fahrt bedienen und schnell nach eigenem Empfinden einstellen lässt, dazu ein überarbeitetes TFT-Kombiinstrument; bei der Connected ist die Scheibe, wie oben erwähnt, überhaupt nicht verstellbar

Der Preisunterschied auf dem indonesischen Markt liegt bei etwa 5 Millionen Rupiah für die Tech-Max-Version — und dieses Geld steckt in erster Linie genau in der Sitzbank.

**Was Besitzer sagen:** Der Motor zieht komfortabel bis 100–110 km/h, danach fängt er an, „nach Luft zu schnappen" — das ist kein Bike für Beschleunigungsorgien, sondern für ein stabiles Reisetempo. Der indonesische XMAX-Besitzerclub veranstaltete bereits 2017 die erste Ausfahrt des neuen Modells direkt auf Bali — die Route Denpasar → Ubud → Kintamani → Besakih → Klungkung → Gianyar → die Ida-Bagus-Mantra-Straße und zurück; auf den kurvigen Abschnitten von Ubud und Kintamani testeten die Teilnehmer die Traktionskontrolle, auf dem geraden Teil der Ida-Bagus-Mantra-Mautstraße beschleunigten sie auf bis zu 140 km/h.

Fertige, von Bikern selbst benannte Routen für die XMAX250 auf Bali: Südküste — Canggu → Uluwatu (über die Jalan Bali Cliff) → Pandawa Beach → GWK; Bergroute — Denpasar → Ubud → Kintamani → Batur-See → Munduk; Osten — Sanur → Candidasa → Sidemen → Virgin Beach. Ausführliche Routen und Kartenpunkte gibt es in unseren Blogartikeln „Die Bukit-Halbinsel mit dem Bike", „Kintamani: Sonnenaufgang am Vulkan Batur" und „Ost-Bali mit dem Bike" (dort auch Virgin Beach) — wir veröffentlichen sie in Kürze.

**Für wen geeignet:** Für Tages- oder Mehrtagestouren über die Insel, bei denen Leistungsreserve für Überholmanöver und Steigungen sowie Komfort auf langen Etappen zählen. Auch im Alltag ist sie eines der gefragtesten Bikes — sowohl bei Touristen als auch bei Langzeitbewohnern auf Bali.

**Wo sie sich auf Bali bewährt:** Auf Routen jenseits des Südens der Insel — Kintamani und der Vulkan Batur, Amed, Lovina, Sidemen, die Ostküste. Aber auch das ist Geschmackssache — manche genießen selbst im Stau von Canggu den größtmöglichen Tour-Enduro, und solcher Enthusiasten gibt es nicht wenige.', 'Yamaha XMAX250 — Connected und Tech Max: gleiche Technik, unterschiedliche Ausstattung', 'Yamaha XMAX250 mieten auf Bali: Unterschied zwischen Connected und Tech Max, technische Daten, die Y-Connect-App und Routen über die Insel.'
  FROM articles a WHERE a.slug = 'yamaha-xmax250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Yamaha MT-25 — Gen 2 und Gen 3: anderes Design, gleicher Motor', 'yamaha-mt-25-test-gen-2-und-gen-3-im-vergleich', 'Die Yamaha MT-25 ist ein kompakter Streetfighter für alle, die Beschleunigung und direktes Ansprechverhalten spüren wollen. Im Fuhrpark stehen Gen-2- und Gen-3-Modelle nach dem Facelift 2025.', 'Die Yamaha MT-25 ist ein kompakter Streetfighter für alle, die Beschleunigung und direktes Ansprechverhalten spüren wollen, statt nur von A nach B zu kommen. Das Bike hat wirklich Charakter — sehr viele Profis und Enthusiasten nennen es eines ihrer liebsten Bikes in dieser Klasse: bei Fahrdynamik, Sitzposition und Optik gleichermaßen. Schaltgetriebe und aggressive Sitzposition unterscheiden dieses Modell grundlegend von den Rollern im Fuhrpark. 2025 brachte Yamaha Indonesia ein deutliches Facelift („Gen 3") heraus, sodass im Fuhrpark Bikes im alten und neuen Design unter demselben Modellnamen nebeneinanderstehen können. [Yamaha MT-25 im Katalog ansehen](/de/bikes?group=motorcycle&model=yamaha_mt25).

**Technische Daten (gemeinsam — der Motor selbst hat sich zwischen den Generationen nicht verändert):**
- Motor: 249,55 cm³, Flüssigkeitskühlung, DOHC, Reihenzweizylinder (2 Zylinder), 8 Ventile
- Leistung: ca. 35,5 PS bei 12.000 U/min
- Drehmoment: ~22,6 Nm bei 10.000 U/min
- Getriebe: 6-Gang-Schaltgetriebe
- Sitzhöhe: ~780 mm
- Tank: ~14 l

**Gen 2 (Update ~2019 — die bekannteste „klassische" Optik der MT-25):**
- Eine vordere Bremsscheibe
- Ohne Slipper-Kupplung, ohne ABS
- Gewicht: ~165–167 kg

**Gen 3 (Facelift 2025, von Yamaha als „Hypernaked" positioniert — laut offizieller Website von Yamaha Indonesia):**
- Neuer aggressiver Scheinwerfer im Stil der MT-07/R-Serie — kantige, „außerirdische" Optik, im Gegensatz zum runden Scheinwerfer der Gen 1 (die Gen 2 hatte sich bereits von der runden Form gelöst, aber die Gen 3 hat eine eigene, noch schärfere Geometrie)
- ABS — bei der MT-25 erstmals in der Gen 3
- Slipper-Kupplung mit Anti-Hopping-Funktion — arbeitet sanfter bei harten Rückschaltvorgängen
- Y-Connect (Bluetooth-App) über ein CCU-Modul — die erste derartige Technologie an einem in Indonesien gebauten Motorrad
- Big Bike Switch 3-in-1 — kompakter Schalterblock im Stil der „großen" Yamaha-Bikes
- Vollständig digitales Kombiinstrument mit Schaltanzeige (Shift Timing Light)
- Steckdose zum Laden von Geräten
- Gewicht: ~169 kg — etwas mehr als bei der Gen 2, durch die neue Ausstattung

**Wo sie sich auf Bali bewährt:** Canggu und Seminyak — kurze, knackige Beschleunigungen im Stadtverkehr und abendliche Ausfahrten an der Uferpromenade, wo der Charakter des Bikes am besten zur Geltung kommt.', 'Yamaha MT-25 — Gen 2 und Gen 3: anderes Design, gleicher Motor', 'Yamaha MT-25 mieten auf Bali: Unterschied zwischen Gen 2 und Gen 3, Motordaten und wo der Streetfighter-Charakter am besten zur Geltung kommt.'
  FROM articles a WHERE a.slug = 'yamaha-mt25-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Kawasaki Ninja ZX-25R — der einzige Serien-Sportler mit 250cc und Reihenvierzylinder', 'kawasaki-ninja-zx-25r-test-der-einzige-vierzylinder-250er', 'Die Kawasaki Ninja ZX-25R ist der einzige Serien-Sportler mit 250cc und Reihenvierzylinder – drehfreudiger Charakter und werkseitiger Quickshifter inklusive.', 'Die Ninja ZX-25R hat eine einzigartige Position in der 250cc-Klasse: Sie ist der einzige Serien-Sportler dieses Hubraums mit Reihenvierzylindermotor (alle Konkurrenten setzen auf Ein- oder Zweizylinder). Daraus ergibt sich der charakteristische, drehfreudige Sound und die Anforderung, den Motor hochzudrehen. [Kawasaki Ninja ZX-25R im Katalog ansehen](/de/bikes?group=motorcycle&model=kawasaki_zx25r).

**Technische Daten:**
- Motor: 249 cm³, Flüssigkeitskühlung, DOHC, Reihenvierzylinder — eine seltene Konfiguration für diese Klasse
- Leistung: ca. 45 PS (indonesische Version ohne Ram-Air) bei 15.500 U/min, Drehzahlbegrenzer bei bis zu 17.000 U/min
- Getriebe: 6-Gang-Schaltgetriebe
- Sitzhöhe: ~785 mm
- Gewicht: ~183 kg
- Tank: ~15 l
- Vollverkleidung, sportliche Sitzposition
- Werkseitiger Quickshifter — Gangwechsel ohne Kupplungsbetätigung, mit automatischem Zwischengas beim Runterschalten

**Was Besitzer sagen:** Ein Vierzylindermotor in der 250cc-Klasse ist so ungewöhnlich, dass Kawasaki seinerzeit ein eigenes Video vom Sound dieses Motors auf dem Prüfstand veröffentlicht hat — Kommentatoren beschrieben den Klang als „böse" und „verrückt" für so einen kleinen Hubraum. Manche erfahrene Fahrer berichten, dass der werkseitige Quickshifter (mit automatischem Zwischengas beim Runterschalten) hervorragend funktioniert und aus normalem balinesischen Tempo ein richtig geiles Fahrerlebnis macht — man muss nicht bis auf Rennstreckentempo beschleunigen, um Spaß am Schalten zu haben. Als Nachteil wird genannt: Ab etwa 180 cm Körpergröße ermüden die Beine zum Tagesende hin durch die Sitzposition, und das Fahrwerk ist eher auf die Stadt als auf die Rennstrecke abgestimmt. Die Höchstleistung liegt erst bei 15.500 U/min an, und wer es gewohnt ist, im unteren Drehzahlbereich zu fahren, wird das Bike bis dahin als etwas zäh empfinden.

**Für wen geeignet:** Für erfahrene Fahrer, die maximale Emotionen aus der 250cc-Klasse holen wollen und bereit sind, hohe Drehzahlen zu fahren — kein Bike für gemütliches Cruisen im unteren Drehzahlbereich.

**Wo sie sich auf Bali bewährt:** Sie zielt eher auf Erlebnis und Charakter als auf eine konkrete Route ab — gut geeignet dort, wo auch die MT-25 überzeugt (Stadt, Uferpromenade), und auf der Rennstrecke von Weltklasse-Format Mandalika auf der Nachbarinsel Lombok. Längst nicht jeder Verleih erlaubt solche Ausflüge, bei uns ist das aber möglich. Das ist das anspruchsvollste Bike im Fuhrpark — nichts für die ersten Motorrad-Erfahrungen und für große Fahrer nicht ideal für einen ganzen Tag.', 'Kawasaki Ninja ZX-25R — der einzige Serien-Sportler mit 250cc und Reihenvierzylinder', 'Kawasaki Ninja ZX-25R mieten auf Bali: seltener 250cc-Reihenvierzylinder, Quickshifter und für wen sich dieser Sportler eignet.'
  FROM articles a WHERE a.slug = 'kawasaki-ninja-zx-25r-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Yamaha XSR155 — Café-Racer mit Retro-Charakter', 'yamaha-xsr155-test-cafe-racer-mit-retro-charakter', 'Die Yamaha XSR155 ist ein Neo-Retro-Bike mit rundem Scheinwerfer, niedrigem Lenker und Café-Racer-Sitzposition, angetrieben vom familieneigenen 155er-Motor in stärkerer Schaltgetriebe-Abstimmung.', 'Die Yamaha XSR155 ist ein Neo-Retro-Bike: runder Scheinwerfer, niedriger Lenker, Café-Racer-Sitzposition. Derselbe familieneigene 155er-Motor wie bei den Rollern der Baureihe, aber in der Schaltgetriebe-Version stärker abgestimmt. [Yamaha XSR155 im Katalog ansehen](/de/bikes?group=motorcycle&model=yamaha_xsr).

**Technische Daten:**
- Motor: 155 cm³, Flüssigkeitskühlung, SOHC, VVA — dieselbe Basis wie bei der Nmax155, aber anders für das Schaltgetriebe abgestimmt
- Leistung: ca. 19,3 PS bei 10.000 U/min
- Getriebe: 6-Gang-Schaltgetriebe
- Sitzhöhe: ~815 mm — niedrige Café-Racer-Sitzposition
- Gewicht: ~131–134 kg
- Tank: ~10 l

**Was Besitzer sagen:** Das Fahrwerk der XSR155 stammt vom Sportbike R15, daher ist das Bike leicht und sehr direkt in der Kontrolle. Bei sanftem Gasgriff liegt der reale Verbrauch bei bis zu ~50 km/l. Wichtig für alle, die zu zweit fahren wollen: Die Rücksitzbank ist kompakt und hart, einen richtigen Haltegriff für den Sozius gibt es bei vielen Versionen nicht. Ein echter balinesischer Mieter hinterließ eine bezeichnende Bewertung genau zu diesem Modell: Trotz der bescheidenen 155 cm³ „fährt sich das Bike hart" auf balinesischen Straßen, ist hervorragend auf seinen Preis abgestimmt und liegt auf dem lokalen Asphalt so sicher, dass es seiner Meinung nach sogar einer Yamaha R3 in denselben Kurven Konkurrenz machen würde — der Vermieter brachte das Bike zu einer drei Stunden entfernten Fahrt nach Amed, und es hat nicht enttäuscht.

**Für wen geeignet:** Für alle, die Stil und Motorrad-Charakter wollen, aber ohne überschüssige Leistung — ein komfortabler Übergang vom Roller zum Bike mit Schaltgetriebe.

**Wo sie sich auf Bali bewährt:** Canggu und Seminyak — die Retro-Ästhetik des Bikes passt perfekt zur Atmosphäre dieser Gegend; aber laut Erfahrungsberichten meistert es auch längere, kurvige Strecken wie eine Fahrt nach Amed problemlos.', 'Yamaha XSR155 — Café-Racer mit Retro-Charakter', 'Yamaha XSR155 mieten auf Bali: technische Daten, Erfahrungsberichte und für wen sich dieses Neo-Retro-Bike mit Schaltgetriebe eignet.'
  FROM articles a WHERE a.slug = 'yamaha-xsr-155-review-retro-style'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Kawasaki Versys-X 250 — Touring mit Reserven für Schotterpisten', 'kawasaki-versys-x250-test-touring-fuer-schotterpisten', 'Die Kawasaki Versys-X 250 ist ein Enduro-Tourer mit hoher Sitzposition, langhubigem Fahrwerk und größerem Tank – für alle, die auch die Nebenstraßen der Insel erkunden wollen.', 'Die Kawasaki Versys-X 250 ist ein Enduro-Tourer: hohe Sitzposition, langhubiges Fahrwerk, größerer Tank. Ein Bike für alle, die nicht nur auf Asphalt unterwegs sein, sondern auch die Nebenstraßen der Insel erkunden wollen. [Kawasaki Versys-X 250 im Katalog ansehen](/de/bikes?group=motorcycle&model=kawasaki_versys).

**Technische Daten:**
- Motor: 249 cm³, Flüssigkeitskühlung, DOHC, Reihenzweizylinder
- Leistung: ca. 27 PS bei 9700 U/min
- Getriebe: 6-Gang-Schaltgetriebe
- Sitzhöhe: ~845 mm — deutlich höher als bei den übrigen Modellen im Fuhrpark
- Gewicht: ~184 kg
- Tank: ~17 l — einer der größten im Fuhrpark, erhöhte Reichweite
- Windschutzscheibe, Enduro-Stufensitzbank, Position für langes Fahren im Stehen/Sitzen

**Was Besitzer sagen:** Der reale Verbrauch bei ruhiger Fahrt bis 105 km/h liegt bei etwa 27–30 km/l (unabhängig auch von balinesischen Vermietern bestätigt — etwa 3–4 l auf 100 km), was bei einem 17-Liter-Tank eine sehr solide Reichweite ohne Nachtanken ergibt. Geländetauglichkeit ist nicht nur Marketing: Bei einem der ersten Testfahrten kam das Bike sicher durch dichten Matsch, ohne dass das Fahrwerk einmal durchschlug. Die Serien-Sitzbank ist am Anfang hart und braucht etwas „Einfahrzeit". Am wohlsten fühlt sich das Bike im Bereich von 80–110 km/h. Echte balinesische Mieter berichten, dass das Bike problemlos sogar bis zu einem abgelegenen Bergdorf kam und dass die Version mit Schaltgetriebe sich bei einer regnerischen Fahrt in den Norden der Insel bewährt hat. Fertige Routen, die Vermieter selbst empfehlen: Süd-Bali — Ubud — Kintamani, die Bergstraßen im Norden der Insel, die Ostküste bis Amed und Tulamben.

**Für wen geeignet:** Für Mehrtagestouren über die Insel und alle, die sich auf Schotter oder holprigen Abschnitten sicher fühlen wollen. Ausführliche Routen in unseren Blogartikeln: „Ost-Bali mit dem Bike", „Kintamani: Sonnenaufgang am Vulkan Batur", „Bedugul — Munduk — Lovina".

**Wo sie sich auf Bali bewährt:** Auf weiten Strecken — Kintamani, der Norden und Osten der Insel (einschließlich Amed und Tulamben), Nebenstraßen abseits der touristischen Hauptrouten.', 'Kawasaki Versys-X 250 — Touring mit Reserven für Schotterpisten', 'Kawasaki Versys-X 250 mieten auf Bali: technische Daten, Reichweite, Erfahrungsberichte und die besten Routen für Enduro-Touring.'
  FROM articles a WHERE a.slug = 'kawasaki-versys-x250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Suzuki V-Strom 250 — Touring mit Fokus auf Komfort und Windschutz', 'suzuki-v-strom-250-test-komfort-und-windschutz-auf-langstrecken', 'Die Suzuki V-Strom 250 ist ein Adventure-Tourer mit Fokus auf Langstreckenkomfort: breite Windschutzscheibe, aufrechte Sitzposition und weich abgestimmtes Fahrwerk.', 'Die Suzuki V-Strom 250 ist ein Adventure-Tourer mit Fokus auf Langstreckenkomfort: breite Windschutzscheibe, ideal aufrechte Sitzposition, weich abgestimmtes Fahrwerk für lange Etappen ohne Ermüdung. [Suzuki V-Strom 250 im Katalog ansehen](/de/bikes?group=motorcycle&model=suzuki_vstrom250).

**Technische Daten:**
- Motor: 248 cm³, Flüssigkeitskühlung, DOHC, Reihenzweizylinder
- Leistung: ca. 25 PS bei 8000 U/min
- Getriebe: 6-Gang-Schaltgetriebe
- Sitzhöhe: ~800–835 mm je nach Version
- Tank: 12 l

**Was Besitzer sagen:** Der Motor wird in Erfahrungsberichten mit einer Nähmaschine verglichen — geschmeidig, leise, sparsam und zuverlässig. Praktisch alle loben die gut gepolsterte Sitzbank und die Sitzposition „wie bei einem großen Motorrad" bei deutlich leichterer Handhabung. Der reale Verbrauch liegt zwischen 32 und 48 km/l. Eines der eindrucksvollsten Nutzungsbeispiele auf Bali: Ein Mieter nahm die V-Strom für über 40 Tage und fuhr damit bis zur Insel Flores und zurück. Eine praktische Lektion von einem anderen balinesischen Mieter: Das serienmäßige Heckgepäckgitter erwies sich als unzuverlässig unterwegs — das Unternehmen setzte ihn stattdessen auf eine Versys mit richtigen Seitenkoffern um; die Lehre daraus: Wer Gepäck plant, ist mit Koffern besser bedient als mit Seilen am Gepäckgitter. Mieter empfehlen besonders die Richtung Sidemen, den Berg Batur und die Straßen um den östlichsten Punkt Balis, und merken an, dass Verkehr wirklich nur in Uluwatu, Canggu und Ubud spürbar ist — danach beginnen Reisterrassen, Dschungel und Meerblick.

**Für wen geeignet:** Für alle, die auf langen Etappen vor allem Komfort suchen, keinen sportlichen Charakter. Ausführliche Routen in unseren Blogartikeln: „Ost-Bali mit dem Bike", „Sekumpul und die Wasserfälle im Zentralnorden Balis", „Die Vulkane Balis mit dem Bike".

**Wo sie sich auf Bali bewährt:** Dieselbe Nische wie die Versys-X250 — weite Strecken, Sidemen, der Berg Batur, die Ostküste. Wenn viel Gepäck geplant ist — sagen Sie uns einfach Bescheid, und wir bringen Seitenkoffer am Bike an.', 'Suzuki V-Strom 250 — Touring mit Fokus auf Komfort und Windschutz', 'Suzuki V-Strom 250 mieten auf Bali: technische Daten, realer Verbrauch und Erfahrungsberichte von Mietern über Langstreckentouren auf der Insel.'
  FROM articles a WHERE a.slug = 'suzuki-v-strom-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'TVS Ronin 225 — Neo-Retro mit Scrambler-Note', 'tvs-ronin-225-test-neo-retro-mit-scrambler-note', 'Die TVS Ronin 225 ist ein Modern-Classic mit Scrambler-Anklängen: runder LED-Scheinwerfer, hoher Lenker und ebenso souverän in der Stadt wie auf Schotterabzweigungen.', 'Die TVS Ronin 225 ist ein Modern-Classic mit Scrambler-Anklängen: runder LED-Scheinwerfer, hoher Lenker, universelle Geometrie, die sich in der Stadt genauso souverän anfühlt wie auf unbefestigten Abzweigungen von der Hauptstraße. Alle Versionen haben serienmäßig ABS. [TVS Ronin 225 im Katalog ansehen](/de/bikes?group=motorcycle&model=tvs_ronin225).

**Technische Daten:**
- Motor: 225,9 cm³, Ölkühlung, Einzylinder, SOHC, 4 Ventile
- Leistung: ca. 20,4 PS bei 7750 U/min
- Drehmoment: ~19,9 Nm bei 3750 U/min — zieht schon von unten heraus, kein Hochdrehen nötig
- Getriebe: 5-Gang-Schaltgetriebe
- Sitzhöhe: ~795 mm
- Gewicht: ~159 kg
- Tank: ~14 l
- ABS bei allen Versionen (bei der Basisversion einkanalig, bei den höheren zweikanalig)

**Zuverlässigkeit:** TVS ist eine Marke mit sehr langer Geschichte in Indien (Zweiräder werden dort seit den 1980ern gebaut), und die Ronin selbst, obwohl vergleichsweise neu (seit 2022), hat in den Jahren des Einsatzes bereits einen starken Ruf in Sachen Zuverlässigkeit aufgebaut: In Erfahrungsberichten von Besitzern mit über 10.000 km Laufleistung wird der Motor als vorbildlich laufruhig beschrieben, die goldfarbenen USD-Gabeln zeigen hohe Verschleißfestigkeit, und der Zusammenbau bleibt auch nach einem Jahr intensiver Fahrt auf verschiedenen Untergründen ohne Spiel oder Klappern. Zuverlässigkeits- und Wartungskosten-Bewertungen der Ronin gehören in unabhängigen Besitzer-Rankings konstant zu den besten der Klasse.

**Was Besitzer sagen:** Der Motor startet mit dem für Retro-Bikes typischen, satten Klang mit leichter Rauheit. Das hohe Drehmoment im unteren Bereich macht das Bike besonders angenehm im dichten Stadtverkehr. Der reale Verbrauch liegt laut Erfahrungsberichten bei 35–45 km/l. Das Fahrwerk ist weich abgestimmt — es schluckt Unebenheiten in der Stadt gut. Manche Versionen bieten Fahrmodi, darunter einen für Regen — angesichts des balinesischen Klimas praktisch. Ausgezeichnete Fahrdynamik und Optik werden in Erfahrungsberichten regelmäßig als Stärke des Modells genannt.

**Für wen geeignet:** Für alle, die ein vielseitiges Motorrad für den Alltag wollen — ohne die Härte eines Sportbikes, aber mit Sicherheitsreserve auf Schotter.

**Wo sie sich auf Bali bewährt:** Dank ihres Neo-Retro-Looks genauso gut in Canggu/Seminyak wie auf unbefestigten Nebenwegen zu den Reisterrassen.', 'TVS Ronin 225 — Neo-Retro mit Scrambler-Note', 'TVS Ronin 225 mieten auf Bali: technische Daten, Zuverlässigkeit und Erfahrungsberichte zu diesem Neo-Retro-Bike mit Scrambler-Charakter.'
  FROM articles a WHERE a.slug = 'tvs-ronin-225-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Keeway Road Falcon 250 — klassischer Cruiser zum Einstiegspreis', 'keeway-road-falcon-250-test-klassischer-cruiser-zum-einstiegspreis', 'Die Keeway Road Falcon 250 ist ein klassischer Cruiser mit langer Silhouette und niedriger Sitzhöhe zum Einstiegspreis der Klasse. Ein ganz neues Modell – erst 2026 auf den Markt gekommen.', 'Die Keeway Road Falcon 250 — lange Silhouette, niedrige Sitzposition, dezentes Schwarz und ein Charakter, der sich an großen amerikanischen Cruisern orientiert, aber auf einer kompakten 250er-Basis. Ein ganz neues Modell auf dem Markt — erst 2026 erschienen, weshalb es bisher kaum Nutzer- und Bali-Vermietungserfahrungen gibt. [Keeway Road Falcon 250 im Katalog ansehen](/de/bikes?group=motorcycle&model=keeway_roadfalcon250).

**Technische Daten:**
- Motor: 248 cm³, Reihenzweizylinder, 4-Takt, 4 Ventile, SOHC, Flüssigkeitskühlung
- Leistung: ca. 24,6 PS bei 8000 U/min
- Drehmoment: ~23,4 Nm bei 6500 U/min
- Getriebe: 6-Gang-Schaltgetriebe mit Slipper-Kupplung
- Sitzhöhe: ~698 mm — eine der niedrigsten Sitzpositionen im Fuhrpark
- Bodenfreiheit: ~186 mm
- Tank: 14 l
- Bremsen: vorne 300-mm-Scheibe (2-Kolben-Sattel), hinten 260 mm
- 5-Zoll-TFT-Display, integrierter Bluetooth-Lautsprecher — eine seltene Option in dieser Klasse
- Direkte Navigationsanzeige im Kombiinstrument — wie bei der XMAX250 braucht man bei diesem Modell überhaupt keine Handyhalterung

**Was Besitzer sagen:** Das Modell wird direkt mit Bikes im Harley-Davidson-Stil und mit der Honda Rebel verglichen — der markante „Tank-Buckel" vorne und die gesamte Silhouette lehnen sich bewusst an große amerikanische Cruiser an, und in der indonesischen Presse gibt es direkte Vergleichstests der Road Falcon gegen die Honda Rebel. Der integrierte Bluetooth-Lautsprecher am Lenker ist eine Seltenheit für Cruiser dieser Klasse. Die Slipper-Kupplung mildert das Zurückschalten ab — nützlich auf den hügeligen Abschnitten Balis. Besonders hervorgehoben wird, dass es sich um ein sehr wendiges Bike mit überraschend kleinem Wenderadius handelt — bei der langen Cruiser-Silhouette ist das nicht offensichtlich, macht sich in der Praxis aber bemerkbar.

**Für wen geeignet:** Für alle, die den klassischen Cruiser-Look und eine entspannte Sitzposition wollen — dank der sehr niedrigen Sitzbank besonders angenehm für kleinere Fahrer.

**Wo sie sich auf Bali bewährt:** Gemütliche Küstenrouten — Sanur, Nusa Dua — aber nicht nur: Unsere Kunden waren damit auch an Orten unterwegs, die sonst klassischen Enduro-Tourern wie der Versys und der V-Strom vorbehalten sind. Das heißt, auch weite Strecken entlang der gesamten Nordküste Balis schafft das Bike trotz seines Cruiser-Looks.', 'Keeway Road Falcon 250 — klassischer Cruiser zum Einstiegspreis', 'Keeway Road Falcon 250 mieten auf Bali: technische Daten, Vergleich mit der Honda Rebel und für wen sich dieser Cruiser eignet.'
  FROM articles a WHERE a.slug = 'keeway-road-falcon-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Morbidelli C252V — V-Twin-Cruiser mit italienischem Namen', 'morbidelli-c252v-test-v-twin-cruiser-mit-italienischem-namen', 'Die Morbidelli C252V ist der zweite Cruiser im Fuhrpark, aber mit echtem V2-Motor statt Reihenzweizylinder und mit Riemenantrieb.', 'Der zweite Cruiser im Fuhrpark, aber vom Charakter her grundlegend anders als die Road Falcon: Die Morbidelli hat einen echten V2-Motor statt eines Reihenzweizylinders, daher der andere, „bassigere" Klang und die Vibration, die viele Cruiser-Fahrer als Teil des Vergnügens ansehen. Die Marke Morbidelli trägt einen italienischen Namen mit echter Rennsportgeschichte (Weltmeistertitel in den 125cc- und 250cc-Grand-Prix-Klassen in den 1970ern) — die Rechte daran gehören seit 2024 demselben Konzern, dem auch Keeway gehört. Das ist also kein Namensvetter, sondern eine offiziell wiederbelebte Marke auf neuer technischer Basis. [Morbidelli C252V im Katalog ansehen](/de/bikes?group=motorcycle&model=morbidelli_c252v).

**Technische Daten:**
- Motor: 249 cm³, V-Zweizylinder (V-Twin), 4-Takt, 8 Ventile, SOHC, Flüssigkeitskühlung
- Leistung: ca. 25,5 PS bei 9000 U/min
- Drehmoment: 25 Nm bei 5500 U/min
- Getriebe: 6-Gang-Schaltgetriebe mit Slipper-Kupplung
- Antrieb: Riemen (Belt Drive) — eine Seltenheit für diese Klasse. In der Praxis bedeutet das: kein Schmieren und regelmäßiges Nachspannen wie bei einer Kette, und der Riemen rostet auch nicht im Regen
- Sitzhöhe: 690 mm — eine der niedrigsten im Fuhrpark
- Gewicht: ~200 kg
- Tank: 15,5 l
- Bodenfreiheit: 173 mm
- Bremsen: vorne 320-mm-Scheibe (4-Kolben-Sattel), hinten 260 mm (2-Kolben); zweikanaliges Bosch-ABS und Traktionskontrolle serienmäßig
- Vordergabel invertiert (USD), 37 mm, 115 mm Federweg; hinten zwei Federbeine mit 5-stufig verstellbarer Federvorspannung
- Höchstgeschwindigkeit — angegeben 125 km/h

**Was Besitzer sagen:** Das Modell ist noch sehr neu auf dem Markt, daher gibt es noch keine jahrelange Nutzungshistorie, aber die ersten Testfahrten in der Presse loben die überraschend leichte Handhabung für einen Cruiser mit so langem Radstand — der Wenderadius verrät die Abmessungen des Bikes nicht. Der V2-Motor wird als optisch beeindruckend beschrieben (gut sichtbar unter dem Tank, mit nachgebildeten Kühlrippen und verchromter Verkleidung) und deutlich basslastiger klingend als typische 250er-Reihenzweizylinder.

**Für wen geeignet:** Für alle, die genau den V-Twin-Charakter eines Cruisers wollen (nicht den Reihenzweizylinder wie bei der Road Falcon) — eine ausgeprägtere Vibration und einen basslastigen Motorsound, dazu einen Riemen statt Kette — kein Schmieren, kein Nachspannen, kein Rosten im Regen.

**Wo sie sich auf Bali bewährt:** Dieselbe Nische wie die Road Falcon — gemütliche Küstenrouten, Sanur, Nusa Dua; der Riemen und die niedrige Sitzposition machen sie besonders angenehm für alle, die einen entspannten Cruiser-Stil ohne Sorgen um die Kette wollen.', 'Morbidelli C252V — V-Twin-Cruiser mit italienischem Namen', 'Morbidelli C252V mieten auf Bali: V-Twin-Motor, Riemenantrieb, technische Daten und der Unterschied zur Road Falcon.'
  FROM articles a WHERE a.slug = 'morbidelli-c252v-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Honda CBR250RR — Vollverkleidung und der sportlichste unter den verkleideten 250ern im Fuhrpark', 'honda-cbr250rr-test-vollverkleidetes-sportbike', 'Die Honda CBR250RR ist der einzige vollverkleidete Sportler im Fuhrpark – die Topversion mit Quickshifter und ABS und eines der technologisch fortschrittlichsten Bikes der 250cc-Klasse in Indonesien.', 'Der einzige vollverkleidete Sportler im Fuhrpark (im Gegensatz zu MT-25 und ZX-25R, die „nackte" Naked Bikes/Streetfighter sind) — die Honda CBR250RR gilt seit ihrem Debüt 2016 als einer der technologischen Vorreiter der 250cc-Klasse in Indonesien. [Honda CBR250RR im Katalog ansehen](/de/bikes?group=motorcycle&model=honda_cbr250rr).

**Technische Daten (Topversion SP Quick Shifter mit ABS — genau diese steht im Fuhrpark):**
- Motor: 249,7 cm³, Flüssigkeitskühlung, DOHC, Reihenzweizylinder, 8 Ventile, mit Modifikationen der Topversion (leichtere Kurbelwelle, neue Ventilfedern, geänderter Zylinderkopf)
- Leistung: ~41 PS bei 13.000 U/min
- Drehmoment: ~25 Nm bei 11.000 U/min
- Getriebe: 6-Gang-Schaltgetriebe
- Sitzhöhe: ~790 mm
- Gewicht: ~168 kg
- ABS, vollständige LED-Beleuchtung, digitales Kombiinstrument, Throttle-by-Wire (elektronische Drosselklappe ohne Seilzug)
- Quickshifter mit 4 einstellbaren Modi (Hoch- und Runterschalten, nur Hochschalten, nur Runterschalten, aus) — Gangwechsel ohne Kupplungsbetätigung
- Slipper-Kupplung mit Anti-Hopping-Funktion
- Vordergabel invertiert (USD), Typ SFF-Big Piston
- 3 Fahrmodi: Comfort, Sport, Sport+
- Angegebene Beschleunigung 0–200 m in 8,65 s, Höchstgeschwindigkeit bis zu 172 km/h

**Was Besitzer sagen:** Die CBR250RR wird immer wieder als eines der technologisch am besten ausgestatteten Bikes der 250cc-Klasse in Indonesien genannt — die Version mit Quickshifter vermittelt ein echtes Rennstreckengefühl, das für diesen Hubraum selten ist.

**Für wen geeignet:** Für alle, die das volle Sportbike-Erlebnis wollen — Vollverkleidung, sportliche Sitzposition „auf dem Tank liegend" und Technik auf MotoGP-Quickshifter-Niveau.

**Wo sie sich auf Bali bewährt:** Wie bei der ZX-25R — Stadt, Uferpromenade, für Erlebnis und Charakter statt eine konkrete Route; angesichts ihrer Rennstrecken-Abstammung entfaltet sie sich auch auf der Rennstrecke Mandalika auf Lombok hervorragend.', 'Honda CBR250RR — Vollverkleidung und der sportlichste unter den verkleideten 250ern im Fuhrpark', 'Honda CBR250RR mieten auf Bali: Topversion mit Quickshifter, technische Daten und für wen sich das volle Sportbike-Erlebnis eignet.'
  FROM articles a WHERE a.slug = 'honda-cbr250rr-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'Honda CB150X — günstiger Adventure-Look auf Basis eines 150er-Motors', 'honda-cb150x-test-guenstiger-einstieg-ins-adventure-segment', 'Die Honda CB150X ist ein günstiger Einstieg in den Adventure-Look mit 150er-Motor, ernstzunehmendem Fahrwerk für ihre Klasse und dem geringsten Gewicht unter den Motorrädern im Fuhrpark.', 'Die CB150X ist nicht dasselbe wie die 250er Versys-X250 und V-Strom250: Sie ist ein günstiger Einstieg in den Adventure-Look mit einem bescheidenen 150er-Einzylindermotor, aber mit einem für diese Klasse wirklich ernstzunehmenden Fahrwerk (Bodenfreiheit fast wie bei der CB500X). Dank des für ein Motorrad sehr geringen Gewichts (139 kg) reicht der 150er-Motor völlig aus — das Bike hebt das Vorderrad leicht an und hält eine überzeugende Dynamik im gesamten Geschwindigkeitsbereich, nicht nur bei niedrigem Tempo, wie man angesichts des einen Zylinders und des bescheidenen Hubraums vermuten könnte. [Honda CB150X im Katalog ansehen](/de/bikes?group=motorcycle&model=honda_cb150x).

**Technische Daten:**
- Motor: 149,16 cm³, Einzylinder, Flüssigkeitskühlung, DOHC, 4 Ventile
- Leistung: ~15,6 PS bei 9000 U/min
- Drehmoment: ~13,8 Nm bei 7000 U/min
- Getriebe: 6-Gang-Schaltgetriebe
- Sitzhöhe: 817 mm
- Bodenfreiheit: 181 mm — fast wie bei der deutlich größeren CB500X
- Gewicht: ~139 kg — das leichteste Motorrad (kein Roller) im Fuhrpark
- Tank: 12 l
- Vordergabel invertiert (USD), Showa SFF-BP 37 mm, hinten Pro-Link-Monoshock
- Wellenförmige (Wavy) Bremsscheiben vorne und hinten
- Vollständig digitales Kombiinstrument mit Echtzeit-Verbrauchsanzeige

**Für wen geeignet:** Für alle, die den Adventure-Look und eine hohe Sitzposition wollen, aber noch nicht bereit für Gewicht und Leistung eines vollwertigen 250er-Tourers sind — eine gute Zwischenstufe auf dem Weg von Stadtbikes zu ernsthafteren Modellen.

**Wo sie sich auf Bali bewährt:** Dieselbe Logik wie bei der ADV160 — Nebenstraßen, nicht perfekter Asphalt, aber von Sitzposition und Charakter her ist das schon ein vollwertiges Motorrad mit Schaltgetriebe, kein Roller.', 'Honda CB150X — günstiger Adventure-Look auf Basis eines 150er-Motors', 'Honda CB150X mieten auf Bali: technische Daten, Bodenfreiheit und für wen sich dieses günstige Adventure-Bike eignet.'
  FROM articles a WHERE a.slug = 'honda-cb150x-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'de', 'PCX160 vs. ADV160 vs. Nmax — wie man sich zwischen den dreien entscheidet', 'pcx160-vs-adv160-vs-nmax-welcher-roller-passt-zu-dir', 'PCX160, ADV160 und Nmax – wie man sich zwischen den drei beliebtesten Rollern im Fuhrpark entscheidet: Unterschiede bei Stauraum, Fahrdynamik und Sitzposition.', 'Ehrlich gesagt unterscheiden sich diese drei Modelle vor allem optisch und dadurch, woran der jeweilige Fahrer gewöhnt ist — kurz gesagt: Geschmackssache. Der wirklich wichtige praktische Unterschied ist vor allem die Stauraumgröße: Die Nmax passt zu allen, die bereit sind, etwas Stauraum zu opfern, weil sie ihre Sitzposition und Fahrdynamik lieben. Was die reine Fahrdynamik angeht, scherzt man im Team: Wer wirklich „Turbo"-Ansprechverhalten will, sollte aus dieser Baureihe lieber die ADV nehmen — sie fühlt sich subjektiv spritziger an als das Modell mit „Turbo" im Namen.

Idealerweise sollte man, bevor man sich für längere Zeit auf ein Bike festlegt, jedes davon 5 Tage bis einen Monat fahren, um den Unterschied wirklich zu spüren. 1–3 Tage reichen oft nicht aus, um ein Bike wirklich kennenzulernen.

Modellkarten: [Honda PCX160](/de/bikes?category=honda_pcx160), [Honda ADV160](/de/bikes?category=honda_adv160), [Yamaha Nmax](/de/bikes?category=yamaha_nmax155).', 'PCX160 vs. ADV160 vs. Nmax — wie man sich zwischen den dreien entscheidet', 'Vergleich von Honda PCX160, Honda ADV160 und Yamaha Nmax im Mietpark auf Bali – welcher Roller passt zu welchem Einsatzzweck.'
  FROM articles a WHERE a.slug = 'pcx160-vs-adv160-vs-nmax-how-to-choose'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Honda PCX160 — confort et volume de rangement au quotidien', 'honda-pcx160-confort-et-volume-de-rangement-au-quotidien', 'Le Honda PCX160 est le choix le plus polyvalent pour un scooter confortable sans sacrifier le volume de rangement. Le modèle préféré des couples et des voyageurs partant avec une valise.', 'Le Honda PCX160 est le choix le plus polyvalent pour qui veut un scooter confortable sans faire de compromis sur le rangement. C''est le modèle que choisissent le plus souvent les couples et les voyageurs partant avec une valise ou un gros sac. [Voir le Honda PCX160 dans notre catalogue](/fr/bikes?category=honda_pcx160).

**Fiche technique :**
- Moteur : 156,9 cm³, refroidissement liquide, eSP+
- Puissance : environ 15,8 ch à 8500 tr/min
- Transmission : variateur (CVT), sans passage de vitesses
- Hauteur de selle : ~764 mm — confortable pour presque tous les gabarits
- Réservoir : 8,1 l
- Coffre sous selle : ~30 l — un casque intégral y tient, avec encore de la place pour d''autres affaires
- Smart key, éclairage LED, prise USB puissante, tableau de bord numérique
- Chez nous, vous trouverez un large choix de coloris personnalisés, différents des teintes standard

**Options :** sur le PCX160, on peut installer un top-case SHAD de 44 l à l''arrière — pratique si le coffre sous selle ne suffit pas. Pour en savoir plus sur les options disponibles, voir notre article [« Options de location qui valent la peine : casques et top-case confort »](/fr/blog/options-de-location-qui-valent-la-peine-casques-et-top-case-confort).

**Ce qu''en disent les propriétaires :** la consommation réelle rapportée dans les avis tourne autour de 40-50 km/l, ce qui rend les balades sur l''île pratiquement gratuites. La réputation de fiabilité du modèle est presque légendaire — sur les forums, on compare le PCX à une tondeuse à gazon : ça démarre et ça roule pendant des années sans surprise. Un détail pratique pour les locataires : le smart key est pratique, mais le remplacer en cas de perte coûte environ 1 million de roupies — mieux vaut donc ne pas le perdre. Pour comprendre comment il fonctionne, voir notre article [« Comment démarrer et utiliser le smart key de votre scooter de location »](/fr/blog/comment-demarrer-et-utiliser-le-smart-key-de-votre-scooter-de-location). Avec un passager, la reprise pour doubler à vitesse élevée diminue sensiblement — pas un problème en ville, mais à garder en tête sur route.

**Où il donne le meilleur de lui-même à Bali :** grâce à sa roue avant de 14 pouces, il tient bien la route — confortable à Canggu, Seminyak, Sanur, et pour les trajets du quotidien à Denpasar.', 'Honda PCX160 — confort et volume de rangement au quotidien', 'Fiche technique, consommation, avis propriétaires et options pour le Honda PCX160 en location à Bali — où il excelle et à qui il convient.'
  FROM articles a WHERE a.slug = 'honda-pcx160-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Honda ADV160 — pour les routes accidentées et les longues échappées', 'honda-adv160-pour-les-routes-accidentees-et-les-longues-echappees', 'Le Honda ADV160 reprend le moteur fiable du PCX160 dans une autre carrosserie : position plus haute, garde au sol plus généreuse, plus à l''aise sur l''asphalte abîmé et les pistes en terre.', 'Le Honda ADV160 reprend le même moteur fiable que le PCX160, mais dans une autre carrosserie : position plus haute, garde au sol plus importante, plus à l''aise sur l''asphalte abîmé et les pistes en terre. [Voir le Honda ADV160 dans notre catalogue](/fr/bikes?category=honda_adv160).

**Fiche technique :**
- Moteur : 156,9 cm³, refroidissement liquide, eSP+ (le même que sur le PCX160)
- Puissance : environ 15,8 ch
- Transmission : variateur (CVT)
- Hauteur de selle : ~795 mm — plus haute que sur les scooters urbains, mieux adaptée aux grands gabarits et à ceux qui aiment une position de conduite surélevée
- Garde au sol : ~165 mm — nettement supérieure à la moyenne
- Coffre sous selle : ~30 l — un casque intégral y tient, avec encore de la place pour d''autres affaires
- Bulle réglable — 2 positions : relevée (look agressif) et abaissée (usage urbain)
- Tableau de bord semi-numérique, prise USB puissante, smart key
- Chez nous, vous trouverez un large choix de coloris personnalisés, différents des teintes standard

**Options :** tout comme sur le PCX160, on peut installer un top-case SHAD de 44 l à l''arrière. Pour en savoir plus, voir notre article [« Options de location qui valent la peine : casques et top-case confort »](/fr/blog/options-de-location-qui-valent-la-peine-casques-et-top-case-confort).

**Ce qu''en disent les propriétaires :** la sobriété est le deuxième gros atout de ce moteur — la consommation réelle rapportée dans les avis se situe autour de 34-38 km/l, on fait rarement le plein même en conduite dynamique. L''ADV160 est d''ailleurs l''un des scooters les plus vifs de la gamme PCX-Nmax-ADV, alors que le moteur est le même que sur le PCX160 — seul le réglage change. La garde au sol se révèle vraiment utile sur les pistes en terre et l''asphalte abîmé, mais les propriétaires préviennent honnêtement : c''est un style adventure urbain, pas un vrai tout-terrain — sur les gros cailloux et les irrégularités sérieuses, la garde au sol reste insuffisante.

**Où il donne le meilleur de lui-même à Bali :** Ubud et ses environs (rizières en terrasses, routes secondaires), Munduk et ses cascades, les zones vallonnées d''Uluwatu et de la péninsule de Bukit — le relief et l''état de la route y varient, et l''ADV160 pardonne davantage qu''un scooter urbain, mais le vrai hors-piste engagé n''est pas son terrain de jeu.', 'Honda ADV160 — pour les routes accidentées et les longues échappées', 'Fiche technique, consommation et avis propriétaires du Honda ADV160 en location à Bali — là où son style adventure urbain prend tout son sens.'
  FROM articles a WHERE a.slug = 'honda-adv-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Yamaha Nmax — New (Gen 2), Neo (Gen 3) et Turbo', 'yamaha-nmax-new-neo-et-turbo-les-differences', 'Le Nmax de notre flotte n''est pas un seul modèle, mais plusieurs générations et finitions sous un même nom : New, Neo et Turbo. On décrypte leurs vraies différences.', 'Le « Nmax » de notre flotte n''est pas un modèle unique, mais plusieurs générations et finitions réunies sous un même nom. New et Neo partagent exactement le même moteur et la même transmission — ce sont juste deux générations différentes de la gamme (Gen 2 et Gen 3). Le Turbo, lui, c''est une autre histoire, avec une transmission électronique aux réglages différents. [Voir le Yamaha Nmax dans notre catalogue](/fr/bikes?category=yamaha_nmax155).

**Nmax New (Gen 2) :**
- Moteur : 155 cm³, Blue Core, VVA, SOHC 4 soupapes
- Puissance : ~15 ch à 8000 tr/min
- Transmission : variateur (CVT) classique à galets
- Poids : ~132 kg
- Réservoir : 7,1 l

**Nmax Neo (Gen 3) :**
- Même moteur Blue Core VVA de 155 cm³ que le New, identique en cylindrée et en conception — seuls le look, la génération et la finition changent, pas la mécanique
- Puissance : ~15 ch à 8000 tr/min
- Transmission : variateur classique
- Poids : ~130 kg
- Deux versions : Neo (de base) et Neo S (+ système Smart Key)

**Nmax « Turbo » :**
- Même cylindrée de moteur que sur le New/Neo
- La grande différence, c''est le YECVT (Yamaha Electric CVT) : dans les grandes lignes, le même principe de variateur, mais avec une gestion électronique au lieu de galets purement mécaniques. C''est davantage une question de ressenti marketing et de réglages électroniques de conduite qu''une transmission fondamentalement différente
- Deux modes de conduite T-Mode/S-Mode + « rapports » virtuels Y-Shift (Low/Medium/High) — une simulation de passage de vitesses, comme en voiture
- Poids : ~133-135 kg selon la version
- Trois versions : Turbo (de base), Turbo Tech Max (écran TFT, port USB-C, selle spécifique), Turbo Tech Max Ultimate (le haut de gamme)
- Précision importante : le « Turbo » du nom renvoie à l''électronique et à la sensation de réactivité, pas à un vrai turbocompresseur sur le moteur
- Chez nous, vous trouverez un large choix de coloris personnalisés, différents des teintes standard

**Ce qu''en disent les propriétaires :** le moteur (quelle que soit la génération) est qualifié d''« increvable » dans les avis — la fiabilité est l''un des grands points forts de la gamme. La sobriété est aussi un atout fort : le même moteur économique de 155 cm³ que sur les autres modèles de la famille (PCX160, ADV160) maintient une consommation raisonnable en usage réel, on fait rarement le plein. Un détail intéressant côté rangement : les chiffres annoncés ne sont pas modestes, mais la forme du coffre fait qu''un casque intégral n''y tient pas toujours. Côté bonnes surprises, il y a un compartiment séparé pour le téléphone et le portefeuille sous le carénage gauche du guidon. Dans les avis des locataires à Bali, on salue particulièrement la reprise dans les montées (« tanjakan ») et la suspension souple sur les longs trajets — par exemple jusqu''à Uluwatu. L''ABS et les pneus tubeless larges sont cités comme un vrai plus dans plusieurs guides pour touristes, justement à cause des averses tropicales fréquentes et des obstacles soudains sur la route comme les chiens — les freins ne bloquent pas la roue en cas de freinage brusque.

**Où il donne le meilleur de lui-même à Bali :** aussi à l''aise dans la circulation urbaine (Canggu, Seminyak) que sur les trajets de moyenne distance, y compris jusqu''à Uluwatu — bonne stabilité en virage et sous la pluie. Valable pour toutes les versions de la même façon — la géométrie et la position de conduite sont quasiment identiques entre elles.', 'Yamaha Nmax — New (Gen 2), Neo (Gen 3) et Turbo', 'Yamaha Nmax en location à Bali : les différences entre New, Neo et Turbo, fiche technique et vrais avis de propriétaires.'
  FROM articles a WHERE a.slug = 'yamaha-nmax-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Yamaha XMAX250 — Connected et Tech Max : même mécanique, finitions différentes', 'yamaha-xmax250-connected-et-tech-max-les-differences', 'Le Yamaha XMAX250 est le scooter le plus puissant de la gamme, aussi à l''aise sur les longues distances qu''en ville. Notre flotte propose les versions Connected et Tech Max, avec une mécanique identique.', 'Le Yamaha XMAX250 est le scooter le plus puissant de la gamme. Beaucoup adorent cette grosse bête, et si tout le monde s''accorde à dire qu''il excelle sur les longues distances, pour beaucoup, rien ne vaut non plus pour les petits trajets en ville. Dans notre flotte, le modèle existe en deux versions — Connected et Tech Max — et il faut bien comprendre une chose : techniquement, c''est la même moto, seule la finition change. [Voir le Yamaha XMAX250 dans notre catalogue](/fr/bikes?category=yamaha_xmax250).

**Fiche technique (identique pour Connected et Tech Max — moteur et partie-cycle strictement les mêmes) :**
- Moteur : 250 cm³, monocylindre, refroidissement liquide, SOHC 4 soupapes, Blue Core, vilebrequin forgé monobloc (one-piece forged crankshaft)
- Puissance : 16,8 kW à 7000 tr/min
- Couple : 24,3 Nm à 5500 tr/min
- Transmission : variateur (CVT)
- Hauteur de selle : 795 mm
- Poids : ~181 kg
- Réservoir : 13 l
- Coffre sous selle : 44,9 l — vraiment spacieux, deux casques intégraux y tiennent avec encore de la place pour des affaires. Détail important : il faut parfois orienter le casque intégral d''une certaine façon pour qu''il rentre correctement
- ABS, contrôle de traction (TCS), Emergency Stop Signal (feux stop clignotants en freinage d''urgence), smart key avec Answer Back System (signal pour retrouver le scooter sur un parking), prise électrique pour recharger le téléphone
- Sur le Connected, le pare-brise est fixe, non réglable. Le réglage du pare-brise est une exclusivité Tech Max (voir plus bas)
- Garantie Yamaha Indonesia : 5 ans / 50 000 km sur le cadre, les composants du système d''alimentation, le cylindre et le piston

**L''application Y-Connect — un détail important qui mérite une explication à part pour le locataire :**

Pour la version XMAX Connected, la connexion à l''application est disponible :

📱 À télécharger ici :
https://apps.apple.com/app/id1495921872
https://apps.apple.com/app/id1585591110

Ce que permet la connexion :
• Réception des appels entrants depuis le guidon
• Contrôle de la musique depuis le guidon
• Navigation affichée dans votre langue
• Intégration pratique avec votre smartphone

**Connected vs Tech Max — quelle est la différence :**

La différence la plus importante — et la plus chère — c''est la selle. Sur le Tech Max, ce n''est pas juste « une autre couture » : c''est une selle conçue spécifiquement par MBK (la marque française qui appartient à Yamaha et se spécialise justement dans les scooters européens), la fameuse « Comfort Seat ». À l''intérieur : une mousse haute densité (high-density foam) et des renforts latéraux (bolster) pensés spécifiquement pour les trajets de plusieurs heures — la selle maintient la posture et réduit la fatigue lombaire sur les longs trajets, ce n''est pas juste plus moelleux au toucher. Au-dessus : simili-cuir avec inserts façon daim et surpiqûres fil doré, plus une garniture chromée. Dans les avis, les propriétaires citent justement la selle comme la principale raison de payer le supplément pour le Tech Max, pas la couleur ou les logos.

Les autres différences sont bien réelles, mais moins importantes — en coût comme en impact — que la selle :
- Coloris exclusif (Magma Black sur les modèles précédents, Ceramic Grey depuis 2025)
- Trappe du coffre sous selle en simili-cuir avec finition daim et surpiqûres dorées (assortie à la selle)
- Repose-pieds en aluminium, garniture chromée, logos spécifiques et texture des poignées Tech Max
- Sur le millésime 2025 du Tech Max apparaît la seule différence vraiment fonctionnelle (pas seulement esthétique) : le pare-brise à réglage électrique (Electric Adjustable Screen), utilisable même en roulant pour l''ajuster rapidement à ses sensations, plus un tableau de bord TFT actualisé ; sur le Connected, comme indiqué plus haut, le pare-brise n''est tout simplement pas réglable

L''écart de prix sur le marché indonésien est d''environ 5 millions de roupies pour la version Tech Max, et cet argent va avant tout dans la selle.

**Ce qu''en disent les propriétaires :** le moteur tire confortablement jusqu''à 100-110 km/h, au-delà il commence à « s''essouffler » — ce n''est pas une machine faite pour l''accélération pure, mais pour une allure de croisière stable. Le club indonésien des propriétaires de XMAX a organisé le tout premier tour du nouveau modèle directement à Bali dès 2017 — itinéraire Denpasar → Ubud → Kintamani → Besakih → Klungkung → Gianyar → voie rapide Ida Bagus Mantra et retour ; sur les portions sinueuses d''Ubud et de Kintamani, les participants ont testé le contrôle de traction, et sur la portion rectiligne de la voie rapide à péage Ida Bagus Mantra, ils sont montés jusqu''à 140 km/h.

Des itinéraires tout prêts pour le XMAX250 à Bali, cités par les motards eux-mêmes : côte sud — Canggu → Uluwatu (par Jalan Bali Cliff) → plage de Pandawa → GWK ; itinéraire montagne — Denpasar → Ubud → Kintamani → lac Batur → Munduk ; itinéraire est — Sanur → Candidasa → Sidemen → Virgin Beach. Itinéraires détaillés et points sur la carte — dans nos articles de blog « La péninsule de Bukit à moto », « Kintamani : lever de soleil sur le volcan Batur » et « L''est de Bali à moto » (où l''on retrouve aussi Virgin Beach) — à paraître prochainement.

**À qui il convient :** pour des sorties d''une journée ou de plusieurs jours sur l''île, où comptent la réserve de puissance pour doubler et grimper, ainsi que le confort sur les longs tronçons de route. Côté usage quotidien aussi, c''est l''un des scooters les plus demandés, aussi bien par les touristes que par les résidents de longue durée à Bali.

**Où il donne le meilleur de lui-même à Bali :** les itinéraires au-delà du sud de l''île — Kintamani et le volcan Batur, Amed, Lovina, Sidemen, la côte est. Mais là encore, c''est une question de goût — certains adorent rouler avec le plus gros tour-enduro possible même dans les embouteillages de Canggu, et ils ne sont pas rares.', 'Yamaha XMAX250 — Connected et Tech Max : même mécanique, finitions différentes', 'Yamaha XMAX250 en location à Bali : différences entre Connected et Tech Max, fiche technique, application Y-Connect et itinéraires sur l''île.'
  FROM articles a WHERE a.slug = 'yamaha-xmax250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Yamaha MT-25 — Gen 2 et Gen 3 : look différent, même moteur', 'yamaha-mt25-gen-2-et-gen-3-look-different-meme-moteur', 'Le Yamaha MT-25 est un streetfighter compact pour qui veut sentir l''accélération et la réactivité d''une moto. Notre flotte compte des Gen 2 et des Gen 3, nés du restylage de 2025.', 'Le Yamaha MT-25 est un streetfighter compact pour qui veut ressentir l''accélération et la réactivité d''une moto, pas juste aller du point A au point B. C''est une moto avec un vrai caractère — de nombreux professionnels et passionnés la citent comme l''une de leurs motos préférées dans sa catégorie, aussi bien pour la dynamique que pour la position de conduite ou le look. Boîte manuelle et position de conduite agressive : voilà ce qui distingue fondamentalement ce modèle des scooters de notre flotte. En 2025, Yamaha Indonesia a lancé un restylage marquant (« Gen 3 »), si bien qu''on peut trouver côte à côte, dans notre flotte, des motos à l''ancien et au nouveau look sous le même nom de modèle. [Voir le Yamaha MT-25 dans notre catalogue](/fr/bikes?group=motorcycle&model=yamaha_mt25).

**Fiche technique commune (le moteur lui-même n''a pas changé entre les générations) :**
- Moteur : 249,55 cm³, refroidissement liquide, DOHC, bicylindre parallèle (2 cylindres), 8 soupapes
- Puissance : environ 35,5 ch à 12 000 tr/min
- Couple : ~22,6 Nm à 10 000 tr/min
- Boîte : mécanique à 6 rapports
- Hauteur de selle : ~780 mm
- Réservoir : ~14 l

**Gen 2 (mise à jour ~2019 — le look « classique » le plus reconnaissable du MT-25) :**
- Un seul disque de frein avant
- Pas d''embrayage assist-slipper, pas d''ABS
- Poids : ~165-167 kg

**Gen 3 (restylage 2025, positionné par Yamaha comme « Hypernaked » — selon le site officiel de Yamaha Indonesia) :**
- Nouveau phare agressif dans l''esprit de la gamme MT-07/série R — optique anguleuse, presque « extraterrestre », par opposition au phare rond de la Gen 1 (la Gen 2 avait déjà abandonné la forme ronde, mais la Gen 3 a sa propre géométrie, encore plus tranchante)
- ABS — apparu pour la première fois sur le MT-25 avec la Gen 3
- Embrayage assist-slipper — plus doux lors des rétrogradages appuyés
- Y-Connect (application Bluetooth) via un module CCU — une première pour une moto assemblée en Indonésie
- Big Bike Switch 3-en-1 — un bloc de commodos compact et unifié, dans l''esprit des « grosses » motos Yamaha
- Tableau de bord entièrement numérique avec indicateur du moment optimal de passage de vitesse (shift timing light)
- Prise électrique pour recharger ses appareils
- Poids : ~169 kg — un peu plus que la Gen 2, à cause du nouvel équipement

**Où elle donne le meilleur d''elle-même à Bali :** Canggu et Seminyak — les accélérations courtes et franches dans la circulation urbaine, et les balades du soir en bord de mer, là où le caractère de la moto s''exprime le mieux.', 'Yamaha MT-25 — Gen 2 et Gen 3 : look différent, même moteur', 'Yamaha MT-25 en location à Bali : différences entre Gen 2 et Gen 3, fiche moteur et là où le caractère streetfighter s''exprime le mieux.'
  FROM articles a WHERE a.slug = 'yamaha-mt25-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Kawasaki Ninja ZX-25R — le seul sportbike 250 cm³ de série avec un 4 cylindres en ligne', 'kawasaki-ninja-zx-25r-le-seul-4-cylindres-en-ligne-250cc', 'Le Kawasaki Ninja ZX-25R est le seul sportbike 250 cm³ de série équipé d''un 4 cylindres en ligne. Caractère haut-régime et quickshifter d''origine.', 'Le Ninja ZX-25R occupe une place unique dans la catégorie 250 cm³ : c''est le seul sportbike de série de cette cylindrée équipé d''un 4 cylindres en ligne (tous ses concurrents se contentent d''un mono ou d''un bicylindre). D''où ce son haut-perché si caractéristique, et cette exigence à monter dans les tours. [Voir le Kawasaki Ninja ZX-25R dans notre catalogue](/fr/bikes?group=motorcycle&model=kawasaki_zx25r).

**Fiche technique :**
- Moteur : 249 cm³, refroidissement liquide, DOHC, 4 cylindres en ligne — une configuration rare pour la catégorie
- Puissance : environ 45 ch (version indonésienne sans ram-air) à 15 500 tr/min, zone rouge jusqu''à 17 000 tr/min
- Boîte : mécanique à 6 rapports
- Hauteur de selle : ~785 mm
- Poids : ~183 kg
- Réservoir : ~15 l
- Carénage intégral, position de conduite sportbike
- Quickshifter d''origine — passage des vitesses sans débrayer, avec blip automatique des gaz au rétrogradage

**Ce qu''en disent les propriétaires :** un moteur 4 cylindres dans la catégorie 250 cm³ est un fait si inhabituel que Kawasaki avait publié à l''époque une vidéo dédiée au son de ce moteur sur banc dyno — les commentateurs décrivaient un son « hargneux » et « fou » pour une si petite cylindrée. Certains pilotes expérimentés soulignent que le quickshifter d''origine (avec blip automatique au rétrogradage) fonctionne à merveille et transforme les vitesses ordinaires de Bali en une conduite vraiment jouissive — pas besoin d''atteindre les vitesses d''un circuit pour prendre du plaisir aux changements de rapport. Côté points faibles : au-delà d''1m80, les jambes commencent à fatiguer en fin de journée à cause de la position, et la suspension est réglée pour la ville, pas pour le circuit. La puissance maximale n''arrive qu''à 15 500 tr/min, et pour quelqu''un habitué à rouler à bas régime, la moto paraîtra molle tant que les tours ne montent pas.

**À qui elle convient :** aux pilotes confirmés qui veulent le maximum de sensations de la catégorie 250 cm³ et sont prêts à garder les tours hauts — ce n''est pas une moto pour rouler tranquillement à bas régime.

**Où elle donne le meilleur d''elle-même à Bali :** elle vise davantage la sensation et le caractère qu''un itinéraire précis — à l''aise là où le MT-25 excelle aussi (ville, front de mer), et sur le circuit de classe mondiale de Mandalika, sur l''île voisine de Lombok. Peu de loueurs autorisent ce genre de sortie, mais chez nous, c''est possible. C''est la moto la plus exigeante de notre flotte — pas pour une première expérience à moto, et pas idéale pour les grands gabarits sur une journée entière.', 'Kawasaki Ninja ZX-25R — le seul sportbike 250 cm³ de série avec un 4 cylindres en ligne', 'Kawasaki Ninja ZX-25R en location à Bali : un rare 4 cylindres en ligne de 250 cm³, un quickshifter, et à qui s''adresse ce sportbike.'
  FROM articles a WHERE a.slug = 'kawasaki-ninja-zx-25r-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Yamaha XSR155 — un café racer au caractère rétro', 'yamaha-xsr155-un-cafe-racer-au-caractere-retro', 'Le Yamaha XSR155 est une moto néo-rétro à phare rond, guidon bas et position café racer, animée par le moteur familial 155 cm³ reconfiguré pour plus de punch en version manuelle.', 'Le Yamaha XSR155 est une moto néo-rétro : phare rond, guidon bas, position café racer. C''est le même moteur familial de 155 cm³ que sur les scooters de la gamme, mais reconfiguré pour donner plus de punch dans la version à boîte manuelle. [Voir le Yamaha XSR155 dans notre catalogue](/fr/bikes?group=motorcycle&model=yamaha_xsr).

**Fiche technique :**
- Moteur : 155 cm³, refroidissement liquide, SOHC, VVA — même base que le Nmax155, mais reconfiguré pour la boîte manuelle
- Puissance : environ 19,3 ch à 10 000 tr/min
- Boîte : mécanique à 6 rapports
- Hauteur de selle : ~815 mm — position basse typique du café racer
- Poids : ~131-134 kg
- Réservoir : ~10 l

**Ce qu''en disent les propriétaires :** le châssis du XSR155 est emprunté au sportbike R15, ce qui rend la moto légère et très réactive à la conduite. Avec une main légère sur les gaz, la consommation réelle peut descendre jusqu''à ~50 km/l. Point important pour ceux qui comptent rouler à deux : la selle passager est compacte et ferme, et beaucoup de versions n''ont pas de vraie poignée passager. Un vrai locataire à Bali a laissé un avis révélateur sur ce modèle précis : malgré ses modestes 155 cm³, la moto « tient bien la route » sur les routes balinaises, parfaitement calibrée pour son prix, et tellement à l''aise sur l''asphalte local qu''elle rivaliserait, selon lui, avec une Yamaha R3 dans les mêmes virages — le loueur avait amené la moto à trois heures de route, jusqu''à Amed, et elle n''a pas déçu.

**À qui elle convient :** à ceux qui veulent le style et le caractère d''une moto sans puissance excessive — une transition en douceur du scooter vers la boîte manuelle.

**Où elle donne le meilleur d''elle-même à Bali :** Canggu et Seminyak — l''esthétique rétro de la moto se marie parfaitement avec l''ambiance du quartier ; mais d''après les avis, elle se débrouille tout aussi bien sur des trajets plus longs et sinueux, comme une virée jusqu''à Amed.', 'Yamaha XSR155 — un café racer au caractère rétro', 'Yamaha XSR155 en location à Bali : fiche technique, avis de propriétaires et à qui s''adresse cette moto néo-rétro à boîte manuelle.'
  FROM articles a WHERE a.slug = 'yamaha-xsr-155-review-retro-style'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Kawasaki Versys-X 250 — un trail routier prêt pour la terre', 'kawasaki-versys-x250-un-trail-routier-pret-pour-la-terre', 'Le Kawasaki Versys-X 250 est un trail routier à position haute, suspensions à long débattement et réservoir généreux, pour qui veut explorer les routes secondaires de l''île.', 'Le Kawasaki Versys-X 250 est un trail routier : position haute, suspensions à long débattement, réservoir généreux. Une moto pour ceux qui comptent ne pas se contenter de rouler sur l''asphalte, mais explorer les routes secondaires de l''île. [Voir le Kawasaki Versys-X 250 dans notre catalogue](/fr/bikes?group=motorcycle&model=kawasaki_versys).

**Fiche technique :**
- Moteur : 249 cm³, refroidissement liquide, DOHC, bicylindre parallèle
- Puissance : environ 27 ch à 9700 tr/min
- Boîte : mécanique à 6 rapports
- Hauteur de selle : ~845 mm — nettement plus haute que les autres modèles de la flotte
- Poids : ~184 kg
- Réservoir : ~17 l — l''un des plus grands de la flotte, pour une autonomie étendue
- Pare-brise, repose-pieds enduro, position adaptée aux longs trajets debout/assis

**Ce qu''en disent les propriétaires :** la consommation réelle à allure tranquille jusqu''à 105 km/h tourne autour de 27-30 km/l (confirmé de façon indépendante par des loueurs balinais — environ 3-4 l/100 km), ce qui, avec un réservoir de 17 litres, donne une autonomie vraiment confortable sans avoir à faire le plein. Le hors-piste n''est pas qu''un argument marketing : lors d''un des premiers essais, la moto a franchi une boue épaisse sans que la suspension touche le fond une seule fois. La selle d''origine est ferme au début et demande un temps de « rodage ». La moto se sent le plus à l''aise entre 80 et 110 km/h. Des locataires balinais bien réels signalent qu''elle les a emmenés sans problème jusqu''à un village de montagne isolé, et que la version à boîte manuelle s''est très bien comportée lors d''un trajet pluvieux vers le nord de l''île. Itinéraires tout prêts cités par les loueurs eux-mêmes : sud de Bali — Ubud — Kintamani, les routes de montagne du nord de l''île, la côte est jusqu''à Amed et Tulamben.

**À qui il convient :** pour des itinéraires de plusieurs jours sur l''île et pour ceux qui veulent de l''assurance sur les pistes en terre ou les routes abîmées. Itinéraires détaillés dans nos articles de blog : « L''est de Bali à moto », « Kintamani : lever de soleil sur le volcan Batur », « Bedugul — Munduk — Lovina ».

**Où il donne le meilleur de lui-même à Bali :** les longs trajets — Kintamani, le nord et l''est de l''île (Amed et Tulamben compris), les routes secondaires en dehors des grands axes touristiques.', 'Kawasaki Versys-X 250 — un trail routier prêt pour la terre', 'Kawasaki Versys-X 250 en location à Bali : fiche technique, autonomie, avis de propriétaires et les meilleurs itinéraires pour ce trail routier.'
  FROM articles a WHERE a.slug = 'kawasaki-versys-x250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Suzuki V-Strom 250 — un trail routier axé confort et protection au vent', 'suzuki-v-strom-250-un-trail-routier-axe-confort-et-protection-au-vent', 'Le Suzuki V-Strom 250 est un trail routier adventure axé sur le confort en conduite prolongée : large pare-brise, position verticale, suspension souple.', 'Le Suzuki V-Strom 250 est un trail routier adventure centré sur le confort en conduite prolongée : large pare-brise, position verticale idéale, suspension souple pour de longs trajets sans fatigue. [Voir le Suzuki V-Strom 250 dans notre catalogue](/fr/bikes?group=motorcycle&model=suzuki_vstrom250).

**Fiche technique :**
- Moteur : 248 cm³, refroidissement liquide, DOHC, bicylindre parallèle
- Puissance : environ 25 ch à 8000 tr/min
- Boîte : mécanique à 6 rapports
- Hauteur de selle : ~800-835 mm selon la version
- Réservoir : 12 l

**Ce qu''en disent les propriétaires :** dans les avis, le moteur est comparé à une machine à coudre — souple, silencieux, économique et fiable. Un point revient systématiquement en positif : une selle bien rembourrée et une position « comme sur une grosse moto », pour une maniabilité pourtant bien plus légère. La consommation réelle va de 32 à 48 km/l. L''un des exemples d''usage les plus parlants à Bali : un locataire a pris le V-Strom pour 40 jours et plus, et a fait l''aller-retour jusqu''à l''île de Florès. Leçon pratique d''un autre locataire balinais : la grille arrière d''origine pour attacher des sacs s''est révélée peu fiable sur la route — l''agence l''a fait passer sur un Versys avec de vraies valises latérales ; la conclusion, c''est que si l''on prévoit des bagages, des valises sont plus pratiques que des sangles sur une grille. Les locataires recommandent particulièrement la direction de Sidemen, le mont Batur et les routes autour du point le plus à l''est de Bali, en notant que la circulation ne se fait vraiment sentir qu''à Uluwatu, Canggu et Ubud — au-delà, ce sont les rizières en terrasses, la jungle et les vues sur l''océan.

**À qui il convient :** à ceux qui recherchent avant tout le confort sur les longs trajets, plutôt qu''un caractère sportif. Itinéraires détaillés dans nos articles de blog : « L''est de Bali à moto », « Sekumpul et les cascades du centre-nord de Bali », « Les volcans de Bali à moto ».

**Où il donne le meilleur de lui-même à Bali :** la même niche que le Versys-X250 — les longs trajets, Sidemen, le mont Batur, la côte est. Si vous prévoyez beaucoup de bagages, dites-le-nous simplement, et nous ajouterons des valises latérales à votre moto.', 'Suzuki V-Strom 250 — un trail routier axé confort et protection au vent', 'Suzuki V-Strom 250 en location à Bali : fiche technique, consommation réelle et avis des locataires sur les longs trajets à travers l''île.'
  FROM articles a WHERE a.slug = 'suzuki-v-strom-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'TVS Ronin 225 — un néo-rétro aux accents scrambler', 'tvs-ronin-225-un-neo-retro-aux-accents-scrambler', 'Le TVS Ronin 225 est un modern classic aux touches scrambler : phare rond à LED, guidon haut, à l''aise aussi bien en ville que sur les pistes en terre.', 'Le TVS Ronin 225 est un modern classic aux touches scrambler : phare rond à LED, guidon haut, une géométrie polyvalente aussi à l''aise en ville que sur les pistes en terre qui partent de la route principale. Toutes les versions sont équipées de l''ABS. [Voir le TVS Ronin 225 dans notre catalogue](/fr/bikes?group=motorcycle&model=tvs_ronin225).

**Fiche technique :**
- Moteur : 225,9 cm³, refroidissement par huile, monocylindre, SOHC, 4 soupapes
- Puissance : environ 20,4 ch à 7750 tr/min
- Couple : ~19,9 Nm à 3750 tr/min — ça tire déjà bas dans les tours, pas besoin de monter en régime
- Boîte : mécanique à 5 rapports
- Hauteur de selle : ~795 mm
- Poids : ~159 kg
- Réservoir : ~14 l
- ABS sur toutes les versions (monocanal sur la version de base, bicanal sur les versions supérieures)

**Fiabilité :** TVS est une marque avec une très longue histoire en Inde (elle produit des deux-roues depuis les années 1980), et le Ronin, bien que relativement récent (depuis 2022), a déjà bâti une solide réputation de fiabilité au fil des années d''utilisation : dans les avis de propriétaires ayant dépassé les 10 000 km, le moteur est décrit comme conservant une douceur exemplaire, les fourches USD dorées montrent une bonne résistance à l''usure, et l''assemblage reste sans jeu ni bruit parasite même après un an de conduite intensive sur des revêtements variés. Dans les classements indépendants de propriétaires, les notes de fiabilité et de coût d''entretien du Ronin comptent régulièrement parmi les meilleures de la catégorie.

**Ce qu''en disent les propriétaires :** le moteur démarre avec ce son grave et légèrement rauque typique des motos rétro. Le fort couple à bas régime rend la moto particulièrement à l''aise dans la circulation urbaine dense. La consommation réelle rapportée dans les avis est de 35-45 km/l. La suspension, réglée souplement, absorbe bien les imperfections urbaines. Certaines versions proposent des modes de conduite, dont un mode adapté à la pluie — utile vu le climat balinais. Une excellente dynamique et un beau look sont régulièrement cités dans les avis comme l''un des points forts du modèle.

**À qui elle convient :** à ceux qui veulent une moto polyvalente pour tous les jours — sans les excès d''un sportbike, mais avec une bonne réserve d''assurance sur les pistes en terre.

**Où elle donne le meilleur d''elle-même à Bali :** aussi à l''aise à Canggu/Seminyak grâce à son look néo-rétro que sur les petites pistes en terre qui mènent aux rizières en terrasses.', 'TVS Ronin 225 — un néo-rétro aux accents scrambler', 'TVS Ronin 225 en location à Bali : fiche technique, fiabilité et avis de propriétaires sur cette moto néo-rétro au caractère scrambler.'
  FROM articles a WHERE a.slug = 'tvs-ronin-225-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Keeway Road Falcon 250 — un cruiser classique au prix d''entrée de gamme', 'keeway-road-falcon-250-un-cruiser-classique-au-prix-dentree-de-gamme', 'Le Keeway Road Falcon 250 est un cruiser classique à la silhouette allongée et à la selle basse, au prix d''entrée de gamme. Un modèle tout récent, sorti en 2026.', 'Le Keeway Road Falcon 250 : silhouette allongée, selle basse, noir sobre et un caractère calqué sur les gros cruisers américains, mais sur une base compacte de 250 cm³. Le modèle est tout récent sur le marché — sorti en 2026 — il y a donc encore très peu d''avis d''utilisateurs ou de loueurs balinais à son sujet. [Voir le Keeway Road Falcon 250 dans notre catalogue](/fr/bikes?group=motorcycle&model=keeway_roadfalcon250).

**Fiche technique :**
- Moteur : 248 cm³, bicylindre parallèle, 4 temps, 4 soupapes, SOHC, refroidissement liquide
- Puissance : environ 24,6 ch à 8000 tr/min
- Couple : ~23,4 Nm à 6500 tr/min
- Boîte : mécanique à 6 rapports avec embrayage slipper
- Hauteur de selle : ~698 mm — l''une des plus basses de la flotte
- Garde au sol : ~186 mm
- Réservoir : 14 l
- Freins : disque avant 300 mm (étrier 2 pistons), arrière 260 mm
- Écran TFT de 5 pouces, haut-parleur Bluetooth intégré — une option rare pour cette catégorie
- Navigation affichée directement sur le tableau de bord — comme sur le XMAX250, un support téléphone n''est pas du tout nécessaire sur ce modèle

**Ce qu''en disent les propriétaires :** le modèle est directement comparé aux motos de style Harley-Davidson et au Honda Rebel — la « bosse » caractéristique du réservoir à l''avant et la silhouette générale renvoient délibérément aux gros cruisers américains, et la presse indonésienne publie des comparatifs directs du Road Falcon face au Honda Rebel. Le haut-parleur Bluetooth intégré au guidon est une rareté pour un cruiser de cette catégorie. L''embrayage slipper adoucit les rétrogradages — utile sur les zones vallonnées de Bali. On note aussi que c''est une moto très maniable, avec un rayon de braquage étonnamment court — rien d''évident pour une silhouette de cruiser aussi longue, mais ça se sent bien à l''usage.

**À qui il convient :** à ceux qui veulent l''image classique du cruiser et une position détendue — particulièrement adapté aux petits gabarits grâce à sa selle très basse.

**Où il donne le meilleur de lui-même à Bali :** les trajets côtiers tranquilles — Sanur, Nusa Dua — mais pas seulement : nos clients l''ont aussi emmené dans des endroits habituellement réservés aux trail-routiers classiques comme le Versys ou le V-Strom. Autrement dit, il assure aussi les longs trajets sur toute la côte nord de Bali, malgré son allure de cruiser.', 'Keeway Road Falcon 250 — un cruiser classique au prix d''entrée de gamme', 'Keeway Road Falcon 250 en location à Bali : fiche technique, comparaison avec le Honda Rebel et à qui s''adresse ce cruiser.'
  FROM articles a WHERE a.slug = 'keeway-road-falcon-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Morbidelli C252V — un cruiser V-twin au nom italien', 'morbidelli-c252v-un-cruiser-v-twin-au-nom-italien', 'Le Morbidelli C252V est le deuxième cruiser de notre flotte, mais avec un vrai bicylindre en V au lieu d''un bicylindre parallèle, et une transmission par courroie.', 'Le deuxième cruiser de notre flotte, mais au caractère fondamentalement différent du Road Falcon : le Morbidelli embarque un vrai bicylindre en V au lieu d''un bicylindre parallèle, d''où un son plus « grave » et une vibration que beaucoup de riders de cruiser considèrent comme faisant partie du plaisir. La marque Morbidelli est un nom italien avec une vraie histoire en compétition (titres de champion en Grand Prix 125 cm³ et 250 cm³ dans les années 1970), dont les droits appartiennent depuis 2024 au même groupe que Keeway — ce n''est donc pas un simple homonyme, mais une marque officiellement ressuscitée sur une base technique nouvelle. [Voir le Morbidelli C252V dans notre catalogue](/fr/bikes?group=motorcycle&model=morbidelli_c252v).

**Fiche technique :**
- Moteur : 249 cm³, bicylindre en V (V-twin), 4 temps, 8 soupapes, SOHC, refroidissement liquide
- Puissance : environ 25,5 ch à 9000 tr/min
- Couple : 25 Nm à 5500 tr/min
- Boîte : mécanique à 6 rapports avec embrayage slipper
- Transmission : par courroie (belt drive) — une rareté pour la catégorie. En pratique, cela veut dire : pas besoin de graisser ni de retendre régulièrement comme une chaîne, et la courroie ne rouille pas sous la pluie
- Hauteur de selle : 690 mm — l''une des plus basses de la flotte
- Poids : ~200 kg
- Réservoir : 15,5 l
- Garde au sol : 173 mm
- Freins : disque avant 320 mm (étrier 4 pistons), arrière 260 mm (2 pistons) ; ABS Bosch bicanal et contrôle de traction de série
- Fourche inversée (USD) de 37 mm, débattement de 115 mm ; à l''arrière, deux amortisseurs avec précontrainte réglable sur 5 positions
- Vitesse maximale annoncée : 125 km/h

**Ce qu''en disent les propriétaires :** le modèle est très récent sur le marché, il n''y a donc pas encore d''historique d''utilisation sur plusieurs années, mais les premiers essais dans la presse notent une prise en main étonnamment légère pour un cruiser avec un empattement aussi long — le rayon de braquage ne trahit pas le gabarit de la moto. Le moteur en V est décrit comme visuellement spectaculaire (bien visible sous le réservoir, avec des ailettes de refroidissement factices et une finition chromée) et sonnant nettement plus grave que les bicylindres parallèles 250 cm³ habituels.

**À qui il convient :** à ceux qui veulent précisément le caractère V-twin d''un cruiser (pas un bicylindre parallèle comme sur le Road Falcon) — une vibration plus marquée et un son grave, plus une courroie au lieu d''une chaîne : pas besoin de graisser ni de retendre, et ça ne rouille pas sous la pluie.

**Où il donne le meilleur de lui-même à Bali :** la même niche que le Road Falcon — les trajets côtiers tranquilles, Sanur, Nusa Dua ; la courroie et la selle basse en font un choix particulièrement adapté à ceux qui veulent un style cruiser détendu sans se soucier de la chaîne.', 'Morbidelli C252V — un cruiser V-twin au nom italien', 'Morbidelli C252V en location à Bali : moteur V-twin, transmission par courroie, fiche technique et ce qui le distingue du Road Falcon.'
  FROM articles a WHERE a.slug = 'morbidelli-c252v-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Honda CBR250RR — un carénage intégral et le plus « circuit » des sportbikes carénés de la flotte', 'honda-cbr250rr-carenage-integral-et-experience-circuit', 'Le Honda CBR250RR est le seul sportbike entièrement caréné de notre flotte, en version haut de gamme avec quickshifter et ABS. L''une des références technologiques de la catégorie 250 cm³ en Indonésie.', 'Seul sportbike entièrement caréné de notre flotte (contrairement au MT-25 et au ZX-25R, qui sont des roadsters/streetfighters « nus ») — le Honda CBR250RR est considéré, depuis ses débuts en 2016, comme l''une des références technologiques de la catégorie 250 cm³ en Indonésie. [Voir le Honda CBR250RR dans notre catalogue](/fr/bikes?group=motorcycle&model=honda_cbr250rr).

**Fiche technique (version haut de gamme SP Quick Shifter avec ABS — celle de notre flotte) :**
- Moteur : 249,7 cm³, refroidissement liquide, DOHC, bicylindre parallèle, 8 soupapes, avec les améliorations de la version haut de gamme (vilebrequin allégé, nouveaux ressorts de soupape, culasse modifiée)
- Puissance : ~41 ch à 13 000 tr/min
- Couple : ~25 Nm à 11 000 tr/min
- Boîte : mécanique à 6 rapports
- Hauteur de selle : ~790 mm
- Poids : ~168 kg
- ABS, éclairage entièrement LED, tableau de bord numérique, throttle-by-wire (accélérateur électronique sans câble)
- Quickshifter avec 4 modes configurables (montée+descente, montée seule, descente seule, désactivé) — passage des vitesses sans débrayer
- Embrayage assist-slipper
- Fourche inversée (USD) type SFF-Big Piston
- 3 modes de conduite : Comfort, Sport, Sport+
- Accélération annoncée : 0 à 200 m en 8,65 s, vitesse maximale jusqu''à 172 km/h

**Ce qu''en disent les propriétaires :** le CBR250RR est régulièrement cité comme l''une des motos les plus « bardées de technologie » de la catégorie 250 cm³ en Indonésie — la version avec quickshifter offre des sensations vraiment proches du circuit, rares pour cette cylindrée.

**À qui il convient :** à ceux qui veulent l''expérience sportbike complète — carénage, position sportive « couché sur le réservoir », et une technologie de quickshifter digne du MotoGP.

**Où il donne le meilleur de lui-même à Bali :** comme le ZX-25R — la ville, le front de mer, pour la sensation et le caractère plutôt que pour un itinéraire précis ; avec ses origines circuit, il s''exprime aussi très bien sur le circuit de Mandalika, à Lombok.', 'Honda CBR250RR — un carénage intégral et le plus « circuit » des sportbikes carénés de la flotte', 'Honda CBR250RR en location à Bali : version haut de gamme avec quickshifter, fiche technique et à qui s''adresse cette expérience sportbike complète.'
  FROM articles a WHERE a.slug = 'honda-cbr250rr-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'Honda CB150X — un look adventure accessible sur base de moteur 150 cm³', 'honda-cb150x-un-look-adventure-accessible', 'Le Honda CB150X est une entrée accessible dans le style adventure, avec un moteur 150 cm³, une partie-cycle sérieuse pour la catégorie et le poids le plus léger de notre flotte.', 'Le CB150X, ce n''est pas la même chose que les 250 cm³ Versys-X250 et V-Strom250 : c''est une entrée accessible dans le style adventure, avec un modeste monocylindre de 150 cm³, mais une partie-cycle vraiment sérieuse pour la catégorie (garde au sol proche de celle du CB500X). Grâce à un poids très léger pour une moto (139 kg), le moteur 150 cm³ suffit largement — la moto lève facilement la roue avant et garde une dynamique sûre sur toute la plage de vitesses, pas seulement à bas régime comme on pourrait le croire avec un monocylindre de cette cylindrée. [Voir le Honda CB150X dans notre catalogue](/fr/bikes?group=motorcycle&model=honda_cb150x).

**Fiche technique :**
- Moteur : 149,16 cm³, monocylindre, refroidissement liquide, DOHC 4 soupapes
- Puissance : ~15,6 ch à 9000 tr/min
- Couple : ~13,8 Nm à 7000 tr/min
- Boîte : mécanique à 6 rapports
- Hauteur de selle : 817 mm
- Garde au sol : 181 mm — presque comme sur le CB500X, bien plus imposant
- Poids : ~139 kg — la moto (hors scooters) la plus légère de la flotte
- Réservoir : 12 l
- Fourche inversée (USD) Showa SFF-BP de 37 mm, mono-amortisseur Pro-Link à l''arrière
- Disques de frein ondulés (wavy) à l''avant et à l''arrière
- Tableau de bord entièrement numérique avec consommation en temps réel

**À qui elle convient :** à ceux qui veulent le style adventure et une position haute, sans être prêts pour le poids et la puissance d''un vrai trail routier 250 cm³ — une bonne étape de transition entre les motos urbaines et des modèles plus engagés.

**Où elle donne le meilleur d''elle-même à Bali :** la même logique que l''ADV160 — routes secondaires, asphalte imparfait, mais par la position et le caractère, c''est déjà une vraie moto à boîte manuelle, pas un scooter.', 'Honda CB150X — un look adventure accessible sur base de moteur 150 cm³', 'Honda CB150X en location à Bali : fiche technique, garde au sol et à qui s''adresse cette moto adventure au budget maîtrisé.'
  FROM articles a WHERE a.slug = 'honda-cb150x-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'fr', 'PCX160 vs ADV160 vs Nmax — comment choisir entre les trois', 'pcx160-vs-adv160-vs-nmax-comment-choisir', 'PCX160, ADV160 et Nmax : comment choisir entre les trois scooters les plus populaires de notre flotte — différences de rangement, de dynamique et de position de conduite.', 'Pour être honnête, ces trois modèles se distinguent avant tout visuellement, et par ce à quoi le rider est habitué — en résumé, c''est une question de goût. Parmi les vraies différences pratiques, la première, c''est la taille du coffre : le Nmax conviendra à ceux qui acceptent de sacrifier un peu de volume de rangement par amour de sa position de conduite et de sa dynamique. Et côté pure dynamique, on plaisante en interne : pour qui veut vraiment des sensations « Turbo », mieux vaut prendre l''ADV dans cette gamme — il donne subjectivement une impression plus vive que le modèle qui porte « Turbo » dans son nom.

Dans l''idéal, avant de choisir votre scooter pour une longue durée, essayez chacun d''eux entre 5 jours et un mois, pour vraiment ressentir la différence. 1 à 3 jours suffisent rarement à bien comprendre une moto.

Fiches des modèles : [Honda PCX160](/fr/bikes?category=honda_pcx160), [Honda ADV160](/fr/bikes?category=honda_adv160), [Yamaha Nmax](/fr/bikes?category=yamaha_nmax155).', 'PCX160 vs ADV160 vs Nmax — comment choisir entre les trois', 'Comparatif Honda PCX160, Honda ADV160 et Yamaha Nmax en location à Bali — quel scooter choisir selon vos besoins.'
  FROM articles a WHERE a.slug = 'pcx160-vs-adv160-vs-nmax-how-to-choose'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Honda PCX160: comodidad y amplio maletero para el día a día', 'honda-pcx160-comodidad-y-amplio-maletero-para-el-dia-a-dia', 'La Honda PCX160 es la opción más versátil para quienes buscan un scooter cómodo sin renunciar al maletero. El modelo que más eligen las parejas y los viajeros con maleta.', 'La Honda PCX160 es la opción más versátil para quienes buscan un scooter cómodo sin renunciar al espacio de maletero. Es el modelo que más eligen las parejas y quienes viajan con maleta o una bolsa grande. [Ver la Honda PCX160 en el catálogo](/es/bikes?category=honda_pcx160).

**Características:**
- Motor: 156,9 cm³, refrigeración líquida, eSP+
- Potencia: unos 15,8 CV a 8.500 rpm
- Transmisión: variador (CVT), sin cambios manuales
- Altura del asiento: ~764 mm — cómoda para casi cualquier estatura
- Depósito: 8,1 l
- Maletero bajo el asiento: ~30 l — cabe un casco integral y todavía queda espacio para más cosas
- Llave inteligente (smart key), iluminación LED, carga USB potente, panel de instrumentos digital
- Tenemos una amplia variedad de colores personalizados, además de los estándar

**Extras:** en la PCX160 se puede montar un top-case trasero SHAD de 44 l — útil para quienes necesitan más que el maletero bajo el asiento. Más detalles sobre los extras disponibles, en nuestro artículo [«Extras de alquiler que merecen la pena: cascos y el baúl cómodo»](/es/blog/extras-de-alquiler-que-merecen-la-pena-cascos-y-el-baul-comodo).

**Lo que dicen los propietarios:** el consumo real según las opiniones ronda los 40-50 km/l, lo que hace que moverse por la isla salga prácticamente gratis. La reputación del modelo es casi legendaria por su fiabilidad — en los foros comparan la PCX con una cortadora de césped: arranca y rueda durante años sin sorpresas. Un detalle práctico para quien alquila: la llave inteligente es cómoda, pero repararla o sustituirla en caso de pérdida cuesta alrededor de 1 millón de rupias, así que lo mejor es no perderla — más sobre cómo funciona, en nuestro artículo [«Cómo arrancar y usar el smart key de tu scooter de alquiler»](/es/blog/como-arrancar-y-usar-el-smart-key-de-tu-scooter-de-alquiler). Con un pasajero a bordo, la capacidad de aceleración para adelantar baja notablemente — no es un problema en ciudad, pero conviene tenerlo en cuenta en carretera.

**Dónde rinde mejor en Bali:** se mantiene firme sobre el asfalto gracias a la rueda delantera de 14 pulgadas — cómoda en Canggu, Seminyak, Sanur, y para el uso diario por Denpasar.', 'Honda PCX160: comodidad y amplio maletero para el día a día', 'Ficha técnica, consumo de combustible, opiniones de propietarios y extras para la Honda PCX160 en alquiler en Bali: dónde rinde mejor y a quién le conviene.'
  FROM articles a WHERE a.slug = 'honda-pcx160-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Honda ADV160: para caminos irregulares y escapadas largas', 'honda-adv160-para-caminos-irregulares-y-escapadas-largas', 'La Honda ADV160 monta el mismo motor fiable que la PCX160, pero en otra carrocería: posición más alta, más distancia al suelo y mayor seguridad sobre asfalto irregular y caminos de tierra.', 'La Honda ADV160 monta el mismo motor fiable que la PCX160, pero en otra carrocería: posición de conducción más alta, mayor distancia al suelo y más seguridad sobre asfalto irregular y caminos de tierra. [Ver la Honda ADV160 en el catálogo](/es/bikes?category=honda_adv160).

**Características:**
- Motor: 156,9 cm³, refrigeración líquida, eSP+ (el mismo que la PCX160)
- Potencia: unos 15,8 CV
- Transmisión: variador (CVT)
- Altura del asiento: ~795 mm — más alta que la de los scooters urbanos, mejor para estaturas más altas y para quienes prefieren una posición más elevada
- Distancia al suelo ~165 mm — notablemente mayor que la estándar
- Maletero bajo el asiento: ~30 l — cabe un casco integral y todavía queda espacio para más cosas
- Parabrisas regulable — 2 posiciones: subido (agresiva) y bajado (urbana)
- Panel semidigital, carga USB potente, llave inteligente
- Tenemos una amplia variedad de colores personalizados, además de los estándar

**Extras:** al igual que en la PCX160, se puede montar un top-case trasero SHAD de 44 l. Más detalles, en nuestro artículo [«Extras de alquiler que merecen la pena: cascos y el baúl cómodo»](/es/blog/extras-de-alquiler-que-merecen-la-pena-cascos-y-el-baul-comodo).

**Lo que dicen los propietarios:** la economía de combustible es otro punto muy fuerte de este motor: según las opiniones, el consumo real se mantiene entre 34 y 38 km/l, así que hay que repostar pocas veces incluso con una conducción activa. Además, la ADV160 es una de las más dinámicas de la gama PCX-Nmax-ADV, pese a compartir motor con la PCX160 — simplemente cambia la puesta a punto. La distancia al suelo realmente se nota en tramos de tierra y asfalto en mal estado, pero los propietarios avisan con honestidad: es un estilo adventure urbano, no una enduro de verdad — sobre piedras grandes e irregularidades serias, esa altura no es suficiente.

**Dónde rinde mejor en Bali:** Ubud y alrededores (terrazas de arroz, caminos secundarios), Munduk y sus cascadas, las zonas de colinas de Uluwatu y Bukit — el relieve y el estado del firme varían, y la ADV160 perdona más que un scooter urbano, aunque el todoterreno serio de verdad no es lo suyo.', 'Honda ADV160: para caminos irregulares y escapadas largas', 'Ficha técnica, consumo y opiniones de propietarios de la Honda ADV160 en alquiler en Bali: dónde brilla este estilo adventure urbano.'
  FROM articles a WHERE a.slug = 'honda-adv-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Yamaha Nmax: New (Gen 2), Neo (Gen 3) y Turbo', 'yamaha-nmax-new-gen-2-neo-gen-3-y-turbo', 'La Nmax de nuestra flota no es un solo modelo, sino varias generaciones y acabados bajo el mismo nombre: New, Neo y Turbo. Te contamos en qué se diferencian realmente.', '"Nmax" en nuestra flota no es un solo modelo, sino varias generaciones y acabados bajo el mismo nombre. New y Neo comparten motor y transmisión — solo cambian de generación dentro de la gama (Gen 2 y Gen 3). Turbo, en cambio, es harina de otro costal, con otra configuración electrónica de la transmisión. [Ver la Yamaha Nmax en el catálogo](/es/bikes?category=yamaha_nmax155).

**Nmax New (Gen 2):**
- Motor: 155 cm³, Blue Core, VVA, SOHC 4 válvulas
- Potencia: ~15 CV a 8.000 rpm
- Transmisión: variador (CVT) clásico de rodillos
- Peso: ~132 kg
- Depósito: 7,1 l

**Nmax Neo (Gen 3):**
- El mismo motor Blue Core VVA de 155 cm³ que la New, en cilindrada y construcción — la diferencia es solo de aspecto, generación y acabado, no de mecánica
- Potencia: ~15 CV a 8.000 rpm
- Transmisión: variador clásico
- Peso: ~130 kg
- Dos versiones: Neo (base) y Neo S (+ sistema Smart Key)

**Nmax "Turbo":**
- El mismo motor en cilindrada que la New/Neo
- La diferencia principal es el YECVT (Yamaha Electric CVT): en esencia el mismo esquema de variador, pero con control electrónico en lugar de rodillos puramente mecánicos. Es más una cuestión de sensaciones de marketing y ajustes electrónicos de conducción que un cambio real de transmisión
- Dos modos de conducción T-Mode/S-Mode + "marchas" virtuales Y-Shift (Low/Medium/High) — imitan el cambio de marchas como en un coche
- Peso: ~133-135 kg según la versión
- Tres versiones: Turbo (base), Turbo Tech Max (pantalla TFT, puerto USB-C, asiento especial), Turbo Tech Max Ultimate (la tope de gama)
- Importante: "Turbo" en el nombre hace referencia a la electrónica y a la sensación de respuesta, no a un turbocompresor real del motor
- Tenemos una amplia variedad de colores personalizados, además de los estándar

**Lo que dicen los propietarios:** el motor (en cualquier generación) lo describen como "indestructible" en las opiniones — la fiabilidad es uno de los puntos fuertes de toda la gama. La economía también es un punto a favor — el mismo motor económico de 155 cm³ que comparte con el resto de la familia (PCX160, ADV160) mantiene un consumo cómodo en viajes reales, así que hay que repostar poco. Un matiz interesante sobre el maletero: las cifras publicadas no son pequeñas, pero la forma del hueco hace que un casco integral no siempre entre. Como detalle simpático, bajo la carenatura izquierda hay un compartimento aparte para el móvil y la cartera. En las opiniones de arrendatarios en Bali se elogia especialmente el tirón en las subidas ("tanjakan") y la suspensión suave para trayectos largos — por ejemplo, hasta Uluwatu. El ABS y los neumáticos sin cámara anchos se destacan en varias guías para turistas precisamente por los frecuentes chaparrones tropicales y los obstáculos repentinos en la carretera, como perros — los frenos no bloquean la rueda en un frenazo de pánico.

**Dónde rinde mejor en Bali:** se mueve con soltura tanto en el tráfico urbano (Canggu, Seminyak) como en carreteras de longitud media, incluidos los trayectos hasta Uluwatu — buena estabilidad en curvas y bajo la lluvia. Esto aplica por igual a todas las versiones — la geometría y la posición de conducción apenas cambian entre ellas.', 'Yamaha Nmax: New (Gen 2), Neo (Gen 3) y Turbo', 'Yamaha Nmax en alquiler en Bali: diferencias entre New, Neo y Turbo, ficha técnica y opiniones reales de propietarios.'
  FROM articles a WHERE a.slug = 'yamaha-nmax-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Yamaha XMAX250: Connected y Tech Max, la misma mecánica, distinto acabado', 'yamaha-xmax250-connected-y-tech-max-la-misma-mecanica-distinto-acabado', 'La Yamaha XMAX250 es el scooter más potente de la gama, ideal tanto para distancias largas como para la ciudad. En nuestra flota hay versiones Connected y Tech Max con la misma mecánica.', 'La Yamaha XMAX250 es el scooter más potente de la gama. A muchos les encanta esta gran bestia, y aunque todos coinciden en que es estupenda para las distancias largas, para muchos otros tampoco hay nada mejor en los trayectos cortos por ciudad. En nuestra flota el modelo está disponible en dos versiones — Connected y Tech Max — y aquí conviene tener claro algo importante: técnicamente es la misma moto, la diferencia está solo en el acabado. [Ver la Yamaha XMAX250 en el catálogo](/es/bikes?category=yamaha_xmax250).

**Características (idénticas para Connected y Tech Max — motor y chasis son iguales):**
- Motor: 250 cm³, monocilíndrico, refrigeración líquida, SOHC 4 válvulas, Blue Core, cigüeñal forjado de una sola pieza (one-piece forged crankshaft)
- Potencia: 16,8 kW a 7.000 rpm
- Par motor: 24,3 Nm a 5.500 rpm
- Transmisión: variador (CVT)
- Altura del asiento: 795 mm
- Peso: ~181 kg
- Depósito: 13 l
- Maletero bajo el asiento: 44,9 l — muchísimo espacio, caben de verdad dos cascos integrales más otras cosas. Un detalle importante: a veces hay que colocar el casco integral en una posición concreta para que entre bien
- ABS, control de tracción (TCS), Emergency Stop Signal (parpadeo de emergencia de la luz de freno en frenadas bruscas), llave inteligente con Answer Back System (señal para localizar la moto en el aparcamiento), toma eléctrica para cargar el móvil
- El parabrisas de la Connected es fijo, sin regulación. El parabrisas regulable es exclusivo de la Tech Max (ver más abajo)
- Garantía de Yamaha Indonesia — 5 años / 50.000 km en el chasis, los componentes del sistema de combustible, el cilindro y el pistón

**La app Y-Connect — un detalle importante que merece la pena explicar al arrendatario:**

En la versión XMAX Connected está disponible la conexión con la app:

📱 Se puede descargar aquí:
https://apps.apple.com/app/id1495921872
https://apps.apple.com/app/id1585591110

Qué ofrece la conexión:
• Recepción de llamadas entrantes desde el manillar
• Control de la música desde el manillar
• Navegación en español
• Integración cómoda con el smartphone

**Connected frente a Tech Max — en qué se diferencian:**

La diferencia más importante y también la más cara es el asiento. En la Tech Max no es simplemente "con otro pespunte": es un asiento diseñado específicamente por MBK (la marca francesa que pertenece a Yamaha y está especializada en scooters europeos) — el llamado "Comfort Seat". Por dentro lleva espuma de alta densidad (high-density foam) y refuerzos laterales tipo bolster a los lados, pensados específicamente para trayectos de varias horas: el asiento sujeta la postura y reduce el cansancio lumbar en tramos largos, no es solo que se sienta más blando. Por fuera, ecopiel con detalles de ante y pespunte en hilo dorado, más un acabado cromado. En sus opiniones, los propietarios señalan precisamente el asiento como el principal motivo para pagar más por la Tech Max, no el color ni los emblemas.

El resto de diferencias también son reales, pero en precio e importancia quedan por detrás del asiento:
- Color exclusivo (Magma Black en los modelos anteriores, desde 2025 Ceramic Grey)
- Tapa del compartimento bajo el asiento en ecopiel con ante y pespunte dorado (a juego con el asiento)
- Estribos de aluminio, moldura cromada, emblemas especiales y acabado de las empuñaduras propios de la Tech Max
- En el modelo Tech Max de 2025 apareció la única diferencia funcional (no solo estética): el parabrisas de ajuste eléctrico (Electric Adjustable Screen), que se puede regular incluso en marcha para encontrar la posición ideal, más un panel TFT renovado; en la Connected, como se explicó antes, el parabrisas no tiene regulación de ningún tipo

La diferencia de precio en el mercado indonesio es de unos 5 millones de rupias por la versión Tech Max, y ese dinero va sobre todo al asiento.

**Lo que dicen los propietarios:** el motor tira con soltura hasta 100-110 km/h, y a partir de ahí empieza a "quedarse sin aire" — no es una moto para acelerones, sino para mantener un ritmo de crucero estable. El club indonesio de propietarios de XMAX organizó el primer touring de este modelo precisamente en Bali allá por 2017 — la ruta fue Denpasar → Ubud → Kintamani → Besakih → Klungkung → Gianyar → la vía Ida Bagus Mantra y vuelta; en los tramos con curvas de Ubud y Kintamani los participantes pusieron a prueba el control de tracción, y en el tramo recto de la autopista de peaje Ida Bagus Mantra llegaron a alcanzar los 140 km/h.

Rutas ya bautizadas para la XMAX250 en Bali, mencionadas por los propios motoristas: costa sur — Canggu → Uluwatu (por Jalan Bali Cliff) → playa de Pandawa → GWK; ruta de montaña — Denpasar → Ubud → Kintamani → lago Batur → Munduk; ruta este — Sanur → Candidasa → Sidemen → playa Virgin. Rutas detalladas y puntos en el mapa, en nuestros artículos del blog «La península de Bukit en moto», «Kintamani: amanecer en el volcán Batur» y «El este de Bali en moto» (ahí también hablamos de Virgin Beach) — los publicaremos próximamente.

**A quién le conviene:** para excursiones de uno o varios días por la isla, donde importa tener potencia de sobra para adelantar y subir pendientes, además de comodidad en tramos largos de carretera. Y también para el uso diario — es una de las motos más demandadas tanto por turistas como por quienes llevan tiempo viviendo en Bali.

**Dónde rinde mejor en Bali:** en rutas más allá del sur de la isla — Kintamani y el volcán Batur, Amed, Lovina, Sidemen, la costa este. Pero, de nuevo, es cuestión de gustos — hay quien disfruta incluso en los atascos de Canggu con el scooter-túring más grande posible, y no son pocos los entusiastas de ese estilo.', 'Yamaha XMAX250: Connected y Tech Max, la misma mecánica, distinto acabado', 'Yamaha XMAX250 en alquiler en Bali: diferencias entre Connected y Tech Max, ficha técnica, la app Y-Connect y rutas por la isla.'
  FROM articles a WHERE a.slug = 'yamaha-xmax250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Yamaha MT-25: Gen 2 y Gen 3, distinto aspecto, el mismo motor', 'yamaha-mt-25-gen-2-y-gen-3-distinto-aspecto-el-mismo-motor', 'La Yamaha MT-25 es un streetfighter compacto para quien quiere sentir la aceleración y la respuesta de una moto de verdad. En nuestra flota conviven unidades Gen 2 y Gen 3 tras el rediseño de 2025.', 'La Yamaha MT-25 es un streetfighter compacto para quien quiere sentir la aceleración y la respuesta de una moto de verdad, no solo ir del punto A al punto B. Es una moto con carácter de verdad — muchísimos profesionales y aficionados la señalan como una de sus favoritas dentro de su categoría, tanto por dinámica como por posición de conducción y por diseño. El cambio manual y la postura agresiva son lo que distingue radicalmente a este modelo de los scooters de la flota. En 2025, Yamaha Indonesia lanzó un rediseño notable ("Gen 3"), así que en nuestra flota pueden convivir unidades con el aspecto antiguo y el nuevo bajo el mismo nombre de modelo. [Ver la Yamaha MT-25 en el catálogo](/es/bikes?group=motorcycle&model=yamaha_mt25).

**Características (comunes — el motor en sí no ha cambiado entre generaciones):**
- Motor: 249,55 cm³, refrigeración líquida, DOHC, bicilíndrico en paralelo (2 cilindros), 8 válvulas
- Potencia: unos 35,5 CV a 12.000 rpm
- Par motor: ~22,6 Nm a 10.000 rpm
- Transmisión: manual de 6 velocidades
- Altura del asiento: ~780 mm
- Depósito: ~14 l

**Gen 2 (actualización de ~2019 — el aspecto "clásico" más reconocible de la MT-25):**
- Un solo disco de freno delantero
- Sin embrague antirrebote (slipper), sin ABS
- Peso: ~165-167 kg

**Gen 3 (rediseño de 2025, Yamaha la presenta como "Hypernaked" según su sitio oficial en Indonesia):**
- Nuevo faro agresivo en la línea de la gama MT-07/serie R — óptica angulosa, "alienígena", frente al faro redondo de la Gen 1 (la Gen 2 ya se había alejado de la forma redonda, pero la Gen 3 tiene su propia geometría, aún más afilada)
- ABS — aparece por primera vez en la MT-25 precisamente en la Gen 3
- Embrague antirrebote (slipper) — reduce el tirón en las reducciones de marcha bruscas
- Y-Connect (app Bluetooth) a través del módulo CCU — la primera tecnología de este tipo en una moto de montaje indonesio
- Big Bike Switch 3-in-1 — bloque de mandos compacto e integrado, al estilo de las motos "grandes" de Yamaha
- Panel de instrumentos totalmente digital con indicador del momento óptimo de cambio (shift timing light)
- Toma eléctrica para cargar dispositivos
- Peso: ~169 kg — algo más que la Gen 2, por el nuevo equipamiento

**Dónde rinde mejor en Bali:** Canggu y Seminyak — aceleraciones cortas y contundentes en el tráfico urbano y paseos nocturnos por el paseo marítimo, donde el carácter de la moto se luce al máximo.', 'Yamaha MT-25: Gen 2 y Gen 3, distinto aspecto, el mismo motor', 'Yamaha MT-25 en alquiler en Bali: diferencias entre Gen 2 y Gen 3, ficha técnica del motor y dónde se nota su carácter de streetfighter.'
  FROM articles a WHERE a.slug = 'yamaha-mt25-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Kawasaki Ninja ZX-25R: la única deportiva de serie de 250cc con cuatro cilindros en línea', 'kawasaki-ninja-zx-25r-deportiva-de-250cc-con-cuatro-cilindros-en-linea', 'La Kawasaki Ninja ZX-25R es la única deportiva de serie de 250cc con motor de cuatro cilindros en línea. Carácter de altas revoluciones y quickshifter de fábrica.', 'La Ninja ZX-25R ocupa una posición única en la clase 250cc: es la única deportiva de serie de esta cilindrada con motor de cuatro cilindros en línea (toda la competencia monta motores mono o bicilíndricos). De ahí su característico sonido de altas revoluciones y su exigencia a la hora de mantener el motor girando alto. [Ver la Kawasaki Ninja ZX-25R en el catálogo](/es/bikes?group=motorcycle&model=kawasaki_zx25r).

**Características:**
- Motor: 249 cm³, refrigeración líquida, DOHC, cuatro cilindros en línea — una configuración poco habitual en esta clase
- Potencia: unos 45 CV (versión indonesia sin ram-air) a 15.500 rpm, línea roja hasta 17.000 rpm
- Transmisión: manual de 6 velocidades
- Altura del asiento: ~785 mm
- Peso: ~183 kg
- Depósito: ~15 l
- Carenado completo, posición de conducción deportiva
- Quickshifter de fábrica (Quick Shifter) — cambios de marcha sin embrague, con "blip" automático de acelerador en las reducciones

**Lo que dicen los propietarios:** el simple hecho de tener un motor de cuatro cilindros en la clase 250cc es tan poco habitual que en su momento Kawasaki publicó un vídeo aparte con el sonido de este motor en el banco de pruebas — los comentaristas describían el sonido como "furioso" y "una locura" para una cilindrada tan pequeña. Algunos pilotos con experiencia destacan que el quickshifter de fábrica (con blip automático en las reducciones) funciona de maravilla y convierte las velocidades normales de Bali en una experiencia de conducción realmente disfrutona — no hace falta ir a un circuito para disfrutar de los cambios. Entre los puntos débiles, mencionan que a partir de 180 cm de estatura las piernas empiezan a cansarse con la postura al final del día, y que la suspensión está pensada para ciudad, no para pista. La potencia máxima llega solo a 15.500 rpm, así que a quien esté acostumbrado a rodar a bajas revoluciones la moto le puede parecer sosa hasta que se sube de vueltas.

**A quién le conviene:** a pilotos con experiencia que quieran el máximo de emoción dentro de la clase 250cc y estén dispuestos a mantener revoluciones altas — no es una moto para una conducción tranquila a pocas vueltas.

**Dónde rinde mejor en Bali:** apunta más a la sensación y al carácter que a una ruta concreta — brilla en los mismos sitios que la MT-25 (ciudad, paseo marítimo) y en el circuito de nivel mundial de Mandalika, en la isla vecina de Lombok. No todos los rentales permiten esas salidas, pero con nosotros es posible. Es la moto más exigente de la flota — no para una primera experiencia sobre dos ruedas, y no es ideal para pilotos altos durante un día entero.', 'Kawasaki Ninja ZX-25R: la única deportiva de serie de 250cc con cuatro cilindros en línea', 'Kawasaki Ninja ZX-25R en alquiler en Bali: el raro motor de cuatro cilindros en línea de 250cc, quickshifter y a quién le conviene esta deportiva.'
  FROM articles a WHERE a.slug = 'kawasaki-ninja-zx-25r-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Yamaha XSR155: un café racer con carácter retro', 'yamaha-xsr155-cafe-racer-con-caracter-retro', 'La Yamaha XSR155 es una moto neorretro con faro redondo, manillar bajo y postura de café racer, montada sobre el conocido motor familiar de 155cc, aquí afinado para dar más con el cambio manual.', 'La Yamaha XSR155 es una moto neorretro: faro redondo, manillar bajo, postura de café racer. Monta el mismo motor familiar de 155cc que los scooters de la gama, pero en su versión para cambio manual viene afinado para dar más. [Ver la Yamaha XSR155 en el catálogo](/es/bikes?group=motorcycle&model=yamaha_xsr).

**Características:**
- Motor: 155 cm³, refrigeración líquida, SOHC, VVA — la misma base que la Nmax155, pero con otra puesta a punto para el cambio manual
- Potencia: unos 19,3 CV a 10.000 rpm
- Transmisión: manual de 6 velocidades
- Altura del asiento: ~815 mm — postura baja de café racer
- Peso: ~131-134 kg
- Depósito: ~10 l

**Lo que dicen los propietarios:** el chasis de la XSR155 está tomado de la deportiva R15, así que es una moto ligera y muy ágil de manejar. Con una mano suave en el acelerador, el consumo real llega hasta ~50 km/l. Un detalle importante para quien piensa ir con acompañante: el asiento trasero es compacto y duro, y en muchas versiones no hay un buen asa para el pasajero. Uno de los arrendatarios en Bali dejó una opinión muy ilustrativa precisamente sobre este modelo: pese a sus modestos 155 cm³, la moto "se mueve con firmeza" en las carreteras de Bali, está muy bien puesta a punto para su precio y se agarra al asfalto local con tanta seguridad que, según él, le daría la réplica incluso a una Yamaha R3 en las mismas curvas — el arrendador le llevó la moto tras tres horas de viaje, hasta Amed, y no le falló.

**A quién le conviene:** a quien quiera estilo y carácter de moto, pero sin potencia excesiva — una transición cómoda del scooter a una moto con cambio manual.

**Dónde rinde mejor en Bali:** Canggu y Seminyak — la estética retro de la moto encaja perfectamente con el ambiente de la zona; pero, a juzgar por las opiniones, también se desenvuelve bien en rutas más largas y sinuosas, como la escapada a Amed.', 'Yamaha XSR155: un café racer con carácter retro', 'Yamaha XSR155 en alquiler en Bali: ficha técnica, opiniones de propietarios y a quién le conviene esta moto neorretro con cambio manual.'
  FROM articles a WHERE a.slug = 'yamaha-xsr-155-review-retro-style'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Kawasaki Versys-X 250: una túring con margen para la tierra', 'kawasaki-versys-x-250-turing-con-margen-para-la-tierra', 'La Kawasaki Versys-X 250 es una enduro-túring con posición elevada, suspensión de largo recorrido y depósito ampliado, pensada para quien quiere explorar los caminos secundarios de la isla.', 'La Kawasaki Versys-X 250 es una enduro-túring: posición elevada, suspensión de largo recorrido, depósito ampliado. Una moto para quien no solo quiere moverse por asfalto, sino explorar los caminos secundarios de la isla. [Ver la Kawasaki Versys-X 250 en el catálogo](/es/bikes?group=motorcycle&model=kawasaki_versys).

**Características:**
- Motor: 249 cm³, refrigeración líquida, DOHC, bicilíndrico en paralelo
- Potencia: unos 27 CV a 9.700 rpm
- Transmisión: manual de 6 velocidades
- Altura del asiento: ~845 mm — notablemente más alta que el resto de modelos de la flota
- Peso: ~184 kg
- Depósito: ~17 l — uno de los más grandes de la flota, con más autonomía
- Parabrisas, estribos de tipo enduro, posición para conducir de pie o sentado en trayectos largos

**Lo que dicen los propietarios:** el consumo real a ritmo tranquilo hasta 105 km/h ronda los 27-30 km/l (confirmado también de forma independiente por rentales de Bali — unos 3-4 l cada 100 km), lo que con un depósito de 17 litros da una autonomía muy sólida sin repostar. El todoterreno no es solo marketing: en una de las primeras pruebas, la moto cruzó con seguridad un barrizal denso sin que la suspensión tocara fondo ni una sola vez. El asiento de serie es duro al principio y necesita "rodaje". La moto se siente más cómoda en el rango de 80-110 km/h. Arrendatarios reales en Bali comentan que la moto los llevó sin problemas incluso hasta un pueblo de montaña remoto, y que la versión con cambio manual se comportó de maravilla en un viaje bajo la lluvia hacia el norte de la isla. Rutas ya probadas que mencionan los propios rentales: sur de Bali — Ubud — Kintamani, las carreteras de montaña del norte de la isla, la costa este hasta Amed y Tulamben.

**A quién le conviene:** para rutas de varios días por la isla y para quien busca seguridad en tramos de tierra o en mal estado. Rutas detalladas, en los artículos del blog: «El este de Bali en moto», «Kintamani: amanecer en el volcán Batur», «Bedugul, Munduk, Lovina».

**Dónde rinde mejor en Bali:** rutas largas — Kintamani, el norte y el este de la isla (incluidos Amed y Tulamben), caminos secundarios fuera de las rutas turísticas principales.', 'Kawasaki Versys-X 250: una túring con margen para la tierra', 'Kawasaki Versys-X 250 en alquiler en Bali: ficha técnica, autonomía, opiniones de propietarios y las mejores rutas para una enduro-túring.'
  FROM articles a WHERE a.slug = 'kawasaki-versys-x250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Suzuki V-Strom 250: túring centrada en la comodidad y la protección contra el viento', 'suzuki-v-strom-250-turing-centrada-en-comodidad-y-proteccion-contra-el-viento', 'La Suzuki V-Strom 250 es una adventure-túring centrada en la comodidad en trayectos largos: parabrisas ancho, postura erguida, suspensión suave.', 'La Suzuki V-Strom 250 es una adventure-túring centrada en la comodidad en trayectos largos: parabrisas ancho, postura erguida ideal, suspensión suave para recorrer grandes distancias sin cansancio. [Ver la Suzuki V-Strom 250 en el catálogo](/es/bikes?group=motorcycle&model=suzuki_vstrom250).

**Características:**
- Motor: 248 cm³, refrigeración líquida, DOHC, bicilíndrico en paralelo
- Potencia: unos 25 CV a 8.000 rpm
- Transmisión: manual de 6 velocidades
- Altura del asiento: ~800-835 mm según la versión
- Depósito: 12 l

**Lo que dicen los propietarios:** en las opiniones comparan el motor con una máquina de coser — suave, silencioso, económico y fiable. Entre los puntos a favor que todos mencionan está el asiento, bien acolchado, y una postura "de moto grande" con un manejo mucho más ligero. El consumo real ronda entre 32 y 48 km/l. Uno de los ejemplos más ilustrativos de uso en Bali: un arrendatario se llevó la V-Strom durante más de 40 días y llegó en ella hasta la isla de Flores y de vuelta. Lección práctica de otro arrendatario en Bali: la parrilla trasera de serie para sujetar bolsas resultó poco fiable en carretera — en la empresa lo cambiaron a una Versys con maletas laterales de verdad; la conclusión es que, si se piensa llevar equipaje, unas maletas rígidas son más prácticas que unas cuerdas sobre la parrilla. Los arrendatarios recomiendan especialmente la dirección hacia Sidemen, el monte Batur y las carreteras alrededor del punto más oriental de Bali, señalando que el tráfico se nota de verdad solo en Uluwatu, Canggu y Ubud — más allá empiezan las terrazas de arroz, la selva y las vistas al océano.

**A quién le conviene:** a quien busca ante todo comodidad en trayectos largos, más que un carácter deportivo. Rutas detalladas, en los artículos del blog: «El este de Bali en moto», «Sekumpul y las cascadas del centro-norte de Bali», «Los volcanes de Bali en moto».

**Dónde rinde mejor en Bali:** el mismo terreno que la Versys-X250 — rutas largas, Sidemen, el monte Batur, la costa este. Si se planea llevar mucho equipaje, basta con avisarnos y añadimos maletas laterales a la moto.', 'Suzuki V-Strom 250: túring centrada en la comodidad y la protección contra el viento', 'Suzuki V-Strom 250 en alquiler en Bali: ficha técnica, consumo real y opiniones de arrendatarios sobre viajes largos por la isla.'
  FROM articles a WHERE a.slug = 'suzuki-v-strom-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'TVS Ronin 225: neorretro al borde del scrambler', 'tvs-ronin-225-neorretro-al-borde-del-scrambler', 'La TVS Ronin 225 es una modern classic con toques de scrambler: faro LED redondo, manillar alto y la misma seguridad en ciudad que en desvíos de tierra.', 'La TVS Ronin 225 es una modern classic con toques de scrambler: faro LED redondo, manillar alto, una geometría versátil que se defiende igual de bien en ciudad que en desvíos de tierra desde la carretera principal. Todas las versiones llevan ABS. [Ver la TVS Ronin 225 en el catálogo](/es/bikes?group=motorcycle&model=tvs_ronin225).

**Características:**
- Motor: 225,9 cm³, refrigeración por aceite, monocilíndrico, SOHC, 4 válvulas
- Potencia: unos 20,4 CV a 7.750 rpm
- Par motor: ~19,9 Nm a 3.750 rpm — entrega tirón ya desde bajas vueltas, sin necesidad de exprimir el motor
- Transmisión: manual de 5 velocidades
- Altura del asiento: ~795 mm
- Peso: ~159 kg
- Depósito: ~14 l
- ABS en todas las versiones (monocanal en la básica, de doble canal en las superiores)

**Fiabilidad:** TVS es una marca con una historia muy larga en la India (fabrica vehículos de dos ruedas desde los años 80), y la propia Ronin, aunque es un modelo relativamente reciente (desde 2022), ya se ha ganado una sólida reputación de fiabilidad tras estos años de uso: en opiniones de propietarios con más de 10.000 km, describen el motor como una unidad que conserva una suavidad ejemplar, las horquillas doradas USD muestran una alta resistencia al desgaste, y el conjunto sigue sin holguras ni ruidos incluso después de un año de uso intensivo sobre firmes distintos. Las valoraciones de fiabilidad y coste de mantenimiento de la Ronin en rankings independientes de propietarios están sistemáticamente entre las más altas de su clase.

**Lo que dicen los propietarios:** el motor arranca con un sonido grave, típico de las motos retro, con un toque ronco. El fuerte par a bajas revoluciones hace que la moto sea especialmente cómoda en tráfico urbano denso. El consumo real en las opiniones es de 35-45 km/l. La suspensión está calibrada blanda — absorbe bien las irregularidades urbanas. Algunas versiones tienen modos de conducción, incluido uno adaptado a la lluvia — útil dado el clima de Bali. La buena dinámica y el aspecto son algo que se menciona constantemente en las opiniones como uno de los puntos fuertes del modelo.

**A quién le conviene:** a quien busca una moto versátil para el día a día — sin la exigencia de una deportiva, pero con margen de sobra en tramos de tierra.

**Dónde rinde mejor en Bali:** tan a gusto en Canggu/Seminyak, gracias a su imagen neorretro, como en los desvíos de tierra hacia las terrazas de arroz.', 'TVS Ronin 225: neorretro al borde del scrambler', 'TVS Ronin 225 en alquiler en Bali: ficha técnica, fiabilidad y opiniones de propietarios sobre esta neorretro de carácter scrambler.'
  FROM articles a WHERE a.slug = 'tvs-ronin-225-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Keeway Road Falcon 250: una crucero clásica a precio de entrada en la clase', 'keeway-road-falcon-250-crucero-clasica-a-precio-de-entrada-en-la-clase', 'La Keeway Road Falcon 250 es una crucero clásica de silueta alargada y asiento bajo, a precio de entrada en la clase. Es un modelo muy nuevo en el mercado, lanzado en 2026.', 'La Keeway Road Falcon 250 tiene silueta alargada, asiento bajo, un color negro discreto y un carácter calcado de las grandes crucero estadounidenses, pero sobre una base compacta de 250cc. Es un modelo muy reciente en el mercado — se lanzó en 2026 — así que todavía apenas hay opiniones de usuarios ni de rentales en Bali. [Ver la Keeway Road Falcon 250 en el catálogo](/es/bikes?group=motorcycle&model=keeway_roadfalcon250).

**Características:**
- Motor: 248 cm³, bicilíndrico en paralelo, 4 tiempos, 4 válvulas, SOHC, refrigeración líquida
- Potencia: unos 24,6 CV a 8.000 rpm
- Par motor: ~23,4 Nm a 6.500 rpm
- Transmisión: manual de 6 velocidades con embrague antirrebote (slipper)
- Altura del asiento: ~698 mm — una de las más bajas de la flota
- Distancia al suelo: ~186 mm
- Depósito: 14 l
- Frenos: disco delantero de 300 mm (pinza de 2 pistones), trasero de 260 mm
- Pantalla TFT de 5 pulgadas, altavoz Bluetooth integrado — una opción poco habitual en esta clase
- Navegación proyectada directamente en el panel de instrumentos — al igual que en la XMAX250, en este modelo tampoco hace falta soporte de móvil

**Lo que dicen los propietarios:** el modelo se compara directamente con motos de estilo Harley-Davidson y con la Honda Rebel — el característico "lomo" del depósito en la parte delantera y la silueta general remiten deliberadamente a las grandes crucero estadounidenses, y en la prensa indonesia hay comparativas directas de la Road Falcon precisamente frente a la Honda Rebel. El altavoz Bluetooth integrado en el manillar es una rareza en esta clase de crucero. El embrague antirrebote suaviza las reducciones de marcha — útil en las zonas con desniveles de Bali. También se destaca que es una moto sorprendentemente manejable, con un radio de giro pequeño para lo que cabría esperar — no resulta obvio para una silueta tan larga de crucero, pero se nota en la práctica.

**A quién le conviene:** a quien busca la imagen clásica de una crucero y una postura relajada — especialmente cómoda para pilotos de estatura baja gracias a su asiento muy bajo.

**Dónde rinde mejor en Bali:** rutas costeras tranquilas — Sanur, Nusa Dua —, pero no solo: nuestros clientes también se han animado a llevarla a zonas normalmente reservadas para las tur-enduro clásicas como la Versys o la V-Strom, así que también aguanta rutas largas por toda la costa norte de Bali, pese a su imagen de crucero.', 'Keeway Road Falcon 250: una crucero clásica a precio de entrada en la clase', 'Keeway Road Falcon 250 en alquiler en Bali: ficha técnica, comparación con la Honda Rebel y a quién le conviene esta crucero.'
  FROM articles a WHERE a.slug = 'keeway-road-falcon-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Morbidelli C252V: una crucero V-twin con nombre italiano', 'morbidelli-c252v-crucero-v-twin-con-nombre-italiano', 'La Morbidelli C252V es la segunda crucero de nuestra flota, pero con un auténtico motor bicilíndrico en V en lugar de un paralelo, y transmisión por correa.', 'Es la segunda crucero de la flota, pero con un carácter radicalmente distinto al de la Road Falcon: la Morbidelli monta un auténtico motor bicilíndrico en V en lugar de un paralelo, de ahí su sonido más "grave" y una vibración que muchos pilotos de crucero consideran parte del placer de conducirla. Morbidelli es un nombre italiano con una historia de competición real (títulos de campeón en las clases 125cc y 250cc de Gran Premio en los años 70), cuyos derechos pertenecen desde 2024 al mismo grupo que es dueño de Keeway — así que no es una coincidencia de apellido, sino una marca oficialmente resucitada sobre una base técnica nueva. [Ver la Morbidelli C252V en el catálogo](/es/bikes?group=motorcycle&model=morbidelli_c252v).

**Características:**
- Motor: 249 cm³, bicilíndrico en V (V-twin), 4 tiempos, 8 válvulas, SOHC, refrigeración líquida
- Potencia: unos 25,5 CV a 9.000 rpm
- Par motor: 25 Nm a 5.500 rpm
- Transmisión: manual de 6 velocidades con embrague antirrebote (slipper)
- Transmisión final: por correa (belt drive) — algo poco habitual en esta clase. En la práctica significa que no hay que engrasarla ni tensarla periódicamente, como una cadena, y que no se oxida con la lluvia
- Altura del asiento: 690 mm — una de las más bajas de la flota
- Peso: ~200 kg
- Depósito: 15,5 l
- Distancia al suelo: 173 mm
- Frenos: disco delantero de 320 mm (pinza de 4 pistones), trasero de 260 mm (2 pistones); ABS Bosch de doble canal y control de tracción de serie
- Horquilla delantera invertida (USD) de 37 mm, recorrido de 115 mm; detrás, dos amortiguadores con precarga regulable en 5 posiciones
- Velocidad máxima declarada: 125 km/h

**Lo que dicen los propietarios:** es un modelo muy reciente en el mercado, así que todavía no tiene un historial de uso de varios años, pero las primeras pruebas en prensa destacan un manejo sorprendentemente ligero para una crucero con una distancia entre ejes tan larga — el radio de giro no delata el tamaño de la moto. El motor en V se describe como visualmente muy llamativo (bien a la vista bajo el depósito, con una imitación de aletas de refrigeración y acabado cromado) y con un sonido notablemente más profundo que el de los típicos bicilíndricos en paralelo de 250cc.

**A quién le conviene:** a quien busca el carácter propio de un V-twin en una crucero (no un paralelo, como en la Road Falcon) — una vibración más marcada y un sonido más grave, más una correa en lugar de cadena, que no hay que engrasar ni tensar y no se oxida con la lluvia.

**Dónde rinde mejor en Bali:** el mismo terreno que la Road Falcon — rutas costeras tranquilas, Sanur, Nusa Dua; la correa y el asiento bajo la hacen especialmente cómoda para quien busca un estilo crucero relajado sin preocuparse de la cadena.', 'Morbidelli C252V: una crucero V-twin con nombre italiano', 'Morbidelli C252V en alquiler en Bali: motor V-twin, transmisión por correa, ficha técnica y en qué se diferencia de la Road Falcon.'
  FROM articles a WHERE a.slug = 'morbidelli-c252v-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Honda CBR250RR: carenado completo y la más «de circuito» de las deportivas con carenado de la flota', 'honda-cbr250rr-carenado-completo-la-mas-de-circuito-de-la-flota', 'La Honda CBR250RR es la única deportiva totalmente carenada de la flota, en su versión tope de gama con quickshifter y ABS. Una de las motos más avanzadas tecnológicamente en la clase 250cc en Indonesia.', 'Es la única deportiva totalmente carenada de la flota (a diferencia de la MT-25 y la ZX-25R, que son naked/streetfighter "desnudas") — la Honda CBR250RR se considera, desde su debut en 2016, una de las motos más avanzadas tecnológicamente de la clase 250cc en Indonesia. [Ver la Honda CBR250RR en el catálogo](/es/bikes?group=motorcycle&model=honda_cbr250rr).

**Características (versión tope de gama SP Quick Shifter con ABS — la que tenemos en la flota):**
- Motor: 249,7 cm³, refrigeración líquida, DOHC, bicilíndrico en paralelo, 8 válvulas, con las mejoras de la versión tope de gama (cigüeñal aligerado, nuevos muelles de válvula, culata modificada)
- Potencia: ~41 CV a 13.000 rpm
- Par motor: ~25 Nm a 11.000 rpm
- Transmisión: manual de 6 velocidades
- Altura del asiento: ~790 mm
- Peso: ~168 kg
- ABS, óptica totalmente LED, panel de instrumentos digital, throttle-by-wire (acelerador electrónico sin cable mecánico)
- Quickshifter con 4 modos configurables (subida+bajada, solo subida, solo bajada, apagado) — cambios de marcha sin usar el embrague
- Embrague antirrebote (slipper)
- Horquilla delantera invertida (USD) tipo SFF-Big Piston
- 3 modos de conducción: Comfort, Sport, Sport+
- Aceleración declarada de 0 a 200 m en 8,65 s, velocidad máxima de hasta 172 km/h

**Lo que dicen los propietarios:** la CBR250RR se menciona constantemente como una de las motos más "cargadas" de tecnología dentro de la clase 250cc en Indonesia — la versión con quickshifter ofrece sensaciones realmente de circuito, poco habituales para esta cilindrada.

**A quién le conviene:** a quien quiera la experiencia deportiva completa — carenado, postura deportiva "tumbado sobre el depósito" y tecnología de nivel MotoGP como el quickshifter.

**Dónde rinde mejor en Bali:** igual que la ZX-25R — ciudad, paseo marítimo, para la sensación y el carácter más que para una ruta concreta; con su ascendencia de circuito, también luce especialmente bien en el trazado de Mandalika, en Lombok.', 'Honda CBR250RR: carenado completo y la más «de circuito» de las deportivas con carenado de la flota', 'Honda CBR250RR en alquiler en Bali: versión tope de gama con quickshifter, ficha técnica y a quién le conviene la experiencia deportiva completa.'
  FROM articles a WHERE a.slug = 'honda-cbr250rr-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'Honda CB150X: estilo adventure accesible sobre un motor de 150cc', 'honda-cb150x-estilo-adventure-accesible-sobre-motor-de-150cc', 'La Honda CB150X es una entrada accesible al estilo adventure con un motor de 150cc, una parte ciclo seria para su clase y el peso más ligero entre las motos de nuestra flota.', 'La CB150X no es lo mismo que las 250cc Versys-X250 y V-Strom250: es una entrada económica al estilo adventure con un modesto motor monocilíndrico de 150cc, pero con una parte ciclo realmente seria para su clase (distancia al suelo casi como la de la CB500X). Gracias a un peso muy ligero para una moto (139 kg), el motor de 150cc sobra y basta — levanta la rueda delantera sin esfuerzo y mantiene una dinámica firme en todo el rango de velocidades, no solo a bajas revoluciones, como podría pensarse por su único cilindro y su modesta cilindrada. [Ver la Honda CB150X en el catálogo](/es/bikes?group=motorcycle&model=honda_cb150x).

**Características:**
- Motor: 149,16 cm³, monocilíndrico, refrigeración líquida, DOHC 4 válvulas
- Potencia: ~15,6 CV a 9.000 rpm
- Par motor: ~13,8 Nm a 7.000 rpm
- Transmisión: manual de 6 velocidades
- Altura del asiento: 817 mm
- Distancia al suelo: 181 mm — casi como la de la CB500X, mucho más grande
- Peso: ~139 kg — la moto (no scooter) más ligera de la flota
- Depósito: 12 l
- Horquilla delantera invertida (USD) Showa SFF-BP de 37 mm, monoamortiguador trasero Pro-Link
- Discos de freno ondulados (wavy) delante y detrás
- Panel de instrumentos totalmente digital con consumo de combustible en tiempo real

**A quién le conviene:** a quien quiera el estilo adventure y una posición elevada, pero no esté listo para el peso y la potencia de una túring de 250cc completa — un buen escalón para pasar de las motos urbanas a modelos más serios.

**Dónde rinde mejor en Bali:** la misma lógica que la ADV160 — caminos secundarios, asfalto irregular, pero por postura y carácter ya es una moto completa con cambio manual, no un scooter.', 'Honda CB150X: estilo adventure accesible sobre un motor de 150cc', 'Honda CB150X en alquiler en Bali: ficha técnica, distancia al suelo y a quién le conviene esta adventure económica.'
  FROM articles a WHERE a.slug = 'honda-cb150x-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'es', 'PCX160 vs ADV160 vs Nmax: cómo elegir entre el trío', 'pcx160-vs-adv160-vs-nmax-como-elegir-entre-el-trio', 'PCX160, ADV160 y Nmax: cómo elegir entre los tres scooters más populares de la flota, en qué se diferencian en maletero, dinámica y postura de conducción.', 'Sinceramente, estos tres modelos se diferencian sobre todo en el aspecto visual y en lo que cada piloto tiene por costumbre — en pocas palabras, es cuestión de gustos. De las diferencias prácticas que sí importan, la primera es el tamaño del maletero: la Nmax es para quien está dispuesto a sacrificar algo de capacidad de maletero a cambio de su postura y su dinámica. Y en cuanto a dinámica pura, en el equipo bromeamos así: quien de verdad quiera una respuesta "Turbo", mejor que dentro de esta gama se lleve la ADV — se siente subjetivamente más viva que el modelo que lleva "Turbo" en el nombre.

Lo ideal, antes de decidirse por una moto para un alquiler largo, es probar cada una entre 5 días y un mes, para notar la diferencia de verdad. Con 1-3 días a menudo no basta para conocer bien una moto.

Fichas de los modelos: [Honda PCX160](/es/bikes?category=honda_pcx160), [Honda ADV160](/es/bikes?category=honda_adv160), [Yamaha Nmax](/es/bikes?category=yamaha_nmax155).', 'PCX160 vs ADV160 vs Nmax: cómo elegir entre el trío', 'Comparativa de Honda PCX160, Honda ADV160 y Yamaha Nmax en alquiler en Bali: qué scooter elegir según tus necesidades.'
  FROM articles a WHERE a.slug = 'pcx160-vs-adv160-vs-nmax-how-to-choose'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Honda PCX160 — comfort e capacità di carico per tutti i giorni', 'honda-pcx160-recensione-comfort-e-capacita-di-carico', 'Honda PCX160 è la scelta più versatile per chi cerca uno scooter comodo senza rinunciare al bagagliaio: il modello preferito da coppie e viaggiatori con valigia.', 'Honda PCX160 è la scelta più versatile per chi vuole uno scooter comodo senza rinunciare al bagagliaio. È il modello che coppie e chi viaggia con valigia o borsone scelgono più spesso. [Guarda la Honda PCX160 nel catalogo](/it/bikes?category=honda_pcx160).

**Caratteristiche:**
- Motore: 156,9 cc, raffreddamento a liquido, eSP+
- Potenza: circa 15,8 CV a 8500 giri/min
- Cambio: variatore automatico (CVT), senza marce da innestare
- Altezza sella: ~764 mm — comoda per praticamente qualsiasi statura
- Serbatoio: 8,1 l
- Bagagliaio sotto sella: ~30 l — ci entra un casco integrale, con spazio anche per altri oggetti
- Smart key, illuminazione a LED, ricarica USB potente, cruscotto digitale
- Da noi trovi un''ampia scelta di colori personalizzati, diversi da quelli standard

**Extra:** sulla PCX160 si può montare un bauletto posteriore SHAD da 44 l — utile per chi trova insufficiente lo spazio sotto sella. Per saperne di più sugli extra disponibili, leggi il nostro articolo [«Extra a noleggio che vale la pena aggiungere: caschi e il bauletto comfort»](/it/blog/extra-a-noleggio-che-vale-la-pena-aggiungere-caschi-e-il-bauletto-comfort).

**Cosa dicono i proprietari:** il consumo reale segnalato nelle recensioni è di circa 40-50 km/l, il che rende gli spostamenti sull''isola praticamente gratuiti. La reputazione del modello in fatto di affidabilità è quasi leggendaria — nei forum la PCX viene paragonata a un tosaerba: si avvia e va avanti per anni senza sorprese. Un dettaglio pratico per chi noleggia: lo smart key è comodo, ma sostituirlo in caso di smarrimento costa circa 1 milione di rupie, quindi meglio non perderlo — per capire come funziona, leggi il nostro articolo [«Come avviare lo scooter e usare la chiave smart»](/it/blog/come-avviare-e-usare-lo-smart-key-del-vostro-scooter-a-noleggio). Con un passeggero a bordo, la ripresa in fase di sorpasso si riduce sensibilmente — non è un problema in città, ma va tenuto presente in strada extraurbana.

**Dove si comporta bene a Bali:** tiene bene l''asfalto grazie alla ruota anteriore da 14 pollici — comoda a Canggu, Seminyak, Sanur, e per gli spostamenti quotidiani a Denpasar.', 'Honda PCX160 — comfort e capacità di carico per tutti i giorni', 'Scheda tecnica, consumi, recensioni dei proprietari ed extra per la Honda PCX160 a noleggio a Bali: dove si comporta meglio e per chi è indicata.'
  FROM articles a WHERE a.slug = 'honda-pcx160-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Honda ADV160 — per strade sconnesse e gite fuori porta', 'honda-adv160-recensione-per-strade-sconnesse-e-gite-fuori-porta', 'Honda ADV160 monta lo stesso motore affidabile della PCX160 in una scocca diversa: seduta più alta, più luce da terra, più sicurezza su asfalto rovinato e sterrato.', 'Honda ADV160 ha lo stesso motore affidabile della PCX160, ma in una scocca diversa: seduta più alta, maggiore luce da terra, più sicura su asfalto rovinato e tratti sterrati. [Guarda la Honda ADV160 nel catalogo](/it/bikes?category=honda_adv160).

**Caratteristiche:**
- Motore: 156,9 cc, raffreddamento a liquido, eSP+ (lo stesso della PCX160)
- Potenza: circa 15,8 CV
- Cambio: variatore automatico (CVT)
- Altezza sella: ~795 mm — più alta rispetto agli scooter urbani, adatta a chi è più alto o preferisce una seduta più elevata
- Luce da terra ~165 mm — decisamente superiore allo standard
- Bagagliaio sotto sella: ~30 l — ci entra un casco integrale, con spazio anche per altri oggetti
- Parabrezza regolabile — 2 posizioni: alta (aggressiva) e bassa (cittadina)
- Cruscotto semi-digitale, ricarica USB potente, smart key
- Da noi trovi un''ampia scelta di colori personalizzati, diversi da quelli standard

**Extra:** come sulla PCX160, si può montare un bauletto posteriore SHAD da 44 l. Per saperne di più, leggi il nostro articolo [«Extra a noleggio che vale la pena aggiungere: caschi e il bauletto comfort»](/it/blog/extra-a-noleggio-che-vale-la-pena-aggiungere-caschi-e-il-bauletto-comfort).

**Cosa dicono i proprietari:** l''economia di esercizio è il secondo grande punto di forza di questo motore: nelle recensioni il consumo reale si mantiene intorno ai 34-38 km/l — si fa rifornimento raramente anche guidando in modo brillante. Tra l''altro, la ADV160 è uno dei modelli più dinamici della gamma PCX-Nmax-ADV, nonostante monti lo stesso motore della PCX160 — cambia solo la mappatura. La luce da terra si fa davvero sentire su sterrato e asfalto rovinato, ma i proprietari avvertono onestamente: si tratta di uno stile adventure urbano, non di una vera enduro — su pietre grandi e dislivelli importanti la luce da terra non basta comunque.

**Dove si comporta bene a Bali:** Ubud e dintorni (terrazze di riso, strade laterali), Munduk e le cascate, i tratti collinari di Uluwatu e del Bukit — il terreno e la qualità del fondo variano, e la ADV160 perdona molto più di uno scooter urbano, ma il vero fuoristrada impegnativo non è il suo terreno.', 'Honda ADV160 — per strade sconnesse e gite fuori porta', 'Scheda tecnica, consumi e recensioni dei proprietari della Honda ADV160 a noleggio a Bali: dove si esprime al meglio il suo stile adventure urbano.'
  FROM articles a WHERE a.slug = 'honda-adv-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Yamaha Nmax — New (Gen 2), Neo (Gen 3) e Turbo', 'yamaha-nmax-new-neo-e-turbo-recensione', 'Yamaha Nmax nel nostro parco non è un modello unico, ma diverse generazioni e allestimenti sotto lo stesso nome: New, Neo e Turbo. Vediamo cosa li distingue davvero.', '“Nmax” nel nostro parco mezzi non è un modello unico, ma diverse generazioni e allestimenti sotto lo stesso nome. New e Neo condividono motore e trasmissione, cambia solo la generazione della gamma (Gen 2 e Gen 3). Turbo invece è un discorso a parte, con un''elettronica della trasmissione diversa. [Guarda la Yamaha Nmax nel catalogo](/it/bikes?category=yamaha_nmax155).

**Nmax New (Gen 2):**
- Motore: 155 cc, Blue Core, VVA, SOHC 4 valvole
- Potenza: ~15 CV a 8000 giri/min
- Cambio: variatore automatico (CVT) classico a rulli
- Peso: ~132 kg
- Serbatoio: 7,1 l

**Nmax Neo (Gen 3):**
- Stesso motore Blue Core VVA da 155 cc di cilindrata e costruzione del New — cambiano solo l''estetica, la generazione e l''allestimento, non la meccanica
- Potenza: ~15 CV a 8000 giri/min
- Cambio: variatore automatico classico
- Peso: ~130 kg
- Due versioni: Neo (base) e Neo S (+ sistema Smart Key)

**Nmax “Turbo”:**
- Stesso motore per cilindrata del New/Neo
- Differenza principale: YECVT (Yamaha Electric CVT) — di fatto lo stesso schema del variatore, ma con controllo elettronico al posto dei rulli puramente meccanici. È più una questione di sensazioni di guida e regolazioni elettroniche che di una trasmissione realmente diversa
- Due modalità di guida T-Mode/S-Mode più le “marce” virtuali Y-Shift (Low/Medium/High) — un''imitazione del cambio marce, come in auto
- Peso: ~133-135 kg a seconda della versione
- Tre versioni: Turbo (base), Turbo Tech Max (display TFT, porta USB-C, sella dedicata), Turbo Tech Max Ultimate (top di gamma)
- Importante: “Turbo” nel nome si riferisce all''elettronica e alla sensazione di risposta, non a un turbocompressore reale sul motore
- Da noi trovi un''ampia scelta di colori personalizzati, diversi da quelli standard

**Cosa dicono i proprietari:** il motore (in qualsiasi generazione) viene definito “indistruttibile” nelle recensioni — l''affidabilità è uno dei punti di forza di tutta la gamma. Anche l''economia di esercizio è un punto forte — lo stesso motore da 155 cc parsimonioso degli altri modelli della famiglia (PCX160, ADV160) mantiene consumi contenuti nell''uso reale, e si fa rifornimento raramente. Una curiosità sul bagagliaio: le cifre dichiarate non sono piccole, ma la forma del vano è tale che un casco integrale non sempre ci entra. Nota positiva: sotto il fianco sinistro del manubrio c''è un vano dedicato per telefono e portafoglio. Nelle recensioni degli affittuari balinesi viene lodata in particolare la ripresa in salita (“tanjakan”) e la sospensione morbida per i tragitti lunghi — ad esempio fino a Uluwatu. L''ABS e gli pneumatici tubeless larghi vengono citati come un vantaggio a parte in diverse guide per turisti, proprio per i frequenti acquazzoni tropicali e gli ostacoli improvvisi sulla strada, come i cani — i freni non bloccano la ruota nel panico.

**Dove si comporta bene a Bali:** si trova a suo agio sia nel traffico cittadino (Canggu, Seminyak) sia su percorsi di media lunghezza, comprese le gite fino a Uluwatu — buona stabilità in curva e sotto la pioggia. Vale allo stesso modo per tutte le versioni — geometria e seduta sono quasi identiche tra loro.', 'Yamaha Nmax — New (Gen 2), Neo (Gen 3) e Turbo', 'Yamaha Nmax a noleggio a Bali: le differenze tra New, Neo e Turbo, scheda tecnica e recensioni reali dei proprietari.'
  FROM articles a WHERE a.slug = 'yamaha-nmax-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Yamaha XMAX250 — Connected e Tech Max: stessa meccanica, livello di finitura diverso', 'yamaha-xmax250-connected-e-tech-max-recensione', 'Yamaha XMAX250 è lo scooter più potente della gamma, ottimo sulle lunghe distanze e in città. Nel nostro parco è disponibile nelle versioni Connected e Tech Max, con la stessa meccanica.', 'Yamaha XMAX250 è lo scooter più potente della gamma. In tanti amano proprio questa grande bestia, e anche se tutti concordano che se la cava benissimo sulle lunghe distanze, per molti non c''è niente di meglio anche negli spostamenti brevi in città. Nel nostro parco il modello è disponibile in due versioni — Connected e Tech Max — ed è importante capire una cosa: tecnicamente è lo stesso scooter, cambia solo la finitura. [Guarda la Yamaha XMAX250 nel catalogo](/it/bikes?category=yamaha_xmax250).

**Caratteristiche (identiche per Connected e Tech Max — motore e ciclistica sono uguali):**
- Motore: 250 cc, monocilindrico, raffreddamento a liquido, SOHC 4 valvole, Blue Core, albero motore forgiato monoblocco (one-piece forged crankshaft)
- Potenza: 16,8 kW a 7000 giri/min
- Coppia: 24,3 Nm a 5500 giri/min
- Cambio: variatore automatico (CVT)
- Altezza sella: 795 mm
- Peso: ~181 kg
- Serbatoio: 13 l
- Bagagliaio sotto sella: 44,9 l — moltissimo spazio, ci entrano davvero due caschi integrali più altri oggetti. Un dettaglio importante: a volte bisogna orientare il casco integrale in un certo modo per farlo entrare correttamente
- ABS, controllo di trazione (TCS), Emergency Stop Signal (lampeggio di emergenza delle luci di stop in frenata brusca), smart key con Answer Back System (segnale acustico per ritrovare lo scooter nel parcheggio), presa elettrica per ricaricare il telefono
- Parabrezza sulla Connected — fisso, non regolabile. La regolazione del parabrezza è un''esclusiva della Tech Max (vedi sotto)
- Garanzia Yamaha Indonesia — 5 anni / 50.000 km su telaio, componenti dell''impianto di alimentazione, cilindro e pistone

**App Y-Connect — un dettaglio importante da spiegare a parte a chi noleggia:**

Per il modello XMAX Connected è disponibile il collegamento con l''app:

📱 Si scarica qui:
https://apps.apple.com/app/id1495921872
https://apps.apple.com/app/id1585591110

Cosa offre il collegamento:
• Ricezione delle chiamate in arrivo dal manubrio
• Cambio brano musicale dal manubrio
• Navigazione in lingua russa
• Integrazione comoda con lo smartphone

**Connected vs Tech Max — la differenza:**

La differenza più importante e più costosa è la sella. Sulla Tech Max non si tratta solo di “una cucitura diversa”: è una sella progettata a parte, prodotta da MBK (marchio francese di proprietà di Yamaha, specializzato proprio negli scooter europei) — la cosiddetta “Comfort Seat”. All''interno c''è una schiuma ad alta densità (high-density foam) e cuscinetti laterali di supporto (bolster) progettati specificamente per i viaggi di più ore: la sella mantiene la postura e riduce l''affaticamento lombare sulle percorrenze lunghe, non è semplicemente più morbida al tatto. Sopra — ecopelle con inserti scamosciati e cuciture a filo dorato, più un inserto cromato. Nelle recensioni, i proprietari indicano proprio la sella come il motivo principale per pagare di più la Tech Max, non il colore o le placche.

Le altre differenze sono reali, ma per prezzo e importanza restano dietro alla sella:
- Colore esclusivo (Magma Black sui modelli precedenti, dal 2025 Ceramic Grey)
- Coperchio del vano sottosella in ecopelle con scamosciato e cuciture dorate (in tinta con la sella)
- Pedane in alluminio, placca cromata, placche dedicate e texture delle manopole Tech Max
- Sul modello Tech Max 2025 è comparsa l''unica differenza davvero funzionale (non solo estetica) — la regolazione elettrica del parabrezza (Electric Adjustable Screen), utilizzabile anche in movimento per regolarlo rapidamente secondo le proprie sensazioni, più un cruscotto TFT aggiornato; sulla Connected il parabrezza, come detto, non è regolabile

La differenza di prezzo sul mercato indonesiano è di circa 5 milioni di rupie per la versione Tech Max, e questi soldi vanno prima di tutto nella sella.

**Cosa dicono i proprietari:** il motore tira comodamente fino a 100-110 km/h, oltre inizia ad “affannarsi” — non è uno scooter da accelerazioni, ma da andatura costante da crociera. Il club indonesiano dei proprietari XMAX ha organizzato il primo raduno del nuovo modello proprio a Bali già nel 2017 — percorso Denpasar → Ubud → Kintamani → Besakih → Klungkung → Gianyar → la statale Ida Bagus Mantra e ritorno; sui tratti tortuosi di Ubud e Kintamani i partecipanti hanno testato il controllo di trazione, mentre sul rettilineo della statale a pedaggio Ida Bagus Mantra hanno raggiunto i 140 km/h.

Gli itinerari già pronti per la XMAX250 a Bali, indicati dagli stessi motociclisti: costa sud — Canggu → Uluwatu (via Jalan Bali Cliff) → spiaggia di Pandawa → GWK; percorso di montagna — Denpasar → Ubud → Kintamani → lago Batur → Munduk; percorso orientale — Sanur → Candidasa → Sidemen → Virgin Beach. Itinerari dettagliati e punti sulla mappa nei nostri articoli del blog «La penisola di Bukit in moto», «Kintamani: l''alba sul vulcano Batur» e «Bali orientale in moto» (dove si trova anche Virgin Beach) — in pubblicazione a breve.

**Per chi è adatta:** per gite di uno o più giorni sull''isola, dove contano la potenza in riserva per sorpassi e salite, oltre al comfort sui tratti lunghi. È anche un''ottima scelta per l''uso quotidiano — uno dei modelli più richiesti sia tra i turisti che tra chi vive a Bali da tempo.

**Dove si comporta bene a Bali:** gli itinerari fuori dal sud dell''isola — Kintamani e il vulcano Batur, Amed, Lovina, Sidemen, la costa orientale. Ma anche qui è una questione di gusti — c''è chi si diverte a guidare questo grande tourer-enduro anche nel traffico di Canggu, e gli appassionati così non sono affatto pochi.', 'Yamaha XMAX250 — Connected e Tech Max: stessa meccanica, livello di finitura diverso', 'Yamaha XMAX250 a noleggio a Bali: differenze tra Connected e Tech Max, scheda tecnica, app Y-Connect e itinerari sull''isola.'
  FROM articles a WHERE a.slug = 'yamaha-xmax250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Yamaha MT-25 — Gen 2 e Gen 3: aspetto diverso, stesso motore', 'yamaha-mt-25-gen-2-e-gen-3-recensione', 'Yamaha MT-25 è uno streetfighter compatto per chi vuole sentire l''accelerazione e la risposta di una vera moto. Nel parco si trovano esemplari Gen 2 e Gen 3 dopo il restyling del 2025.', 'Yamaha MT-25 è uno streetfighter compatto per chi vuole sentire l''accelerazione e la risposta di una vera moto, non solo andare dal punto A al punto B. È una moto con carattere davvero riconoscibile: moltissimi appassionati e professionisti la indicano come una delle loro preferite nella categoria, sia per dinamica che per posizione di guida e look. Cambio manuale e assetto aggressivo sono ciò che la distingue davvero dagli scooter del nostro parco. Nel 2025 Yamaha Indonesia ha lanciato un restyling importante (“Gen 3”), quindi nel parco possono trovarsi affiancati esemplari vecchio e nuovo stile con lo stesso nome di modello. [Guarda la Yamaha MT-25 nel catalogo](/it/bikes?group=motorcycle&model=yamaha_mt25).

**Caratteristiche (comuni — il motore in sé non è cambiato tra le generazioni):**
- Motore: 249,55 cc, raffreddamento a liquido, DOHC, bicilindrico parallelo, 8 valvole
- Potenza: circa 35,5 CV a 12.000 giri/min
- Coppia: ~22,6 Nm a 10.000 giri/min
- Cambio: manuale a 6 marce
- Altezza sella: ~780 mm
- Serbatoio: ~14 l

**Gen 2 (aggiornamento ~2019 — il look “classico” più riconoscibile della MT-25):**
- Un solo disco freno anteriore
- Senza frizione antisaltellamento, senza ABS
- Peso: ~165-167 kg

**Gen 3 (restyling 2025, posizionata da Yamaha come “Hypernaked” — secondo il sito ufficiale Yamaha Indonesia):**
- Nuovo faro aggressivo in stile MT-07/serie R — ottica spigolosa, “aliena”, diversa dal faro tondo della Gen 1 (la Gen 2 si era già allontanata dalla forma rotonda, ma la Gen 3 ha una geometria propria, ancora più tagliente)
- ABS — presente per la prima volta sulla MT-25 proprio con la Gen 3
- Frizione antisaltellamento — lavora in modo più morbido nelle scalate brusche
- Y-Connect (app Bluetooth) tramite modulo CCU — prima tecnologia di questo tipo su una moto assemblata in Indonesia
- Big Bike Switch 3-in-1 — blocco compatto dei comandi unificato, in stile con le moto “grandi” di Yamaha
- Cruscotto completamente digitale con spia del momento ottimale per cambiare marcia (shift timing light)
- Presa elettrica per ricaricare i dispositivi
- Peso: ~169 kg — leggermente superiore alla Gen 2, per via della nuova dotazione

**Dove si comporta bene a Bali:** Canggu e Seminyak — scatti brevi e decisi nel traffico cittadino e giri serali sul lungomare, dove il carattere della moto si esprime al meglio.', 'Yamaha MT-25 — Gen 2 e Gen 3: aspetto diverso, stesso motore', 'Yamaha MT-25 a noleggio a Bali: le differenze tra Gen 2 e Gen 3, scheda tecnica del motore e dove si esprime al meglio il carattere streetfighter.'
  FROM articles a WHERE a.slug = 'yamaha-mt25-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Kawasaki Ninja ZX-25R — l''unica sportiva di serie da 250 cc con quattro cilindri in linea', 'kawasaki-ninja-zx-25r-recensione-quattro-cilindri-in-linea', 'Kawasaki Ninja ZX-25R è l''unica sportiva di serie da 250cc con motore a quattro cilindri in linea. Carattere ad alti regimi e quickshifter di serie.', 'Ninja ZX-25R occupa una posizione unica nella classe 250cc: è l''unica sportiva di serie di questa cilindrata con motore a quattro cilindri in linea (tutte le concorrenti montano motori mono o bicilindrici). Da qui il caratteristico suono ad alti regimi e la necessità di tenere il motore su di giri. [Guarda la Kawasaki Ninja ZX-25R nel catalogo](/it/bikes?group=motorcycle&model=kawasaki_zx25r).

**Caratteristiche:**
- Motore: 249 cc, raffreddamento a liquido, DOHC, quattro cilindri in linea — configurazione rara per la categoria
- Potenza: circa 45 CV (versione indonesiana senza ram-air) a 15.500 giri/min, zona rossa fino a 17.000 giri/min
- Cambio: manuale a 6 marce
- Altezza sella: ~785 mm
- Peso: ~183 kg
- Serbatoio: ~15 l
- Carena completa, posizione di guida sportiva
- Quickshifter di serie (Quick Shifter) — cambio marcia senza usare la frizione, con blip automatico dell''acceleratore in scalata

**Cosa dicono i proprietari:** il solo fatto di avere un motore a 4 cilindri nella classe 250cc è così insolito che Kawasaki, a suo tempo, ha pubblicato un video dedicato al suono di questo motore al banco prova — i commenti descrivevano il suono come “cattivo” e “folle” per una cilindrata così piccola. Alcuni piloti esperti segnalano che il quickshifter di serie (con blip automatico in scalata) funziona benissimo e trasforma le normali velocità balinesi in una guida davvero appagante — non serve andare in pista per godersi i cambi marcia. Tra i difetti: chi supera i 180 cm di altezza, a fine giornata sente le gambe affaticate per via della posizione di guida, e la sospensione è tarata per la città, non per la pista. La potenza di picco arriva solo a 15.500 giri/min, e chi è abituato a guidare a bassi regimi troverà la moto fiacca finché i giri non salgono.

**Per chi è adatta:** a piloti sicuri che vogliono il massimo delle emozioni dalla classe 250cc e sono disposti a tenere alti i regimi — non è una moto per una guida tranquilla a bassi giri.

**Dove si comporta bene a Bali:** punta più sulle sensazioni e sul carattere che su un percorso specifico — si trova bene dove va bene anche la MT-25 (città, lungomare), e sul circuito di livello mondiale di Mandalika, sull''isola vicina di Lombok. Non tutti i noleggi permettono queste uscite, ma con noi è possibile. È la moto più esigente del parco — non adatta a chi guida una moto per la prima volta, e non ideale per piloti alti per un''intera giornata.', 'Kawasaki Ninja ZX-25R — l''unica sportiva di serie da 250 cc con quattro cilindri in linea', 'Kawasaki Ninja ZX-25R a noleggio a Bali: il raro motore a 4 cilindri in linea da 250cc, il quickshifter e per chi è adatta questa sportiva.'
  FROM articles a WHERE a.slug = 'kawasaki-ninja-zx-25r-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Yamaha XSR155 — un cafe racer dal carattere retrò', 'yamaha-xsr155-recensione-cafe-racer-dal-carattere-retro', 'Yamaha XSR155 è una moto neo-retrò con faro tondo, manubrio basso e posizione da cafe racer, su un motore di famiglia da 155 cc tarato più potente per il cambio manuale.', 'Yamaha XSR155 è una moto neo-retrò: faro tondo, manubrio basso, posizione da cafe racer. Lo stesso motore di famiglia da 155 cc degli scooter della gamma, ma nella versione a cambio manuale è tarato più potente. [Guarda la Yamaha XSR155 nel catalogo](/it/bikes?group=motorcycle&model=yamaha_xsr).

**Caratteristiche:**
- Motore: 155 cc, raffreddamento a liquido, SOHC, VVA — la stessa base dell''Nmax155, ma con una mappatura diversa per il cambio manuale
- Potenza: circa 19,3 CV a 10.000 giri/min
- Cambio: manuale a 6 marce
- Altezza sella: ~815 mm — seduta bassa da cafe racer
- Peso: ~131-134 kg
- Serbatoio: ~10 l

**Cosa dicono i proprietari:** il telaio della XSR155 deriva dalla sportiva R15, quindi la moto è leggera e molto reattiva nella guida. Con un uso attento del gas, il consumo reale arriva fino a ~50 km/l. Un punto importante per chi pensa di viaggiare in due: la sella posteriore è compatta e rigida, e su molte versioni manca una maniglia adeguata per il passeggero. Uno degli affittuari balinesi ha lasciato una recensione significativa proprio su questo modello: nonostante i modesti 155 cc, la moto “va dura” sulle strade di Bali, è ben tarata per il suo prezzo e si tiene così sicura sull''asfalto locale che, a suo dire, se la giocherebbe alla pari persino con una Yamaha R3 nelle stesse curve — il noleggiatore gli ha portato la moto a tre ore di distanza, ad Amed, e non lo ha deluso.

**Per chi è adatta:** a chi cerca stile e carattere motociclistico, ma senza potenza eccessiva — un passaggio confortevole dallo scooter alla moto con cambio manuale.

**Dove si comporta bene a Bali:** Canggu e Seminyak — l''estetica retrò della moto si sposa perfettamente con l''atmosfera della zona; ma, a giudicare dalle recensioni, se la cava bene anche su itinerari più lunghi e tortuosi, come la gita ad Amed.', 'Yamaha XSR155 — un cafe racer dal carattere retrò', 'Yamaha XSR155 a noleggio a Bali: scheda tecnica, recensioni dei proprietari e per chi è adatta questa moto neo-retrò con cambio manuale.'
  FROM articles a WHERE a.slug = 'yamaha-xsr-155-review-retro-style'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Kawasaki Versys-X 250 — touring con margine per lo sterrato', 'kawasaki-versys-x250-recensione-touring-fuoristrada', 'Kawasaki Versys-X 250 è una enduro-touring con seduta alta, sospensioni a lunga escursione e serbatoio maggiorato, per chi vuole esplorare le strade laterali dell''isola.', 'Kawasaki Versys-X 250 è una enduro-touring: seduta alta, sospensioni a lunga escursione, serbatoio maggiorato. Una moto per chi non vuole solo percorrere l''asfalto, ma esplorare anche le strade laterali dell''isola. [Guarda la Kawasaki Versys-X 250 nel catalogo](/it/bikes?group=motorcycle&model=kawasaki_versys).

**Caratteristiche:**
- Motore: 249 cc, raffreddamento a liquido, DOHC, bicilindrico parallelo
- Potenza: circa 27 CV a 9700 giri/min
- Cambio: manuale a 6 marce
- Altezza sella: ~845 mm — nettamente più alta rispetto agli altri modelli del parco
- Peso: ~184 kg
- Serbatoio: ~17 l — uno dei più grandi del parco, autonomia maggiorata
- Parabrezza, pedana enduro, posizione per guidare a lungo sia in piedi che seduti

**Cosa dicono i proprietari:** il consumo reale con guida tranquilla fino a 105 km/h è di circa 27-30 km/l (confermato indipendentemente anche dai noleggiatori balinesi — circa 3-4 l per 100 km), il che con un serbatoio da 17 litri garantisce un''autonomia notevole senza rifornimenti. Il fuoristrada non è solo marketing: in uno dei primi test la moto ha attraversato con sicurezza un tratto di fango profondo senza mai toccare il fondo con la sospensione. La sella di serie è rigida all''inizio e richiede un periodo di “rodaggio”. La moto è più a suo agio nella fascia 80-110 km/h. Gli affittuari balinesi segnalano che la moto li ha portati senza problemi persino fino a un villaggio di montagna isolato, e che la versione a cambio manuale si è comportata benissimo in un viaggio sotto la pioggia verso il nord dell''isola. Itinerari già pronti, indicati dagli stessi noleggiatori: sud di Bali — Ubud — Kintamani, le strade di montagna del nord dell''isola, la costa orientale fino ad Amed e Tulamben.

**Per chi è adatta:** per itinerari di più giorni sull''isola e per chi vuole sicurezza su sterrato o asfalto rovinato. Itinerari dettagliati negli articoli del blog: «Bali orientale in moto», «Kintamani: l''alba sul vulcano Batur», «Bedugul — Munduk — Lovina».

**Dove si comporta bene a Bali:** itinerari lunghi — Kintamani, il nord e l''est dell''isola (compresi Amed e Tulamben), strade laterali fuori dalle principali rotte turistiche.', 'Kawasaki Versys-X 250 — touring con margine per lo sterrato', 'Kawasaki Versys-X 250 a noleggio a Bali: scheda tecnica, autonomia, recensioni dei proprietari e i migliori itinerari per l''enduro-touring.'
  FROM articles a WHERE a.slug = 'kawasaki-versys-x250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Suzuki V-Strom 250 — touring con focus su comfort e protezione dal vento', 'suzuki-v-strom-250-recensione-comfort-e-protezione-dal-vento', 'Suzuki V-Strom 250 è una adventure-touring con focus sul comfort nei viaggi lunghi: parabrezza largo, seduta verticale e sospensioni morbide.', 'Suzuki V-Strom 250 è una adventure-touring con focus sul comfort nei viaggi lunghi: parabrezza largo, seduta verticale ideale, sospensioni morbide per percorrenze lunghe senza affaticamento. [Guarda la Suzuki V-Strom 250 nel catalogo](/it/bikes?group=motorcycle&model=suzuki_vstrom250).

**Caratteristiche:**
- Motore: 248 cc, raffreddamento a liquido, DOHC, bicilindrico parallelo
- Potenza: circa 25 CV a 8000 giri/min
- Cambio: manuale a 6 marce
- Altezza sella: ~800-835 mm a seconda della versione
- Serbatoio: 12 l

**Cosa dicono i proprietari:** nelle recensioni il motore viene paragonato a una macchina da cucire — scorrevole, silenzioso, parsimonioso e affidabile. Tra i pro citati da tutti — una sella ben imbottita e una posizione di guida “da moto grande” ma con una maneggevolezza molto più semplice. Il consumo reale nell''uso quotidiano va da 32 a 48 km/l. Uno degli esempi più significativi di utilizzo a Bali: un affittuario ha preso la V-Strom per oltre 40 giorni ed è arrivato fino all''isola di Flores e ritorno. Una lezione pratica da un altro affittuario balinese: il portapacchi posteriore di serie si è rivelato poco affidabile in viaggio — in agenzia lo hanno fatto passare a una Versys con veri e propri bauletti laterali; la conclusione è che, se si prevede di portare bagagli, i bauletti sono più comodi delle corde sul portapacchi. Gli affittuari consigliano in particolare la direzione verso Sidemen, il monte Batur e le strade intorno al punto più orientale di Bali, notando che il traffico si fa sentire davvero solo a Uluwatu, Canggu e Ubud — oltre iniziano le terrazze di riso, la giungla e le viste sull''oceano.

**Per chi è adatta:** a chi cerca soprattutto comfort sui lunghi tragitti, non un carattere sportivo. Itinerari dettagliati negli articoli del blog: «Bali orientale in moto», «Le cascate di Sekumpul nel nord centrale di Bali», «I vulcani di Bali in moto».

**Dove si comporta bene a Bali:** la stessa nicchia della Versys-X250 — itinerari lunghi, Sidemen, il monte Batur, la costa orientale. Se si prevede molto bagaglio, basta dircelo e aggiungiamo i bauletti laterali alla moto.', 'Suzuki V-Strom 250 — touring con focus su comfort e protezione dal vento', 'Suzuki V-Strom 250 a noleggio a Bali: scheda tecnica, consumi reali e recensioni di chi l''ha usata per i viaggi lunghi sull''isola.'
  FROM articles a WHERE a.slug = 'suzuki-v-strom-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'TVS Ronin 225 — neo-retrò al limite dello scrambler', 'tvs-ronin-225-recensione-neo-retro-al-limite-dello-scrambler', 'TVS Ronin 225 è una modern classic con accenti da scrambler: faro LED tondo, manubrio alto e sicurezza sia in città sia sulle deviazioni sterrate.', 'TVS Ronin 225 è una modern classic con accenti da scrambler: faro LED tondo, manubrio alto, geometria versatile che si trova a suo agio sia in città sia sulle deviazioni sterrate dalla strada principale. Tutte le versioni montano l''ABS. [Guarda la TVS Ronin 225 nel catalogo](/it/bikes?group=motorcycle&model=tvs_ronin225).

**Caratteristiche:**
- Motore: 225,9 cc, raffreddamento a olio, monocilindrico, SOHC, 4 valvole
- Potenza: circa 20,4 CV a 7750 giri/min
- Coppia: ~19,9 Nm a 3750 giri/min — spinge già ai bassi regimi, non serve tenerla su di giri
- Cambio: manuale a 5 marce
- Altezza sella: ~795 mm
- Peso: ~159 kg
- Serbatoio: ~14 l
- ABS su tutte le versioni (monocanale sulla base, bicanale sulle versioni superiori)

**Affidabilità:** TVS è un marchio con una storia molto lunga in India (produce veicoli a due ruote dagli anni ''80), e la stessa Ronin, pur essendo un modello relativamente recente (dal 2022), ha già costruito una solida reputazione di affidabilità negli anni di utilizzo: nelle recensioni dei proprietari con oltre 10.000 km percorsi, il motore viene descritto come ancora fluido come al primo giorno, le forcelle dorate USD mostrano un''ottima resistenza all''usura, e gli accoppiamenti restano privi di giochi e vibrazioni anche dopo un anno di guida intensa su fondi diversi. Nei rating indipendenti dei proprietari, i punteggi di affidabilità e costo di manutenzione della Ronin sono stabilmente tra i più alti della categoria.

**Cosa dicono i proprietari:** il motore si avvia con un suono profondo tipico delle moto retrò, con una leggera rauchezza. Una buona coppia ai bassi regimi rende la moto particolarmente comoda nel traffico cittadino intenso. Il consumo reale nelle recensioni è di 35-45 km/l. Le sospensioni sono tarate morbide — assorbono bene le sconnessioni cittadine. Alcune versioni offrono modalità di guida, incluse quelle adattate per la pioggia — utile considerando il clima di Bali. Ottima dinamica di guida e aspetto estetico — segnalati regolarmente nelle recensioni come uno dei punti di forza del modello.

**Per chi è adatta:** a chi vuole una moto versatile per l''uso quotidiano — senza l''intransigenza di una sportiva, ma con margine di sicurezza sui tratti sterrati.

**Dove si comporta bene a Bali:** è brillante a Canggu/Seminyak grazie al look neo-retrò, tanto quanto sulle deviazioni sterrate laterali verso le terrazze di riso.', 'TVS Ronin 225 — neo-retrò al limite dello scrambler', 'TVS Ronin 225 a noleggio a Bali: scheda tecnica, affidabilità e recensioni dei proprietari su questa neo-retrò dal carattere scrambler.'
  FROM articles a WHERE a.slug = 'tvs-ronin-225-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Keeway Road Falcon 250 — una cruiser classica al prezzo d''ingresso della categoria', 'keeway-road-falcon-250-recensione-cruiser-classica', 'Keeway Road Falcon 250 è una cruiser classica dalla linea allungata e seduta bassa, al prezzo d''ingresso della categoria. Modello nuovissimo, lanciato nel 2026.', 'Keeway Road Falcon 250 ha una linea allungata, seduta bassa, un colore nero sobrio e un carattere ispirato alle grandi cruiser americane, ma su una base compatta da 250 cc. Il modello è nuovissimo sul mercato — lanciato nel 2026 — quindi recensioni degli utenti e dei noleggiatori balinesi al momento ce ne sono ancora poche. [Guarda la Keeway Road Falcon 250 nel catalogo](/it/bikes?group=motorcycle&model=keeway_roadfalcon250).

**Caratteristiche:**
- Motore: 248 cc, bicilindrico parallelo, 4 tempi, 4 valvole, SOHC, raffreddamento a liquido
- Potenza: circa 24,6 CV a 8000 giri/min
- Coppia: ~23,4 Nm a 6500 giri/min
- Cambio: manuale a 6 marce con frizione antisaltellamento
- Altezza sella: ~698 mm — una delle sedute più basse del parco
- Luce da terra: ~186 mm
- Serbatoio: 14 l
- Freni: disco anteriore da 300 mm (pinza a 2 pistoncini), posteriore da 260 mm
- Display TFT da 5 pollici, cassa Bluetooth integrata — un''opzione rara per questa categoria
- Navigazione proiettata direttamente sul cruscotto — come sulla XMAX250, per questo modello il supporto per il telefono non serve proprio

**Cosa dicono i proprietari:** il modello viene paragonato direttamente alle moto in stile Harley-Davidson e alla Honda Rebel — il caratteristico “serbatoio a gobba” anteriore e la linea generale richiamano volutamente le grandi cruiser americane, e sulla stampa indonesiana si trovano recensioni comparative dirette tra la Road Falcon e la Honda Rebel. La cassa Bluetooth integrata nel manubrio è una rarità per le cruiser di questa categoria. La frizione antisaltellamento ammorbidisce le scalate — utile sui tratti collinari di Bali. Viene segnalata anche una manovrabilità sorprendente, con un raggio di sterzata piccolo — per una linea da cruiser così allungata non è scontato, ma si nota nella pratica.

**Per chi è adatta:** a chi vuole l''immagine classica della cruiser e una posizione di guida rilassata — particolarmente comoda per i piloti di statura non elevata, grazie alla sella molto bassa.

**Dove si comporta bene a Bali:** itinerari costieri tranquilli — Sanur, Nusa Dua — ma non solo: i nostri clienti l''hanno portata anche in luoghi di solito riservati alle classiche enduro-touring come la Versys e la V-Strom, quindi anche gli itinerari lunghi lungo tutta la costa nord di Bali sono alla sua portata, nonostante l''immagine da cruiser.', 'Keeway Road Falcon 250 — una cruiser classica al prezzo d''ingresso della categoria', 'Keeway Road Falcon 250 a noleggio a Bali: scheda tecnica, confronto con la Honda Rebel e per chi è adatta questa cruiser.'
  FROM articles a WHERE a.slug = 'keeway-road-falcon-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Morbidelli C252V — una cruiser V-twin con un nome italiano', 'morbidelli-c252v-recensione-cruiser-v-twin-italiana', 'Morbidelli C252V è la seconda cruiser del parco, ma con un vero motore V-twin al posto del bicilindrico parallelo e con trasmissione a cinghia.', 'La seconda cruiser del parco, ma con un carattere del tutto diverso dalla Road Falcon: la Morbidelli monta un vero motore bicilindrico a V (V-twin) invece del bicilindrico parallelo, da cui un suono diverso, più “basso”, e una vibrazione che molti motociclisti da cruiser considerano parte del piacere di guida. Il marchio Morbidelli è un nome italiano con una vera storia agonistica (titoli iridati nelle classi 125cc e 250cc del motomondiale negli anni ''70), i cui diritti dal 2024 appartengono allo stesso gruppo proprietario di Keeway — quindi non si tratta di un omonimo, ma di un marchio ufficialmente rilanciato su una nuova base tecnica. [Guarda la Morbidelli C252V nel catalogo](/it/bikes?group=motorcycle&model=morbidelli_c252v).

**Caratteristiche:**
- Motore: 249 cc, bicilindrico a V (V-twin), 4 tempi, 8 valvole, SOHC, raffreddamento a liquido
- Potenza: circa 25,5 CV a 9000 giri/min
- Coppia: 25 Nm a 5500 giri/min
- Cambio: manuale a 6 marce con frizione antisaltellamento
- Trasmissione: a cinghia (belt drive) — una rarità per la categoria. In pratica significa: non serve lubrificarla e tenderla periodicamente come una catena, e la cinghia non arrugginisce sotto la pioggia
- Altezza sella: 690 mm — una delle più basse del parco
- Peso: ~200 kg
- Serbatoio: 15,5 l
- Luce da terra: 173 mm
- Freni: disco anteriore da 320 mm (pinza a 4 pistoncini), posteriore da 260 mm (2 pistoncini); ABS Bosch bicanale e controllo di trazione di serie
- Forcella anteriore rovesciata (USD) da 37 mm, escursione 115 mm; dietro due ammortizzatori con precarico regolabile su 5 posizioni
- Velocità massima dichiarata — 125 km/h

**Cosa dicono i proprietari:** il modello è molto recente sul mercato, quindi non esiste ancora una lunga storia di utilizzo, ma i primi test della stampa segnalano una maneggevolezza sorprendentemente leggera per una cruiser con un passo così lungo — il raggio di sterzata non tradisce le dimensioni della moto. Il motore a V viene descritto come esteticamente d''effetto (ben visibile sotto il serbatoio, con alette di raffreddamento decorative e finitura cromata) e dal suono decisamente più profondo dei tipici bicilindrici paralleli da 250cc.

**Per chi è adatta:** a chi vuole proprio il carattere V-twin della cruiser (non il bicilindrico parallelo della Road Falcon) — una vibrazione più marcata e un suono più basso del motore, più la cinghia al posto della catena, che non richiede lubrificazione né tensionamento e non arrugginisce sotto la pioggia.

**Dove si comporta bene a Bali:** la stessa nicchia della Road Falcon — itinerari costieri tranquilli, Sanur, Nusa Dua; la cinghia e la seduta bassa la rendono particolarmente comoda per chi vuole uno stile cruiser rilassato senza pensieri per la catena.', 'Morbidelli C252V — una cruiser V-twin con un nome italiano', 'Morbidelli C252V a noleggio a Bali: motore V-twin, trasmissione a cinghia, scheda tecnica e le differenze rispetto alla Road Falcon.'
  FROM articles a WHERE a.slug = 'morbidelli-c252v-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Honda CBR250RR — carena completa e la più “da pista” tra le sportive carenate del parco', 'honda-cbr250rr-recensione-carena-completa', 'Honda CBR250RR è l''unica sportiva completamente carenata del parco, nella versione top con quickshifter e ABS. Una delle moto tecnologicamente più avanzate della classe 250cc in Indonesia.', 'L''unica sportiva completamente carenata del parco (a differenza di MT-25 e ZX-25R, che sono naked/streetfighter “nude”) — la Honda CBR250RR, fin dal debutto nel 2016, è considerata una delle moto tecnologicamente più avanzate della classe 250cc in Indonesia. [Guarda la Honda CBR250RR nel catalogo](/it/bikes?group=motorcycle&model=honda_cbr250rr).

**Caratteristiche (versione top di gamma SP Quick Shifter con ABS — proprio quella nel parco):**
- Motore: 249,7 cc, raffreddamento a liquido, DOHC, bicilindrico parallelo, 8 valvole, con le modifiche della versione top (albero motore alleggerito, nuove molle delle valvole, testata modificata)
- Potenza: ~41 CV a 13.000 giri/min
- Coppia: ~25 Nm a 11.000 giri/min
- Cambio: manuale a 6 marce
- Altezza sella: ~790 mm
- Peso: ~168 kg
- ABS, ottica interamente a LED, cruscotto digitale, throttle-by-wire (acceleratore elettronico senza cavo)
- Quickshifter con 4 modalità configurabili (su+giù, solo su, solo giù, disattivato) — cambio marcia senza usare la frizione
- Frizione antisaltellamento
- Forcella anteriore rovesciata (USD) tipo SFF-Big Piston
- 3 modalità di guida: Comfort, Sport, Sport+
- Accelerazione dichiarata 0-200 m in 8,65 secondi, velocità massima fino a 172 km/h

**Cosa dicono i proprietari:** la CBR250RR viene citata costantemente come una delle moto tecnologicamente più “ricche” della classe 250cc indonesiana — la versione con quickshifter regala sensazioni davvero da pista, rare per questa cilindrata.

**Per chi è adatta:** a chi vuole l''esperienza sportiva completa — carena, posizione di guida sportiva “distesi sul serbatoio” e tecnologie da MotoGP come il quickshifter.

**Dove si comporta bene a Bali:** come la ZX-25R — città, lungomare, per le sensazioni e il carattere, non per un percorso specifico; considerato il suo pedigree da pista, si esprime al meglio anche sul circuito di Mandalika, a Lombok.', 'Honda CBR250RR — carena completa e la più “da pista” tra le sportive carenate del parco', 'Honda CBR250RR a noleggio a Bali: versione top con quickshifter, scheda tecnica e per chi è adatta l''esperienza sportiva completa.'
  FROM articles a WHERE a.slug = 'honda-cbr250rr-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'Honda CB150X — uno stile adventure accessibile su base 150 cc', 'honda-cb150x-recensione-adventure-accessibile', 'Honda CB150X è un ingresso accessibile nello stile adventure su motore da 150 cc, con una ciclistica seria per la categoria e il peso più leggero tra le moto del parco.', 'La CB150X non è la stessa cosa delle 250cc Versys-X250 e V-Strom250: è un ingresso economico nello stile adventure su un modesto motore monocilindrico da 150 cc, ma con una ciclistica davvero seria per la categoria (luce da terra quasi come la CB500X). Grazie al peso molto contenuto per una moto (139 kg), il motore da 150 cc qui è più che sufficiente — la moto solleva facilmente la ruota anteriore e mantiene una dinamica sicura in tutta la gamma di velocità, non solo alle basse, come si potrebbe pensare guardando al monocilindrico e alla cilindrata modesta. [Guarda la Honda CB150X nel catalogo](/it/bikes?group=motorcycle&model=honda_cb150x).

**Caratteristiche:**
- Motore: 149,16 cc, monocilindrico, raffreddamento a liquido, DOHC 4 valvole
- Potenza: ~15,6 CV a 9000 giri/min
- Coppia: ~13,8 Nm a 7000 giri/min
- Cambio: manuale a 6 marce
- Altezza sella: 817 mm
- Luce da terra: 181 mm — quasi come la ben più grande CB500X
- Peso: ~139 kg — la moto (non scooter) più leggera del parco
- Serbatoio: 12 l
- Forcella anteriore rovesciata (USD) Showa SFF-BP da 37 mm, monoammortizzatore posteriore Pro-Link
- Dischi freno ondulati (wavy) anteriore e posteriore
- Cruscotto completamente digitale con consumo di carburante in tempo reale

**Per chi è adatta:** a chi vuole lo stile adventure e una seduta alta, ma non è pronto per il peso e la potenza di un vero tourer da 250cc — un buon gradino di passaggio dalle moto cittadine a modelli più impegnativi.

**Dove si comporta bene a Bali:** la stessa logica della ADV160 — strade laterali, asfalto non perfetto, ma per assetto e carattere è già una moto vera e propria con cambio manuale, non uno scooter.', 'Honda CB150X — uno stile adventure accessibile su base 150 cc', 'Honda CB150X a noleggio a Bali: scheda tecnica, luce da terra e per chi è adatta questa moto adventure economica.'
  FROM articles a WHERE a.slug = 'honda-cb150x-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'it', 'PCX160 vs ADV160 vs Nmax — come scegliere tra i tre', 'pcx160-vs-adv160-vs-nmax-come-scegliere', 'PCX160, ADV160 e Nmax: come scegliere tra i tre scooter più popolari del parco, tra differenze di bagagliaio, dinamica e seduta.', 'A dire il vero, questi tre modelli si distinguono soprattutto visivamente e per ciò a cui il pilota è abituato — se dobbiamo essere sintetici, è una questione di gusti. Tra le differenze pratiche davvero importanti, al primo posto c''è la capacità del bagagliaio: la Nmax è adatta a chi è disposto a sacrificare un po'' di capacità di carico in cambio della seduta e della dinamica che ama. Sulla pura dinamica, invece, in team si scherza così: a chi serve davvero una risposta da “Turbo”, conviene prendere l''ADV da questa gamma — soggettivamente si sente più scattante del modello che ha proprio “Turbo” nel nome.

L''ideale, prima di scegliere la moto giusta per un periodo lungo, è provarle tutte, da 5 giorni a un mese, per sentire davvero la differenza. 1-3 giorni spesso non bastano per capire fino in fondo una moto.

Schede dei modelli: [Honda PCX160](/it/bikes?category=honda_pcx160), [Honda ADV160](/it/bikes?category=honda_adv160), [Yamaha Nmax](/it/bikes?category=yamaha_nmax155).', 'PCX160 vs ADV160 vs Nmax — come scegliere tra i tre', 'Confronto tra Honda PCX160, Honda ADV160 e Yamaha Nmax a noleggio a Bali: quale scooter scegliere in base alle proprie esigenze.'
  FROM articles a WHERE a.slug = 'pcx160-vs-adv160-vs-nmax-how-to-choose'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Honda PCX160 — 快適さと収納力を兼ね備えた毎日の一台', 'honda-pcx160-review', 'Honda PCX160は、収納力を犠牲にせず快適な乗り心地を求める人に最も万能なスクーターです。カップルやスーツケースを持つ旅行者に最も選ばれているモデルです。', 'Honda PCX160は、収納力を妥協せずに快適なスクーターを求める人に最も万能な選択肢です。カップルやスーツケース・大きな荷物を持って旅行する人に特に選ばれているモデルです。[カタログでHonda PCX160を見る](/ja/bikes?category=honda_pcx160)。

**スペック:**
- エンジン: 156.9cc、水冷、eSP+
- 最高出力: 約15.8馬力(8500rpm)
- トランスミッション: CVT(変速操作なし)
- シート高: 約764mm — ほぼどんな身長でも快適
- 燃料タンク: 8.1L
- シート下収納: 約30L — フルフェイスヘルメットが入り、さらに荷物も入るスペースあり
- スマートキー、LEDライト、大出力USB充電ポート、デジタルメーターパネル
- 当店では標準色とは異なる豊富なカスタムカラーをご用意しています

**オプション装備:** PCX160には44LのSHAD製リアトップボックスを取り付けることができます — シート下収納だけでは足りない方に便利です。オプション装備の詳細は、ブログ記事[「レンタルで追加する価値のあるオプション:ヘルメットとコンフォートボックス」](/ja/blog/rental-extras-worth-adding-helmets-and-the-comfort-box)をご覧ください。

**オーナーの声:** 実際の燃費はレビューによると約40~50km/Lで、島内の移動がほぼ無料同然になります。信頼性についての評判はほぼ伝説的で、フォーラムではPCXは芝刈り機に例えられるほど — エンジンがかかり、何年も走り続けても大きなトラブルがないと言われています。レンタルする上で実用的なポイントとして、スマートキーは便利ですが紛失した際の再発行には約100万ルピアかかるため、キーはなくさないように注意が必要です — 仕組みについて詳しくはブログ記事[「バイクのスタート方法とキーフォブの使い方」](/ja/blog/how-to-start-and-use-your-rental-scooters-smart-key)をご覧ください。二人乗りで高速走行時は追い越しのための加速力がかなり落ちるので、市内では問題ありませんが幹線道路では注意が必要です。

**バリ島でおすすめのエリア:** 前輪14インチのおかげで舗装路でも安定した走行が可能 — チャング、スミニャック、サヌールでの快適な移動や、デンパサールでの日常の足として最適です。', 'Honda PCX160 — 快適さと収納力を兼ね備えた毎日の一台', 'バリ島でHonda PCX160をレンタル:スペック、燃費、オーナーの口コミ、オプション装備まで — どんな人に向いているバイクかを解説します。'
  FROM articles a WHERE a.slug = 'honda-pcx160-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Honda ADV160 — 悪路走破と遠出のための一台', 'honda-adv-review', 'Honda ADV160は、PCX160と同じ信頼性の高いエンジンを異なるボディに搭載したモデルです。シート高と地上高が高く、荒れた舗装路や未舗装路でも安心して走れます。', 'Honda ADV160は、PCX160と同じ信頼性の高いエンジンを積みながら、異なるボディを持つモデルです。シート高が高く、地上高も大きいため、荒れた舗装路や未舗装路でもより安心して走行できます。[カタログでHonda ADV160を見る](/ja/bikes?category=honda_adv160)。

**スペック:**
- エンジン: 156.9cc、水冷、eSP+(PCX160と同じエンジン)
- 最高出力: 約15.8馬力
- トランスミッション: CVT
- シート高: 約795mm — 街乗りスクーターより高く、身長が高い方や高めのライディングポジションを好む方に向いています
- 最低地上高: 約165mm — 標準的なスクーターより大幅に高い
- シート下収納: 約30L — フルフェイスヘルメットが入り、さらに荷物用のスペースも確保
- 可動式スクリーン — 2段階調整可能(アップ位置=アグレッシブ、ダウン位置=街乗り向け)
- セミデジタルメーターパネル、大出力USB充電ポート、スマートキー
- 当店では標準色とは異なる豊富なカスタムカラーをご用意しています

**オプション装備:** PCX160と同様に、44LのSHAD製リアトップボックスを取り付け可能です。詳しくはブログ記事[「レンタルで追加する価値のあるオプション:ヘルメットとコンフォートボックス」](/ja/blog/rental-extras-worth-adding-helmets-and-the-comfort-box)をご覧ください。

**オーナーの声:** 燃費の良さはこのエンジンの2つ目の大きな強みです — レビューによると実燃費は34~38km/L前後で、アクティブに走っても給油の頻度は少なくて済みます。さらにADV160は、PCX160と同じエンジンを積みながらもPCX-Nmax-ADVラインナップの中で最もキビキビ走るモデルの一つです — セッティングが異なるだけでこの違いが生まれています。地上高の高さは未舗装路や荒れた路面で実際に効果を発揮しますが、オーナーたちは正直に注意点も挙げています:これはあくまで「街乗りアドベンチャースタイル」であって本格的なエンデューロではなく、大きな岩や深刻な凹凸には地上高が足りません。

**バリ島でおすすめのエリア:** ウブドとその周辺(棚田や脇道)、ムンドゥックと滝めぐり、ウルワツやブキット半島の丘陵地帯 — 地形や路面状況は場所によって様々ですが、ADV160は街乗りスクーターよりずっと融通が利きます。ただし本格的なオフロードには向いていません。', 'Honda ADV160 — 悪路走破と遠出のための一台', 'バリ島でレンタルできるHonda ADV160のスペック、燃費、オーナーの口コミを紹介 — 街乗りアドベンチャースタイルの魅力が光る場面とは。'
  FROM articles a WHERE a.slug = 'honda-adv-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Yamaha Nmax — New(Gen 2)、Neo(Gen 3)、Turbo', 'yamaha-nmax-review', '当店のNmaxは1つのモデルではなく、New・Neo・Turboという複数の世代とグレードが同じ名前の下に存在します。それぞれの実際の違いを解説します。', '当店の「Nmax」は1つのモデルではなく、同じ名前の下にいくつかの世代とグレードが混在しています。NewとNeoはエンジンとトランスミッションについては同じ機構で、ラインナップの世代が異なるだけです(Gen 2とGen 3)。一方Turboはトランスミッションの電子制御が異なる、別系統のモデルです。[カタログでYamaha Nmaxを見る](/ja/bikes?category=yamaha_nmax155)。

**Nmax New(Gen 2):**
- エンジン: 155cc、Blue Core、VVA、SOHC 4バルブ
- 最高出力: 約15馬力(8000rpm)
- トランスミッション: 従来型ローラー式CVT
- 車両重量: 約132kg
- 燃料タンク: 7.1L

**Nmax Neo(Gen 3):**
- Newと同じ155cc Blue Core VVAエンジンを排気量・構造ともに搭載 — 違いは外観・世代・グレードのみで、中身は同じ
- 最高出力: 約15馬力(8000rpm)
- トランスミッション: 従来型CVT
- 車両重量: 約130kg
- 2グレード:Neo(ベース)とNeo S(+スマートキーシステム)

**Nmax「Turbo」:**
- New/Neoと同排気量のエンジン
- 最大の違いはYECVT(Yamaha Electric CVT)— 基本的な構造は同じCVTですが、純粋な機械式ローラーの代わりに電子制御が加わっています。これは根本的に異なるトランスミッションというより、乗り味や電子制御による演出面での違いが大きいと言えます
- 走行モードT-Mode/S-Modeの2種類 + 仮想「ギア」のY-Shift(Low/Medium/High)— 自動車のような変速感を再現
- 車両重量: グレードにより約133~135kg
- 3グレード:Turbo(ベース)、Turbo Tech Max(TFTディスプレイ、USB-Cポート、専用シート)、Turbo Tech Max Ultimate(最上位)
- 補足:名前の「Turbo」はエンジンの過給機を意味するものではなく、電子制御や操作へのレスポンス感を指しています
- 当店では標準色とは異なる豊富なカスタムカラーをご用意しています

**オーナーの声:** レビューではどの世代のエンジンも「壊れない」と評されており、信頼性はラインナップ全体の強みの一つです。燃費の良さも強みで、ファミリーの他モデル(PCX160、ADV160)と同じ経済的な155ccエンジンが、実際の走行でも無理のない燃費を保ち、給油の頻度が少なくて済みます。収納については興味深い点があります — 公称値は決して小さくありませんが、収納スペースの形状の関係でフルフェイスヘルメットが必ずしも入るとは限りません。うれしいポイントとしては、左のハンドルカウル下にスマホと財布専用の小物入れがあります。バリ島の利用者からのレビューでは、坂道(「タンジャカン」)での粘り強さや、ウルワツなどへの遠出での柔らかいサスペンションが特に評価されています。ABSと太めのチューブレスタイヤは、頻発する熱帯のスコールや犬などの突然の障害物への対応として、旅行者向けの複数のガイドでも評価されています — パニックブレーキでもタイヤがロックしません。

**バリ島でおすすめのエリア:** 市街地の流れ(チャング、スミニャック)でも、ウルワツまでの中距離ルートでも安定して走れます — カーブや雨天でも高い安定性があります。全グレードに共通する特長で、ジオメトリーやポジションもほぼ変わりません。', 'Yamaha Nmax — New(Gen 2)、Neo(Gen 3)、Turbo', 'バリ島でレンタルできるYamaha Nmax:New、Neo、Turboの違い、スペック、実際のオーナーの口コミを紹介。'
  FROM articles a WHERE a.slug = 'yamaha-nmax-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Yamaha XMAX250 — Connected と Tech Max:機構は同じ、仕上げのグレードが違う', 'yamaha-xmax250-review', 'Yamaha XMAX250は、ラインナップ最強のスクーターで、長距離でも街乗りでも活躍します。ラインナップにはConnectedとTech Maxがあり、機構は共通です。', 'Yamaha XMAX250は、当店ラインナップ中で最もパワフルなスクーターです。この大きな「野獣」を愛用するファンは多く、長距離走行に強いことは誰もが認めるところですが、実は短距離の街乗りにもこれ以上のものはないと感じる人も少なくありません。ラインナップにはConnectedとTech Maxの2つのグレードがありますが、技術的にはまったく同じバイクで、違いは仕上げのみである点は押さえておきたいポイントです。[カタログでYamaha XMAX250を見る](/ja/bikes?category=yamaha_xmax250)。

**スペック(ConnectedとTech Maxで共通 — エンジンと足回りは同一):**
- エンジン: 250cc、単気筒、水冷、SOHC 4バルブ、Blue Core、一体鍛造クランクシャフト
- 最高出力: 16.8kW(7000rpm)
- 最大トルク: 24.3Nm(5500rpm)
- トランスミッション: CVT
- シート高: 795mm
- 車両重量: 約181kg
- 燃料タンク: 13L
- シート下収納: 44.9L — 非常に大容量で、フルフェイスヘルメット2個と荷物が実際に収まります。ポイントとして、フルフェイスヘルメットを正しく収めるには向きを工夫する必要がある場合があります
- ABS、トラクションコントロール(TCS)、緊急ストップシグナル(急ブレーキ時にストップランプが点滅)、Answer Back System付きスマートキー(駐車場でバイクを探す際の合図機能)、スマホ充電用電源ソケット
- Connectedのウインドスクリーンは固定式で調整不可。スクリーン調整機能はTech Max専用(詳細は後述)
- Yamaha Indonesiaによる保証 — フレーム、燃料システム部品、シリンダー、ピストンについて5年/50,000km保証

**Y-Connectアプリ — レンタルされる方に特にご説明したい重要なポイント:**

XMAX Connectedはアプリとの連携が可能です:

📱 ダウンロードはこちら:
https://apps.apple.com/app/id1495921872
https://apps.apple.com/app/id1585591110

アプリでできること:
• ハンドルからの着信応答
• ハンドルからの音楽操作
• 日本語対応のナビゲーション
• スマートフォンとのスムーズな連携

**Connected vs Tech Max — 何が違うのか:**

最も重要で、最もコストのかかる違いはシートです。Tech Maxのシートは単に「ステッチが違う」だけではなく、MBK(Yamaha傘下でヨーロッパ向けスクーターを専門とするフランスのブランド)が設計した専用シート、いわゆる「コンフォートシート」です。内部には高密度フォームと左右のボルスター(サポート)が使われており、長時間走行を前提に設計されています — 単に触感が柔らかいだけでなく、長距離走行時のポジションを保持し、腰への負担を軽減します。表皮はスエード調のパネルと金色のステッチが入ったエコレザーに、クロームパーツをあしらっています。オーナーレビューでも、色やエンブレムではなく、このシートこそがTech Maxに追加料金を払う一番の理由だと特に評価されています。

その他の違いも実在しますが、価格や重要度ではシートに及びません:
- 専用カラー(旧モデルはMagma Black、2025年以降はCeramic Grey)
- シート下ポケットのカバーがスエード調パネルと金色ステッチ入りのエコレザー製(シートと同じ意匠)
- アルミ製ステップフロア、クロームパーツ、Tech Max専用のエンブレムとグリップの質感
- 2025年モデルのTech Maxには、見た目だけでなく機能面での唯一の違いとして電動スクリーン調整機能(Electric Adjustable Screen)が追加され、走行中でも好みに合わせて素早く調整可能。さらに刷新されたTFTメーターパネルも搭載。前述のとおりConnectedのスクリーンはそもそも調整機能自体がありません

インドネシア市場での価格差は、Tech Maxグレードで約500万ルピア — その差額の大部分は、まさにこのシートに使われています。

**オーナーの声:** エンジンは時速100~110km程度までは快適に加速しますが、それ以上になると「息切れ」してきます — このバイクは加速を楽しむためというより、安定した巡航ペースを維持するためのバイクです。インドネシアのXMAXオーナーズクラブは、2017年という早い時期にこの新モデルの初のツーリングをバリ島で実施しました — ルートはデンパサール→ウブド→キンタマーニ→ブサキ→クルンクン→ギアニャール→Ida Bagus Mantra有料道路経由で戻るというもので、ウブドやキンタマーニのワインディング区間ではトラクションコントロールの動作を確認し、Ida Bagus Mantra有料道路の直線区間では時速140kmまで加速したとのことです。

バイカーたち自身が名付けたXMAX250向けのバリ島定番ルート:南部海岸ルート — チャング→ウルワツ(Jalan Bali Cliff経由)→パンダワビーチ→GWK;山岳ルート — デンパサール→ウブド→キンタマーニ→バトゥール湖→ムンドゥック;東部ルート — サヌール→チャンディダサ→シドゥメン→ヴァージンビーチ。詳しいルートと地図上のポイントは、ブログ記事「バイクで巡るブキット半島」「キンタマーニ:バトゥール山の日の出」「バイクで巡る東バリ」(ヴァージンビーチもこちらに掲載)で近日公開予定です。

**こんな方におすすめ:** 島内の日帰りや複数日のツーリングで、追い越しや坂道でのパワーの余裕、長距離走行時の快適性を重視する方に。日常の足としても優秀で、観光客にも、バリ島に長く暮らすロングステイヤーにも特に人気の高い一台です。

**バリ島でおすすめのエリア:** 島南部を離れたルート — キンタマーニとバトゥール山、アメッド、ロビナ、シドゥメン、東海岸など。とはいえこれも好みの問題で、チャングの渋滞の中でさえ、このラインナップ最大級のツアラーに乗ること自体を楽しむファンも少なくありません。', 'Yamaha XMAX250 — Connected と Tech Max:機構は同じ、仕上げのグレードが違う', 'バリ島でレンタルできるYamaha XMAX250:ConnectedとTech Maxの違い、スペック、Y-Connectアプリ、島内おすすめルートを紹介。'
  FROM articles a WHERE a.slug = 'yamaha-xmax250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Yamaha MT-25 — Gen 2とGen 3:見た目は違えど同じエンジン', 'yamaha-mt25-review', 'Yamaha MT-25は、加速や操作への反応を楽しみたい方向けのコンパクトなストリートファイターです。2025年のモデルチェンジ後、ラインナップにはGen 2とGen 3の両方が存在します。', 'Yamaha MT-25は、AからBへただ移動するだけでなく、加速や操作への反応そのものを楽しみたい方向けのコンパクトなストリートファイターです。本当に個性のあるバイクで、走りの軽快さ、ポジション、外観のいずれにおいても、プロ・愛好家を問わず自分のカテゴリーで一番のお気に入りに挙げる人が非常に多いモデルです。マニュアルトランスミッションとアグレッシブなポジションが、ラインナップ内のスクーターとの決定的な違いです。2025年にYamaha Indonesiaが大幅なモデルチェンジ(「Gen 3」)を行ったため、同じモデル名でも旧型と新型が並んでいることがあります。[カタログでYamaha MT-25を見る](/ja/bikes?group=motorcycle&model=yamaha_mt25)。

**スペック(共通 — エンジン自体は世代間で変更なし):**
- エンジン: 249.55cc、水冷、DOHC、並列2気筒、8バルブ
- 最高出力: 約35.5馬力(12,000rpm)
- 最大トルク: 約22.6Nm(10,000rpm)
- トランスミッション: 6速MT
- シート高: 約780mm
- 燃料タンク: 約14L

**Gen 2(約2019年モデルチェンジ — 最もよく知られる「クラシック」なMT-25の姿):**
- フロントディスクブレーキ1枚
- アシスト&スリッパークラッチなし、ABSなし
- 車両重量: 約165~167kg

**Gen 3(2025年モデルチェンジ、Yamaha Indonesia公式サイトでは「ハイパーネイキッド」と位置付け):**
- MT-07/Rシリーズを彷彿とさせる新しいアグレッシブなヘッドライト — 角ばった「エイリアン風」のデザインで、丸目だったGen 1とは対照的(Gen 2の時点ですでに丸型からは離れていましたが、Gen 3はさらに鋭角的な独自のジオメトリーを持っています)
- ABS — MT-25においてGen 3で初めて搭載
- アシスト&スリッパークラッチ — 急なシフトダウン時もスムーズに作動
- Y-Connect(Bluetoothアプリ)をCCUモジュール経由で搭載 — インドネシア生産のバイクとしては初めての技術
- Big Bike Switch 3-in-1 — Yamahaの大型バイクを思わせる、コンパクトに統合されたスイッチユニット
- フル液晶メーターパネル(シフトタイミングライト付き)
- デバイス充電用の電源ソケット
- 車両重量: 約169kg — 新装備の分、Gen 2よりわずかに増加

**バリ島でおすすめのエリア:** チャングとスミニャック — 市街地の交通の中での小気味よい加速や、海沿いを走る夕方のツーリングなど、このバイクの個性が最も発揮されるシーンです。', 'Yamaha MT-25 — Gen 2とGen 3:見た目は違えど同じエンジン', 'バリ島でレンタルできるYamaha MT-25:Gen 2とGen 3の違い、エンジンスペック、ストリートファイターの個性が光るシーンを紹介。'
  FROM articles a WHERE a.slug = 'yamaha-mt25-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Kawasaki Ninja ZX-25R — 直列4気筒を積む唯一の量産250ccスポーツバイク', 'kawasaki-ninja-zx-25r-review', 'Kawasaki Ninja ZX-25Rは、直列4気筒エンジンを搭載した唯一の量産250ccスポーツバイクです。高回転型の走りと純正クイックシフターが魅力です。', 'Ninja ZX-25Rは、250ccクラスで唯一無二の存在です — 同クラス市販スポーツバイクの中で唯一、直列4気筒エンジンを搭載しています(競合はすべて単気筒または2気筒)。そのため高回転域で唸る独特のサウンドと、回転数をしっかり上げて走る必要があるという特性を持っています。[カタログでKawasaki Ninja ZX-25Rを見る](/ja/bikes?group=motorcycle&model=kawasaki_zx25r)。

**スペック:**
- エンジン: 249cc、水冷、DOHC、直列4気筒 — このクラスでは非常に珍しい構成
- 最高出力: 約45馬力(ラムエア非搭載のインドネシア仕様、15,500rpm)、レッドゾーンは17,000rpmまで
- トランスミッション: 6速MT
- シート高: 約785mm
- 車両重量: 約183kg
- 燃料タンク: 約15L
- フルカウル、スポーツバイクポジション
- 純正クイックシフター搭載 — クラッチ操作なしでギアチェンジ可能、シフトダウン時のオートブリッピング機能付き

**オーナーの声:** 250ccクラスに4気筒エンジンを積むこと自体があまりに異例なため、Kawasakiはかつてこのエンジンをダイノベンチにかけたサウンド動画を公開したほどです — コメント欄では、この排気量にしては「凶暴」で「クレイジー」なサウンドだと評されています。経験豊富なライダーの中には、純正クイックシフター(シフトダウン時のオートブリッピング付き)の出来の良さを評価する声もあり、バリ島の普段の速度域でも変速そのものが楽しくなる、サーキットまで飛ばさなくてもシフトチェンジの快感を味わえると言われています。弱点として挙げられるのは、身長180cm以上のライダーだと一日の終わりにはポジションで脚が疲れてくること、サスペンションはサーキットではなく街乗り向けにセッティングされていることです。パワーバンドのピークは15,500rpm付近まで上がらないため、低回転域での走行に慣れているライダーには、回転を上げるまでは物足りなく感じられるでしょう。

**こんな方におすすめ:** 250ccクラスから最大限の興奮を引き出したい、高回転を維持する走りに抵抗のない、経験豊富なライダーに。低回転でのんびり走るためのバイクではありません。

**バリ島でおすすめのエリア:** 特定のルートというより、走りの興奮やキャラクターを楽しむためのバイクです — MT-25と同様に市街地や海沿いの道でも楽しめますし、隣のロンボク島にある世界レベルのマンダリカ・サーキットもおすすめです。このようなサーキット走行を許可しているレンタル業者は多くありませんが、当店では可能です。当店のラインナップの中で最も上級者向けの一台で、バイク初体験には不向きであり、長身のライダーが一日中乗るにはやや厳しい面もあります。', 'Kawasaki Ninja ZX-25R — 直列4気筒を積む唯一の量産250ccスポーツバイク', 'バリ島でレンタルできるKawasaki Ninja ZX-25R:希少な直列4気筒250ccエンジンとクイックシフター、どんなライダーに向いているかを紹介。'
  FROM articles a WHERE a.slug = 'kawasaki-ninja-zx-25r-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Yamaha XSR155 — レトロな個性を持つカフェレーサー', 'yamaha-xsr-155-review-retro-style', 'Yamaha XSR155は、丸型ヘッドライトと低いハンドル、カフェレーサースタイルのポジションを持つネオレトロバイクです。ファミリー共通の155ccエンジンをマニュアル向けに力強くセッティングしています。', 'Yamaha XSR155は、丸型ヘッドライト、低めのハンドル、カフェレーサースタイルのポジションを持つネオレトロバイクです。ラインナップのスクーターと同じファミリーの155ccエンジンを積んでいますが、マニュアル仕様向けにより力強くセッティングされています。[カタログでYamaha XSR155を見る](/ja/bikes?group=motorcycle&model=yamaha_xsr)。

**スペック:**
- エンジン: 155cc、水冷、SOHC、VVA — Nmax155と同じベースですが、マニュアル向けに異なるセッティング
- 最高出力: 約19.3馬力(10,000rpm)
- トランスミッション: 6速MT
- シート高: 約815mm — カフェレーサーらしい低めのポジション
- 車両重量: 約131~134kg
- 燃料タンク: 約10L

**オーナーの声:** XSR155のシャーシはスポーツバイクR15から流用されているため、車体が軽く、非常に扱いやすいハンドリングを持っています。丁寧なスロットル操作をすれば、実燃費は約50km/Lに達します。二人乗りを予定している方には重要なポイントとして、リアシートはコンパクトで硬めであり、多くのバージョンにはまともなタンデムグリップが付いていません。実際にバリ島でレンタルしたある利用者からは、このモデルについて印象的な感想が寄せられています:控えめな155ccにもかかわらず、バリ島の道では「硬派に走る」バイクで、価格に対して非常によくセッティングされており、地元の舗装路でも驚くほど安定していて、同じコーナーならYamaha R3にすら引けを取らないと本人は語っています — このライダーは片道3時間かけてアメッドまでこのバイクを走らせましたが、まったく問題ありませんでした。

**こんな方におすすめ:** 過剰なパワーは不要だけれど、バイクらしいスタイルとキャラクターを楽しみたい方に — スクーターからマニュアルバイクへの快適なステップアップにも最適です。

**バリ島でおすすめのエリア:** チャングとスミニャック — レトロな雰囲気がエリアの空気感にぴったり合います。ただしレビューを見る限り、アメッドへのツーリングのような長めでワインディングの多いルートも十分にこなせます。', 'Yamaha XSR155 — レトロな個性を持つカフェレーサー', 'バリ島でレンタルできるYamaha XSR155のスペック、オーナーの口コミ、マニュアルミッションのネオレトロバイクがどんな人に向いているかを紹介。'
  FROM articles a WHERE a.slug = 'yamaha-xsr-155-review-retro-style'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Kawasaki Versys-X 250 — 未舗装路まで対応するツアラー', 'kawasaki-versys-x250-review', 'Kawasaki Versys-X 250は、高いシートポジション、ロングストロークサスペンション、大容量タンクを備えたエンデューロツアラーです。島の脇道を探検したい方に。', 'Kawasaki Versys-X 250は、エンデューロツアラーです — 高いシートポジション、ロングストロークサスペンション、大容量タンクを備えています。舗装路を走るだけでなく、島の脇道を探検したい方向けの一台です。[カタログでKawasaki Versys-X 250を見る](/ja/bikes?group=motorcycle&model=kawasaki_versys)。

**スペック:**
- エンジン: 249cc、水冷、DOHC、並列2気筒
- 最高出力: 約27馬力(9700rpm)
- トランスミッション: 6速MT
- シート高: 約845mm — ラインナップの他モデルより明らかに高め
- 車両重量: 約184kg
- 燃料タンク: 約17L — ラインナップ最大級で、航続距離に余裕あり
- ウインドスクリーン、エンデューロスタンディングステップ、立ち乗り・着座どちらでも長時間走行しやすいポジション

**オーナーの声:** 時速105km程度までの穏やかな走行での実燃費は約27~30km/L(バリ島のレンタル業者独自の計測でも100kmあたり約3~4Lとほぼ一致)— 17Lタンクと組み合わせると給油なしでかなりの距離を走れます。オフロード性能は単なる謳い文句ではなく、初期テストライドの一つでは深いぬかるみをサスペンションが底突きすることなく安定して走破しました。標準シートは最初は硬めで「慣らし」が必要です。最も快適に感じる速度域は80~110km/h。実際にバリ島でレンタルした利用客からは、遠く離れた山村までトラブルなく到達できた、マニュアル仕様のバージョンは島の北部への雨の中のツーリングでも実力を発揮した、といった声が寄せられています。プロカー業者自身が挙げる定番ルート:バリ南部 — ウブド — キンタマーニ、島北部の山岳道路、アメッドやトゥランベンまでの東海岸。

**こんな方におすすめ:** 島内を巡る複数日のツーリングや、未舗装路・荒れた路面でも安心感が欲しい方に。詳しいルートはブログ記事「バイクで巡る東バリ」「キンタマーニ:バトゥール山の日の出」「ブドゥグル — ムンドゥック — ロビナ」で紹介しています。

**バリ島でおすすめのエリア:** 遠出のルート — キンタマーニ、島の北部・東部(アメッドやトゥランベンを含む)、主要な観光ルートを外れた脇道など。', 'Kawasaki Versys-X 250 — 未舗装路まで対応するツアラー', 'バリ島でレンタルできるKawasaki Versys-X 250のスペック、航続距離、オーナーの口コミ、エンデューロツーリングにおすすめのルートを紹介。'
  FROM articles a WHERE a.slug = 'kawasaki-versys-x250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Suzuki V-Strom 250 — 快適性と防風性を重視したツアラー', 'suzuki-v-strom-250-review', 'Suzuki V-Strom 250は、長時間のライディングでの快適性を重視したアドベンチャーツアラーです。幅広のウインドスクリーン、アップライトなポジション、ソフトなサスペンションが特徴です。', 'Suzuki V-Strom 250は、長時間のライディングでの快適性を重視したアドベンチャーツアラーです — 幅広のウインドスクリーン、理想的なアップライトポジション、疲れにくいソフトなサスペンションを備えています。[カタログでSuzuki V-Strom 250を見る](/ja/bikes?group=motorcycle&model=suzuki_vstrom250)。

**スペック:**
- エンジン: 248cc、水冷、DOHC、並列2気筒
- 最高出力: 約25馬力(8000rpm)
- トランスミッション: 6速MT
- シート高: バージョンにより約800~835mm
- 燃料タンク: 12L

**オーナーの声:** レビューではこのエンジンは「ミシンのよう」と表現されることが多く、滑らかで静か、燃費が良く信頼性も高いと評判です。誰もが挙げる長所は、しっかりとボリュームのあるシートと「大型バイクのような」ライディングポジションでありながら、はるかに扱いやすい操作性です。実燃費は32~48km/Lほど。バリ島での使用例として特に印象的なのは、あるレンタル利用者が40日以上V-Stromに乗り、フローレス島まで往復したケースです。別のバリ島の利用者からの実用的な教訓として、標準装備のリアラックへの荷物固定は走行中に不安定だったため、当店側でサイドケース付きのVersysに乗り換えてもらったことがあります — 教訓として、荷物を積む予定があるならラックにロープで縛るよりケースのほうが便利です。利用者からは特にシドゥメン、バトゥール山、バリ島最東端周辺の道が勧められており、交通量が気になるのはウルワツ、チャング、ウブド周辺だけで、その先は棚田やジャングル、海の景色が広がると言われています。

**こんな方におすすめ:** スポーティな走りよりも、長距離移動での快適性を重視したい方に。詳しいルートはブログ記事「バイクで巡る東バリ」「スクンプルとバリ中北部の滝めぐり」「バイクで巡るバリの火山」で紹介しています。

**バリ島でおすすめのエリア:** Versys-X250と同じ立ち位置で、遠出のルート、シドゥメン、バトゥール山、東海岸などに向いています。荷物が多くなりそうな場合は、お気軽にお申し付けください — サイドケースを取り付けます。', 'Suzuki V-Strom 250 — 快適性と防風性を重視したツアラー', 'バリ島でレンタルできるSuzuki V-Strom 250のスペック、実燃費、島内の遠出についての利用者の口コミを紹介。'
  FROM articles a WHERE a.slug = 'suzuki-v-strom-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'TVS Ronin 225 — スクランブラー寄りのネオレトロ', 'tvs-ronin-225-review', 'TVS Ronin 225は、丸型LEDヘッドライトと高めのハンドル位置を持つ、スクランブラーのテイストを取り入れたモダンクラシックです。市街地でも未舗装路でも安心して走れます。', 'TVS Ronin 225は、スクランブラーのテイストを取り入れたモダンクラシックです — 丸型LEDヘッドライト、高めのハンドル位置、市街地でも本線から外れた未舗装路でも安心して扱える万能なジオメトリーが特徴です。全グレードにABSを標準装備。[カタログでTVS Ronin 225を見る](/ja/bikes?group=motorcycle&model=tvs_ronin225)。

**スペック:**
- エンジン: 225.9cc、油冷、単気筒、SOHC、4バルブ
- 最高出力: 約20.4馬力(7750rpm)
- 最大トルク: 約19.9Nm(3750rpm)— 低回転から力強く、無理に回さなくても十分なトルクを発揮
- トランスミッション: 5速MT
- シート高: 約795mm
- 車両重量: 約159kg
- 燃料タンク: 約14L
- 全グレードABS標準装備(ベースグレードはシングルチャンネル、上位グレードはデュアルチャンネル)

**信頼性:** TVSはインドで非常に長い歴史を持つブランドで、二輪車の製造は1980年代から続いています。Ronin自体は2022年発売と比較的新しいモデルですが、これまでの使用実績で高い信頼性の評判をすでに確立しています — 走行距離10,000km超のオーナーレビューでは、エンジンは基準通りの滑らかさを保っていると評され、ゴールドカラーの倒立フォークも高い耐摩耗性を示し、さまざまな路面を1年間アクティブに走った後もガタつきや異音のない組み付け精度を維持していると言われています。独立系のオーナー評価ランキングでも、Roninの信頼性とメンテナンスコストの評価はクラス最高水準で安定しています。

**オーナーの声:** エンジン始動時には、レトロバイク特有の低くやや荒々しいサウンドが響きます。低速トルクの強さのおかげで、渋滞した市街地でも特に快適に扱えます。レビューによる実燃費は35~45km/L。サスペンションはソフトにセッティングされており、市街地の路面の凹凸をよく吸収します。一部グレードには雨天モードを含むライディングモードが搭載されており、バリ島の気候を考えると便利な機能です。優れた走りの軽快さと外観は、モデルの強みとしてレビューで頻繁に言及されています。

**こんな方におすすめ:** スポーツバイクほどの過激さは不要だけれど、未舗装路でも安心感のある、毎日使える万能なバイクを求める方に。

**バリ島でおすすめのエリア:** ネオレトロなスタイルが映えるチャングやスミニャックでも、棚田へ続く未舗装の脇道でも、どちらも得意とする一台です。', 'TVS Ronin 225 — スクランブラー寄りのネオレトロ', 'バリ島でレンタルできるTVS Ronin 225のスペック、信頼性、スクランブラーテイストのネオレトロバイクについてのオーナーの口コミを紹介。'
  FROM articles a WHERE a.slug = 'tvs-ronin-225-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Keeway Road Falcon 250 — 入門クラスの価格で楽しむクラシッククルーザー', 'keeway-road-falcon-250-review', 'Keeway Road Falcon 250は、ロングシルエットと低いシート高を持つクラシッククルーザーを、入門クラスの価格で楽しめるモデルです。2026年発売の新しいバイクです。', 'Keeway Road Falcon 250は、ロングシルエット、低いシートポジション、落ち着いたブラックカラーと、アメリカン大型クルーザーを彷彿とさせるキャラクターを、コンパクトな250ccベースに凝縮したモデルです。市場に登場したばかりの新しいモデルで、発売は2026年 — そのためユーザーレビューやバリ島でのレンタル利用者の口コミはまだほとんどありません。[カタログでKeeway Road Falcon 250を見る](/ja/bikes?group=motorcycle&model=keeway_roadfalcon250)。

**スペック:**
- エンジン: 248cc、並列2気筒、4ストローク、4バルブ、SOHC、水冷
- 最高出力: 約24.6馬力(8000rpm)
- 最大トルク: 約23.4Nm(6500rpm)
- トランスミッション: 6速MT、スリッパークラッチ付き
- シート高: 約698mm — ラインナップの中でも特に低いシート高
- 最低地上高: 約186mm
- 燃料タンク: 14L
- ブレーキ:フロント300mmディスク(2ピストンキャリパー)、リア260mmディスク
- 5インチTFTディスプレイ、内蔵Bluetoothスピーカー — このクラスでは珍しい装備
- メーターパネルへのナビ直接表示 — XMAX250と同様、このモデルはスマホホルダーが一切不要です

**オーナーの声:** このモデルはHarley-Davidsonスタイルのバイクや Honda Rebelと直接比較されることが多く、特徴的なタンク前方の「こぶ」型デザインや全体のシルエットは、意図的にアメリカン大型クルーザーを連想させるものです。インドネシアのメディアでもRoad FalconとHonda Rebelを直接比較したレビューが掲載されています。ハンドル内蔵のBluetoothスピーカーは、このクラスのクルーザーとしては珍しい装備です。スリッパークラッチのおかげでシフトダウン時の変速がスムーズになり、バリ島の起伏の多い道でも役立ちます。また、ロングなクルーザーシルエットにもかかわらず、意外なほど小回りが利く点も評価されています — 見た目からは想像しにくいですが、実際に乗ると実感できるポイントです。

**こんな方におすすめ:** クラシックなクルーザーのスタイルとリラックスしたライディングポジションを求める方に。特にシート高が非常に低いため、身長が高くないライダーにも扱いやすい一台です。

**バリ島でおすすめのエリア:** サヌールやヌサドゥアなど、のんびりとした海沿いのルートが中心ですが、それだけではありません — 当店のお客様の中には、本来VersysやV-Stromのようなクラシックツアラー向けとされるエリアまでこのバイクで走破した方もいます。つまりクルーザーらしい見た目にもかかわらず、バリ島北部沿岸を巡る遠出のルートもこなせる一台です。', 'Keeway Road Falcon 250 — 入門クラスの価格で楽しむクラシッククルーザー', 'バリ島でレンタルできるKeeway Road Falcon 250のスペック、Honda Rebelとの比較、このクルーザーがどんな人に向いているかを紹介。'
  FROM articles a WHERE a.slug = 'keeway-road-falcon-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Morbidelli C252V — イタリアの名を冠したVツインクルーザー', 'morbidelli-c252v-review', 'Morbidelli C252Vは、当店2台目のクルーザーですが、並列2気筒ではなく本物のV型2気筒エンジンとベルトドライブを備えています。', '当店2台目のクルーザーですが、Road Falconとはキャラクターがまったく異なります — Morbidelliは並列2気筒ではなく本物のV型2気筒エンジンを積んでいるため、より「重低音」の効いたサウンドと振動を持ち、多くのクルーザー好きのライダーはこれを楽しみの一部と捉えています。Morbidelliというブランドはイタリアの本物のレース史を持つ名前です(1970年代にロードレース世界選手権125cc・250ccクラスでチャンピオンを獲得)。2024年からKeewayと同じグループがこの権利を保有しており、単なる同名ブランドではなく、新しい技術基盤のもとで公式に復活したブランドです。[カタログでMorbidelli C252Vを見る](/ja/bikes?group=motorcycle&model=morbidelli_c252v)。

**スペック:**
- エンジン: 249cc、V型2気筒(Vツイン)、4ストローク、8バルブ、SOHC、水冷
- 最高出力: 約25.5馬力(9000rpm)
- 最大トルク: 25Nm(5500rpm)
- トランスミッション: 6速MT、スリッパークラッチ付き
- 駆動方式: ベルトドライブ — このクラスでは珍しい方式。実用面では、チェーンのような注油や張り調整が不要で、雨でも錆びないという利点があります
- シート高: 690mm — ラインナップの中でも特に低い部類
- 車両重量: 約200kg
- 燃料タンク: 15.5L
- 最低地上高: 173mm
- ブレーキ:フロント320mmディスク(4ピストンキャリパー)、リア260mmディスク(2ピストン);Bosch製2チャンネルABSとトラクションコントロールを標準装備
- フロントフォーク: 倒立式(USD)37mm、ストローク115mm;リアはツインショックで、プリロード5段階調整式
- 最高速度:公称125km/h

**オーナーの声:** 市場に出たばかりのモデルのため長年の使用実績はまだありませんが、メディアによる初期のテストライドでは、これだけロングホイールベースのクルーザーにしては意外なほど扱いやすいハンドリングが評価されています — 最小回転半径は車体のサイズを感じさせません。V型エンジンは見た目のインパクトも高く評価されており(タンク下に見える、フィン風の意匠とクロームパーツが特徴的)、一般的な250cc並列2気筒よりも明らかに低く響くサウンドだと評されています。

**こんな方におすすめ:** Road Falconのような並列2気筒ではなく、本物のVツインクルーザーらしい鼓動感と重低音サウンドを求める方に。さらにチェーンではなくベルトドライブなので、注油や張り調整の手間がなく、雨でも錆びません。

**バリ島でおすすめのエリア:** Road Falconと同じ立ち位置で、サヌールやヌサドゥアなど、のんびりとした海沿いのルートに最適です。ベルトドライブと低いシート高のおかげで、チェーンの手入れを気にせずリラックスしたクルーザースタイルを楽しみたい方には特に扱いやすい一台です。', 'Morbidelli C252V — イタリアの名を冠したVツインクルーザー', 'バリ島でレンタルできるMorbidelli C252V:Vツインエンジンとベルトドライブのスペック、Road Falconとの違いを紹介。'
  FROM articles a WHERE a.slug = 'morbidelli-c252v-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Honda CBR250RR — フルカウルとラインナップ随一のトラック志向', 'honda-cbr250rr-review', 'Honda CBR250RRは、当店で唯一のフルカウル・スポーツバイクで、クイックシフターとABSを備えたトップグレード仕様です。インドネシアの250ccクラスにおける技術的リーダーの一台です。', '当店のラインナップで唯一のフルカウル・スポーツバイク(ネイキッド/ストリートファイターであるMT-25やZX-25Rとは異なります)— Honda CBR250RRは2016年のデビュー以来、インドネシアの250ccクラスにおける技術的リーダーの一台とされています。[カタログでHonda CBR250RRを見る](/ja/bikes?group=motorcycle&model=honda_cbr250rr)。

**スペック(当店にあるのはABS搭載のトップグレード「SP クイックシフター」仕様):**
- エンジン: 249.7cc、水冷、DOHC、並列2気筒、8バルブ、トップグレード専用のチューニング(軽量クランクシャフト、新設計バルブスプリング、専用シリンダーヘッド)
- 最高出力: 約41馬力(13,000rpm)
- 最大トルク: 約25Nm(11,000rpm)
- トランスミッション: 6速MT
- シート高: 約790mm
- 車両重量: 約168kg
- ABS、フルLEDライト、デジタルメーターパネル、スロットルバイワイヤ(ケーブルレス電子制御スロットル)
- クイックシフター(4モード切替可能:アップ+ダウン、アップのみ、ダウンのみ、オフ)— クラッチ操作なしでギアチェンジが可能
- アシスト&スリッパークラッチ
- フロントフォーク: 倒立式(USD)SFF-ビッグピストンタイプ
- ライディングモード3種:Comfort、Sport、Sport+
- 公称0-200m加速8.65秒、最高速度172km/h

**オーナーの声:** CBR250RRはインドネシアの250ccクラスの中でも特にハイテク装備が充実したバイクとして常に名前が挙がります — クイックシフター搭載モデルはこの排気量では珍しい、本物のサーキット感覚を味わわせてくれます。

**こんな方におすすめ:** フルカウル、タンクに伏せるスポーツポジション、MotoGP譲りのクイックシフターまで — 本格的なスポーツバイク体験を求める方に。

**バリ島でおすすめのエリア:** ZX-25Rと同様、市街地や海沿いの道など、特定のルートというよりは走りの興奮やキャラクターを楽しむバイクです。サーキット由来の血統を活かすなら、ロンボク島のマンダリカ・サーキットでも本領を発揮します。', 'Honda CBR250RR — フルカウルとラインナップ随一のトラック志向', 'バリ島でレンタルできるHonda CBR250RR:クイックシフター搭載のトップグレード仕様のスペックと、本格スポーツバイク体験におすすめの理由を紹介。'
  FROM articles a WHERE a.slug = 'honda-cbr250rr-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'Honda CB150X — 150ccベースの手頃なアドベンチャーモデル', 'honda-cb150x-review', 'Honda CB150Xは、150ccエンジンを積んだ手頃なアドベンチャースタイル入門機です。クラス随一の本格的な足回りと、ラインナップ最軽量の車体が魅力です。', 'CB150Xは、250ccのVersys-X250やV-Strom250とは違うポジションのバイクです — 控えめな150cc単気筒エンジンを積んだ、アドベンチャースタイルへの手頃な入門機でありながら、クラスとしては本格的な足回り(最低地上高はCB500Xに迫るレベル)を持っています。バイクとして非常に軽量(139kg)なおかげで、150ccエンジンでも十分すぎるほど — フロントを軽々と持ち上げ、単気筒・控えめな排気量から想像されるような低速域だけでなく、全速度域で頼もしい走りを見せます。[カタログでHonda CB150Xを見る](/ja/bikes?group=motorcycle&model=honda_cb150x)。

**スペック:**
- エンジン: 149.16cc、単気筒、水冷、DOHC 4バルブ
- 最高出力: 約15.6馬力(9000rpm)
- 最大トルク: 約13.8Nm(7000rpm)
- トランスミッション: 6速MT
- シート高: 817mm
- 最低地上高: 181mm — はるかに大きなCB500Xに迫る数値
- 車両重量: 約139kg — 当店のラインナップ中(スクーターを除く)最軽量のバイク
- 燃料タンク: 12L
- フロントフォーク: 倒立式(USD)Showa SFF-BP 37mm、リア:Pro-Linkモノショック
- 前後ウェーブディスクブレーキ
- フル液晶メーターパネル(リアルタイム燃費表示付き)

**こんな方におすすめ:** アドベンチャースタイルと高いシートポジションを求めているものの、本格的な250ccツアラーの重さやパワーにはまだ抵抗がある方 — 街乗りバイクからより本格的なモデルへのステップアップにも最適です。

**バリ島でおすすめのエリア:** ADV160と同じ考え方で、脇道や状態の良くない舗装路に強い一台です。ただしポジションや特性は本格的なマニュアルバイクそのもので、スクーターとは一線を画します。', 'Honda CB150X — 150ccベースの手頃なアドベンチャーモデル', 'バリ島でレンタルできるHonda CB150Xのスペックと最低地上高を紹介 — 手頃なアドベンチャーバイクはどんな人におすすめか解説します。'
  FROM articles a WHERE a.slug = 'honda-cb150x-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ja', 'PCX160 vs ADV160 vs Nmax — 3台からどう選ぶか', 'pcx160-vs-adv160-vs-nmax-how-to-choose', 'PCX160、ADV160、Nmax — 当店で最も人気の高い3台のスクーターから選ぶ方法を解説します。収納力、走りの軽快さ、ポジションの違いとは。', '正直なところ、この3台の違いはまず見た目と、ライダーが普段何に乗り慣れているかによるところが大きく、突き詰めれば好みの問題です。実用面で本当に重要な違いとして最初に挙げられるのが収納力です — Nmaxは、そのポジションや走りの軽快さを気に入っているなら収納力の一部を我慢してもいいという方に向いています。純粋な走りの軽快さについては、スタッフの間ではこんな冗談も出ます:本当に「Turbo」らしいキビキビした反応が欲しいなら、このラインナップの中ではむしろADVを選んだほうがいい — 名前に「Turbo」を冠したモデルよりも、体感的にはADVのほうが機敏に感じられるからです。

理想を言えば、長期でどのバイクにするか決める前に、それぞれを5日から1ヶ月ほど試して実際の違いを体感してみることをおすすめします。1~3日程度では、そのバイクの本当の良さを理解するには足りないことが多いためです。

各モデルのカタログページ:[Honda PCX160](/ja/bikes?category=honda_pcx160)、[Honda ADV160](/ja/bikes?category=honda_adv160)、[Yamaha Nmax](/ja/bikes?category=yamaha_nmax155)。', 'PCX160 vs ADV160 vs Nmax — 3台からどう選ぶか', 'バリ島でレンタルできるHonda PCX160、Honda ADV160、Yamaha Nmaxを徹底比較 — 目的に合わせたスクーター選びの参考に。'
  FROM articles a WHERE a.slug = 'pcx160-vs-adv160-vs-nmax-how-to-choose'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '혼다 PCX160 — 매일 타기 좋은 편안함과 넉넉한 수납공간', 'honda-pcx160-review', '혼다 PCX160은 수납공간을 포기하지 않으면서 편안한 스쿠터를 원하는 사람에게 가장 무난한 선택입니다. 커플이나 캐리어를 들고 여행하는 사람들이 가장 많이 선택하는 모델입니다.', '혼다 PCX160은 수납공간을 포기하지 않으면서 편안한 스쿠터를 원하는 사람에게 가장 무난한 선택입니다. 커플이나 캐리어, 큰 가방을 들고 다니는 여행자들이 가장 많이 선택하는 모델이기도 합니다. [카탈로그에서 혼다 PCX160 보기](/ko/bikes?category=honda_pcx160).

**제원:**
- 엔진: 156.9cc, 수냉식, eSP+
- 출력: 약 15.8마력 (8500rpm)
- 변속기: 무단변속기(CVT), 변속 조작 없음
- 시트고: 약 764mm — 거의 모든 신장에서 편안하게 탈 수 있음
- 연료탱크: 8.1L
- 시트 아래 수납공간: 약 30L — 풀페이스 헬멧이 들어가고도 다른 짐을 넣을 공간이 남음
- 스마트키, LED 라이트, 강력한 USB 충전 포트, 디지털 계기판
- 저희 렌탈샵에서는 기본 색상 외에도 다양한 커스텀 컬러를 보유하고 있습니다

**추가 옵션:** PCX160에는 44L 용량의 SHAD 리어 탑박스를 장착할 수 있습니다 — 시트 아래 수납공간만으로 부족한 분들에게 유용합니다. 추가 장비에 대한 자세한 내용은 저희 블로그 글 [「렌탈 시 추가하면 좋은 옵션: 헬멧과 편리한 박스」](/ko/blog/rental-extras-worth-adding-helmets-and-the-comfort-box)에서 확인하실 수 있습니다.

**오너들의 후기:** 실제 연비는 리뷰에서 리터당 40-50km 정도로 언급되며, 섬 곳곳을 돌아다녀도 연료비 부담이 거의 없는 수준입니다. 내구성에 대한 평판은 거의 전설적인 수준이어서, 포럼에서는 PCX를 잔디깎이에 비유하기도 합니다 — 시동을 걸면 몇 년이고 별문제 없이 달린다는 뜻입니다. 렌탈 이용자에게 실용적으로 알아두면 좋은 부분: 스마트키는 편리하지만 분실 시 재발급 비용이 대략 100만 루피아 정도이므로 키를 잃어버리지 않도록 주의하는 것이 좋습니다 — 작동 원리에 대한 자세한 내용은 저희 블로그 글 [「바이크 시동 걸기와 키(스마트키) 사용법」](/ko/blog/how-to-start-and-use-your-rental-scooters-smart-key)에서 확인하실 수 있습니다. 동승자를 태우고 속도를 낼 때는 추월을 위한 가속 여유가 눈에 띄게 줄어듭니다 — 시내에서는 문제없지만 큰 도로에서는 염두에 두는 것이 좋습니다.

**발리에서 특히 좋은 곳:** 14인치 앞바퀴 덕분에 아스팔트 도로에서 안정적으로 달리며, 창구, 스미냑, 사누르, 그리고 덴파사르 시내 일상 이동에 편안합니다.', '혼다 PCX160 — 매일 타기 좋은 편안함과 넉넉한 수납공간', '발리에서 렌탈 가능한 혼다 PCX160의 제원, 연비, 오너 후기와 추가 옵션 — 어디에 적합하고 누구에게 추천하는지 알아보세요.'
  FROM articles a WHERE a.slug = 'honda-pcx160-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '혼다 ADV160 — 험한 도로와 장거리 라이딩을 위한 선택', 'honda-adv-review', '혼다 ADV160은 PCX160과 같은 믿을 수 있는 엔진을 쓰지만 차체는 다릅니다. 시트고가 높고 지상고가 넉넉해 파손된 아스팔트나 비포장 구간에서도 더 안정적으로 달릴 수 있습니다.', '혼다 ADV160은 PCX160과 같은 믿을 수 있는 엔진을 쓰지만 전혀 다른 차체를 갖고 있습니다. 시트고가 더 높고 지상고가 넉넉해 파손된 아스팔트나 비포장 구간에서도 더 안정적으로 달릴 수 있습니다. [카탈로그에서 혼다 ADV160 보기](/ko/bikes?category=honda_adv160).

**제원:**
- 엔진: 156.9cc, 수냉식, eSP+ (PCX160과 동일한 엔진)
- 출력: 약 15.8마력
- 변속기: 무단변속기(CVT)
- 시트고: 약 795mm — 도심형 스쿠터보다 높아 키가 큰 라이더나 높은 착좌감을 선호하는 분에게 적합
- 지상고 약 165mm — 일반 모델보다 눈에 띄게 높음
- 시트 아래 수납공간: 약 30L — 풀페이스 헬멧이 들어가고도 다른 짐을 넣을 공간이 남음
- 조절 가능한 윈드스크린 — 2단계(위로 올린 공격적인 포지션 / 내린 시내 주행용 포지션)
- 세미 디지털 계기판, 강력한 USB 충전 포트, 스마트키
- 저희 렌탈샵에서는 기본 색상 외에도 다양한 커스텀 컬러를 보유하고 있습니다

**추가 옵션:** PCX160과 마찬가지로 44L 용량의 SHAD 리어 탑박스를 장착할 수 있습니다. 자세한 내용은 저희 블로그 글 [「렌탈 시 추가하면 좋은 옵션: 헬멧과 편리한 박스」](/ko/blog/rental-extras-worth-adding-helmets-and-the-comfort-box)에서 확인하실 수 있습니다.

**오너들의 후기:** 경제성은 이 엔진의 또 다른 강력한 장점입니다 — 리뷰에 따르면 실연비는 리터당 34-38km 수준으로, 활동적으로 타도 주유소를 자주 찾을 필요가 없습니다. 흥미로운 점은 ADV160이 PCX-Nmax-ADV 라인업 중에서도 가장 다이내믹한 축에 속한다는 점인데, 엔진 자체는 PCX160과 동일하지만 세팅이 다르기 때문입니다. 지상고는 비포장이나 파손된 구간에서 실제로 효과를 발휘하지만, 오너들은 솔직하게 경고합니다: 이것은 도심형 어드벤처 스타일링이지 진짜 엔듀로는 아니라는 것 — 큰 돌이나 험한 요철에서는 지상고가 충분하지 않을 수 있습니다.

**발리에서 특히 좋은 곳:** 우붓과 그 주변(계단식 논, 좁은 골목길), 문둑과 폭포, 울루와투와 부킷의 언덕 구간 — 지형과 노면 상태가 제각각인 이런 곳에서 ADV160은 일반 도심형 스쿠터보다 훨씬 너그럽게 대응하지만, 정말 본격적인 오프로드는 이 바이크의 영역이 아닙니다.', '혼다 ADV160 — 험한 도로와 장거리 라이딩을 위한 선택', '발리에서 렌탈 가능한 혼다 ADV160의 제원, 연비, 오너 후기 — 도심형 어드벤처 스타일링이 빛을 발하는 곳은 어디일까요.'
  FROM articles a WHERE a.slug = 'honda-adv-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '야마하 Nmax — New(2세대), Neo(3세대), 그리고 Turbo', 'yamaha-nmax-review', 'Nmax는 저희 차량 중 하나의 모델이 아니라, 같은 이름 아래 여러 세대와 트림이 존재합니다. New, Neo, Turbo가 실제로 어떻게 다른지 정리해 드립니다.', '"Nmax"는 저희 차량 라인업에서 하나의 모델이 아니라, 같은 이름 아래 여러 세대와 트림이 존재하는 모델군입니다. New와 Neo는 엔진과 변속기 면에서는 동일한 기술이며, 단지 세대(2세대와 3세대)가 다를 뿐입니다. 반면 Turbo는 변속기 전자 제어 방식이 다른 별개의 이야기입니다. [카탈로그에서 야마하 Nmax 보기](/ko/bikes?category=yamaha_nmax155).

**Nmax New(2세대):**
- 엔진: 155cc, Blue Core, VVA, SOHC 4밸브
- 출력: 약 15마력(8000rpm)
- 변속기: 롤러 방식의 클래식 무단변속기(CVT)
- 무게: 약 132kg
- 연료탱크: 7.1L

**Nmax Neo(3세대):**
- 배기량과 구조 면에서 New와 동일한 155cc Blue Core VVA 엔진 — 외관, 세대, 트림만 다를 뿐 내부는 동일
- 출력: 약 15마력(8000rpm)
- 변속기: 클래식 무단변속기
- 무게: 약 130kg
- 두 가지 버전: Neo(기본)와 Neo S(+ 스마트키 시스템)

**Nmax "Turbo":**
- New/Neo와 배기량이 동일한 엔진
- 가장 큰 차이는 YECVT(야마하 일렉트릭 CVT) — 본질적으로는 같은 무단변속 방식이지만 순수 기계식 롤러 대신 전자 제어를 사용합니다. 완전히 다른 변속 구조라기보다는 주행 감각과 전자 세팅에 관한 부분에 가깝습니다
- T-Mode/S-Mode 두 가지 주행 모드와 가상 "기어" Y-Shift(Low/Medium/High) — 자동차처럼 기어 변속을 흉내 낸 기능
- 무게: 버전에 따라 약 133-135kg
- 세 가지 버전: Turbo(기본), Turbo Tech Max(TFT 디스플레이, USB-C 포트, 전용 시트), Turbo Tech Max Ultimate(최상위)
- 참고: 이름의 "Turbo"는 전자장비와 반응성에 관한 것이지, 실제 엔진 터보차저를 의미하는 것이 아닙니다
- 저희 렌탈샵에서는 기본 색상 외에도 다양한 커스텀 컬러를 보유하고 있습니다

**오너들의 후기:** 세대와 관계없이 엔진은 리뷰에서 "거의 망가지지 않는다"고 불릴 정도로, 내구성은 이 라인업 전체의 강점 중 하나입니다. 경제성도 강점입니다 — 같은 라인업의 다른 모델(PCX160, ADV160)과 동일한 경제적인 155cc 엔진 덕분에 실제 주행에서도 연비 부담이 크지 않아 주유를 자주 할 필요가 없습니다. 수납공간에 관한 흥미로운 점: 공식 스펙상 용량은 작지 않지만, 수납공간의 형태 때문에 풀페이스 헬멧이 항상 들어가는 것은 아닙니다. 좋은 점으로는 왼쪽 핸들 커버 아래에 휴대폰과 지갑을 넣을 수 있는 별도의 수납공간이 있다는 점입니다. 발리 현지 렌탈 이용자들의 리뷰에서는 오르막에서의 견인력("tanjakan")과 장거리 주행 시 부드러운 서스펜션이 특히 좋은 평가를 받습니다 — 예를 들어 울루와투까지 가는 길에서요. ABS와 넓은 튜브리스 타이어는 관광객 대상 여러 가이드에서 특히 장점으로 꼽히는데, 열대성 폭우와 개처럼 갑자기 나타나는 도로 위 장애물이 잦기 때문입니다 — 급제동 시에도 바퀴가 잠기지 않습니다.

**발리에서 특히 좋은 곳:** 시내 교통 흐름(창구, 스미냑)에서도, 울루와투까지 가는 중거리 도로에서도 안정적으로 달립니다 — 코너링과 우천 시 주행 안정성이 좋습니다. 모든 버전에서 지오메트리와 착좌감에 큰 차이가 없어 이 특성은 어느 버전에나 공통적으로 적용됩니다.', '야마하 Nmax — New(2세대), Neo(3세대), 그리고 Turbo', '발리에서 렌탈 가능한 야마하 Nmax: New, Neo, Turbo의 차이점과 제원, 실제 오너 후기를 확인하세요.'
  FROM articles a WHERE a.slug = 'yamaha-nmax-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '야마하 XMAX250 — Connected와 Tech Max: 기계는 같고, 마감이 다르다', 'yamaha-xmax250-review', '야마하 XMAX250은 라인업에서 가장 강력한 스쿠터입니다. 장거리 주행은 물론 시내 짧은 이동에서도 좋은 선택입니다. 저희 차량은 동일한 기계 구조의 Connected와 Tech Max 버전으로 운영됩니다.', '야마하 XMAX250은 라인업에서 가장 강력한 스쿠터입니다. 많은 분들이 바로 이 덩치 큰 녀석을 특히 좋아하는데, 장거리에 강하다는 데는 모두가 동의하지만, 짧은 시내 이동에서도 이만한 게 없다고 느끼는 분들도 많습니다. 저희 차량은 Connected와 Tech Max 두 가지 버전으로 운영되는데, 여기서 중요한 점은 기술적으로 완전히 같은 바이크이며 차이는 마감뿐이라는 것입니다. [카탈로그에서 야마하 XMAX250 보기](/ko/bikes?category=yamaha_xmax250).

**제원(Connected와 Tech Max 공통 — 엔진과 섀시는 동일):**
- 엔진: 250cc, 단기통, 수냉식, SOHC 4밸브, Blue Core, 일체형 단조 크랭크샤프트(one-piece forged crankshaft)
- 출력: 16.8kW(7000rpm)
- 최대토크: 24.3Nm(5500rpm)
- 변속기: 무단변속기(CVT)
- 시트고: 795mm
- 무게: 약 181kg
- 연료탱크: 13L
- 시트 아래 수납공간: 44.9L — 매우 넉넉해서 풀페이스 헬멧 2개와 짐까지 들어갑니다. 다만 풀페이스 헬멧을 제대로 넣으려면 특정 방향으로 돌려서 넣어야 할 때가 있습니다
- ABS, 트랙션 컨트롤(TCS), 비상 정지 신호(급제동 시 제동등이 깜빡이는 기능), Answer Back System이 포함된 스마트키(주차장에서 바이크를 찾을 때 신호를 보내는 기능), 휴대폰 충전용 전원 소켓
- Connected의 윈드스크린은 고정식으로 조절이 불가능합니다. 윈드스크린 조절 기능은 Tech Max 전용입니다(아래 참고)
- 야마하 인도네시아 보증: 프레임, 연료 시스템 부품, 실린더, 피스톤에 대해 5년/50,000km

**Y-Connect 앱 — 렌탈 고객에게 꼭 따로 설명해 드려야 할 부분:**

XMAX Connected 모델은 전용 앱 연동이 가능합니다:

📱 다운로드는 여기서:
https://apps.apple.com/app/id1495921872
https://apps.apple.com/app/id1585591110

연동하면 가능한 것:
• 핸들에서 전화 수신
• 핸들에서 음악 전환
• 한국어 내비게이션
• 스마트폰과의 편리한 연동

**Connected와 Tech Max — 무엇이 다른가:**

가장 중요하고 가장 비싼 차이는 시트입니다. Tech Max의 시트는 단순히 "박음질이 다른" 수준이 아니라, MBK(야마하 소유의 프랑스 브랜드로 유럽형 스쿠터를 전문으로 함)에서 별도로 설계한 시트로, 이른바 "컴포트 시트(Comfort Seat)"라 불립니다. 내부에는 고밀도 폼(high-density foam)과 양옆을 받쳐주는 볼스터(bolster)가 들어 있으며, 장시간 주행을 염두에 두고 설계되었습니다 — 시트가 자세를 잡아주고 장거리 주행에서 허리 피로를 줄여주는 것이지, 단순히 촉감이 더 부드러운 게 아닙니다. 표면은 스웨이드 소재와 금색 스티치가 들어간 에코가죽이며, 크롬 장식이 더해집니다. 오너들의 후기에서는 Tech Max에 추가 비용을 지불할 가장 큰 이유로 색상이나 엠블럼이 아니라 바로 이 시트를 꼽습니다.

그 외의 차이들도 실제로 존재하지만, 가격과 중요도 면에서는 시트에 미치지 못합니다:
- 전용 컬러(이전 모델은 Magma Black, 2025년부터는 Ceramic Grey)
- 스웨이드와 금색 스티치가 들어간 에코가죽 시트 아래 수납함 커버(시트와 톤을 맞춤)
- 알루미늄 발판, 크롬 장식, Tech Max 전용 엠블럼과 손잡이 질감
- 2025년형 Tech Max에는 유일하게 기능적인(단순 미관상이 아닌) 차이가 하나 추가되었습니다 — 전동식 윈드스크린 조절(Electric Adjustable Screen)로, 주행 중에도 사용할 수 있어 취향에 맞게 빠르게 조절할 수 있고, 업데이트된 TFT 계기판도 함께 적용되었습니다. 반면 Connected의 윈드스크린은 앞서 말했듯 아예 조절이 불가능합니다

인도네시아 시장 기준 Tech Max 버전의 가격 차이는 약 500만 루피아이며, 이 비용의 대부분은 바로 시트에 들어갑니다.

**오너들의 후기:** 엔진은 100-110km/h까지는 편안하게 가속하지만, 그 이상에서는 "숨이 차기" 시작합니다 — 가속을 위한 바이크가 아니라 안정적인 크루징 템포를 위한 바이크입니다. 인도네시아의 XMAX 오너 클럽은 이미 2017년에 신모델 첫 투어링을 발리에서 진행했습니다 — 덴파사르 → 우붓 → 킨타마니 → 브사키 → 클룽쿵 → 기안야르 → Ida Bagus Mantra 도로를 거쳐 돌아오는 코스였는데, 우붓과 킨타마니의 굽이진 구간에서는 참가자들이 트랙션 컨트롤을 시험해 보았고, Ida Bagus Mantra 톨로드의 직선 구간에서는 시속 140km까지 가속했습니다.

발리에서 라이더들이 직접 이름 붙인 XMAX250용 정형 루트들도 있습니다: 남부 해안 루트 — 창구 → 울루와투(Jalan Bali Cliff 경유) → 판다와 비치 → GWK; 산악 루트 — 덴파사르 → 우붓 → 킨타마니 → 바투르 호수 → 문둑; 동부 루트 — 사누르 → 찬디다사 → 시드멘 → 버진 비치. 상세 루트와 지도상 포인트는 저희 블로그 글 「부킷 반도를 바이크로」, 「킨타마니: 바투르 화산 일출」, 「동부 발리를 바이크로」(버진 비치도 여기에 포함)에서 확인하실 수 있습니다 — 곧 공개될 예정입니다.

**추천 대상:** 추월이나 오르막에서의 여유 있는 출력과, 장거리 구간에서의 편안함이 중요한 당일치기 또는 여러 날에 걸친 섬 여행에 적합합니다. 일상적인 주행에서도 좋은 선택이며, 관광객과 발리 장기 거주자 모두에게 가장 인기 있는 바이크 중 하나입니다.

**발리에서 특히 좋은 곳:** 남부 지역을 벗어난 루트 — 킨타마니와 바투르 화산, 아메드, 로비나, 시드멘, 동부 해안. 다만 이것도 결국은 취향의 문제라서, 창구의 정체된 도로에서조차 이만큼 큰 투어링 어드벤처 바이크를 즐기는 분들도 적지 않습니다.', '야마하 XMAX250 — Connected와 Tech Max: 기계는 같고, 마감이 다르다', '발리에서 렌탈 가능한 야마하 XMAX250: Connected와 Tech Max의 차이, 제원, Y-Connect 앱, 섬 곳곳의 추천 루트까지 소개합니다.'
  FROM articles a WHERE a.slug = 'yamaha-xmax250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '야마하 MT-25 — 2세대와 3세대: 외관은 다르지만 엔진은 그대로', 'yamaha-mt25-review', '야마하 MT-25는 가속감과 반응성을 제대로 느끼고 싶은 사람을 위한 소형 스트리트파이터입니다. 저희 차량에는 2025년 페이스리프트를 거친 3세대와 이전 2세대 바이크가 함께 있습니다.', '야마하 MT-25는 단순히 A지점에서 B지점으로 이동하는 것이 아니라 가속감과 반응성을 제대로 느끼고 싶은 사람을 위한 소형 스트리트파이터입니다. 정말 개성이 강한 바이크로, 많은 전문가와 애호가들이 동급 중 가장 좋아하는 바이크로 꼽습니다 — 가속감, 착좌감, 외관 모두에서요. 수동변속기와 공격적인 라이딩 포지션은 저희 렌탈 라인업의 스쿠터들과 이 모델을 근본적으로 구분 짓는 요소입니다. 2025년 야마하 인도네시아는 눈에 띄는 페이스리프트("3세대")를 출시했기 때문에, 저희 차량에는 같은 모델명 아래 구형과 신형 외관의 바이크가 나란히 있을 수 있습니다. [카탈로그에서 야마하 MT-25 보기](/ko/bikes?group=motorcycle&model=yamaha_mt25).

**제원(공통 — 엔진 자체는 세대 간 변경 없음):**
- 엔진: 249.55cc, 수냉식, DOHC, 병렬 2기통, 8밸브
- 출력: 약 35.5마력(12,000rpm)
- 최대토크: 약 22.6Nm(10,000rpm)
- 변속기: 6단 수동
- 시트고: 약 780mm
- 연료탱크: 약 14L

**2세대(약 2019년 업데이트 — 가장 익숙한 "클래식" MT-25 외관):**
- 프론트 디스크 브레이크 1개
- 어시스트 슬리퍼 클러치 없음, ABS 없음
- 무게: 약 165-167kg

**3세대(2025년 페이스리프트, 야마하 인도네시아 공식 사이트 기준 "하이퍼네이키드" 포지셔닝):**
- MT-07/R 시리즈 라인업 스타일의 새롭고 공격적인 헤드라이트 — 각진, "외계 생명체" 같은 형태로, 둥근 형태였던 1세대(2세대는 이미 원형 헤드라이트에서 벗어났지만, 3세대는 더욱 날카로운 독자적 지오메트리를 갖춤)와 대비됩니다
- ABS — MT-25에 처음 적용된 것이 바로 3세대
- 어시스트 슬리퍼 클러치 — 급격한 다운시프트 시 더 부드럽게 작동
- CCU 모듈을 통한 Y-Connect(블루투스 앱) — 인도네시아 조립 모터사이클에 최초로 적용된 기술
- Big Bike Switch 3-in-1 — 야마하의 "빅 바이크" 스타일을 반영한 통합형 컴팩트 스위치 블록
- 변속 타이밍 표시등(shift timing light)이 포함된 완전 디지털 계기판
- 기기 충전용 전원 소켓
- 무게: 약 169kg — 새 장비 추가로 2세대보다 약간 무거워짐

**발리에서 특히 좋은 곳:** 창구와 스미냑 — 시내 교통 속에서의 짧고 강한 가속, 그리고 바이크의 개성이 가장 잘 드러나는 해변도로 저녁 드라이브.', '야마하 MT-25 — 2세대와 3세대: 외관은 다르지만 엔진은 그대로', '발리에서 렌탈 가능한 야마하 MT-25: 2세대와 3세대의 차이, 엔진 제원, 스트리트파이터의 개성이 드러나는 곳을 소개합니다.'
  FROM articles a WHERE a.slug = 'yamaha-mt25-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '카와사키 닌자 ZX-25R — 인라인 4기통을 탑재한 유일한 양산형 250cc 스포츠바이크', 'kawasaki-ninja-zx-25r-review', '카와사키 닌자 ZX-25R은 인라인 4기통 엔진을 탑재한 유일한 양산형 250cc 스포츠바이크입니다. 고회전 지향 성격과 순정 퀵시프터를 갖춘 모델입니다.', '닌자 ZX-25R은 250cc 클래스에서 독보적인 위치를 차지하고 있습니다 — 인라인 4기통 엔진을 탑재한 유일한 양산형 스포츠바이크입니다(경쟁 모델은 모두 단기통 또는 2기통 엔진). 그래서 특유의 고회전 사운드와 회전수를 끝까지 끌어올려야 진가를 발휘하는 성격을 갖고 있습니다. [카탈로그에서 카와사키 닌자 ZX-25R 보기](/ko/bikes?group=motorcycle&model=kawasaki_zx25r).

**제원:**
- 엔진: 249cc, 수냉식, DOHC, 인라인 4기통 — 이 클래스에서는 드문 구성
- 출력: 약 45마력(램에어 미적용 인도네시아 사양, 15,500rpm), 레드라인 최대 17,000rpm
- 변속기: 6단 수동
- 시트고: 약 785mm
- 무게: 약 183kg
- 연료탱크: 약 15L
- 풀페어링, 스포츠바이크 포지션
- 순정 퀵시프터(Quick Shifter) — 클러치 조작 없이 변속 가능하며, 다운시프트 시 자동 블립 기능 포함

**오너들의 후기:** 250cc 클래스에 4기통 엔진이 들어간 것 자체가 워낙 이례적이어서, 카와사키는 예전에 이 엔진을 다이노 벤치에서 돌린 사운드 영상을 따로 공개하기도 했습니다 — 시청자들은 이렇게 작은 배기량치고 "미친", "광적인" 사운드라고 표현했습니다. 일부 숙련된 라이더들은 자동 블립 기능이 포함된 순정 퀵시프터가 매우 잘 작동해서, 평범한 발리의 속도조차 진짜 즐거운 라이딩으로 바꿔준다고 평가합니다 — 트랙까지 갈 필요 없이 변속만으로도 즐거움을 느낄 수 있다는 뜻입니다. 단점으로는, 키 180cm 이상인 라이더의 경우 하루가 끝날 무렵 라이딩 포지션 때문에 다리에 피로가 쌓이기 시작하고, 서스펜션이 트랙이 아닌 시내 주행에 맞춰 세팅되어 있다는 점이 꼽힙니다. 최고 출력은 15,500rpm에서야 나오기 때문에, 저회전 위주로 타는 데 익숙한 사람에게는 회전수를 끌어올리기 전까지 답답하게 느껴질 수 있습니다.

**추천 대상:** 250cc 클래스에서 최대한의 감동을 느끼고 싶고 고회전을 유지할 준비가 된 자신 있는 라이더 — 저회전에서 느긋하게 타는 바이크가 아닙니다.

**발리에서 특히 좋은 곳:** 특정 루트보다는 감성과 개성을 즐기는 바이크입니다 — MT-25와 마찬가지로 시내와 해변도로에서, 그리고 이웃 섬 롬복의 세계적 수준 서킷 만달리카에서 진가를 발휘합니다. 이런 주행을 허용하는 렌탈샵은 많지 않지만, 저희와 함께라면 가능합니다. 저희 차량 중 가장 다루기 까다로운 바이크로, 첫 모터사이클 경험용으로는 적합하지 않으며, 키가 큰 라이더가 하루 종일 타기에도 이상적이지는 않습니다.', '카와사키 닌자 ZX-25R — 인라인 4기통을 탑재한 유일한 양산형 250cc 스포츠바이크', '발리에서 렌탈 가능한 카와사키 닌자 ZX-25R: 희귀한 250cc 인라인 4기통 엔진, 퀵시프터, 그리고 이 스포츠바이크가 누구에게 어울리는지 알아보세요.'
  FROM articles a WHERE a.slug = 'kawasaki-ninja-zx-25r-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '야마하 XSR155 — 레트로 감성의 카페레이서', 'yamaha-xsr-155-review-retro-style', '야마하 XSR155는 원형 헤드라이트, 낮은 핸들바, 카페레이서 포지션을 갖춘 네오레트로 바이크입니다. 스쿠터 라인업과 같은 155cc 패밀리 엔진을 쓰지만, 수동변속기용으로 더 강하게 세팅되어 있습니다.', '야마하 XSR155는 네오레트로 바이크입니다: 원형 헤드라이트, 낮은 핸들바, 카페레이서 포지션. 저희 스쿠터 라인업과 같은 155cc 패밀리 엔진을 쓰지만, 수동변속기 버전에 맞게 더 강하게 세팅되어 있습니다. [카탈로그에서 야마하 XSR155 보기](/ko/bikes?group=motorcycle&model=yamaha_xsr).

**제원:**
- 엔진: 155cc, 수냉식, SOHC, VVA — Nmax155와 같은 베이스지만 세팅이 다름
- 출력: 약 19.3마력(10,000rpm)
- 변속기: 6단 수동
- 시트고: 약 815mm — 낮은 카페레이서 포지션
- 무게: 약 131-134kg
- 연료탱크: 약 10L

**오너들의 후기:** XSR155의 섀시는 스포츠바이크 R15에서 가져온 것이어서, 가볍고 조작 반응이 매우 좋습니다. 조심스럽게 스로틀을 다루면 실연비는 리터당 약 50km까지 나옵니다. 동승자와 함께 탈 계획이 있다면 알아둘 중요한 점: 뒷좌석이 좁고 딱딱하며, 여러 버전에서 동승자용 손잡이가 제대로 없습니다. 발리 현지 렌탈 이용자 중 한 분이 이 모델에 대해 인상적인 후기를 남겼습니다: 155cc라는 소박한 배기량임에도 발리 도로에서는 "탄탄하게 달린다"며, 가격 대비 세팅이 훌륭하고 현지 아스팔트에서의 접지감이 자신 있어서, 그의 표현을 빌리면 같은 코너에서 야마하 R3와 견줄 만하다고 했습니다 — 그는 이 바이크로 3시간을 달려 아메드까지 갔는데, 실망시키지 않았다고 합니다.

**추천 대상:** 과도한 출력 없이 모터사이클의 스타일과 개성을 원하는 분 — 스쿠터에서 수동변속기 바이크로 넘어가기에 부담 없는 전환점입니다.

**발리에서 특히 좋은 곳:** 창구와 스미냑 — 바이크의 레트로 감성이 이 지역 분위기와 잘 어울립니다. 다만 후기를 보면 아메드 같은 더 길고 구불구불한 루트도 충분히 소화합니다.', '야마하 XSR155 — 레트로 감성의 카페레이서', '발리에서 렌탈 가능한 야마하 XSR155: 제원, 오너 후기, 그리고 수동변속기를 갖춘 이 네오레트로 바이크가 누구에게 어울리는지 알아보세요.'
  FROM articles a WHERE a.slug = 'yamaha-xsr-155-review-retro-style'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '카와사키 Versys-X 250 — 비포장까지 버텨주는 투어링', 'kawasaki-versys-x250-review', '카와사키 Versys-X 250은 높은 시트고, 롱트래블 서스펜션, 넉넉한 연료탱크를 갖춘 엔듀로 투어링 바이크입니다. 섬의 옆길까지 탐험하고 싶은 분들을 위한 선택입니다.', '카와사키 Versys-X 250은 엔듀로 투어링 바이크입니다: 높은 시트고, 롱트래블 서스펜션, 넉넉한 연료탱크. 단순히 아스팔트만 달리는 게 아니라 섬의 옆길까지 탐험하려는 분들을 위한 바이크입니다. [카탈로그에서 카와사키 Versys-X 250 보기](/ko/bikes?group=motorcycle&model=kawasaki_versys).

**제원:**
- 엔진: 249cc, 수냉식, DOHC, 병렬 2기통
- 출력: 약 27마력(9700rpm)
- 변속기: 6단 수동
- 시트고: 약 845mm — 저희 다른 차량보다 눈에 띄게 높음
- 무게: 약 184kg
- 연료탱크: 약 17L — 저희 차량 중 가장 큰 축에 속하며 주행 가능 거리가 늘어남
- 윈드스크린, 엔듀로 스타일 스탠드, 장거리용 서서/앉아서 겸용 라이딩 포지션

**오너들의 후기:** 시속 105km 이하의 편안한 주행 시 실연비는 리터당 약 27-30km(발리 렌탈업체들도 독립적으로 확인한 수치로는 100km당 약 3-4L 수준)로, 17L 연료탱크와 함께면 주유 없이도 꽤 먼 거리를 갈 수 있습니다. 오프로드 성능은 단순한 마케팅이 아닙니다 — 초기 테스트 주행 중 하나에서는 서스펜션이 한 번도 바닥을 치지 않고 진흙 구간을 안정적으로 통과했습니다. 기본 시트는 처음에는 딱딱해서 "길들이기"가 필요합니다. 가장 편안하게 느껴지는 속도 구간은 80-110km/h입니다. 실제 발리 렌탈 이용자들은 이 바이크로 외딴 산간 마을까지 문제없이 갔다는 후기를 남겼고, 수동변속기 버전은 비 오는 날 섬 북부까지 가는 주행에서 훌륭한 성능을 보였다고 합니다. 렌탈업체들이 직접 추천하는 루트로는: 남부 발리 — 우붓 — 킨타마니, 섬 북부의 산악 도로, 아메드와 툴람벤까지 이어지는 동부 해안이 있습니다.

**추천 대상:** 섬을 여러 날에 걸쳐 돌아다니는 루트에 적합하며, 비포장이나 파손된 구간에서도 자신감을 원하는 분에게 좋습니다. 상세 루트는 저희 블로그 글: 「동부 발리를 바이크로」, 「킨타마니: 바투르 화산 일출」, 「브두굴 — 문둑 — 로비나」에서 확인하실 수 있습니다.

**발리에서 특히 좋은 곳:** 장거리 루트 — 킨타마니, 섬 북부와 동부(아메드와 툴람벤 포함), 주요 관광 도로를 벗어난 옆길들.', '카와사키 Versys-X 250 — 비포장까지 버텨주는 투어링', '발리에서 렌탈 가능한 카와사키 Versys-X 250: 제원, 주행 가능 거리, 오너 후기와 엔듀로 투어링에 좋은 추천 루트를 소개합니다.'
  FROM articles a WHERE a.slug = 'kawasaki-versys-x250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '스즈키 V-Strom 250 — 편안함과 방풍성에 집중한 투어링', 'suzuki-v-strom-250-review', '스즈키 V-Strom 250은 장거리 주행 편안함에 집중한 어드벤처 투어링 바이크입니다. 넓은 윈드스크린, 곧은 라이딩 포지션, 부드러운 서스펜션이 특징입니다.', '스즈키 V-Strom 250은 장거리 주행 시 편안함에 집중한 어드벤처 투어링 바이크입니다: 넓은 윈드스크린, 이상적인 직립 포지션, 장거리 이동에도 피로가 덜한 부드러운 서스펜션. [카탈로그에서 스즈키 V-Strom 250 보기](/ko/bikes?group=motorcycle&model=suzuki_vstrom250).

**제원:**
- 엔진: 248cc, 수냉식, DOHC, 병렬 2기통
- 출력: 약 25마력(8000rpm)
- 변속기: 6단 수동
- 시트고: 버전에 따라 약 800-835mm
- 연료탱크: 12L

**오너들의 후기:** 리뷰에서는 엔진을 재봉틀에 비유합니다 — 매끄럽고, 조용하고, 경제적이고, 믿음직합니다. 대부분의 후기에서 공통적으로 꼽는 장점은 푹신한 시트감과 "큰 모터사이클" 같은 라이딩 포지션이면서도 조작성은 훨씬 가볍다는 점입니다. 실주행 연비는 리터당 32-48km입니다. 발리에서의 가장 인상적인 활용 사례 중 하나는, 한 렌탈 이용자가 V-Strom을 40일 이상 빌려 플로레스 섬까지 왕복한 사례입니다. 다른 발리 렌탈 이용자로부터 얻은 실용적인 교훈도 있습니다: 기본 장착된 리어 러기지 랙에 가방을 고정하는 방식이 주행 중 불안정한 것으로 드러나서, 렌탈업체 측에서 양쪽에 제대로 된 사이드케이스가 달린 Versys로 바꿔주었다고 합니다 — 결론은, 짐을 많이 실을 계획이라면 랙에 끈으로 묶는 것보다 케이스가 더 편리하다는 것입니다. 렌탈 이용자들은 시드멘, 바투르 화산, 발리 최동단 주변 도로 방향을 특히 추천하며, 정체가 심하게 느껴지는 구간은 울루와투, 창구, 우붓 정도이고 그 이후로는 계단식 논, 정글, 바다 전망이 펼쳐진다고 언급합니다.

**추천 대상:** 스포츠 성향보다는 장거리 이동의 편안함을 우선시하는 분. 상세 루트는 저희 블로그 글: 「동부 발리를 바이크로」, 「세쿰풀과 발리 중북부 폭포들」, 「발리 화산을 바이크로」에서 확인하실 수 있습니다.

**발리에서 특히 좋은 곳:** Versys-X250과 같은 영역 — 장거리 루트, 시드멘, 바투르 화산, 동부 해안. 짐이 많을 계획이라면 말씀만 주시면 사이드케이스를 장착해 드립니다.', '스즈키 V-Strom 250 — 편안함과 방풍성에 집중한 투어링', '발리에서 렌탈 가능한 스즈키 V-Strom 250: 제원, 실연비, 그리고 섬 장거리 주행에 대한 렌탈 이용자들의 후기를 소개합니다.'
  FROM articles a WHERE a.slug = 'suzuki-v-strom-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', 'TVS 로닌 225 — 스크램블러 감성이 살짝 가미된 네오클래식', 'tvs-ronin-225-review', 'TVS 로닌 225는 원형 LED 헤드라이트와 높은 핸들바 포지션을 갖춘 스크램블러 감성의 모던 클래식입니다. 시내와 비포장 옆길 모두에서 자신 있게 달릴 수 있는 범용 지오메트리를 갖췄습니다.', 'TVS 로닌 225는 스크램블러 감성이 살짝 가미된 모던 클래식입니다: 원형 LED 헤드라이트, 높은 핸들바 포지션, 시내에서도 큰길을 벗어난 비포장 구간에서도 똑같이 자신 있게 달릴 수 있는 범용 지오메트리. 모든 버전에 ABS가 기본 적용됩니다. [카탈로그에서 TVS 로닌 225 보기](/ko/bikes?group=motorcycle&model=tvs_ronin225).

**제원:**
- 엔진: 225.9cc, 유냉식, 단기통, SOHC, 4밸브
- 출력: 약 20.4마력(7750rpm)
- 최대토크: 약 19.9Nm(3750rpm) — 저회전부터 토크가 나와 회전수를 끌어올릴 필요가 없음
- 변속기: 5단 수동
- 시트고: 약 795mm
- 무게: 약 159kg
- 연료탱크: 약 14L
- 전 버전 ABS 적용(기본형은 1채널, 상위 트림은 2채널)

**내구성:** TVS는 인도에서 매우 오랜 역사를 가진 브랜드로(1980년대부터 이륜차를 생산), 로닌 자체는 비교적 신모델(2022년 출시)임에도 지난 운행 기간 동안 이미 탄탄한 내구성 평판을 쌓았습니다: 주행거리 1만km 이상 오너들의 후기에서는 엔진이 여전히 기준점이 될 만큼 매끄러움을 유지하고, 골드 컬러의 USD 프론트 포크는 높은 내마모성을 보여주며, 다양한 노면에서 1년 넘게 활발히 타도 차체에 유격이나 덜컹거림이 생기지 않는다고 언급됩니다. 독립적인 오너 평가 순위에서 로닌의 내구성과 유지비용 평가는 동급에서 꾸준히 최상위권에 속합니다.

**오너들의 후기:** 시동을 걸면 레트로 바이크 특유의 살짝 거친 저음이 인상적입니다. 강한 저회전 토크 덕분에 혼잡한 시내 교통에서 특히 편안합니다. 리뷰에서 언급되는 실연비는 리터당 35-45km입니다. 서스펜션은 부드럽게 세팅되어 있어 시내 노면 요철을 잘 흡수합니다. 일부 버전에는 비 오는 날에 맞춘 모드를 포함한 라이딩 모드가 있어, 발리 기후를 고려하면 유용합니다. 뛰어난 다이내믹함과 외관은 이 모델의 강점으로 후기에서 자주 언급됩니다.

**추천 대상:** 스포츠바이크의 부담스러움 없이, 비포장 구간에서도 자신 있게 탈 수 있는 매일 쓰기 좋은 범용 모터사이클을 원하는 분.

**발리에서 특히 좋은 곳:** 네오클래식 이미지 덕분에 창구/스미냑에서도 잘 어울리고, 계단식 논으로 이어지는 비포장 옆길에서도 똑같이 좋습니다.', 'TVS 로닌 225 — 스크램블러 감성이 살짝 가미된 네오클래식', '발리에서 렌탈 가능한 TVS 로닌 225: 제원, 내구성, 그리고 스크램블러 감성의 네오클래식 바이크에 대한 오너 후기를 소개합니다.'
  FROM articles a WHERE a.slug = 'tvs-ronin-225-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '키웨이 로드 팔콘 250 — 입문급 가격의 클래식 크루저', 'keeway-road-falcon-250-review', '키웨이 로드 팔콘 250은 길쭉한 실루엣과 낮은 시트고를 갖춘 클래식 크루저로, 입문급 가격대에 만날 수 있습니다. 2026년 출시된 신모델로, 저희 차량 라인업 중 최신 추가 모델입니다.', '키웨이 로드 팔콘 250은 길쭉한 실루엣, 낮은 시트고, 차분한 블랙 컬러, 그리고 미국의 대형 크루저를 떠올리게 하는 캐릭터를 갖고 있지만, 이 모든 것이 컴팩트한 250cc 기반에 담겨 있습니다. 시장에 나온 지 얼마 안 된 완전 신모델(2026년 출시)이라, 실사용자 및 발리 렌탈 후기는 아직 거의 없습니다. [카탈로그에서 키웨이 로드 팔콘 250 보기](/ko/bikes?group=motorcycle&model=keeway_roadfalcon250).

**제원:**
- 엔진: 248cc, 병렬 2기통, 4행정, 4밸브, SOHC, 수냉식
- 출력: 약 24.6마력(8000rpm)
- 최대토크: 약 23.4Nm(6500rpm)
- 변속기: 슬리퍼 클러치 적용 6단 수동
- 시트고: 약 698mm — 저희 차량 중 가장 낮은 시트고 중 하나
- 지상고: 약 186mm
- 연료탱크: 14L
- 브레이크: 전륜 300mm 디스크(2피스톤 캘리퍼), 후륜 260mm
- 5인치 TFT 디스플레이, 내장형 블루투스 스피커 — 이 클래스에서는 드문 옵션
- 계기판에 내비게이션이 직접 표시되는 기능 — XMAX250과 마찬가지로, 이 모델도 휴대폰 거치대가 필요 없습니다

**오너들의 후기:** 이 모델은 할리데이비슨 스타일 바이크나 혼다 레벨과 직접 비교되곤 합니다 — 앞쪽의 특징적인 "탱크 험프"와 전체적인 실루엣이 의도적으로 대형 미국 크루저를 연상시키며, 인도네시아 매체에서도 로드 팔콘과 혼다 레벨을 직접 비교한 리뷰가 나와 있습니다. 핸들에 내장된 블루투스 스피커는 이 클래스 크루저에서는 흔치 않은 기능입니다. 슬리퍼 클러치는 다운시프트 시 충격을 완화해주어 발리의 언덕 구간에서 유용합니다. 또한 길쭉한 크루저 실루엣치고는 의외로 회전 반경이 작아 매우 다루기 쉬운 바이크라는 점도 눈에 띄는데, 겉모습만 봐서는 예상하기 어렵지만 실제로 타보면 확실히 체감된다고 합니다.

**추천 대상:** 클래식한 크루저 이미지와 여유로운 라이딩 포지션을 원하는 분 — 특히 시트고가 매우 낮아 키가 작은 라이더에게 편리합니다.

**발리에서 특히 좋은 곳:** 사누르, 누사두아 같은 여유로운 해안 루트에 잘 맞지만, 그게 전부는 아닙니다 — 저희 고객 중에는 보통 Versys나 V-Strom 같은 전형적인 투어링 엔듀로용으로 여겨지는 장소까지 이 바이크로 다녀온 분들도 있습니다. 즉, 크루저 이미지와 달리 발리 북부 해안을 따라가는 장거리 루트도 충분히 소화합니다.', '키웨이 로드 팔콘 250 — 입문급 가격의 클래식 크루저', '발리에서 렌탈 가능한 키웨이 로드 팔콘 250: 제원, 혼다 레벨과의 비교, 그리고 이 크루저가 누구에게 어울리는지 알아보세요.'
  FROM articles a WHERE a.slug = 'keeway-road-falcon-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '모르비델리 C252V — 이탈리아 이름을 단 V-트윈 크루저', 'morbidelli-c252v-review', '모르비델리 C252V는 저희 차량 중 두 번째 크루저이지만, 병렬 2기통 대신 진짜 V형 2기통 엔진을 탑재한 다른 성격의 바이크입니다.', '저희 차량 중 두 번째 크루저이지만 로드 팔콘과는 근본적으로 성격이 다릅니다: 모르비델리는 병렬 2기통 대신 진짜 V형 2기통 엔진을 탑재해, 더 "묵직한" 저음과, 많은 크루저 라이더들이 즐거움의 일부로 여기는 진동을 만들어냅니다. 모르비델리 브랜드는 실제 레이싱 역사를 가진 이탈리아 브랜드로(1970년대 그랑프리 125cc, 250cc 클래스 챔피언 타이틀), 2024년부터는 키웨이를 소유한 것과 같은 그룹이 이 브랜드의 권리를 갖고 있습니다 — 즉 동명이인이 아니라 새로운 기술 기반 위에서 공식적으로 부활한 브랜드입니다. [카탈로그에서 모르비델리 C252V 보기](/ko/bikes?group=motorcycle&model=morbidelli_c252v).

**제원:**
- 엔진: 249cc, V형 2기통(V-twin), 4행정, 8밸브, SOHC, 수냉식
- 출력: 약 25.5마력(9000rpm)
- 최대토크: 25Nm(5500rpm)
- 변속기: 슬리퍼 클러치 적용 6단 수동
- 구동방식: 벨트 드라이브(belt drive) — 이 클래스에서는 드묾. 실제로는 체인처럼 주기적으로 윤활하거나 장력을 조정할 필요가 없고, 비에도 녹슬지 않는다는 뜻입니다
- 시트고: 690mm — 저희 차량 중 가장 낮은 축
- 무게: 약 200kg
- 연료탱크: 15.5L
- 지상고: 173mm
- 브레이크: 전륜 320mm 디스크(4피스톤 캘리퍼), 후륜 260mm(2피스톤); 보쉬 2채널 ABS와 트랙션 컨트롤 기본 탑재
- 프론트 포크는 37mm 인버티드(USD) 타입, 트래블 115mm; 후륜은 5단계 프리로드 조절이 가능한 듀얼 쇼크
- 공식 발표 최고속도 125km/h

**오너들의 후기:** 시장에 나온 지 얼마 안 된 매우 신선한 모델이라 아직 다년간의 운행 이력은 없지만, 초기 시승 리뷰에서는 이 정도로 긴 휠베이스를 가진 크루저치고는 의외로 가볍게 조작할 수 있다는 점이 꼽힙니다 — 회전 반경이 바이크의 덩치를 배신할 정도로 작습니다. V형 엔진은 시각적으로도 인상적이고(탱크 아래로 보이며, 냉각핀을 모방한 디자인과 크롬 마감이 특징), 전형적인 250cc 병렬 2기통보다 눈에 띄게 더 깊은 사운드를 낸다고 묘사됩니다.

**추천 대상:** 병렬 2기통(로드 팔콘)이 아닌, 진짜 V-트윈 크루저 캐릭터 — 더 뚜렷한 진동과 묵직한 엔진음, 그리고 체인 대신 벨트를 원하는 분(윤활이나 장력 조정이 필요 없고 비에도 녹슬지 않음).

**발리에서 특히 좋은 곳:** 로드 팔콘과 같은 영역 — 여유로운 해안 루트, 사누르, 누사두아; 벨트와 낮은 시트고 덕분에 체인 걱정 없이 여유로운 크루저 스타일을 즐기고 싶은 분에게 특히 편리합니다.', '모르비델리 C252V — 이탈리아 이름을 단 V-트윈 크루저', '발리에서 렌탈 가능한 모르비델리 C252V: V-트윈 엔진, 벨트 드라이브, 제원과 로드 팔콘과의 차이점을 소개합니다.'
  FROM articles a WHERE a.slug = 'morbidelli-c252v-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '혼다 CBR250RR — 풀페어링을 갖춘, 페어링 스포츠바이크 중 가장 "트랙 지향적인" 모델', 'honda-cbr250rr-review', '혼다 CBR250RR은 저희 차량 중 유일한 완전 페어링 스포츠바이크이며, 퀵시프터와 ABS를 갖춘 최상위 버전입니다. 2016년 출시 이후 인도네시아 250cc 클래스의 기술적 선두주자 중 하나로 꼽혀 왔습니다.', '저희 차량 중 유일한 완전 페어링 스포츠바이크입니다(네이키드/스트리트파이터인 MT-25, ZX-25R과 대비되는 부분) — 혼다 CBR250RR은 2016년 데뷔 이후 인도네시아 250cc 클래스의 기술적 선두주자 중 하나로 꼽혀 왔습니다. [카탈로그에서 혼다 CBR250RR 보기](/ko/bikes?group=motorcycle&model=honda_cbr250rr).

**제원(저희 차량에 있는 것은 ABS 탑재 SP 퀵시프터 최상위 버전):**
- 엔진: 249.7cc, 수냉식, DOHC, 병렬 2기통, 8밸브, 최상위 버전 전용 개선 사항 적용(경량 크랭크샤프트, 신형 밸브 스프링, 개선된 실린더 헤드)
- 출력: 약 41마력(13,000rpm)
- 최대토크: 약 25Nm(11,000rpm)
- 변속기: 6단 수동
- 시트고: 약 790mm
- 무게: 약 168kg
- ABS, 풀 LED 라이트, 디지털 계기판, 스로틀 바이 와이어(케이블 없는 전자식 스로틀)
- 4가지 설정 가능한 퀵시프터(업다운, 업만, 다운만, 오프) — 클러치 조작 없이 변속 가능
- 어시스트 슬리퍼 클러치
- SFF-Big Piston 타입 인버티드(USD) 프론트 포크
- 3가지 라이딩 모드: Comfort, Sport, Sport+
- 공식 발표 0-200m 가속 8.65초, 최고속도 172km/h

**오너들의 후기:** CBR250RR은 인도네시아 250cc 클래스에서 가장 기술이 "꽉 찬" 바이크 중 하나로 꾸준히 언급됩니다 — 퀵시프터가 탑재된 버전은 이 배기량대에서는 보기 드문 진짜 트랙 감각을 선사합니다.

**추천 대상:** 완전한 스포츠바이크 경험을 원하는 분 — 페어링, 탱크에 엎드리는 스포츠 라이딩 포지션, 그리고 MotoGP급 퀵시프터 같은 기술까지.

**발리에서 특히 좋은 곳:** ZX-25R과 마찬가지로 — 시내, 해변도로 등 특정 루트보다는 감성과 개성을 즐기기에 좋은 곳들입니다. 트랙 혈통을 감안하면 롬복의 만달리카 서킷에서도 진가를 확실히 발휘합니다.', '혼다 CBR250RR — 풀페어링을 갖춘, 페어링 스포츠바이크 중 가장 "트랙 지향적인" 모델', '발리에서 렌탈 가능한 혼다 CBR250RR: 퀵시프터를 갖춘 최상위 버전, 제원, 그리고 완전한 스포츠바이크 경험이 누구에게 어울리는지 알아보세요.'
  FROM articles a WHERE a.slug = 'honda-cbr250rr-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', '혼다 CB150X — 150cc 엔진 기반의 합리적인 가격대 어드벤처 스타일', 'honda-cb150x-review', '혼다 CB150X는 150cc 단기통 엔진을 기반으로 한 합리적인 가격대의 어드벤처 스타일 입문 모델로, 동급 대비 진지한 하체 성능과 저희 차량 중 가장 가벼운 무게를 갖췄습니다.', 'CB150X는 250cc급인 Versys-X250, V-Strom250과는 다른 모델입니다: 소박한 150cc 단기통 엔진을 기반으로 한 합리적인 가격대의 어드벤처 스타일 입문 모델이지만, 동급 대비 진지한 하체 성능을 갖추고 있습니다(지상고는 거의 CB500X급). 모터사이클치고 매우 가벼운 무게(139kg) 덕분에 150cc 엔진만으로도 충분해서, 앞바퀴를 쉽게 들 수 있고 저회전뿐 아니라 전 속도 영역에서 자신 있는 다이내믹함을 유지합니다 — 단기통에 소박한 배기량만 보고 저회전에서만 힘을 쓸 거라 생각하기 쉽지만 실제로는 그렇지 않습니다. [카탈로그에서 혼다 CB150X 보기](/ko/bikes?group=motorcycle&model=honda_cb150x).

**제원:**
- 엔진: 149.16cc, 단기통, 수냉식, DOHC 4밸브
- 출력: 약 15.6마력(9000rpm)
- 최대토크: 약 13.8Nm(7000rpm)
- 변속기: 6단 수동
- 시트고: 817mm
- 지상고: 181mm — 훨씬 큰 모델인 CB500X와 거의 비슷한 수준
- 무게: 약 139kg — 저희 차량 중(스쿠터 제외) 가장 가벼운 모터사이클
- 연료탱크: 12L
- 프론트 포크는 쇼와 SFF-BP 37mm 인버티드(USD), 리어는 프로링크 모노쇼크
- 전후륜 웨이브(wavy) 디스크 브레이크
- 실시간 연비 표시가 되는 완전 디지털 계기판

**추천 대상:** 어드벤처 스타일링과 높은 시트고를 원하지만, 완전한 250cc급 투어러의 무게와 출력까지는 부담스러운 분 — 시내형 바이크에서 더 본격적인 모델로 넘어가기 좋은 단계입니다.

**발리에서 특히 좋은 곳:** ADV160과 같은 논리입니다 — 옆길, 완벽하지 않은 아스팔트에서 좋지만, 착좌감과 성격 면에서는 이미 스쿠터가 아닌 완전한 수동변속기 모터사이클입니다.', '혼다 CB150X — 150cc 엔진 기반의 합리적인 가격대 어드벤처 스타일', '발리에서 렌탈 가능한 혼다 CB150X: 제원, 지상고, 그리고 합리적인 가격의 어드벤처 바이크가 누구에게 어울리는지 알아보세요.'
  FROM articles a WHERE a.slug = 'honda-cb150x-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ko', 'PCX160 vs ADV160 vs Nmax — 셋 중 무엇을 고를지', 'pcx160-vs-adv160-vs-nmax-how-to-choose', 'PCX160, ADV160, Nmax 중 무엇을 고를지 — 세 인기 스쿠터 중 가장 인기 있는 모델들을 수납공간, 다이내믹함, 착좌감 기준으로 비교해 드립니다.', '솔직히 말하면 이 세 모델은 무엇보다 외관과 라이더가 익숙한 스타일에 따라 갈립니다 — 간단히 말해 취향의 문제입니다. 실질적으로 중요한 차이 중 첫 번째는 수납공간 크기입니다: Nmax는 착좌감과 다이내믹함을 위해 수납공간 일부를 포기할 의향이 있는 분에게 어울립니다. 순수 다이내믹함으로는 저희 팀 내에서 이런 농담을 하곤 합니다: 진짜 "터보" 같은 반응성을 원한다면 이 라인업 중에서는 오히려 ADV를 골라야 한다고 — 이름에 "Turbo"가 들어간 모델보다 체감상 더 빠릿하게 느껴지기 때문입니다.

이상적으로는, 오래 탈 바이크를 정하기 전에 각 모델을 5일에서 한 달 정도 타보면서 차이를 실제로 체감해 보는 것을 권장합니다. 1-3일로는 바이크를 진정으로 이해하기에 부족할 때가 많습니다.

모델 페이지: [혼다 PCX160](/ko/bikes?category=honda_pcx160), [혼다 ADV160](/ko/bikes?category=honda_adv160), [야마하 Nmax](/ko/bikes?category=yamaha_nmax155).', 'PCX160 vs ADV160 vs Nmax — 셋 중 무엇을 고를지', '발리 렌탈용 혼다 PCX160, 혼다 ADV160, 야마하 Nmax 비교 — 목적에 맞는 스쿠터를 고르는 방법을 알아보세요.'
  FROM articles a WHERE a.slug = 'pcx160-vs-adv160-vs-nmax-how-to-choose'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Honda PCX160 — الراحة والسعة لكل يوم', 'honda-pcx160-review', 'دراجة Honda PCX160 هي الخيار الأكثر تنوعًا لمن يريد سكوتر مريح دون التضحية بسعة الصندوق. هذا هو الطراز الذي يختاره غالبًا الأزواج والمسافرون الذين يحملون حقيبة سفر.', 'تُعد Honda PCX160 الخيار الأكثر تنوعًا لمن يبحث عن سكوتر مريح دون التضحية بسعة الصندوق. هذا هو الطراز الذي يفضّله غالبًا الأزواج، وكذلك من يسافر بحقيبة كبيرة أو حقيبة سفر. [شاهد Honda PCX160 في الكتالوج](/ar/bikes?category=honda_pcx160).

**المواصفات:**
- المحرك: 156.9 سم³، تبريد بالسائل، eSP+
- القوة: نحو 15.8 حصان عند 8500 لفة/د
- ناقل الحركة: أوتوماتيكي (CVT)، دون تعشيق يدوي
- ارتفاع المقعد: نحو 764 مم — مريح لمعظم الأطوال تقريبًا
- خزان الوقود: 8.1 لتر
- صندوق تحت المقعد: نحو 30 لتر — يتسع لخوذة كاملة الوجه ويبقى مكان لأغراض أخرى
- مفتاح ذكي (Smart Key)، إضاءة LED، منفذ شحن USB قوي، لوحة عدادات رقمية
- لدينا مجموعة واسعة من الألوان المخصصة التي تختلف عن الألوان القياسية

**الإضافات:** يمكن تركيب صندوق خلفي من SHAD بسعة 44 لترًا على PCX160 — مناسب لمن لا يكفيه الصندوق الموجود تحت المقعد. لمزيد من التفاصيل حول الإضافات المتاحة، راجع مقالنا [«إضافات مفيدة عند الاستئجار: الخوذات والصندوق المريح»](/ar/blog/rental-extras-worth-adding-helmets-and-the-comfort-box).

**ما يقوله المالكون:** يتراوح استهلاك الوقود الفعلي بحسب التقييمات بين 40 و50 كم/لتر تقريبًا، ما يجعل التنقل في أنحاء الجزيرة شبه مجاني. سمعة الطراز من حيث الموثوقية تكاد تكون أسطورية — في المنتديات يشبّه أصحاب PCX دراجتهم بجزازة العشب: تعمل وتسير لسنوات دون مفاجآت. تفصيل عملي يستحق الانتباه للمستأجرين: المفتاح الذكي مريح، لكن استبداله عند الفقدان يكلّف نحو مليون روبية، لذا يُفضَّل عدم إضاعته — لمزيد من التفاصيل حول طريقة عمله راجع مقالنا [«كيف تُشغّل الدراجة وتستخدم المفتاح الذكي»](/ar/blog/how-to-start-and-use-your-rental-scooters-smart-key). عند ركوب راكب إضافي بسرعة عالية، يقلّ احتياطي التسارع اللازم للتجاوز بشكل ملحوظ — وهذا ليس مشكلة داخل المدينة، لكن يستحق الانتباه على الطرق السريعة.

**أين تُبلي بلاءً حسنًا في بالي:** تتماسك بثبات على الإسفلت بفضل العجلة الأمامية مقاس 14 بوصة — مريحة في تشانغو وسيمينياك وسانور، وكذلك للتنقلات اليومية في دينباسار.', 'Honda PCX160 — الراحة والسعة لكل يوم', 'مواصفات Honda PCX160 واستهلاك الوقود وآراء المالكين والإضافات المتاحة عند استئجارها في بالي — أين تُبلي بلاءً حسنًا ولمن تناسب.'
  FROM articles a WHERE a.slug = 'honda-pcx160-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Honda ADV160 — للطرق الوعرة والرحلات البعيدة', 'honda-adv-review', 'تحمل Honda ADV160 المحرك الموثوق نفسه الموجود في PCX160، لكن في هيكل مختلف: وضعية جلوس أعلى، ودرجة تخليص أرضي أكبر، وثبات أكثر على الإسفلت المتهالك والطرق الترابية.', 'تحمل Honda ADV160 المحرك الموثوق نفسه الموجود في PCX160، لكن ضمن هيكل مختلف: وضعية جلوس أعلى، ودرجة تخليص أرضي أكبر، وثبات أفضل على الإسفلت المتهالك والطرق الترابية. [شاهد Honda ADV160 في الكتالوج](/ar/bikes?category=honda_adv160).

**المواصفات:**
- المحرك: 156.9 سم³، تبريد بالسائل، eSP+ (نفس محرك PCX160)
- القوة: نحو 15.8 حصان
- ناقل الحركة: أوتوماتيكي (CVT)
- ارتفاع المقعد: نحو 795 مم — أعلى من السكوترات المدنية، ويناسب أصحاب القامة الأطول ومن يفضّلون وضعية جلوس أعلى
- درجة التخليص الأرضي: نحو 165 مم — أكبر بشكل ملحوظ من المعتاد
- صندوق تحت المقعد: نحو 30 لتر — يتسع لخوذة كاملة الوجه ويبقى مكان لأغراض أخرى
- واقٍ أمامي (Visor) قابل للتعديل بوضعين: مرتفع (رياضي) ومنخفض (مدني)
- لوحة عدادات نصف رقمية، منفذ شحن USB قوي، مفتاح ذكي
- لدينا مجموعة واسعة من الألوان المخصصة التي تختلف عن الألوان القياسية

**الإضافات:** كما هو الحال مع PCX160، يمكن تركيب صندوق خلفي من SHAD بسعة 44 لترًا. لمزيد من التفاصيل راجع مقالنا [«إضافات مفيدة عند الاستئجار: الخوذات والصندوق المريح»](/ar/blog/rental-extras-worth-adding-helmets-and-the-comfort-box).

**ما يقوله المالكون:** الاقتصاد في استهلاك الوقود هو الميزة القوية الثانية لهذا المحرك: يتراوح الاستهلاك الفعلي بحسب التقييمات بين 34 و38 كم/لتر — ونادرًا ما تحتاج إلى التزود بالوقود حتى مع القيادة النشطة. والملاحظ أن ADV160 من أكثر الدراجات حيوية ضمن عائلة PCX-Nmax-ADV، رغم أن محركها هو نفسه محرك PCX160 — الفرق فقط في الإعدادات. درجة التخليص الأرضي تُثبت جدواها فعليًا على الطرق الترابية والمتهالكة، لكن المالكين ينصحون بصدق: هذا طابع مغامرة حضري وليس دراجة إندورو حقيقية — على الصخور الكبيرة والوعورة الشديدة لن تكفي درجة التخليص المتاحة.

**أين تُبلي بلاءً حسنًا في بالي:** أوبود وضواحيها (مدرجات الأرز والطرق الجانبية)، موندوك والشلالات، والمناطق التلالية في أولوواتو وشبه جزيرة بوكيت — حيث تختلف التضاريس وجودة الرصف، وتتحمّل ADV160 أخطاءً أكثر من سكوتر مدني عادي، لكن الطرق الوعرة الحقيقية ليست مجالها.', 'Honda ADV160 — للطرق الوعرة والرحلات البعيدة', 'مواصفات Honda ADV160 واستهلاك الوقود وآراء المالكين عند استئجارها في بالي — أين يظهر طابعها المغامر الحضري بأفضل صورة.'
  FROM articles a WHERE a.slug = 'honda-adv-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Yamaha Nmax — الإصدارات New (الجيل الثاني) وNeo (الجيل الثالث) وTurbo', 'yamaha-nmax-review', 'Nmax في أسطولنا ليست طرازًا واحدًا، بل عدة أجيال ومستويات تجهيز تحت اسم واحد: New وNeo وTurbo. نوضح هنا الفرق الحقيقي بينها.', '"Nmax" في أسطولنا ليست طرازًا واحدًا، بل عدة أجيال ومستويات تجهيز تحت اسم واحد. الإصداران New وNeo متطابقان من حيث المحرك وناقل الحركة، والفرق بينهما هو فقط جيل الطراز (الجيل الثاني والجيل الثالث). أما Turbo فهي قصة مختلفة، بإعدادات إلكترونية مغايرة لناقل الحركة. [شاهد Yamaha Nmax في الكتالوج](/ar/bikes?category=yamaha_nmax155).

**Nmax New (الجيل الثاني):**
- المحرك: 155 سم³، تقنية Blue Core، نظام VVA، SOHC رباعي الصمامات
- القوة: نحو 15 حصانًا عند 8000 لفة/د
- ناقل الحركة: أوتوماتيكي كلاسيكي (CVT) بالبكرات
- الوزن: نحو 132 كجم
- خزان الوقود: 7.1 لتر

**Nmax Neo (الجيل الثالث):**
- نفس محرك Blue Core VVA سعة 155 سم³ الموجود في New من حيث السعة والتصميم — الاختلاف بصري فقط، فهو جيل وتجهيز مختلفان لا محرك مختلف
- القوة: نحو 15 حصانًا عند 8000 لفة/د
- ناقل الحركة: أوتوماتيكي كلاسيكي
- الوزن: نحو 130 كجم
- إصداران: Neo (الأساسي) وNeo S (+ نظام المفتاح الذكي Smart Key)

**Nmax "Turbo":**
- نفس سعة محرك New/Neo
- الفرق الرئيسي هو نظام YECVT (Yamaha Electric CVT): في جوهره نفس مبدأ الناقل الأوتوماتيكي، لكن بتحكم إلكتروني بدل البكرات الميكانيكية البحتة. الأمر أقرب إلى تسويق تجربة القيادة وإعدادات إلكترونية إضافية منه إلى ناقل حركة مختلف جوهريًا
- وضعا قيادة T-Mode/S-Mode بالإضافة إلى "تروس" افتراضية Y-Shift (منخفض/متوسط/مرتفع) — محاكاة لتعشيق السرعات كما في السيارات
- الوزن: نحو 133-135 كجم حسب الإصدار
- ثلاثة إصدارات: Turbo (الأساسي)، وTurbo Tech Max (شاشة TFT، منفذ USB-C، مقعد خاص)، وTurbo Tech Max Ultimate (الفئة العليا)
- ملاحظة مهمة: كلمة "Turbo" في الاسم تشير إلى الإلكترونيات وإحساس الاستجابة، وليست شاحنًا توربينيًا فعليًا للمحرك
- لدينا مجموعة واسعة من الألوان المخصصة التي تختلف عن الألوان القياسية

**ما يقوله المالكون:** يصف المالكون المحرك (في أي جيل) بأنه "لا يُتعب" — فالموثوقية إحدى أبرز نقاط قوة هذه الفئة عمومًا. الاقتصاد في استهلاك الوقود ميزة قوية أخرى — فالمحرك الاقتصادي سعة 155 سم³ نفسه المستخدم في باقي طرازات العائلة (PCX160، ADV160) يحافظ في الاستخدام الفعلي على استهلاك معقول، فلا تحتاج إلى التزود بالوقود كثيرًا. تفصيل لافت يخص الصندوق: السعة المعلنة ليست صغيرة، لكن شكل التجويف يجعل الخوذة كاملة الوجه لا تتسع فيه دائمًا. ومن الإيجابيات وجود حيّز خاص أسفل غطاء المقود الأيسر لوضع الهاتف والمحفظة. في تقييمات المستأجرين في بالي، يُشاد خصوصًا بقوة الجر عند الصعود ("tanjakan") وبنعومة نظام التعليق في الرحلات الطويلة — كالتوجه إلى أولوواتو مثلًا. كما تُعد فرامل ABS والإطارات العريضة عديمة الأنبوب من الإيجابيات التي تذكرها عدة أدلة سياحية، خصوصًا بسبب الأمطار الاستوائية المتكررة والعوائق المفاجئة على الطريق كالكلاب — إذ لا تحبس الفرامل العجلة عند الكبح المفاجئ.

**أين تُبلي بلاءً حسنًا في بالي:** تتصرف بثقة سواء في زحمة المدينة (تشانغو، سيمينياك) أو على الطرق متوسطة الطول، بما في ذلك التوجه إلى أولوواتو — بثبات جيد في المنعطفات وتحت المطر. الأمر ينطبق على جميع الإصدارات بالتساوي تقريبًا، فالهندسة ووضعية الجلوس متشابهتان بينها.', 'Yamaha Nmax — الإصدارات New (الجيل الثاني) وNeo (الجيل الثالث) وTurbo', 'استئجار Yamaha Nmax في بالي: الفرق بين إصدارات New وNeo وTurbo، والمواصفات، وآراء حقيقية من المالكين.'
  FROM articles a WHERE a.slug = 'yamaha-nmax-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Yamaha XMAX250 — إصدارا Connected وTech Max: ميكانيكا واحدة، ومستوى تجهيز مختلف', 'yamaha-xmax250-review', 'Yamaha XMAX250 هي أقوى سكوتر في التشكيلة، وتُبلي جيدًا سواء للمسافات الطويلة أو داخل المدينة. في أسطولنا إصداران، Connected وTech Max، بميكانيكا متطابقة.', 'Yamaha XMAX250 هي أقوى سكوتر في التشكيلة. كثيرون يحبون هذا "الوحش" الكبير تحديدًا، وبينما يتفق الجميع على أنه ممتاز للمسافات الطويلة، يرى كثيرون أيضًا أنه لا شيء يضاهيه حتى في التنقلات القصيرة داخل المدينة. يتوفر الطراز في أسطولنا بإصدارين — Connected وTech Max — والمهم هنا أن نفهم: من الناحية التقنية هي نفس الدراجة، والفرق يقتصر على مستوى التجهيز. [شاهد Yamaha XMAX250 في الكتالوج](/ar/bikes?category=yamaha_xmax250).

**المواصفات (متطابقة بين Connected وTech Max — المحرك والهيكل الميكانيكي متماثلان):**
- المحرك: 250 سم³، أحادي الأسطوانة، تبريد بالسائل، SOHC رباعي الصمامات، تقنية Blue Core، عمود مرفقي مطروق قطعة واحدة (one-piece forged crankshaft)
- القوة: 16.8 كيلوواط عند 7000 لفة/د
- عزم الدوران: 24.3 نيوتن.متر عند 5500 لفة/د
- ناقل الحركة: أوتوماتيكي (CVT)
- ارتفاع المقعد: 795 مم
- الوزن: نحو 181 كجم
- خزان الوقود: 13 لتر
- صندوق تحت المقعد: 44.9 لترًا — سعة كبيرة جدًا، تتسع فعليًا لخوذتين كاملتي الوجه بالإضافة إلى الأغراض. ملاحظة مهمة: أحيانًا يلزم توجيه الخوذة الكاملة بطريقة معينة لترتيبها بشكل صحيح
- فرامل ABS، نظام التحكم بالجر TCS، إشارة التوقف الطارئ Emergency Stop Signal (وميض ضوء الفرامل عند الكبح المفاجئ)، مفتاح ذكي مزوّد بنظام Answer Back System (إشارة للعثور على الدراجة في موقف السيارات)، ومنفذ كهربائي لشحن الهاتف
- الزجاج الأمامي في Connected ثابت وغير قابل للتعديل. تعديل الزجاج ميزة حصرية لإصدار Tech Max (انظر أدناه)
- ضمان من Yamaha إندونيسيا — 5 سنوات / 50,000 كم على الهيكل ومكونات نظام الوقود والأسطوانة والمكبس

**تطبيق Y-Connect — تفصيل مهم يستحق شرحًا خاصًا للمستأجر:**

بالنسبة لطراز XMAX Connected، يتوفر الاتصال بالتطبيق:

📱 يمكن التحميل من هنا:
https://apps.apple.com/app/id1495921872
https://apps.apple.com/app/id1585591110

ما الذي يوفره الاتصال بالتطبيق:
• استقبال المكالمات الواردة من المقود
• التحكم بالموسيقى من المقود
• ملاحة تدعم اللغة العربية
• تكامل سلس مع الهاتف الذكي

**Connected مقابل Tech Max — ما الفرق؟**

أهم فرق وأغلاه هو المقعد. مقعد Tech Max ليس مجرد "خياطة مختلفة"، بل مقعد مصمم خصيصًا من إنتاج MBK (العلامة الفرنسية المملوكة لياماها والمتخصصة تحديدًا في السكوترات الأوروبية) — يُعرف باسم "Comfort Seat". في الداخل، إسفنج عالي الكثافة (high-density foam) ودعامات جانبية (bolster) مصممة خصيصًا للرحلات الطويلة: المقعد يُثبّت وضعية الجلوس ويقلل إجهاد أسفل الظهر في الرحلات الممتدة، وليس مجرد ألين ملمسًا. من الأعلى، جلد صناعي (إيكو ليذر) مع لمسات من الشمواة وخياطة بخيط ذهبي، إضافة إلى لمسة كروم. يشير المالكون في تقييماتهم إلى أن المقعد تحديدًا هو السبب الرئيسي للدفع الإضافي مقابل Tech Max، وليس اللون أو الشعارات.

الفروق الأخرى حقيقية أيضًا، لكنها أقل أهمية وقيمة من المقعد:
- لون حصري (Magma Black في الطرازات السابقة، ومنذ 2025 أصبح Ceramic Grey)
- غطاء الجيب تحت المقعد من جلد صناعي مع شمواة وخياطة ذهبية (بتناسق مع المقعد)
- مساند أقدام من الألمنيوم، ولمسة كروم، وشعارات خاصة وملمس مقابض مميز بطراز Tech Max
- في طراز Tech Max لعام 2025 ظهر الفرق الوظيفي الوحيد (وليس تجميليًا فقط) — تعديل كهربائي للزجاج الأمامي (Electric Adjustable Screen) يمكن استخدامه حتى أثناء السير لضبطه بسرعة حسب الحاجة، إضافة إلى لوحة عدادات TFT محدثة؛ أما إصدار Connected فزجاجه، كما ذُكر أعلاه، غير قابل للتعديل إطلاقًا

الفرق في السعر في السوق الإندونيسي نحو 5 ملايين روبية لصالح إصدار Tech Max، وهذا المبلغ يذهب في المقام الأول إلى المقعد تحديدًا.

**ما يقوله المالكون:** المحرك يسحب بارتياح حتى 100-110 كم/س، وبعدها يبدأ "يلهث" قليلًا — فهذه ليست دراجة للتسارع الشديد، بل لسرعة طواف ثابتة. نظّم نادي مالكي XMAX في إندونيسيا أول رحلة جماعية (touring) للطراز الجديد في بالي منذ عام 2017 — على مسار دينباسار ← أوبود ← كينتاماني ← بيساكيه ← كلونكونغ ← جيانيار ← طريق Ida Bagus Mantra السريع والعودة؛ وفي المنعطفات في أوبود وكينتاماني اختبر المشاركون عمل نظام التحكم بالجر، وعلى القطاع المستقيم من طريق Ida Bagus Mantra السريع وصلت السرعة إلى 140 كم/س.

المسارات الجاهزة المسمّاة لدراجة XMAX250 في بالي، كما يسميها الدراجون أنفسهم: الساحل الجنوبي — تشانغو ← أولوواتو (عبر طريق Jalan Bali Cliff) ← شاطئ باندوا ← GWK؛ المسار الجبلي — دينباسار ← أوبود ← كينتاماني ← بحيرة باتور ← موندوك؛ والمسار الشرقي — سانور ← كانديداسا ← سيدمين ← شاطئ فيرجن. المسارات التفصيلية والنقاط على الخريطة موجودة في مقالات مدونتنا «شبه جزيرة بوكيت على متن دراجة» و«كينتاماني: شروق الشمس على بركان باتور» و«شرق بالي على متن دراجة» (وفيها أيضًا شاطئ فيرجن) — سننشرها قريبًا.

**لمن تناسب:** للرحلات التي تستغرق يومًا واحدًا أو عدة أيام حول الجزيرة، حيث يهم وجود احتياطي قوة كافٍ للتجاوز والصعود، إضافة إلى الراحة على المسارات الطويلة. كما أنها من أكثر الدراجات المطلوبة للاستخدام اليومي أيضًا، سواء لدى السياح أو المقيمين لفترات طويلة في بالي.

**أين تُبلي بلاءً حسنًا في بالي:** المسارات خارج جنوب الجزيرة — كينتاماني وبركان باتور، وأميد، ولوفينا، وسيدمين، والساحل الشرقي. لكن مرة أخرى هذه مسألة ذوق — فهناك من يستمتع حتى في زحمة تشانغو بقيادة أكبر دراجة تور-إندورو ممكنة، وهذا النوع من المتحمسين ليس قليلًا على الإطلاق.', 'Yamaha XMAX250 — إصدارا Connected وTech Max: ميكانيكا واحدة، ومستوى تجهيز مختلف', 'استئجار Yamaha XMAX250 في بالي: الفرق بين إصداري Connected وTech Max، والمواصفات، وتطبيق Y-Connect، ومسارات حول الجزيرة.'
  FROM articles a WHERE a.slug = 'yamaha-xmax250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Yamaha MT-25 — الجيل الثاني والجيل الثالث: مظهر مختلف، ونفس المحرك', 'yamaha-mt25-review', 'Yamaha MT-25 دراجة ستريت فايتر مدمجة لمن يريد الإحساس بتسارع الدراجة واستجابتها. يضم أسطولنا نسختي الجيل الثاني والجيل الثالث بعد إعادة التصميم لعام 2025.', 'Yamaha MT-25 دراجة ستريت فايتر مدمجة لمن يريد الشعور بتسارع الدراجة واستجابتها، لا مجرد الانتقال من نقطة إلى أخرى. هذه دراجة ذات طابع حقيقي — يصفها كثير من المحترفين والهواة بأنها من أكثر الدراجات المحبوبة في فئتها: من حيث الأداء والجلسة والمظهر معًا. ناقل الحركة اليدوي والجلسة الرياضية هما ما يميز هذا الطراز جوهريًا عن سكوترات الأسطول. أصدرت Yamaha إندونيسيا في عام 2025 إعادة تصميم ملحوظة ("الجيل الثالث")، لذا قد تجد في الأسطول دراجات بالمظهر القديم والجديد تحت اسم الطراز نفسه. [شاهد Yamaha MT-25 في الكتالوج](/ar/bikes?group=motorcycle&model=yamaha_mt25).

**المواصفات (مشتركة — المحرك نفسه لم يتغير بين الجيلين):**
- المحرك: 249.55 سم³، تبريد بالسائل، DOHC، سلينداران متوازيان، 8 صمامات
- القوة: نحو 35.5 حصانًا عند 12,000 لفة/د
- عزم الدوران: نحو 22.6 نيوتن.متر عند 10,000 لفة/د
- ناقل الحركة: يدوي بست سرعات
- ارتفاع المقعد: نحو 780 مم
- خزان الوقود: نحو 14 لترًا

**الجيل الثاني (تحديث نحو عام 2019 — المظهر "الكلاسيكي" الأكثر تميّزًا لـ MT-25):**
- قرص فرامل أمامي واحد
- بدون قابض مساعد-انزلاقي (Slipper Clutch)، وبدون ABS
- الوزن: نحو 165-167 كجم

**الجيل الثالث (إعادة تصميم 2025، تصنّفها Yamaha بأنها "Hypernaked" وفق الموقع الرسمي لياماها إندونيسيا):**
- مصباح أمامي جديد بتصميم حاد يستلهم طراز MT-07/سلسلة R — بصريات زاوية ذات طابع "غريب" (فضائي)، بخلاف المصباح الدائري في الجيل الأول (ابتعد الجيل الثاني بالفعل عن الشكل الدائري، لكن للجيل الثالث هندسته الخاصة الأكثر حدة)
- فرامل ABS — ظهرت لأول مرة في MT-25 مع الجيل الثالث تحديدًا
- قابض مساعد-انزلاقي (Slipper Clutch) — يعمل بسلاسة أكبر عند خفض السرعات بشكل حاد
- تطبيق Y-Connect (عبر البلوتوث) من خلال وحدة CCU — أول تقنية من نوعها في دراجة نارية مُجمَّعة في إندونيسيا
- مفاتيح تحكم Big Bike Switch ثلاثية الوظائف — وحدة مفاتيح مدمجة مستوحاة من دراجات ياماها "الكبيرة"
- لوحة عدادات رقمية بالكامل مزودة بمؤشر توقيت التعشيق الأمثل (shift timing light)
- منفذ كهربائي لشحن الأجهزة
- الوزن: نحو 169 كجم — أكبر قليلًا من الجيل الثاني بسبب التجهيزات الجديدة

**أين تُبلي بلاءً حسنًا في بالي:** تشانغو وسيمينياك — تسارعات قصيرة وحادة في زحمة المدينة، وجولات مسائية على الكورنيش حيث يظهر طابع الدراجة بأفضل صورة.', 'Yamaha MT-25 — الجيل الثاني والجيل الثالث: مظهر مختلف، ونفس المحرك', 'استئجار Yamaha MT-25 في بالي: الفرق بين الجيل الثاني والجيل الثالث، ومواصفات المحرك، وأين يظهر طابع الستريت فايتر بأفضل صورة.'
  FROM articles a WHERE a.slug = 'yamaha-mt25-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Kawasaki Ninja ZX-25R — الدراجة الرياضية الوحيدة سعة 250 سم³ ذات المحرك الرباعي المتوازي في الإنتاج التسلسلي', 'kawasaki-ninja-zx-25r-review', 'Kawasaki Ninja ZX-25R هي الدراجة الرياضية الوحيدة في فئة 250 سم³ المزوّدة بمحرك رباعي الأسطوانات المتوازية ضمن الإنتاج التسلسلي. طابع عالي الدوران وناقل حركة سريع (Quick Shifter) من المصنع.', 'تحتل Ninja ZX-25R موقعًا فريدًا في فئة 250 سم³: فهي الدراجة الرياضية الوحيدة بهذه السعة المزوّدة بمحرك رباعي الأسطوانات المتوازية ضمن الإنتاج التسلسلي (بينما جميع منافساتها تعتمد على محركات أحادية أو ثنائية الأسطوانات). ومن هنا يأتي صوتها المميز عالي الدوران وحاجتها إلى تدوير المحرك بقوة لاستخراج أفضل أداء. [شاهد Kawasaki Ninja ZX-25R في الكتالوج](/ar/bikes?group=motorcycle&model=kawasaki_zx25r).

**المواصفات:**
- المحرك: 249 سم³، تبريد بالسائل، DOHC، رباعي الأسطوانات المتوازية — تصميم نادر لهذه الفئة
- القوة: نحو 45 حصانًا (النسخة الإندونيسية دون نظام Ram Air) عند 15,500 لفة/د، والحد الأقصى للدوران يصل إلى 17,000 لفة/د
- ناقل الحركة: يدوي بست سرعات
- ارتفاع المقعد: نحو 785 مم
- الوزن: نحو 183 كجم
- خزان الوقود: نحو 15 لترًا
- هيكل انسيابي كامل (Full Fairing)، وجلسة قيادة رياضية
- ناقل حركة سريع من المصنع (Quick Shifter) — تبديل السرعات دون الضغط على القابض، مع "بليب" (نبضة خانق) تلقائية عند خفض السرعة

**ما يقوله المالكون:** كون المحرك رباعي الأسطوانات في فئة 250 سم³ أمرًا غير مألوف لدرجة أن Kawasaki نشرت في وقتها مقطع فيديو منفصلًا لصوت هذا المحرك على منصة اختبار الأداء (dyno) — وصف المعلّقون الصوت بأنه "غاضب" و"جنوني" بالنسبة لسعة صغيرة كهذه. يشير بعض الدراجين ذوي الخبرة إلى أن ناقل الحركة السريع من المصنع (مع نبضة الخانق التلقائية عند الخفض) يعمل بشكل ممتاز ويحوّل السرعات المعتادة في بالي إلى تجربة قيادة ممتعة فعلًا — فلا حاجة للوصول إلى سرعات المضمار للاستمتاع بالتعشيق. أما السلبيات، فمن يتجاوز طوله 180 سم قد تتعب ساقاه من الجلسة بنهاية اليوم، كما أن نظام التعليق مضبوط للمدينة وليس للمضمار. تصل القوة القصوى فقط عند 15,500 لفة/د، ومن اعتاد القيادة عند دورات منخفضة سيجد الدراجة بطيئة الاستجابة حتى يرفع الدوران.

**لمن تناسب:** للدراجين الواثقين الذين يريدون أقصى إحساس ممكن من فئة 250 سم³ ومستعدون للحفاظ على دورات مرتفعة — فهذه ليست دراجة للقيادة الهادئة عند دورات منخفضة.

**أين تُبلي بلاءً حسنًا في بالي:** هي دراجة موجهة نحو الإحساس والطابع أكثر من مسار محدد — تُبلي جيدًا في نفس الأماكن التي تناسب MT-25 (المدينة، الكورنيش)، وكذلك على حلبة مانداليكا العالمية المستوى في جزيرة لومبوك المجاورة. لا تسمح كل شركات التأجير بهذا النوع من الرحلات، لكن معنا الأمر ممكن. هذه أكثر دراجة تتطلب خبرة في الأسطول — ليست مناسبة لأول تجربة على دراجة نارية، وليست مثالية للدراجين طويلي القامة طوال اليوم.', 'Kawasaki Ninja ZX-25R — الدراجة الرياضية الوحيدة سعة 250 سم³ ذات المحرك الرباعي المتوازي في الإنتاج التسلسلي', 'استئجار Kawasaki Ninja ZX-25R في بالي: محرك نادر رباعي الأسطوانات المتوازية سعة 250 سم³، وناقل حركة سريع، ولمن تناسب هذه الدراجة الرياضية.'
  FROM articles a WHERE a.slug = 'kawasaki-ninja-zx-25r-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Yamaha XSR155 — كافيه ريسر بطابع كلاسيكي', 'yamaha-xsr-155-review-retro-style', 'Yamaha XSR155 دراجة بطراز كلاسيكي حديث (نيو-ريترو)، بمصباح أمامي دائري ومقود منخفض وجلسة كافيه ريسر، مبنية على محرك العائلة سعة 155 سم³ بضبط أقوى يناسب ناقل الحركة اليدوي.', 'Yamaha XSR155 دراجة بطراز كلاسيكي حديث: مصباح أمامي دائري، ومقود منخفض، وجلسة كافيه ريسر. تحمل محرك العائلة نفسه سعة 155 سم³ الموجود في سكوترات التشكيلة، لكن بضبط أقوى في نسخة ناقل الحركة اليدوي. [شاهد Yamaha XSR155 في الكتالوج](/ar/bikes?group=motorcycle&model=yamaha_xsr).

**المواصفات:**
- المحرك: 155 سم³، تبريد بالسائل، SOHC، نظام VVA — نفس أساس محرك Nmax155 لكن بضبط مختلف يناسب ناقل الحركة اليدوي
- القوة: نحو 19.3 حصانًا عند 10,000 لفة/د
- ناقل الحركة: يدوي بست سرعات
- ارتفاع المقعد: نحو 815 مم — جلسة منخفضة بطراز كافيه ريسر
- الوزن: نحو 131-134 كجم
- خزان الوقود: نحو 10 لترات

**ما يقوله المالكون:** الهيكل (الشاسيه) في XSR155 مستعار من الدراجة الرياضية R15، لذا فالدراجة خفيفة وسريعة الاستجابة في القيادة. مع خانق حذر، يصل الاستهلاك الفعلي إلى نحو 50 كم/لتر. ملاحظة مهمة لمن يخطط للركوب مع راكب آخر: المقعد الخلفي صغير وصلب، ولا يتوفر مقبض مناسب للراكب في كثير من الإصدارات. ترك أحد المستأجرين الفعليين في بالي تقييمًا لافتًا لهذا الطراز تحديدًا: رغم سعة 155 سم³ المتواضعة، تقول الدراجة إنها "تسير بقوة" على طرق بالي، ومضبوطة بشكل ممتاز مقابل سعرها، وتتماسك على الإسفلت المحلي بثقة عالية لدرجة أنها، بحسب رأيه، قد تتفوق حتى على Yamaha R3 في المنعطفات نفسها — وقد قاد المستأجر الدراجة في رحلة استمرت ثلاث ساعات إلى أميد، ولم تخذله.

**لمن تناسب:** لمن يريد أسلوبًا وطابعًا مميزًا للدراجة النارية دون قوة زائدة عن الحاجة — انتقال مريح من السكوتر إلى دراجة بناقل حركة يدوي.

**أين تُبلي بلاءً حسنًا في بالي:** تشانغو وسيمينياك — يتناغم الطابع الكلاسيكي للدراجة مع أجواء المنطقة بشكل ممتاز؛ لكن وفق التقييمات، تتعامل بكفاءة أيضًا مع المسارات الأطول والأكثر التواءً مثل رحلة إلى أميد.', 'Yamaha XSR155 — كافيه ريسر بطابع كلاسيكي', 'استئجار Yamaha XSR155 في بالي: المواصفات، وآراء المالكين، ولمن تناسب هذه الدراجة الكلاسيكية الحديثة بناقل الحركة اليدوي.'
  FROM articles a WHERE a.slug = 'yamaha-xsr-155-review-retro-style'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Kawasaki Versys-X 250 — دراجة تورينغ بقدرة احتياطية للطرق الترابية', 'kawasaki-versys-x250-review', 'Kawasaki Versys-X 250 دراجة إندورو-تورينغ بجلسة عالية ونظام تعليق طويل المشوار وخزان وقود موسّع، لمن يريد استكشاف الطرق الجانبية في الجزيرة.', 'Kawasaki Versys-X 250 دراجة إندورو-تورينغ: جلسة عالية، ونظام تعليق طويل المشوار، وخزان وقود موسّع. دراجة لمن يخطط لأكثر من مجرد القيادة على الإسفلت، بل لاستكشاف الطرق الجانبية في الجزيرة. [شاهد Kawasaki Versys-X 250 في الكتالوج](/ar/bikes?group=motorcycle&model=kawasaki_versys).

**المواصفات:**
- المحرك: 249 سم³، تبريد بالسائل، DOHC، سلينداران متوازيان
- القوة: نحو 27 حصانًا عند 9700 لفة/د
- ناقل الحركة: يدوي بست سرعات
- ارتفاع المقعد: نحو 845 مم — أعلى بشكل ملحوظ من باقي طرازات الأسطول
- الوزن: نحو 184 كجم
- خزان الوقود: نحو 17 لترًا — من أكبر الخزانات في الأسطول، ما يمنح مدى قيادة موسّعًا
- زجاج أمامي واقٍ من الرياح، ومساند قدم بطراز إندورو، ووضعية تسمح بالقيادة الطويلة جالسًا أو واقفًا

**ما يقوله المالكون:** الاستهلاك الفعلي عند القيادة الهادئة حتى 105 كم/س يبلغ نحو 27-30 كم/لتر (وهو ما تؤكده أيضًا شركات التأجير المحلية في بالي بشكل مستقل — نحو 3-4 لترات لكل 100 كم)، وهو ما يمنح مع خزان سعة 17 لترًا مدى قيادة كبيرًا جدًا دون الحاجة للتزود المتكرر بالوقود. القدرة على الطرق الوعرة ليست مجرد تسويق: في أحد أولى اختبارات القيادة، اجتازت الدراجة طينًا كثيفًا بثبات دون أن يلامس نظام التعليق القاع ولو مرة. المقعد القياسي صلب في البداية ويحتاج إلى فترة "ترويض". تشعر الدراجة بأكبر راحة في نطاق سرعة 80-110 كم/س. يشير مستأجرون حقيقيون في بالي إلى أن الدراجة أوصلتهم دون مشاكل حتى إلى قرية جبلية نائية، وأن النسخة بناقل الحركة اليدوي أثبتت جدارتها في رحلة ممطرة نحو شمال الجزيرة. من المسارات الجاهزة التي تذكرها شركات التأجير نفسها: جنوب بالي — أوبود — كينتاماني، والطرق الجبلية في شمال الجزيرة، والساحل الشرقي وصولًا إلى أميد وتولامبين.

**لمن تناسب:** للمسارات متعددة الأيام حول الجزيرة ولمن يريد ثقة على الطرق الترابية أو المتهالكة. المسارات التفصيلية موجودة في مقالات المدونة: «شرق بالي على متن دراجة»، و«كينتاماني: شروق الشمس على بركان باتور»، و«بيدوغول – موندوك – لوفينا».

**أين تُبلي بلاءً حسنًا في بالي:** المسارات البعيدة — كينتاماني، وشمال الجزيرة وشرقها (بما في ذلك أميد وتولامبين)، والطرق الجانبية خارج المسارات السياحية الرئيسية.', 'Kawasaki Versys-X 250 — دراجة تورينغ بقدرة احتياطية للطرق الترابية', 'استئجار Kawasaki Versys-X 250 في بالي: المواصفات، ومدى القيادة، وآراء المالكين، وأفضل المسارات لدراجات الإندورو-تورينغ.'
  FROM articles a WHERE a.slug = 'kawasaki-versys-x250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Suzuki V-Strom 250 — دراجة تورينغ تركز على الراحة والحماية من الرياح', 'suzuki-v-strom-250-review', 'Suzuki V-Strom 250 دراجة أدفنتشر-تورينغ تركز على الراحة في الرحلات الطويلة: زجاج أمامي عريض، وجلسة مستقيمة، ونظام تعليق ناعم.', 'Suzuki V-Strom 250 دراجة أدفنتشر-تورينغ تركز على الراحة في الرحلات الطويلة: زجاج أمامي عريض، وجلسة مستقيمة مثالية، ونظام تعليق ناعم يقلل الإرهاق في الرحلات الطويلة. [شاهد Suzuki V-Strom 250 في الكتالوج](/ar/bikes?group=motorcycle&model=suzuki_vstrom250).

**المواصفات:**
- المحرك: 248 سم³، تبريد بالسائل، DOHC، سلينداران متوازيان
- القوة: نحو 25 حصانًا عند 8000 لفة/د
- ناقل الحركة: يدوي بست سرعات
- ارتفاع المقعد: نحو 800-835 مم حسب الإصدار
- خزان الوقود: 12 لترًا

**ما يقوله المالكون:** يشبّه أصحاب الدراجة المحرك بآلة الخياطة — سلس، هادئ، اقتصادي وموثوق. من أبرز الإيجابيات المتكررة لدى الجميع: مقعد محشو جيدًا وجلسة "أشبه بدراجة كبيرة" مع سهولة تحكم أخف بكثير. استهلاك الوقود في القيادة الفعلية يتراوح بين 32 و48 كم/لتر. من أبرز الأمثلة العملية على استخدامها في بالي: مستأجر استأجر V-Strom لأكثر من 40 يومًا وقادها إلى جزيرة فلوريس وعاد بها. درس عملي من مستأجر آخر في بالي: تبيّن أن الحامل الخلفي القياسي لتثبيت الحقائب غير موثوق أثناء الطريق — فقامت الشركة بتبديلها له بدراجة Versys مزودة بحقائب جانبية كاملة (كوفرات)؛ والخلاصة أنه إذا كانت هناك أمتعة، فالحقائب الجانبية الصلبة أنسب من ربطها بالحبال على الحامل. يوصي المستأجرون خصوصًا باتجاه سيدمين وجبل باتور والطرق المحيطة بأقصى نقطة شرقية في بالي، مشيرين إلى أن الازدحام يُشعَر به فعليًا فقط في أولوواتو وتشانغو وأوبود — وبعدها تبدأ مدرجات الأرز والغابات وإطلالات المحيط.

**لمن تناسب:** لمن يبحث في المقام الأول عن الراحة في الرحلات الطويلة، وليس عن طابع رياضي. المسارات التفصيلية في مقالات المدونة: «شرق بالي على متن دراجة»، و«سيكومبول وشلالات شمال وسط بالي»، و«براكين بالي على متن دراجة».

**أين تُبلي بلاءً حسنًا في بالي:** نفس فئة Versys-X250 — المسارات البعيدة، وسيدمين، وجبل باتور، والساحل الشرقي. إذا كنت تخطط لحمل أمتعة كثيرة، فقط أخبرنا وسنضيف لك حقائب جانبية على الدراجة.', 'Suzuki V-Strom 250 — دراجة تورينغ تركز على الراحة والحماية من الرياح', 'استئجار Suzuki V-Strom 250 في بالي: المواصفات، والاستهلاك الفعلي للوقود، وآراء المستأجرين حول الرحلات الطويلة في الجزيرة.'
  FROM articles a WHERE a.slug = 'suzuki-v-strom-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'TVS Ronin 225 — طراز كلاسيكي حديث على حدود السكرامبلر', 'tvs-ronin-225-review', 'TVS Ronin 225 دراجة مودرن-كلاسيك بلمسات سكرامبلر: مصباح LED دائري، ومقود بوضعية مرتفعة، وثبات سواء في المدينة أو على المخارج الترابية.', 'TVS Ronin 225 دراجة مودرن-كلاسيك بلمسات سكرامبلر: مصباح LED دائري، ومقود بوضعية مرتفعة، وهندسة متعددة الاستخدامات تتعامل بثقة متساوية في المدينة وعلى المخارج الترابية من الطريق الرئيسي. جميع الإصدارات مزودة بفرامل ABS. [شاهد TVS Ronin 225 في الكتالوج](/ar/bikes?group=motorcycle&model=tvs_ronin225).

**المواصفات:**
- المحرك: 225.9 سم³، تبريد بالزيت، أحادي الأسطوانة، SOHC، 4 صمامات
- القوة: نحو 20.4 حصانًا عند 7750 لفة/د
- عزم الدوران: نحو 19.9 نيوتن.متر عند 3750 لفة/د — يعطي قوة جر من الدورات المنخفضة دون الحاجة لتدوير المحرك بقوة
- ناقل الحركة: يدوي بخمس سرعات
- ارتفاع المقعد: نحو 795 مم
- الوزن: نحو 159 كجم
- خزان الوقود: نحو 14 لترًا
- فرامل ABS في جميع الإصدارات (أحادية القناة في الإصدار الأساسي، وثنائية القناة في الإصدارات الأعلى)

**الموثوقية:** تُعد TVS علامة ذات تاريخ طويل جدًا في الهند (تصنّع المركبات ثنائية العجلات منذ ثمانينيات القرن الماضي)، وRonin نفسها، رغم كونها طرازًا حديثًا نسبيًا (منذ عام 2022)، تمكنت خلال سنوات الاستخدام حتى الآن من بناء سمعة قوية في الموثوقية: في تقييمات المالكين بعد قطع مسافات تتجاوز 10,000 كم، يوصف المحرك بأنه يحافظ على نعومة مثالية، وتُظهر شوكات USD الذهبية مقاومة عالية للتآكل، ويبقى التجميع خاليًا من أي اهتزاز أو فراغ حتى بعد عام من القيادة النشطة على أسطح مختلفة. تصنيفات الموثوقية وتكلفة الصيانة لـRonin في تقييمات المالكين المستقلة من بين الأعلى ثباتًا في فئتها.

**ما يقوله المالكون:** يعمل المحرك بصوت عميق مميز للدراجات الكلاسيكية مع بحة خفيفة. عزم الدوران القوي عند الدورات المنخفضة يجعل الدراجة مريحة بشكل خاص في زحمة المدينة الكثيفة. الاستهلاك الفعلي بحسب التقييمات يتراوح بين 35 و45 كم/لتر. نظام التعليق مضبوط بنعومة — يمتص جيدًا مطبات المدينة. تحتوي بعض الإصدارات على أوضاع قيادة، من بينها وضع مخصص للمطر — مفيد بالنظر إلى مناخ بالي. الأداء الممتاز والمظهر الخارجي من النقاط التي تُذكر بانتظام في التقييمات كإحدى نقاط قوة الطراز.

**لمن تناسب:** لمن يريد دراجة نارية متعددة الاستخدامات للحياة اليومية — دون حدّة الدراجات الرياضية، لكن بثقة احتياطية على الطرق الترابية.

**أين تُبلي بلاءً حسنًا في بالي:** جيدة في تشانغو/سيمينياك بفضل مظهرها الكلاسيكي الحديث، وجيدة بنفس القدر على المخارج الترابية الجانبية المؤدية إلى مدرجات الأرز.', 'TVS Ronin 225 — طراز كلاسيكي حديث على حدود السكرامبلر', 'استئجار TVS Ronin 225 في بالي: المواصفات، والموثوقية، وآراء المالكين حول هذه الدراجة الكلاسيكية الحديثة بطابع سكرامبلر.'
  FROM articles a WHERE a.slug = 'tvs-ronin-225-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Keeway Road Falcon 250 — كروزر كلاسيكي بسعر مدخل الفئة', 'keeway-road-falcon-250-review', 'Keeway Road Falcon 250 كروزر كلاسيكي بهيكل ممدود وجلسة منخفضة، بسعر يناسب من يدخل هذه الفئة لأول مرة. طراز جديد في السوق — صدر عام 2026.', 'Keeway Road Falcon 250 تتميز بهيكل ممدود، وجلسة منخفضة، ولون أسود أنيق، وطابع مستوحى من الكروزرات الأمريكية الكبيرة، لكن على أساس مدمج سعة 250 سم³. الطراز جديد تمامًا في السوق — صدر عام 2026، لذا لا تتوفر بعد تقييمات فعلية من المستخدمين أو من مستأجري بالي تقريبًا. [شاهد Keeway Road Falcon 250 في الكتالوج](/ar/bikes?group=motorcycle&model=keeway_roadfalcon250).

**المواصفات:**
- المحرك: 248 سم³، سلينداران متوازيان، رباعي الأشواط، 4 صمامات، SOHC، تبريد بالسائل
- القوة: نحو 24.6 حصانًا عند 8000 لفة/د
- عزم الدوران: نحو 23.4 نيوتن.متر عند 6500 لفة/د
- ناقل الحركة: يدوي بست سرعات مع قابض انزلاقي (Slipper Clutch)
- ارتفاع المقعد: نحو 698 مم — من أدنى الجلسات في الأسطول
- درجة التخليص الأرضي: نحو 186 مم
- خزان الوقود: 14 لترًا
- الفرامل: قرص أمامي 300 مم (مكبس مزدوج)، وقرص خلفي 260 مم
- شاشة TFT مقاس 5 بوصات، ومكبر صوت بلوتوث مدمج — خيار نادر لهذه الفئة
- عرض الملاحة مباشرة على لوحة العدادات — تمامًا كما في XMAX250، فلا حاجة إطلاقًا إلى حامل هاتف مع هذا الطراز

**ما يقوله المالكون:** يُقارَن هذا الطراز مباشرة بدراجات بطراز Harley-Davidson وبـHonda Rebel — فـ"سنام" الخزان المميز في المقدمة والهيكل العام مستوحيان عن قصد من الكروزرات الأمريكية الكبيرة، وتوجد في الصحافة الإندونيسية مراجعات مقارنة مباشرة بين Road Falcon وHonda Rebel تحديدًا. مكبر الصوت البلوتوث المدمج في المقود أمر نادر لدراجات الكروزر من هذه الفئة. القابض الانزلاقي يخفف من صدمة التعشيق عند خفض السرعات — مفيد في مناطق بالي التلالية. ويُلاحَظ أيضًا أنها دراجة سهلة المناورة بشكل غير متوقع وبنصف قطر دوران صغير — وهو أمر ليس بديهيًا بالنظر إلى هيكلها الطويل كدراجة كروزر، لكنه ملحوظ عمليًا.

**لمن تناسب:** لمن يريد المظهر الكلاسيكي لدراجة الكروزر وجلسة مريحة — مناسبة بشكل خاص للدراجين قصيري القامة بفضل مقعدها المنخفض جدًا.

**أين تُبلي بلاءً حسنًا في بالي:** المسارات الساحلية الهادئة — سانور، ونوسا دوا — وليس فقط ذلك: فقد وصل بها بعض عملائنا إلى مواقع عادة ما تُخصص لدراجات تور-إندورو كلاسيكية مثل Versys وV-Strom، أي أن الدراجة تتحمل أيضًا المسارات البعيدة على طول الساحل الشمالي لبالي، رغم مظهرها الكروزري.', 'Keeway Road Falcon 250 — كروزر كلاسيكي بسعر مدخل الفئة', 'استئجار Keeway Road Falcon 250 في بالي: المواصفات، ومقارنة مع Honda Rebel، ولمن تناسب هذه الدراجة الكروزر.'
  FROM articles a WHERE a.slug = 'keeway-road-falcon-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Morbidelli C252V — كروزر بمحرك V-twin واسم إيطالي', 'morbidelli-c252v-review', 'Morbidelli C252V هي الكروزر الثاني في أسطولنا، لكنها تحمل محركًا حقيقيًا على شكل V بأسطوانتين بدلًا من الأسطوانتين المتوازيتين، ونظام دفع بالسير.', 'الكروزر الثاني في أسطولنا، لكنه مختلف جوهريًا في الطابع عن Road Falcon: تحمل Morbidelli محركًا حقيقيًا على شكل V بأسطوانتين (V-twin) بدلًا من الأسطوانتين المتوازيتين، ومن هنا يأتي صوت أعمق ("باسي") واهتزاز يعتبره كثير من دراجي الكروزر جزءًا من المتعة. علامة Morbidelli اسم إيطالي بتاريخ حقيقي في السباقات (ألقاب بطولة في فئتي 125 و250 سم³ في الجائزة الكبرى خلال سبعينيات القرن الماضي)، وحقوق العلامة أصبحت منذ عام 2024 مملوكة لنفس المجموعة المالكة لـKeeway — فهذه ليست مصادفة تشابه اسم، بل علامة أُحييت رسميًا على أساس تقني جديد. [شاهد Morbidelli C252V في الكتالوج](/ar/bikes?group=motorcycle&model=morbidelli_c252v).

**المواصفات:**
- المحرك: 249 سم³، محرك V بأسطوانتين (V-twin)، رباعي الأشواط، 8 صمامات، SOHC، تبريد بالسائل
- القوة: نحو 25.5 حصانًا عند 9000 لفة/د
- عزم الدوران: 25 نيوتن.متر عند 5500 لفة/د
- ناقل الحركة: يدوي بست سرعات مع قابض انزلاقي
- نظام الدفع: سير (belt drive) — أمر نادر لهذه الفئة. عمليًا يعني ذلك: لا حاجة للتشحيم أو الشد الدوري كما في السلسلة، ولا يصدأ السير من المطر
- ارتفاع المقعد: 690 مم — من أدنى الارتفاعات في الأسطول
- الوزن: نحو 200 كجم
- خزان الوقود: 15.5 لتر
- درجة التخليص الأرضي: 173 مم
- الفرامل: قرص أمامي 320 مم (مكبس رباعي)، وقرص خلفي 260 مم (مكبس مزدوج)؛ فرامل ABS ثنائية القناة من Bosch ونظام تحكم بالجر ضمن التجهيز القياسي
- شوكة أمامية مقلوبة (USD) 37 مم، بمشوار 115 مم؛ وفي الخلف مخمدان قابلان لضبط الشد المسبق على 5 مستويات
- السرعة القصوى المعلنة: 125 كم/س

**ما يقوله المالكون:** الطراز جديد جدًا في السوق، لذا لا يوجد بعد تاريخ استخدام طويل، لكن أولى تجارب القيادة في الصحافة تشير إلى سهولة تحكم غير متوقعة لكروزر بقاعدة عجلات طويلة كهذه — فنصف قطر الدوران لا يُظهر حجم الدراجة الحقيقي. يوصف المحرك على شكل V بأنه لافت بصريًا (يظهر تحت الخزان، مع محاكاة لزعانف التبريد ولمسات كروم) وذو صوت أعمق بوضوح من الأسطوانتين المتوازيتين التقليديتين سعة 250 سم³.

**لمن تناسب:** لمن يريد تحديدًا طابع V-twin لدراجة الكروزر (وليس الأسطوانتين المتوازيتين كما في Road Falcon) — اهتزازًا أوضح وصوتًا أعمق للمحرك، بالإضافة إلى سير بدلًا من السلسلة — لا حاجة للتشحيم أو الشد، ولا يصدأ في المطر.

**أين تُبلي بلاءً حسنًا في بالي:** نفس فئة Road Falcon — المسارات الساحلية الهادئة، سانور، نوسا دوا؛ والسير مع الجلسة المنخفضة يجعلانها مريحة بشكل خاص لمن يريد أسلوب كروزر مسترخٍ دون القلق بشأن السلسلة.', 'Morbidelli C252V — كروزر بمحرك V-twin واسم إيطالي', 'استئجار Morbidelli C252V في بالي: محرك V-twin، ونظام دفع بالسير، والمواصفات، والفرق بين هذا الكروزر وRoad Falcon.'
  FROM articles a WHERE a.slug = 'morbidelli-c252v-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Honda CBR250RR — هيكل انسيابي كامل وأكثر دراجات المضمار في أسطولنا', 'honda-cbr250rr-review', 'Honda CBR250RR هي الدراجة الرياضية الوحيدة بهيكل انسيابي كامل في أسطولنا، بنسختها العليا المزودة بناقل حركة سريع وفرامل ABS. من أبرز الطرازات التقنية في فئة 250 سم³ بإندونيسيا.', 'الدراجة الرياضية الوحيدة بهيكل انسيابي كامل في أسطولنا (بخلاف MT-25 وZX-25R اللتين تُعدّان دراجتي نيكد/ستريت فايتر "عاريتين") — تُعتبر Honda CBR250RR منذ ظهورها عام 2016 من أبرز الطرازات التقنية في فئة 250 سم³ بإندونيسيا. [شاهد Honda CBR250RR في الكتالوج](/ar/bikes?group=motorcycle&model=honda_cbr250rr).

**المواصفات (النسخة العليا SP Quick Shifter مع ABS — وهي المتوفرة في أسطولنا):**
- المحرك: 249.7 سم³، تبريد بالسائل، DOHC، سلينداران متوازيان، 8 صمامات، مع تحسينات النسخة العليا (عمود مرفقي مخفف الوزن، نوابض صمامات جديدة، رأس أسطوانة معدّل)
- القوة: نحو 41 حصانًا عند 13,000 لفة/د
- عزم الدوران: نحو 25 نيوتن.متر عند 11,000 لفة/د
- ناقل الحركة: يدوي بست سرعات
- ارتفاع المقعد: نحو 790 مم
- الوزن: نحو 168 كجم
- فرامل ABS، إضاءة LED كاملة، لوحة عدادات رقمية، خانق إلكتروني (throttle-by-wire) دون سلك ميكانيكي
- ناقل حركة سريع بأربعة أوضاع قابلة للتعديل (للأعلى وللأسفل، للأعلى فقط، للأسفل فقط، إيقاف) — تبديل السرعات دون الضغط على القابض
- قابض مساعد-انزلاقي (Slipper Clutch)
- شوكة أمامية مقلوبة (USD) من نوع SFF-Big Piston
- 3 أوضاع قيادة: Comfort وSport وSport+
- التسارع المعلن من صفر إلى 200 متر في 8.65 ثانية، والسرعة القصوى حتى 172 كم/س

**ما يقوله المالكون:** تُذكر CBR250RR باستمرار كواحدة من أكثر الدراجات "غنى" تقنيًا في فئة 250 سم³ بإندونيسيا — فالنسخة المزودة بناقل الحركة السريع تمنح إحساسًا حقيقيًا بأجواء المضمار، وهو أمر نادر لهذه السعة من المحرك.

**لمن تناسب:** لمن يريد تجربة دراجة رياضية كاملة — هيكل انسيابي، وجلسة رياضية "منبطحة على الخزان"، وتقنيات بمستوى ناقل الحركة السريع في MotoGP.

**أين تُبلي بلاءً حسنًا في بالي:** مثل ZX-25R تمامًا — المدينة والكورنيش، لأجل الإحساس والطابع وليس لمسار محدد؛ ونظرًا لأصولها في عالم المضمار، تُبلي بلاءً ممتازًا أيضًا على حلبة مانداليكا في لومبوك.', 'Honda CBR250RR — هيكل انسيابي كامل وأكثر دراجات المضمار في أسطولنا', 'استئجار Honda CBR250RR في بالي: النسخة العليا بناقل حركة سريع، والمواصفات، ولمن تناسب تجربة الدراجة الرياضية الكاملة.'
  FROM articles a WHERE a.slug = 'honda-cbr250rr-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'Honda CB150X — طابع أدفنتشر ميسور التكلفة بمحرك سعة 150 سم³', 'honda-cb150x-review', 'Honda CB150X مدخل ميسور إلى طراز الأدفنتشر بمحرك سعة 150 سم³، بمواصفات جادة لفئتها وأخف وزن بين دراجات الأسطول.', 'CB150X ليست مثل Versys-X250 وV-Strom250 سعة 250 سم³: فهي مدخل اقتصادي إلى طراز الأدفنتشر بمحرك متواضع أحادي الأسطوانة سعة 150 سم³، لكن بمواصفات هيكلية جادة فعلًا لفئتها (درجة تخليص أرضي تقارب دراجة CB500X الأكبر بكثير). وبفضل وزنها الخفيف جدًا كدراجة نارية (139 كجم)، يصبح محرك 150 سم³ كافيًا تمامًا — إذ ترفع الدراجة عجلتها الأمامية بسهولة وتحافظ على أداء واثق في كامل نطاق السرعات، وليس فقط عند السرعات المنخفضة كما قد يُظن من أسطوانة واحدة وسعة متواضعة. [شاهد Honda CB150X في الكتالوج](/ar/bikes?group=motorcycle&model=honda_cb150x).

**المواصفات:**
- المحرك: 149.16 سم³، أحادي الأسطوانة، تبريد بالسائل، DOHC رباعي الصمامات
- القوة: نحو 15.6 حصانًا عند 9000 لفة/د
- عزم الدوران: نحو 13.8 نيوتن.متر عند 7000 لفة/د
- ناقل الحركة: يدوي بست سرعات
- ارتفاع المقعد: 817 مم
- درجة التخليص الأرضي: 181 مم — تقارب دراجة CB500X الأكبر بكثير
- الوزن: نحو 139 كجم — أخف دراجة نارية (وليست سكوتر) في الأسطول
- خزان الوقود: 12 لترًا
- شوكة أمامية مقلوبة (USD) من Showa طراز SFF-BP مقاس 37 مم، ونظام تعليق خلفي أحادي Pro-Link
- أقراص فرامل متموجة (Wavy) في الأمام والخلف
- لوحة عدادات رقمية بالكامل تعرض استهلاك الوقود اللحظي

**لمن تناسب:** لمن يريد طابع الأدفنتشر والجلسة العالية، دون الاستعداد لوزن وقوة دراجة تورينغ كاملة سعة 250 سم³ — خطوة جيدة للانتقال من الدراجات المدنية إلى طرازات أكثر جدية.

**أين تُبلي بلاءً حسنًا في بالي:** نفس منطق ADV160 — الطرق الجانبية والإسفلت غير المثالي، لكن من حيث الجلسة والطابع فهي دراجة نارية كاملة بناقل حركة يدوي، وليست سكوترًا.', 'Honda CB150X — طابع أدفنتشر ميسور التكلفة بمحرك سعة 150 سم³', 'استئجار Honda CB150X في بالي: المواصفات، ودرجة التخليص الأرضي، ولمن تناسب دراجة الأدفنتشر الاقتصادية.'
  FROM articles a WHERE a.slug = 'honda-cb150x-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'ar', 'PCX160 مقابل ADV160 مقابل Nmax — كيف تختار من بين الثلاثة', 'pcx160-vs-adv160-vs-nmax-how-to-choose', 'PCX160 وADV160 وNmax — كيف تختار بين أكثر ثلاثة سكوترات طلبًا في أسطولنا: ما الفرق بينها من حيث سعة الصندوق والأداء والجلسة.', 'بصراحة، تختلف هذه الطرازات الثلاثة في المقام الأول من الناحية البصرية وفيما اعتاد عليه الراكب — باختصار، الأمر مسألة ذوق. من أهم الفروق العملية الحقيقية يأتي حجم الصندوق في المقدمة: تناسب Nmax من هو مستعد للتضحية بجزء من سعة الصندوق مقابل حبه لجلستها وأدائها. أما من حيث الأداء الصرف، فيمزح فريقنا فيما بينهم قائلين إن من يريد فعلًا استجابة بطابع "توربو"، فمن الأفضل أن يختار ADV من هذه التشكيلة — إذ يُحسّ به ذاتيًا أكثر حيوية من الطراز الذي يحمل كلمة "Turbo" في اسمه.

من الناحية المثالية، قبل اختيار دراجة لفترة طويلة، يُفضَّل تجربة كل طراز لمدة تتراوح من 5 أيام إلى شهر لتشعر فعلًا بالفرق. غالبًا لا تكفي مدة يوم إلى ثلاثة أيام لفهم الدراجة فهمًا حقيقيًا.

بطاقات الطرازات: [Honda PCX160](/ar/bikes?category=honda_pcx160)، [Honda ADV160](/ar/bikes?category=honda_adv160)، [Yamaha Nmax](/ar/bikes?category=yamaha_nmax155).', 'PCX160 مقابل ADV160 مقابل Nmax — كيف تختار من بين الثلاثة', 'مقارنة بين Honda PCX160 وHonda ADV160 وYamaha Nmax عند الاستئجار في بالي — أي سكوتر تختار وفق احتياجاتك.'
  FROM articles a WHERE a.slug = 'pcx160-vs-adv160-vs-nmax-how-to-choose'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Honda PCX160 — रोज़ाना के लिए आराम और स्पेस', 'honda-pcx160-review', 'Honda PCX160 उन लोगों की पहली पसंद है जो बिना स्टोरेज स्पेस से समझौता किए आरामदायक स्कूटर चाहते हैं। यह वह मॉडल है जिसे अक्सर कपल्स और सूटकेस के साथ ट्रैवल करने वाले लोग चुनते हैं।', 'Honda PCX160 उन लोगों के लिए सबसे बेहतरीन ऑल-राउंड चॉइस है जो बिना स्टोरेज स्पेस से समझौता किए एक आरामदायक स्कूटर चाहते हैं। यही वह मॉडल है जिसे ज़्यादातर कपल्स और सूटकेस या बड़े बैग के साथ घूमने वाले ट्रैवलर्स चुनते हैं। [हमारे कैटलॉग में Honda PCX160 देखें](/hi/bikes?category=honda_pcx160)।

**स्पेसिफिकेशन:**
- इंजन: 156.9cc, लिक्विड-कूल्ड, eSP+
- पावर: करीब 15.8 hp, 8500 rpm पर
- गियरबॉक्स: CVT (ऑटोमैटिक), कोई गियर बदलने की ज़रूरत नहीं
- सीट हाइट: ~764mm — लगभग किसी भी हाइट के राइडर के लिए आरामदायक
- फ्यूल टैंक: 8.1 लीटर
- सीट के नीचे स्टोरेज: ~30 लीटर — एक फुल-फेस हेलमेट आराम से आ जाता है और बाकी सामान के लिए भी जगह बचती है
- स्मार्ट-की, LED लाइटिंग, पावरफुल USB चार्जिंग, डिजिटल इंस्ट्रूमेंट पैनल
- हमारे पास स्टैंडर्ड रंगों के अलावा कस्टम कलर्स की भी अच्छी-खासी रेंज मिलेगी

**एक्स्ट्रा एक्सेसरीज़:** PCX160 पर 44 लीटर का SHAD टॉप-बॉक्स लगाया जा सकता है — उन लोगों के लिए फायदेमंद जिन्हें सीट के नीचे की स्टोरेज कम लगती है। एक्स्ट्रा एक्सेसरीज़ के बारे में और जानने के लिए हमारा आर्टिकल पढ़ें [«रेंटल एक्स्ट्रा जो लेने लायक हैं: हेलमेट और कम्फर्ट बॉक्स»](/hi/blog/rental-extras-worth-adding-helmets-and-the-comfort-box)।

**मालिकों का क्या कहना है:** रिव्यूज़ में असली फ्यूल माइलेज करीब 40-50 km/l बताया जाता है, जिससे पूरे आइलैंड में घूमना लगभग मुफ्त जैसा लगता है। रिलायबिलिटी के मामले में इस मॉडल की रेप्युटेशन लगभग लेजेंडरी है — फोरम्स पर PCX की तुलना लॉनमूवर से की जाती है: स्टार्ट होता है और सालों तक बिना किसी झंझट के चलता रहता है। रेंटल लेने वालों के लिए एक प्रैक्टिकल बात: स्मार्ट-की इस्तेमाल में आसान है, लेकिन अगर खो जाए तो इसे दोबारा बनवाने में करीब 10 लाख रुपिया खर्च हो सकता है, इसलिए चाबी संभालकर रखना बेहतर है — यह कैसे काम करती है, इसके बारे में हमारा आर्टिकल पढ़ें [«बाइक कैसे स्टार्ट करें और की-फोब का इस्तेमाल कैसे करें»](/hi/blog/how-to-start-and-use-your-rental-scooters-smart-key)। पीछे पैसेंजर बैठा हो तो ओवरटेकिंग के लिए एक्सीलरेशन रिज़र्व काफी कम हो जाता है — शहर में कोई दिक्कत नहीं, लेकिन हाईवे पर इसका ध्यान रखना चाहिए।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** आगे के 14-इंच व्हील की वजह से डामर पर पकड़ भरोसेमंद रहती है — चांगू, सेमिन्याक, सानूर में आरामदायक, और डेनपासार में रोज़मर्रा की राइड्स के लिए भी बढ़िया।', 'Honda PCX160 — रोज़ाना के लिए आराम और स्पेस', 'बाली में किराए पर मिलने वाले Honda PCX160 के स्पेसिफिकेशन, फ्यूल माइलेज, मालिकों के रिव्यू और एक्सेसरीज़ — कहाँ फिट बैठता है और किसे लेना चाहिए।'
  FROM articles a WHERE a.slug = 'honda-pcx160-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Honda ADV160 — ऊबड़-खाबड़ रास्तों और लंबी राइड्स के लिए', 'honda-adv-review', 'Honda ADV160 में PCX160 वाला ही भरोसेमंद इंजन है, लेकिन बॉडी अलग है: ऊँची सीटिंग, ज़्यादा ग्राउंड क्लियरेंस, और टूटी सड़कों व कच्चे रास्तों पर ज़्यादा भरोसेमंद।', 'Honda ADV160 में वही भरोसेमंद इंजन है जो PCX160 में है, लेकिन बॉडी अलग है: ऊँची सीटिंग पोज़ीशन, ज़्यादा ग्राउंड क्लियरेंस, और टूटी-फूटी सड़कों व कच्चे रास्तों पर ज़्यादा कॉन्फिडेंस के साथ चलता है। [हमारे कैटलॉग में Honda ADV160 देखें](/hi/bikes?category=honda_adv160)।

**स्पेसिफिकेशन:**
- इंजन: 156.9cc, लिक्विड-कूल्ड, eSP+ (PCX160 वाला ही इंजन)
- पावर: करीब 15.8 hp
- गियरबॉक्स: CVT
- सीट हाइट: ~795mm — शहर के स्कूटरों से ज़्यादा ऊँची, लंबे कद के राइडर्स और ऊँची सीटिंग पोज़ीशन पसंद करने वालों के लिए बेहतर
- ग्राउंड क्लियरेंस ~165mm — स्टैंडर्ड से काफी ज़्यादा
- सीट के नीचे स्टोरेज: ~30 लीटर — एक फुल-फेस हेलमेट आराम से आ जाता है और बाकी सामान के लिए भी जगह बचती है
- एडजस्टेबल विज़र — 2 पोज़िशन: ऊपर (एग्रेसिव लुक) और नीचे (सिटी राइडिंग)
- सेमी-डिजिटल इंस्ट्रूमेंट पैनल, पावरफुल USB चार्जिंग, स्मार्ट-की
- हमारे पास स्टैंडर्ड रंगों के अलावा कस्टम कलर्स की भी अच्छी-खासी रेंज मिलेगी

**एक्स्ट्रा एक्सेसरीज़:** PCX160 की तरह ही, इस पर भी 44 लीटर का SHAD टॉप-बॉक्स लगाया जा सकता है। ज़्यादा जानकारी के लिए हमारा आर्टिकल पढ़ें [«रेंटल एक्स्ट्रा जो लेने लायक हैं: हेलमेट और कम्फर्ट बॉक्स»](/hi/blog/rental-extras-worth-adding-helmets-and-the-comfort-box)।

**मालिकों का क्या कहना है:** इस इंजन की दूसरी बड़ी खूबी है इसकी फ्यूल इफिशिएंसी: रिव्यूज़ में असली माइलेज 34-38 km/l के आसपास रहता है — एक्टिव राइडिंग में भी बार-बार फ्यूल भरवाने की ज़रूरत नहीं पड़ती। और दिलचस्प बात यह है कि ADV160, PCX-Nmax-ADV लाइनअप में सबसे ज़्यादा स्पोर्टी बाइक्स में से एक है, हालांकि इंजन PCX160 वाला ही है — बस ट्यूनिंग अलग है। ग्राउंड क्लियरेंस कच्चे और टूटे-फूटे रास्तों पर वाकई काम आता है, लेकिन मालिक ईमानदारी से बताते हैं: यह सिटी-एडवेंचर स्टाइलिंग है, असली एंड्यूरो नहीं — बड़े पत्थरों और गंभीर ऊबड़-खाबड़ रास्तों पर यह क्लियरेंस कम पड़ जाता है।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** उबुद और आसपास का इलाका (राइस टैरेस, छोटी साइड रोड्स), मुंडुक और वॉटरफॉल्स, उलुवातु और बुकित प्रायद्वीप के पहाड़ी हिस्से — इन जगहों पर सतह और रास्ते की क्वालिटी अलग-अलग होती है, ADV160 एक सिटी स्कूटर के मुकाबले ज़्यादा माफ कर देता है, लेकिन असली सीरियस ऑफ-रोडिंग इसके बस की बात नहीं।', 'Honda ADV160 — ऊबड़-खाबड़ रास्तों और लंबी राइड्स के लिए', 'बाली में किराए पर मिलने वाले Honda ADV160 के स्पेसिफिकेशन, फ्यूल माइलेज और मालिकों के रिव्यू — कहाँ इसकी सिटी-एडवेंचर स्टाइलिंग सबसे ज़्यादा काम आती है।'
  FROM articles a WHERE a.slug = 'honda-adv-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Yamaha Nmax — New (Gen 2), Neo (Gen 3) और Turbo', 'yamaha-nmax-review', 'हमारी फ्लीट में Nmax कोई एक मॉडल नहीं, बल्कि एक ही नाम के नीचे कई जनरेशन और ट्रिम्स हैं: New, Neo और Turbo। जानिए इनमें असल में क्या फर्क है।', 'हमारी फ्लीट में "Nmax" कोई एक मॉडल नहीं है, बल्कि एक ही नाम के नीचे कई जनरेशन और ट्रिम्स आते हैं। New और Neo — इंजन और ट्रांसमिशन के मामले में एक ही टेक्नोलॉजी है, बस लाइनअप की अलग-अलग जनरेशन (Gen 2 और Gen 3) हैं। जबकि Turbo की कहानी अलग है — इसमें ट्रांसमिशन की अलग इलेक्ट्रॉनिक सेटिंग्स दी गई हैं। [हमारे कैटलॉग में Yamaha Nmax देखें](/hi/bikes?category=yamaha_nmax155)।

**Nmax New (Gen 2):**
- इंजन: 155cc, Blue Core, VVA, SOHC 4-वाल्व
- पावर: ~15 hp, 8000 rpm पर
- गियरबॉक्स: क्लासिक रोलर-टाइप CVT
- वज़न: ~132 kg
- फ्यूल टैंक: 7.1 लीटर

**Nmax Neo (Gen 3):**
- New वाला ही 155cc Blue Core VVA इंजन, कैपेसिटी और बनावट में बिल्कुल समान — फर्क सिर्फ लुक, जनरेशन और ट्रिम में है, अंदरूनी टेक्नोलॉजी वही है
- पावर: ~15 hp, 8000 rpm पर
- गियरबॉक्स: क्लासिक CVT
- वज़न: ~130 kg
- दो वर्ज़न: Neo (बेस) और Neo S (+ Smart Key सिस्टम)

**Nmax "Turbo":**
- New/Neo वाला ही इंजन कैपेसिटी
- सबसे बड़ा फर्क है YECVT (Yamaha Electric CVT): असल में वही CVT सिस्टम, बस मैकेनिकल रोलर्स की जगह इलेक्ट्रॉनिक कंट्रोल। यह ज़्यादातर राइडिंग फील और इलेक्ट्रॉनिक सेटिंग्स की मार्केटिंग है, कोई पूरी तरह अलग ट्रांसमिशन नहीं
- दो राइडिंग मोड T-Mode/S-Mode + वर्चुअल "गियर" Y-Shift (Low/Medium/High) — कार की तरह गियर बदलने का एहसास देने वाला फीचर
- वज़न: वर्ज़न के हिसाब से ~133-135 kg
- तीन वर्ज़न: Turbo (बेस), Turbo Tech Max (TFT डिस्प्ले, USB-C पोर्ट, स्पेशल सीट), Turbo Tech Max Ultimate (टॉप वर्ज़न)
- ज़रूरी बात: नाम में "Turbo" इलेक्ट्रॉनिक्स और रिस्पॉन्स के फील की वजह से है, इसका मतलब इंजन में असली टर्बोचार्जिंग नहीं है
- हमारे पास स्टैंडर्ड रंगों के अलावा कस्टम कलर्स की भी अच्छी-खासी रेंज मिलेगी

**मालिकों का क्या कहना है:** रिव्यूज़ में इंजन (चाहे कोई भी जनरेशन हो) को "अमर" जैसा बताया जाता है — रिलायबिलिटी पूरी लाइनअप की सबसे बड़ी ताकतों में से एक है। फ्यूल इफिशिएंसी भी मज़बूत पॉइंट है — फैमिली की बाकी मॉडल्स (PCX160, ADV160) वाला ही इकॉनमिकल 155cc इंजन, असली राइडिंग में माइलेज कम्फर्टेबल रेंज में रहता है, बार-बार फ्यूल भरवाने की ज़रूरत नहीं पड़ती। स्टोरेज को लेकर एक दिलचस्प बात: नंबर तो अच्छे-खासे बताए गए हैं, लेकिन नीचे की जगह की शेप ऐसी है कि फुल-फेस हेलमेट हमेशा नहीं आता। एक अच्छी बात यह है कि बाएं हैंडलबार कवर के नीचे फोन और वॉलेट के लिए अलग कम्पार्टमेंट है। बाली के रेंटल यूज़र्स के रिव्यूज़ में खासतौर पर चढ़ाई ("tanjakan") पर टॉर्क और लंबी राइड्स के लिए सॉफ्ट सस्पेंशन की तारीफ की जाती है — जैसे उलुवातु तक की राइड। कई टूरिस्ट गाइड्स में ABS और चौड़े ट्यूबलेस टायर्स को अलग से प्लस पॉइंट बताया जाता है, खासकर बार-बार होने वाली उष्णकटिबंधीय बारिश और सड़क पर अचानक आने वाली रुकावटों जैसे कुत्तों की वजह से — पैनिक ब्रेकिंग में भी पहिया लॉक नहीं होता।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** शहर के ट्रैफिक (चांगू, सेमिन्याक) में भी और मीडियम लंबाई के हाईवे पर भी भरोसेमंद रहता है, जिसमें उलुवातु तक की राइड भी शामिल है — मोड़ों पर और बारिश में अच्छी स्टेबिलिटी। यह सभी वर्ज़न पर एक जैसा लागू होता है — इनकी जियोमेट्री और सीटिंग पोज़ीशन में लगभग कोई फर्क नहीं है।', 'Yamaha Nmax — New (Gen 2), Neo (Gen 3) और Turbo', 'बाली में किराए पर Yamaha Nmax: New, Neo और Turbo में क्या फर्क है, स्पेसिफिकेशन और मालिकों के असली रिव्यू।'
  FROM articles a WHERE a.slug = 'yamaha-nmax-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Yamaha XMAX250 — Connected और Tech Max: मैकेनिकल एक जैसी, फिनिशिंग अलग', 'yamaha-xmax250-review', 'Yamaha XMAX250 हमारी लाइनअप का सबसे पावरफुल स्कूटर है, जो लंबी दूरी और शहर दोनों में बढ़िया चलता है। फ्लीट में Connected और Tech Max वर्ज़न हैं, दोनों की मैकेनिकल एक जैसी है।', 'Yamaha XMAX250 हमारी लाइनअप का सबसे पावरफुल स्कूटर है। बहुत से लोग इस बड़े "जानवर" को खासतौर पर पसंद करते हैं, और भले ही सब मानते हैं कि यह लंबी दूरी के लिए बढ़िया है — कई लोगों के लिए छोटी शहरी राइड्स के लिए भी इससे बेहतर कुछ नहीं। हमारी फ्लीट में यह मॉडल दो वर्ज़न में मिलती है — Connected और Tech Max — और यहां समझना ज़रूरी है: टेक्निकली यह एक ही बाइक है, फर्क सिर्फ फिनिशिंग में है। [हमारे कैटलॉग में Yamaha XMAX250 देखें](/hi/bikes?category=yamaha_xmax250)।

**स्पेसिफिकेशन (Connected और Tech Max दोनों के लिए एक जैसे — इंजन और चेसिस बिल्कुल समान):**
- इंजन: 250cc, सिंगल-सिलेंडर, लिक्विड-कूल्ड, SOHC 4-वाल्व, Blue Core, वन-पीस फोर्ज्ड क्रैंकशाफ्ट
- पावर: 16.8 kW, 7000 rpm पर
- टॉर्क: 24.3 Nm, 5500 rpm पर
- गियरबॉक्स: CVT
- सीट हाइट: 795mm
- वज़न: ~181 kg
- फ्यूल टैंक: 13 लीटर
- सीट के नीचे स्टोरेज: 44.9 लीटर — काफी ज़्यादा, इसमें दो फुल-फेस हेलमेट के साथ बाकी सामान भी आराम से आ जाता है। एक ज़रूरी बात: कभी-कभी फुल-फेस हेलमेट को सही तरीके से रखने के लिए एक खास एंगल में घुमाना पड़ता है
- ABS, ट्रैक्शन कंट्रोल (TCS), Emergency Stop Signal (इमरजेंसी ब्रेकिंग के दौरान स्टॉप-लाइट का ऑटोमैटिक ब्लिंकिंग), Answer Back System वाली स्मार्ट-की (पार्किंग में बाइक ढूंढने के लिए सिग्नल), फोन चार्जिंग के लिए इलेक्ट्रिकल सॉकेट
- Connected वर्ज़न में विंडस्क्रीन फिक्स्ड है, एडजस्ट नहीं होती। एडजस्टेबल विंडस्क्रीन सिर्फ Tech Max में है (नीचे देखें)
- Yamaha Indonesia की वारंटी — फ्रेम, फ्यूल सिस्टम के पार्ट्स, सिलेंडर और पिस्टन पर 5 साल / 50,000 km

**Y-Connect ऐप — एक ज़रूरी बात जिसे रेंटल लेने वाले को अलग से समझाना ज़रूरी है:**

XMAX Connected मॉडल में ऐप कनेक्ट करने की सुविधा मिलती है:

📱 यहाँ से डाउनलोड करें:
https://apps.apple.com/app/id1495921872
https://apps.apple.com/app/id1585591110

कनेक्ट करने से क्या मिलता है:
• हैंडलबार से इनकमिंग कॉल रिसीव करना
• हैंडलबार से म्यूज़िक कंट्रोल
• फोन की भाषा में नेविगेशन
• स्मार्टफोन के साथ आसान इंटीग्रेशन

**Connected बनाम Tech Max — फर्क क्या है:**

सबसे ज़रूरी और सबसे महंगा फर्क है सीट। Tech Max की सीट सिर्फ "अलग स्टिचिंग" वाली नहीं है, बल्कि यह MBK (Yamaha की फ्रेंच ब्रांड, जो खासतौर पर यूरोपियन स्कूटर्स में स्पेशलाइज़ करती है) की बनाई हुई अलग से डिज़ाइन की गई सीट है — जिसे "Comfort Seat" कहा जाता है। अंदर हाई-डेंसिटी फोम और साइड्स पर बॉल्स्टर सपोर्ट दिए गए हैं, जो खासतौर पर घंटों की राइडिंग के लिए डिज़ाइन किए गए हैं: यह सीट लंबी राइड्स में पोज़ीशन बनाए रखती है और कमर की थकान कम करती है, सिर्फ छूने में सॉफ्ट होना काफी नहीं है। ऊपर से इको-लेदर, सुएड इंसर्ट्स और गोल्ड थ्रेड स्टिचिंग, साथ ही क्रोम इंसर्ट भी है। रिव्यूज़ में मालिक अलग से बताते हैं कि Tech Max के लिए एक्स्ट्रा पैसे देने की सबसे बड़ी वजह यही सीट है, न कि कलर या बैजिंग।

बाकी फर्क भी असली हैं, लेकिन कीमत और अहमियत के मामले में सीट से कम हैं:
- एक्सक्लूसिव कलर (पुराने मॉडल में Magma Black, 2025 से Ceramic Grey)
- सीट के नीचे पॉकेट का कवर इको-लेदर और सुएड में, गोल्ड स्टिचिंग के साथ (सीट से मैच करता हुआ)
- एल्युमिनियम फुटपेग प्लेट्स, क्रोम ट्रिम, स्पेशल बैजिंग और Tech Max की अलग टेक्सचर वाली ग्रिप्स
- 2025 वाले Tech Max मॉडल में एक ऐसा फर्क आया जो सिर्फ दिखावटी नहीं, बल्कि फंक्शनल भी है — इलेक्ट्रिकली एडजस्टेबल विंडस्क्रीन (Electric Adjustable Screen), जिसे चलते-चलते भी अपनी पसंद के हिसाब से तुरंत सेट किया जा सकता है, साथ ही अपडेटेड TFT इंस्ट्रूमेंट पैनल भी है; जबकि Connected में विंडस्क्रीन, जैसा ऊपर बताया गया, बिल्कुल भी एडजस्ट नहीं होती

इंडोनेशियन मार्केट में Tech Max वर्ज़न की कीमत का फर्क करीब 50 लाख रुपिया है, और यह एक्स्ट्रा पैसा सबसे पहले उसी सीट में जाता है।

**मालिकों का क्या कहना है:** इंजन आराम से 100-110 km/h तक खींच लेता है, उसके बाद थोड़ा "हांफने" लगता है — यह तेज़ रफ्तार पकड़ने वाली बाइक नहीं, बल्कि स्टेबल क्रूज़िंग पेस के लिए बनी बाइक है। इंडोनेशियन XMAX ओनर्स क्लब ने 2017 में ही इस मॉडल का पहला टूरिंग इवेंट बाली में किया था — रूट था डेनपासार → उबुद → किंतामणि → बेसाकिह → क्लुंगकुंग → गियानयार → Ida Bagus Mantra रोड और वापस; उबुद और किंतामणि के घुमावदार हिस्सों में पार्टिसिपेंट्स ने ट्रैक्शन कंट्रोल टेस्ट किया, और Ida Bagus Mantra टोल रोड के सीधे हिस्से पर 140 km/h तक स्पीड बढ़ाई।

बाली में XMAX250 के लिए तय किए हुए रूट, जिन्हें खुद बाइकर्स नाम देते हैं: साउथ कोस्ट — चांगू → उलुवातु (Jalan Bali Cliff होते हुए) → पंडावा बीच → GWK; माउंटेन रूट — डेनपासार → उबुद → किंतामणि → बातूर झील → मुंडुक; ईस्ट रूट — सानूर → कैंडिडासा → सिडेमेन → वर्जिन बीच। डिटेल्ड रूट्स और मैप पॉइंट्स — हमारे ब्लॉग आर्टिकल्स «बुकित प्रायद्वीप बाइक पर», «किंतामणि: बातूर ज्वालामुखी पर सूर्योदय» और «ईस्ट बाली बाइक पर» (यहीं वर्जिन बीच भी शामिल है) में — जल्द ही पब्लिश करेंगे।

**किसे लेना चाहिए:** एक-दिन या मल्टी-डे आइलैंड ट्रिप्स के लिए, जहाँ ओवरटेकिंग और चढ़ाई के लिए एक्स्ट्रा पावर और लंबे हाईवे स्ट्रेच पर कम्फर्ट ज़रूरी है। रोज़मर्रा की राइडिंग के लिए भी — यह बाली में टूरिस्ट्स और लंबे समय से रहने वाले दोनों में सबसे पॉपुलर बाइक्स में से एक है।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** आइलैंड के साउथ से बाहर के रूट — किंतामणि और बातूर ज्वालामुखी, अमेड, लोविना, सिडेमेन, ईस्ट कोस्ट। लेकिन फिर भी यह पसंद की बात है — कुछ लोग चांगू के ट्रैफिक में भी इतनी बड़ी टूर-एंड्यूरो बाइक चलाने में मज़ा लेते हैं, और ऐसे एंथूज़ियास्ट्स की कमी नहीं है।', 'Yamaha XMAX250 — Connected और Tech Max: मैकेनिकल एक जैसी, फिनिशिंग अलग', 'बाली में किराए पर Yamaha XMAX250: Connected और Tech Max में फर्क, स्पेसिफिकेशन, Y-Connect ऐप और आइलैंड के बेहतरीन रूट्स।'
  FROM articles a WHERE a.slug = 'yamaha-xmax250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Yamaha MT-25 — Gen 2 और Gen 3: लुक अलग, इंजन वही', 'yamaha-mt25-review', 'Yamaha MT-25 एक कॉम्पैक्ट स्ट्रीटफाइटर है, उन लोगों के लिए जो मोटरसाइकिल का असली एक्सीलरेशन और रिस्पॉन्स महसूस करना चाहते हैं। फ्लीट में 2025 के रीस्टाइलिंग के बाद Gen 2 और Gen 3, दोनों मिलती हैं।', 'Yamaha MT-25 एक कॉम्पैक्ट स्ट्रीटफाइटर है, उन लोगों के लिए जो सिर्फ पॉइंट A से पॉइंट B तक पहुंचना नहीं चाहते, बल्कि मोटरसाइकिल का एक्सीलरेशन और रिस्पॉन्स महसूस करना चाहते हैं। बाइक में सच में कैरेक्टर है — कई प्रोफेशनल्स और एंथूज़ियास्ट्स इसे अपनी कैटेगरी की सबसे पसंदीदा बाइक्स में गिनते हैं: डायनामिक्स, सीटिंग पोज़ीशन और लुक — सभी मामलों में। मैनुअल गियरबॉक्स और एग्रेसिव राइडिंग पोज़ीशन — यही वह चीज़ है जो इस मॉडल को फ्लीट के स्कूटर्स से बुनियादी तौर पर अलग बनाती है। 2025 में Yamaha Indonesia ने एक बड़ा रीस्टाइलिंग किया ("Gen 3"), इसलिए फ्लीट में एक ही मॉडल नाम के तहत पुराने और नए लुक वाली बाइक्स साथ-साथ मिल सकती हैं। [हमारे कैटलॉग में Yamaha MT-25 देखें](/hi/bikes?group=motorcycle&model=yamaha_mt25)।

**स्पेसिफिकेशन (दोनों जनरेशन के लिए कॉमन — इंजन में कोई बदलाव नहीं हुआ है):**
- इंजन: 249.55cc, लिक्विड-कूल्ड, DOHC, पैरेलल-ट्विन (2 सिलेंडर), 8-वाल्व
- पावर: करीब 35.5 hp, 12,000 rpm पर
- टॉर्क: ~22.6 Nm, 10,000 rpm पर
- गियरबॉक्स: 6-स्पीड मैनुअल
- सीट हाइट: ~780mm
- फ्यूल टैंक: ~14 लीटर

**Gen 2 (करीब 2019 का अपडेट — MT-25 का सबसे पहचाना जाने वाला "क्लासिक" लुक):**
- आगे सिंगल ब्रेक डिस्क
- बिना असिस्ट-स्लिपर क्लच, बिना ABS
- वज़न: ~165-167 kg

**Gen 3 (2025 का रीस्टाइलिंग, Yamaha Indonesia की ऑफिशियल वेबसाइट पर इसे "Hypernaked" बताया गया है):**
- MT-07/R-सीरीज़ जैसी नई एग्रेसिव हेडलाइट — एंगुलर, "एलियन" जैसी लुक, गोल Gen 1 हेडलाइट से बिल्कुल अलग (Gen 2 में पहले ही गोल शेप छूट गई थी, लेकिन Gen 3 की अपनी, और भी शार्प जियोमेट्री है)
- ABS — MT-25 में पहली बार Gen 3 के साथ आया
- असिस्ट-स्लिपर क्लच — तेज़ी से डाउनशिफ्ट करने पर स्मूथ काम करता है
- Y-Connect (Bluetooth ऐप) CCU मॉड्यूल के ज़रिए — इंडोनेशिया में असेंबल होने वाली किसी मोटरसाइकिल में यह पहली बार आई ऐसी टेक्नोलॉजी है
- Big Bike Switch 3-in-1 — Yamaha की बड़ी बाइक्स जैसा कॉम्पैक्ट, ऑल-इन-वन स्विच ब्लॉक
- पूरी तरह डिजिटल इंस्ट्रूमेंट पैनल, साथ में शिफ्ट टाइमिंग लाइट इंडिकेटर
- गैजेट्स चार्ज करने के लिए इलेक्ट्रिकल सॉकेट
- वज़न: ~169 kg — नए फीचर्स की वजह से Gen 2 से थोड़ा ज़्यादा

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** चांगू और सेमिन्याक — शहर के ट्रैफिक में छोटे-छोटे तेज़ एक्सीलरेशन और बीच रोड पर शाम की राइड्स, जहाँ इस बाइक का असली कैरेक्टर सबसे अच्छे से सामने आता है।', 'Yamaha MT-25 — Gen 2 और Gen 3: लुक अलग, इंजन वही', 'बाली में किराए पर Yamaha MT-25: Gen 2 और Gen 3 में फर्क, इंजन स्पेसिफिकेशन और कहाँ इस स्ट्रीटफाइटर का असली कैरेक्टर सामने आता है।'
  FROM articles a WHERE a.slug = 'yamaha-mt25-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Kawasaki Ninja ZX-25R — इनलाइन-4 इंजन वाला इकलौता 250cc प्रोडक्शन स्पोर्टबाइक', 'kawasaki-ninja-zx-25r-review', 'Kawasaki Ninja ZX-25R इनलाइन-4 सिलेंडर इंजन वाला इकलौता 250cc प्रोडक्शन स्पोर्टबाइक है। हाई-रेव कैरेक्टर और फैक्ट्री-फिटेड क्विकशिफ्टर इसकी खासियत हैं।', 'Ninja ZX-25R की 250cc क्लास में एक अनोखी जगह है: यह इस कैपेसिटी का इकलौता प्रोडक्शन स्पोर्टबाइक है जिसमें इनलाइन-4 सिलेंडर इंजन है (बाकी सभी कॉम्पिटिटर्स में सिंगल या ट्विन-सिलेंडर इंजन हैं)। यहीं से आता है इसका खास हाई-रेव साउंड और इंजन को हाई RPM पर रखने की ज़रूरत। [हमारे कैटलॉग में Kawasaki Ninja ZX-25R देखें](/hi/bikes?group=motorcycle&model=kawasaki_zx25r)।

**स्पेसिफिकेशन:**
- इंजन: 249cc, लिक्विड-कूल्ड, DOHC, इनलाइन-4 — इस क्लास के लिए बहुत ही दुर्लभ कॉन्फिगरेशन
- पावर: करीब 45 hp (इंडोनेशियन वर्ज़न, बिना रैम-एयर के), 15,500 rpm पर, रेडलाइन 17,000 rpm तक
- गियरबॉक्स: 6-स्पीड मैनुअल
- सीट हाइट: ~785mm
- वज़न: ~183 kg
- फ्यूल टैंक: ~15 लीटर
- फुल फेयरिंग, स्पोर्टबाइक राइडिंग पोज़ीशन
- फैक्ट्री-फिटेड क्विकशिफ्टर — बिना क्लच दबाए गियर बदलने की सुविधा, डाउनशिफ्ट पर ऑटोमैटिक थ्रॉटल ब्लिप के साथ

**मालिकों का क्या कहना है:** 250cc क्लास में 4-सिलेंडर इंजन इतना असामान्य है कि Kawasaki ने कभी इस इंजन की डायनो-स्टैंड साउंड का अलग वीडियो तक जारी किया था — कमेंटेटर्स ने इतनी छोटी कैपेसिटी के लिए इसकी आवाज़ को "गुस्सैल" और "पागलपन भरी" बताया। कुछ एक्सपीरियंस्ड राइडर्स बताते हैं कि फैक्ट्री क्विकशिफ्टर (ऑटोमैटिक डाउनशिफ्ट ब्लिप के साथ) बहुत बढ़िया काम करता है और बाली की नॉर्मल स्पीड को भी असली मज़ेदार राइडिंग में बदल देता है — गियर बदलने का मज़ा लेने के लिए ट्रैक स्पीड तक पहुंचने की ज़रूरत नहीं। नकारात्मक पक्ष में लोग बताते हैं: 180cm से ज़्यादा हाइट वालों के लिए दिन के आखिर तक राइडिंग पोज़ीशन से पैर थकने लगते हैं, और सस्पेंशन शहर के लिए ट्यून किया गया है, ट्रैक के लिए नहीं। पीक पावर सिर्फ 15,500 rpm पर आती है, इसलिए जो राइडर लो RPM पर चलाने के आदी हैं, उन्हें जब तक RPM ऊपर न उठाएं, बाइक सुस्त लग सकती है।

**किसे लेना चाहिए:** ऐसे कॉन्फिडेंट राइडर्स के लिए जो 250cc क्लास से मैक्सिमम थ्रिल चाहते हैं और हाई RPM पर राइड करने को तैयार हैं — यह लो-RPM पर आराम से चलाने वाली बाइक नहीं है।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** यह किसी खास रूट से ज़्यादा एक्सपीरियंस और कैरेक्टर के लिए बनी बाइक है — MT-25 की तरह ही जगहों पर बढ़िया (शहर, बीच रोड), और पड़ोसी आइलैंड लोम्बोक की वर्ल्ड-क्लास मंदालिका ट्रैक पर भी। हर रेंटल कंपनी ऐसी राइड्स की परमिशन नहीं देती, लेकिन हमारे साथ यह मुमकिन है। यह फ्लीट की सबसे डिमांडिंग बाइक है — पहली मोटरसाइकिल के तौर पर सही नहीं, और पूरे दिन के लिए लंबे कद के राइडर्स के लिए भी आइडियल नहीं।', 'Kawasaki Ninja ZX-25R — इनलाइन-4 इंजन वाला इकलौता 250cc प्रोडक्शन स्पोर्टबाइक', 'बाली में किराए पर Kawasaki Ninja ZX-25R: दुर्लभ इनलाइन-4 सिलेंडर 250cc इंजन, क्विकशिफ्टर और यह स्पोर्टबाइक किसके लिए सही है।'
  FROM articles a WHERE a.slug = 'kawasaki-ninja-zx-25r-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Yamaha XSR155 — रेट्रो कैरेक्टर वाला कैफे-रेसर', 'yamaha-xsr-155-review-retro-style', 'Yamaha XSR155 एक नियो-रेट्रो बाइक है, गोल हेडलाइट, नीचे हैंडलबार और कैफे-रेसर पोज़ीशन के साथ, जिसमें फैमिली का 155cc इंजन मैनुअल गियरबॉक्स के लिए ज़्यादा पावरफुल ट्यून किया गया है।', 'Yamaha XSR155 एक नियो-रेट्रो बाइक है: गोल हेडलाइट, नीचा हैंडलबार, कैफे-रेसर राइडिंग पोज़ीशन। इसमें वही फैमिली 155cc इंजन है जो लाइनअप के स्कूटर्स में है, बस मैनुअल गियरबॉक्स वाले वर्ज़न के लिए ज़्यादा पावरफुल ट्यून किया गया है। [हमारे कैटलॉग में Yamaha XSR155 देखें](/hi/bikes?group=motorcycle&model=yamaha_xsr)।

**स्पेसिफिकेशन:**
- इंजन: 155cc, लिक्विड-कूल्ड, SOHC, VVA — Nmax155 वाला ही बेस, बस मैनुअल गियरबॉक्स के लिए अलग ट्यूनिंग
- पावर: करीब 19.3 hp, 10,000 rpm पर
- गियरबॉक्स: 6-स्पीड मैनुअल
- सीट हाइट: ~815mm — कैफे-रेसर की नीची राइडिंग पोज़ीशन
- वज़न: ~131-134 kg
- फ्यूल टैंक: ~10 लीटर

**मालिकों का क्या कहना है:** XSR155 का चेसिस स्पोर्टबाइक R15 से लिया गया है, इसलिए बाइक हल्की है और हैंडलिंग में बहुत रिस्पॉन्सिव है। सावधानी से थ्रॉटल चलाने पर असली माइलेज ~50 km/l तक पहुंच जाता है। जो लोग दो लोगों के साथ राइड करने की सोच रहे हैं, उनके लिए एक ज़रूरी बात: पिछली सीट कॉम्पैक्ट और सख्त है, कई वर्ज़न में पैसेंजर के लिए ठीक-ठाक हैंडल भी नहीं है। बाली के एक असली रेंटल कस्टमर ने इसी मॉडल के बारे में एक दिलचस्प रिव्यू दिया: सिर्फ 155cc होने के बावजूद, यह बाइक बाली की सड़कों पर "जमकर चलती है", अपनी कीमत के हिसाब से शानदार ट्यून है, और लोकल डामर पर इतनी भरोसेमंद रहती है कि उसके मुताबिक, यह उन्हीं मोड़ों पर Yamaha R3 को भी टक्कर दे सकती है — रेंटल कंपनी ने यह बाइक तीन घंटे की राइड दूर, अमेड तक पहुंचाई थी, और उसने निराश नहीं किया।

**किसे लेना चाहिए:** जो लोग मोटरसाइकिल का स्टाइल और कैरेक्टर चाहते हैं, लेकिन ज़रूरत से ज़्यादा पावर नहीं — स्कूटर से मैनुअल गियरबॉक्स वाली बाइक की तरफ जाने का एक कम्फर्टेबल स्टेप।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** चांगू और सेमिन्याक — बाइक का रेट्रो लुक इन इलाकों के माहौल के साथ बहुत अच्छे से जमता है; लेकिन रिव्यूज़ के हिसाब से, अमेड जैसी लंबी और घुमावदार राइड्स में भी यह आसानी से निभा लेती है।', 'Yamaha XSR155 — रेट्रो कैरेक्टर वाला कैफे-रेसर', 'बाली में किराए पर Yamaha XSR155: स्पेसिफिकेशन, मालिकों के रिव्यू और मैनुअल गियरबॉक्स वाली यह नियो-रेट्रो बाइक किसके लिए सही है।'
  FROM articles a WHERE a.slug = 'yamaha-xsr-155-review-retro-style'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Kawasaki Versys-X 250 — कच्चे रास्तों के लिए तैयार टूरिंग बाइक', 'kawasaki-versys-x250-review', 'Kawasaki Versys-X 250 एक एंड्यूरो-टूरिंग बाइक है, ऊँची सीटिंग, लॉन्ग-ट्रैवल सस्पेंशन और बड़े फ्यूल टैंक के साथ, उन लोगों के लिए जो आइलैंड की साइड रोड्स एक्सप्लोर करना चाहते हैं।', 'Kawasaki Versys-X 250 एक एंड्यूरो-टूरिंग बाइक है: ऊँची सीटिंग पोज़ीशन, लॉन्ग-ट्रैवल सस्पेंशन, बड़ा फ्यूल टैंक। यह उन लोगों के लिए बाइक है जो सिर्फ डामर पर चलना नहीं, बल्कि आइलैंड की साइड रोड्स एक्सप्लोर करना चाहते हैं। [हमारे कैटलॉग में Kawasaki Versys-X 250 देखें](/hi/bikes?group=motorcycle&model=kawasaki_versys)।

**स्पेसिफिकेशन:**
- इंजन: 249cc, लिक्विड-कूल्ड, DOHC, पैरेलल-ट्विन
- पावर: करीब 27 hp, 9700 rpm पर
- गियरबॉक्स: 6-स्पीड मैनुअल
- सीट हाइट: ~845mm — फ्लीट की बाकी बाइक्स से काफी ऊँची
- वज़न: ~184 kg
- फ्यूल टैंक: ~17 लीटर — फ्लीट में सबसे बड़ी टंकियों में से एक, ज़्यादा रेंज
- विंडस्क्रीन, एंड्यूरो स्टैंडिंग बार, खड़े होकर/बैठकर लंबी राइड के लिए पोज़ीशन

**मालिकों का क्या कहना है:** 105 km/h तक की शांत राइडिंग में असली माइलेज करीब 27-30 km/l है (बाली की दूसरी रेंटल कंपनियां भी इसकी पुष्टि करती हैं — करीब 3-4 लीटर प्रति 100 km), जो 17-लीटर टैंक के साथ बिना रीफ्यूल किए एक बहुत अच्छी रेंज देता है। ऑफ-रोडिंग सिर्फ मार्केटिंग नहीं है: एक शुरुआती टेस्ट-ड्राइव में बाइक बिना सस्पेंशन को एक बार भी बॉटम-आउट किए घनी कीचड़ से आराम से निकल गई। स्टॉक सीट शुरुआत में सख्त लगती है और इसे "ब्रेक-इन" होने में समय लगता है। बाइक 80-110 km/h की रेंज में सबसे कम्फर्टेबल फील होती है। बाली के असली रेंटल कस्टमर्स बताते हैं कि यह बाइक बिना किसी दिक्कत के दूर के पहाड़ी गाँव तक भी ले गई, और मैनुअल गियरबॉक्स वाला वर्ज़न बारिश में आइलैंड के नॉर्थ तक की राइड में बहुत बढ़िया साबित हुआ। खुद रेंटल कंपनियां जो रेडीमेड रूट बताती हैं: साउथ बाली — उबुद — किंतामणि, आइलैंड के नॉर्थ की माउंटेन रोड्स, ईस्ट कोस्ट (अमेड और तुलामबेन तक)।

**किसे लेना चाहिए:** आइलैंड में मल्टी-डे रूट्स के लिए और उन लोगों के लिए जो कच्ची या टूटी-फूटी सड़कों पर भी कॉन्फिडेंट रहना चाहते हैं। डिटेल्ड रूट्स — ब्लॉग आर्टिकल्स में: «ईस्ट बाली बाइक पर», «किंतामणि: बातूर ज्वालामुखी पर सूर्योदय», «बेडुगुल — मुंडुक — लोविना»।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** लंबे रूट्स — किंतामणि, आइलैंड का नॉर्थ और ईस्ट (अमेड और तुलामबेन समेत), मेन टूरिस्ट रास्तों से हटकर साइड रोड्स।', 'Kawasaki Versys-X 250 — कच्चे रास्तों के लिए तैयार टूरिंग बाइक', 'बाली में किराए पर Kawasaki Versys-X 250: स्पेसिफिकेशन, रेंज, मालिकों के रिव्यू और एंड्यूरो-टूरिंग के लिए बेहतरीन रूट्स।'
  FROM articles a WHERE a.slug = 'kawasaki-versys-x250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Suzuki V-Strom 250 — कम्फर्ट और विंड प्रोटेक्शन पर फोकस्ड टूरिंग बाइक', 'suzuki-v-strom-250-review', 'Suzuki V-Strom 250 एक एडवेंचर-टूरिंग बाइक है, जिसका फोकस लंबी राइड्स में कम्फर्ट पर है: चौड़ी विंडस्क्रीन, अपराइट राइडिंग पोज़ीशन, सॉफ्ट सस्पेंशन।', 'Suzuki V-Strom 250 एक एडवेंचर-टूरिंग बाइक है, जिसका पूरा फोकस लंबी राइड्स में कम्फर्ट पर है: चौड़ी विंडस्क्रीन, बिल्कुल सीधी अपराइट राइडिंग पोज़ीशन, और बिना थकान के लंबी दूरी तय करने के लिए सॉफ्ट सस्पेंशन। [हमारे कैटलॉग में Suzuki V-Strom 250 देखें](/hi/bikes?group=motorcycle&model=suzuki_vstrom250)।

**स्पेसिफिकेशन:**
- इंजन: 248cc, लिक्विड-कूल्ड, DOHC, पैरेलल-ट्विन
- पावर: करीब 25 hp, 8000 rpm पर
- गियरबॉक्स: 6-स्पीड मैनुअल
- सीट हाइट: वर्ज़न के हिसाब से ~800-835mm
- फ्यूल टैंक: 12 लीटर

**मालिकों का क्या कहना है:** रिव्यूज़ में इंजन की तुलना सिलाई मशीन से की जाती है — स्मूथ, शांत, फ्यूल-इफिशिएंट और भरोसेमंद। लगभग हर रिव्यू में प्लस पॉइंट है अच्छी तरह पैडेड सीट और "बड़ी मोटरसाइकिल जैसी" राइडिंग पोज़ीशन, वो भी हैंडलिंग में कहीं ज़्यादा आसान बाइक के साथ। असली राइडिंग में फ्यूल माइलेज 32 से 48 km/l के बीच रहता है। बाली में इस्तेमाल की सबसे दमदार मिसालों में से एक — एक रेंटल कस्टमर ने V-Strom 40+ दिनों के लिए लिया और उस पर फ्लोरेस आइलैंड तक गया और वापस आया। बाली के एक और रेंटल कस्टमर का प्रैक्टिकल सबक: स्टॉक बैक रैक बैग बांधने के लिए रास्ते में भरोसेमंद साबित नहीं हुआ — कंपनी ने उन्हें साइड में पूरे कोफर वाली Versys पर शिफ्ट कर दिया; सीख यह है कि अगर सामान ज़्यादा लेकर जाना है, तो रैक पर रस्सियों की जगह कोफर ज़्यादा सुविधाजनक हैं। रेंटल कस्टमर्स खासतौर पर सिडेमेन, बातूर पर्वत और बाली के सबसे पूर्वी छोर के आसपास की सड़कों की सिफारिश करते हैं, और बताते हैं कि ट्रैफिक सिर्फ उलुवातु, चांगू और उबुद में ही असली मायने में महसूस होता है — उसके बाद राइस टैरेस, जंगल और ओशन व्यूज़ शुरू हो जाते हैं।

**किसे लेना चाहिए:** जो लोग सबसे पहले लंबी राइड्स में कम्फर्ट ढूंढ रहे हैं, स्पोर्टी कैरेक्टर नहीं। डिटेल्ड रूट्स — ब्लॉग आर्टिकल्स में: «ईस्ट बाली बाइक पर», «सेकुम्पुल और सेंट्रल नॉर्थ बाली के वॉटरफॉल्स», «बाली के ज्वालामुखी बाइक पर»।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** Versys-X250 वाला ही सेगमेंट — लंबे रूट, सिडेमेन, बातूर पर्वत, ईस्ट कोस्ट। अगर ज़्यादा सामान ले जाना है — बस हमें बता दें, हम बाइक पर साइड कोफर लगा देंगे।', 'Suzuki V-Strom 250 — कम्फर्ट और विंड प्रोटेक्शन पर फोकस्ड टूरिंग बाइक', 'बाली में किराए पर Suzuki V-Strom 250: स्पेसिफिकेशन, असली फ्यूल माइलेज और लंबी आइलैंड ट्रिप्स पर रेंटल कस्टमर्स के रिव्यू।'
  FROM articles a WHERE a.slug = 'suzuki-v-strom-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'TVS Ronin 225 — स्क्रैम्बलर टच के साथ नियो-रेट्रो', 'tvs-ronin-225-review', 'TVS Ronin 225 एक मॉडर्न-क्लासिक बाइक है जिसमें स्क्रैम्बलर वाइब भी है: गोल LED हेडलाइट, ऊँचा हैंडलबार, और शहर से लेकर कच्चे रास्तों तक बराबर कॉन्फिडेंस।', 'TVS Ronin 225 एक मॉडर्न-क्लासिक बाइक है जिसमें स्क्रैम्बलर वाइब भी है: गोल LED हेडलाइट, ऊँचा हैंडलबार, ऐसी जियोमेट्री जो शहर में और मेन रोड से हटकर कच्चे रास्तों पर, दोनों जगह बराबर कॉन्फिडेंस के साथ चलती है। सभी वर्ज़न ABS के साथ आते हैं। [हमारे कैटलॉग में TVS Ronin 225 देखें](/hi/bikes?group=motorcycle&model=tvs_ronin225)।

**स्पेसिफिकेशन:**
- इंजन: 225.9cc, ऑयल-कूल्ड, सिंगल-सिलेंडर, SOHC, 4-वाल्व
- पावर: करीब 20.4 hp, 7750 rpm पर
- टॉर्क: ~19.9 Nm, 3750 rpm पर — कम RPM से ही अच्छी पुल मिलती है, ज़्यादा रेव करने की ज़रूरत नहीं
- गियरबॉक्स: 5-स्पीड मैनुअल
- सीट हाइट: ~795mm
- वज़न: ~159 kg
- फ्यूल टैंक: ~14 लीटर
- सभी वर्ज़न में ABS (बेस वर्ज़न में सिंगल-चैनल, हायर वर्ज़न में डुअल-चैनल)

**रिलायबिलिटी:** TVS भारत की एक बहुत पुरानी ब्रांड है (1980 के दशक से दोपहिया वाहन बना रही है), और Ronin खुद, भले ही अपेक्षाकृत नया मॉडल हो (2022 से), बीते सालों की राइडिंग में पहले ही रिलायबिलिटी के मामले में मज़बूत रेप्युटेशन बना चुका है: 10,000 km से ज़्यादा चलाने वाले मालिकों के रिव्यूज़ में इंजन को शुरू जैसा ही स्मूथ बताया जाता है, गोल्डन USD फोर्क्स लंबे समय तक टिकाऊ बने रहते हैं, और अलग-अलग सतहों पर एक साल की एक्टिव राइडिंग के बाद भी बिल्ड क्वालिटी में कोई खड़खड़ाहट या ढीलापन नहीं आता। इंडिपेंडेंट ओनर रेटिंग्स में Ronin की रिलायबिलिटी और मेंटेनेंस कॉस्ट लगातार क्लास में सबसे बेहतर मानी जाती है।

**मालिकों का क्या कहना है:** इंजन रेट्रो बाइक्स वाली खास गहरी, थोड़ी खरखराई हुई आवाज़ के साथ स्टार्ट होता है। मज़बूत लो-एंड टॉर्क बाइक को घने शहरी ट्रैफिक में खासतौर पर कम्फर्टेबल बनाता है। रिव्यूज़ में असली माइलेज 35-45 km/l के आसपास है। सस्पेंशन सॉफ्ट ट्यून किया गया है — शहर के गड्ढों को अच्छे से सोख लेता है। कुछ वर्ज़न में राइडिंग मोड्स भी हैं, जिनमें बारिश के लिए एक स्पेशल मोड भी शामिल है — बाली के मौसम को देखते हुए काफी काम का। रिव्यूज़ में इसकी शानदार डायनामिक्स और लुक की भी बार-बार तारीफ की जाती है, जिसे मॉडल की सबसे बड़ी ताकतों में गिना जाता है।

**किसे लेना चाहिए:** जो लोग रोज़ाना इस्तेमाल के लिए एक ऑल-राउंडर मोटरसाइकिल चाहते हैं — बिना स्पोर्टबाइक की तेज़ी के, लेकिन कच्चे रास्तों पर भी पूरे कॉन्फिडेंस के साथ।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** नियो-रेट्रो लुक की वजह से चांगू/सेमिन्याक में जितना बढ़िया है, राइस टैरेस की तरफ जाने वाले साइड के कच्चे रास्तों पर भी उतना ही बढ़िया।', 'TVS Ronin 225 — स्क्रैम्बलर टच के साथ नियो-रेट्रो', 'बाली में किराए पर TVS Ronin 225: स्पेसिफिकेशन, रिलायबिलिटी और स्क्रैम्बलर कैरेक्टर वाली इस नियो-रेट्रो बाइक पर मालिकों के रिव्यू।'
  FROM articles a WHERE a.slug = 'tvs-ronin-225-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Keeway Road Falcon 250 — एंट्री-लेवल कीमत में क्लासिक क्रूज़र', 'keeway-road-falcon-250-review', 'Keeway Road Falcon 250 एक क्लासिक क्रूज़र है, लंबे सिल्हूट और नीची सीटिंग के साथ, एंट्री-लेवल कीमत में। मार्केट में बिल्कुल नई मॉडल — 2026 में लॉन्च हुई।', 'Keeway Road Falcon 250 का लंबा सिल्हूट, नीची सीटिंग पोज़ीशन, सोबर ब्लैक कलर और कैरेक्टर बड़े अमेरिकन क्रूज़र्स से इंस्पायर्ड है, लेकिन यह सब एक कॉम्पैक्ट 250cc बेस पर है। मॉडल मार्केट में बिल्कुल नई है — 2026 में लॉन्च हुई, इसलिए फिलहाल यूज़र और बाली रेंटल रिव्यू लगभग न के बराबर हैं। [हमारे कैटलॉग में Keeway Road Falcon 250 देखें](/hi/bikes?group=motorcycle&model=keeway_roadfalcon250)।

**स्पेसिफिकेशन:**
- इंजन: 248cc, पैरेलल-ट्विन, 4-स्ट्रोक, 4-वाल्व, SOHC, लिक्विड-कूल्ड
- पावर: करीब 24.6 hp, 8000 rpm पर
- टॉर्क: ~23.4 Nm, 6500 rpm पर
- गियरबॉक्स: 6-स्पीड मैनुअल, स्लिपर क्लच के साथ
- सीट हाइट: ~698mm — फ्लीट की सबसे नीची सीटिंग पोज़ीशन में से एक
- ग्राउंड क्लियरेंस: ~186mm
- फ्यूल टैंक: 14 लीटर
- ब्रेक्स: आगे 300mm डिस्क (2-पिस्टन कैलिपर), पीछे 260mm
- 5-इंच TFT डिस्प्ले, बिल्ट-इन Bluetooth स्पीकर — इस क्लास के लिए काफी दुर्लभ फीचर
- इंस्ट्रूमेंट पैनल पर सीधे नेविगेशन — XMAX250 की तरह, इस मॉडल के लिए भी फोन होल्डर की कोई ज़रूरत नहीं

**मालिकों का क्या कहना है:** इस मॉडल की सीधे तुलना Harley-Davidson स्टाइल की बाइक्स और Honda Rebel से की जाती है — सामने का खास "टैंक-हंप" लुक और पूरा सिल्हूट जानबूझकर बड़े अमेरिकन क्रूज़र्स की याद दिलाता है, और इंडोनेशियन प्रेस में Road Falcon की सीधे Honda Rebel के साथ तुलना करने वाले रिव्यू मिल जाते हैं। हैंडलबार में बिल्ट-इन Bluetooth स्पीकर इस क्लास के क्रूज़र्स में एक दुर्लभ फीचर है। स्लिपर क्लच डाउनशिफ्ट को स्मूथ बनाता है — बाली के पहाड़ी हिस्सों में काफी काम आता है। अलग से यह भी बताया जाता है कि यह बाइक काफी manoeuvrable है और इसका टर्निंग रेडियस उम्मीद से काफी कम है — इतने लंबे क्रूज़र सिल्हूट को देखते हुए यह जल्दी समझ नहीं आता, लेकिन इस्तेमाल में साफ महसूस होता है।

**किसे लेना चाहिए:** जो लोग क्लासिक क्रूज़र लुक और रिलैक्स्ड राइडिंग पोज़ीशन चाहते हैं — बहुत नीची सीट की वजह से कम हाइट वाले राइडर्स के लिए खासतौर पर सुविधाजनक।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** धीमी रफ्तार के कोस्टल रूट्स — सानूर, नुसा दुआ — लेकिन सिर्फ यहीं तक नहीं: हमारे कस्टमर्स इसे उन जगहों तक भी ले गए हैं जो आमतौर पर Versys और V-Strom जैसी क्लासिक टूर-एंड्यूरो बाइक्स के लिए मानी जाती हैं, यानी क्रूज़र लुक के बावजूद, बाली के पूरे नॉर्थ कोस्ट के लंबे रूट भी यह बाइक बखूबी निभा लेती है।', 'Keeway Road Falcon 250 — एंट्री-लेवल कीमत में क्लासिक क्रूज़र', 'बाली में किराए पर Keeway Road Falcon 250: स्पेसिफिकेशन, Honda Rebel से तुलना और यह क्रूज़र किसके लिए सही है।'
  FROM articles a WHERE a.slug = 'keeway-road-falcon-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Morbidelli C252V — इटैलियन नाम वाला V-twin क्रूज़र', 'morbidelli-c252v-review', 'Morbidelli C252V फ्लीट का दूसरा क्रूज़र है, लेकिन इसमें पैरेलल-ट्विन की जगह असली V-ट्विन इंजन और बेल्ट ड्राइव दिया गया है।', 'फ्लीट का दूसरा क्रूज़र, लेकिन Road Falcon से कैरेक्टर के मामले में बिल्कुल अलग: Morbidelli में पैरेलल-ट्विन की जगह असली V-शेप ट्विन-सिलेंडर इंजन है, इसी वजह से इसकी आवाज़ ज़्यादा "बेसी" है और वाइब्रेशन भी अलग, जिसे कई क्रूज़र राइडर्स मज़े का ही हिस्सा मानते हैं। Morbidelli ब्रांड एक इटैलियन नाम है जिसकी असली रेसिंग हिस्ट्री रही है (1970 के दशक में 125cc और 250cc ग्रां प्री क्लास में चैंपियनशिप टाइटल्स), जिसके अधिकार 2024 से उसी ग्रुप के पास हैं जो Keeway का मालिक है — यानी यह सिर्फ नाम की समानता नहीं, बल्कि एक नई टेक्निकल बेस पर ऑफिशियली रिवाइव की गई ब्रांड है। [हमारे कैटलॉग में Morbidelli C252V देखें](/hi/bikes?group=motorcycle&model=morbidelli_c252v)।

**स्पेसिफिकेशन:**
- इंजन: 249cc, V-ट्विन, 4-स्ट्रोक, 8-वाल्व, SOHC, लिक्विड-कूल्ड
- पावर: करीब 25.5 hp, 9000 rpm पर
- टॉर्क: 25 Nm, 5500 rpm पर
- गियरबॉक्स: 6-स्पीड मैनुअल, स्लिपर क्लच के साथ
- ड्राइव: बेल्ट ड्राइव — इस क्लास के लिए दुर्लभ फीचर। प्रैक्टिकल मायने में इसका मतलब है: चेन की तरह न तो इसे बार-बार लुब्रिकेट करना पड़ता है, न कसना पड़ता है, और बारिश में यह जंग भी नहीं पकड़ती
- सीट हाइट: 690mm — फ्लीट में सबसे नीची में से एक
- वज़न: ~200 kg
- फ्यूल टैंक: 15.5 लीटर
- ग्राउंड क्लियरेंस: 173mm
- ब्रेक्स: आगे 320mm डिस्क (4-पिस्टन कैलिपर), पीछे 260mm (2-पिस्टन); स्टैंडर्ड में डुअल-चैनल Bosch ABS और ट्रैक्शन कंट्रोल
- आगे इनवर्टेड (USD) फोर्क 37mm, 115mm ट्रैवल; पीछे दो शॉक एब्ज़ॉर्बर, 5-स्टेप प्रीलोड एडजस्टमेंट के साथ
- टॉप स्पीड — क्लेम्ड 125 km/h

**मालिकों का क्या कहना है:** मॉडल मार्केट में बहुत नई है, इसलिए अभी सालों की राइडिंग हिस्ट्री नहीं बनी है, लेकिन प्रेस में हुए शुरुआती टेस्ट-राइड्स में इतने लंबे व्हीलबेस वाले क्रूज़र के लिए हैंडलिंग को अनएक्सपेक्टेड रूप से हल्का बताया गया है — टर्निंग रेडियस बाइक के साइज़ का अंदाज़ा नहीं लगने देता। V-शेप इंजन को विज़ुअली इम्प्रेसिव बताया जाता है (टैंक के नीचे साफ नज़र आता है, कूलिंग फिन्स के लुक और क्रोम फिनिश के साथ) और आवाज़ आम 250cc पैरेलल-ट्विन इंजन्स से काफी गहरी बताई जाती है।

**किसे लेना चाहिए:** जो लोग खासतौर पर V-twin वाला क्रूज़र कैरेक्टर चाहते हैं (Road Falcon की तरह पैरेलल-ट्विन नहीं) — ज़्यादा साफ वाइब्रेशन और बेसी इंजन साउंड, साथ ही चेन की जगह बेल्ट — जिसे न लुब्रिकेट करना पड़ता है, न कसना, और बारिश में जंग भी नहीं लगती।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** Road Falcon वाला ही सेगमेंट — धीमी रफ्तार के कोस्टल रूट्स, सानूर, नुसा दुआ; बेल्ट ड्राइव और नीची सीटिंग इसे खासतौर पर उन लोगों के लिए सुविधाजनक बनाती है जो बिना चेन की चिंता किए रिलैक्स्ड क्रूज़र स्टाइल चाहते हैं।', 'Morbidelli C252V — इटैलियन नाम वाला V-twin क्रूज़र', 'बाली में किराए पर Morbidelli C252V: V-twin इंजन, बेल्ट ड्राइव, स्पेसिफिकेशन और यह क्रूज़र Road Falcon से कैसे अलग है।'
  FROM articles a WHERE a.slug = 'morbidelli-c252v-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Honda CBR250RR — फुल फेयरिंग और फ्लीट की सबसे «ट्रैक-रेडी» फेयर्ड स्पोर्टबाइक', 'honda-cbr250rr-review', 'Honda CBR250RR फ्लीट की इकलौती पूरी तरह फेयर्ड स्पोर्टबाइक है, क्विकशिफ्टर और ABS वाले टॉप वर्ज़न में। इंडोनेशिया के 250cc क्लास के टेक्नोलॉजिकल लीडर्स में से एक।', 'फ्लीट का इकलौता पूरी तरह फेयर्ड स्पोर्टबाइक (MT-25 और ZX-25R के उलट, जो "नेकेड" स्ट्रीटफाइटर हैं) — Honda CBR250RR को 2016 में डेब्यू के दिन से ही इंडोनेशिया के 250cc क्लास के टेक्नोलॉजिकल लीडर्स में गिना जाता है। [हमारे कैटलॉग में Honda CBR250RR देखें](/hi/bikes?group=motorcycle&model=honda_cbr250rr)।

**स्पेसिफिकेशन (टॉप वर्ज़न SP Quick Shifter, ABS के साथ — फ्लीट में यही वर्ज़न है):**
- इंजन: 249.7cc, लिक्विड-कूल्ड, DOHC, पैरेलल-ट्विन, 8-वाल्व, टॉप वर्ज़न के अपग्रेड्स के साथ (लाइटर क्रैंकशाफ्ट, नए वाल्व स्प्रिंग्स, बदला हुआ हेड)
- पावर: ~41 hp, 13,000 rpm पर
- टॉर्क: ~25 Nm, 11,000 rpm पर
- गियरबॉक्स: 6-स्पीड मैनुअल
- सीट हाइट: ~790mm
- वज़न: ~168 kg
- ABS, फुल LED लाइटिंग, डिजिटल इंस्ट्रूमेंट पैनल, थ्रॉटल-बाय-वायर (बिना केबल का इलेक्ट्रॉनिक थ्रॉटल)
- क्विकशिफ्टर, 4 कस्टमाइज़ेबल मोड्स के साथ (अप+डाउन, सिर्फ अप, सिर्फ डाउन, ऑफ) — बिना क्लच दबाए गियर बदलने की सुविधा
- असिस्ट-स्लिपर क्लच
- आगे इनवर्टेड (USD) फोर्क, SFF-Big Piston टाइप
- 3 राइडिंग मोड: Comfort, Sport, Sport+
- क्लेम्ड 0-200m एक्सीलरेशन 8.65 सेकंड में, टॉप स्पीड 172 km/h तक

**मालिकों का क्या कहना है:** CBR250RR को लगातार इंडोनेशिया के 250cc क्लास की सबसे टेक-लोडेड बाइक्स में गिना जाता है — क्विकशिफ्टर वाला वर्ज़न इतनी छोटी इंजन कैपेसिटी के लिए दुर्लभ, बिल्कुल ट्रैक जैसा फील देता है।

**किसे लेना चाहिए:** जो लोग पूरा स्पोर्टबाइक एक्सपीरियंस चाहते हैं — फुल फेयरिंग, टैंक पर लेटी हुई स्पोर्टी राइडिंग पोज़ीशन, और MotoGP जैसे क्विकशिफ्टर की टेक्नोलॉजी।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** ZX-25R की तरह ही — शहर, बीच रोड, यह किसी खास रूट के लिए नहीं, बल्कि एक्सपीरियंस और कैरेक्टर के लिए बनी बाइक है; ट्रैक-रेडी जीन्स को देखते हुए यह लोम्बोक की मंदालिका ट्रैक पर भी शानदार साबित होती है।', 'Honda CBR250RR — फुल फेयरिंग और फ्लीट की सबसे «ट्रैक-रेडी» फेयर्ड स्पोर्टबाइक', 'बाली में किराए पर Honda CBR250RR: क्विकशिफ्टर वाला टॉप वर्ज़न, स्पेसिफिकेशन और पूरा स्पोर्टबाइक एक्सपीरियंस किसके लिए सही है।'
  FROM articles a WHERE a.slug = 'honda-cbr250rr-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'Honda CB150X — 150cc इंजन पर बना बजट-फ्रेंडली एडवेंचर लुक', 'honda-cb150x-review', 'Honda CB150X 150cc इंजन पर एक अफोर्डेबल एडवेंचर-स्टाइल एंट्री है, इस क्लास के लिए सीरियस हार्डवेयर और फ्लीट की मोटरसाइकिल्स में सबसे हल्के वज़न के साथ।', 'CB150X, 250cc वाली Versys-X250 और V-Strom250 जैसी बाइक नहीं है: यह एक बजट-फ्रेंडली एडवेंचर स्टाइलिंग है, छोटे 150cc सिंगल-सिलेंडर इंजन पर, लेकिन इस क्लास के लिए वाकई सीरियस हार्डवेयर के साथ (ग्राउंड क्लियरेंस लगभग CB500X जितना)। मोटरसाइकिल के हिसाब से बहुत हल्के वज़न (139 kg) की वजह से यहां 150cc इंजन ज़्यादा से ज़्यादा काफी है — बाइक आसानी से फ्रंट व्हील उठा लेती है और पूरी स्पीड रेंज में भरोसेमंद डायनामिक्स बनाए रखती है, सिर्फ लो-स्पीड पर नहीं जैसा सिंगल-सिलेंडर और छोटी कैपेसिटी देखकर सोचा जा सकता है। [हमारे कैटलॉग में Honda CB150X देखें](/hi/bikes?group=motorcycle&model=honda_cb150x)।

**स्पेसिफिकेशन:**
- इंजन: 149.16cc, सिंगल-सिलेंडर, लिक्विड-कूल्ड, DOHC 4-वाल्व
- पावर: ~15.6 hp, 9000 rpm पर
- टॉर्क: ~13.8 Nm, 7000 rpm पर
- गियरबॉक्स: 6-स्पीड मैनुअल
- सीट हाइट: 817mm
- ग्राउंड क्लियरेंस: 181mm — कहीं बड़ी CB500X के लगभग बराबर
- वज़न: ~139 kg — फ्लीट की सबसे हल्की मोटरसाइकिल (स्कूटर को छोड़कर)
- फ्यूल टैंक: 12 लीटर
- आगे इनवर्टेड (USD) Showa SFF-BP फोर्क 37mm, पीछे Pro-Link मोनोशॉक
- आगे-पीछे वेवी (wavy) ब्रेक डिस्क
- पूरी तरह डिजिटल इंस्ट्रूमेंट पैनल, रियल-टाइम फ्यूल कंजम्प्शन डिस्प्ले के साथ

**किसे लेना चाहिए:** जो लोग एडवेंचर स्टाइलिंग और ऊँची सीटिंग पोज़ीशन चाहते हैं, लेकिन पूरी तरह 250cc टूरर के वज़न और पावर के लिए तैयार नहीं — सिटी बाइक्स से ज़्यादा सीरियस मॉडल्स की तरफ जाने का एक अच्छा स्टेप।

**बाली में यह कहाँ सबसे अच्छा साथ निभाता है:** ADV160 वाली ही लॉजिक — साइड रोड्स, इंपरफेक्ट डामर, लेकिन सीटिंग और कैरेक्टर के मामले में यह पहले से ही एक पूरी मैनुअल गियरबॉक्स वाली मोटरसाइकिल है, स्कूटर नहीं।', 'Honda CB150X — 150cc इंजन पर बना बजट-फ्रेंडली एडवेंचर लुक', 'बाली में किराए पर Honda CB150X: स्पेसिफिकेशन, ग्राउंड क्लियरेंस और यह बजट एडवेंचर बाइक किसके लिए सही है।'
  FROM articles a WHERE a.slug = 'honda-cb150x-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'hi', 'PCX160 vs ADV160 vs Nmax — तीनों में से कैसे चुनें', 'pcx160-vs-adv160-vs-nmax-how-to-choose', 'PCX160, ADV160 और Nmax — फ्लीट के तीन सबसे पॉपुलर स्कूटर्स में से कैसे चुनें: स्टोरेज, डायनामिक्स और सीटिंग पोज़ीशन में क्या फर्क है।', 'ईमानदारी से कहें तो, ये तीनों मॉडल सबसे ज़्यादा लुक और राइडर की आदत के हिसाब से अलग हैं — शॉर्ट में कहें तो यह पसंद की बात है। सच में मायने रखने वाले प्रैक्टिकल फर्क में सबसे पहले आता है स्टोरेज साइज़: Nmax उन लोगों के लिए सही है जो इसकी सीटिंग पोज़ीशन और डायनामिक्स से प्यार करने के लिए थोड़ा स्टोरेज कैपेसिटी कुर्बान करने को तैयार हैं। और खालिस डायनामिक्स के मामले में टीम में मज़ाक में कहा जाता है: जिन्हें सच में "Turbo" जैसा रिस्पॉन्स चाहिए, उन्हें इस लाइनअप से ADV लेना चाहिए — यह नाम में "Turbo" वाले मॉडल से भी सब्जेक्टिवली ज़्यादा फुर्तीला महसूस होता है।

आदर्श रूप में, अगर लंबे समय के लिए बाइक चुननी है, तो हर मॉडल को 5 दिन से लेकर एक महीने तक चलाकर देखें, ताकि फर्क सच में महसूस हो सके। असली मायने में बाइक समझने के लिए अक्सर 1-3 दिन काफी नहीं होते।

मॉडल कैटलॉग: [Honda PCX160](/hi/bikes?category=honda_pcx160), [Honda ADV160](/hi/bikes?category=honda_adv160), [Yamaha Nmax](/hi/bikes?category=yamaha_nmax155)।', 'PCX160 vs ADV160 vs Nmax — तीनों में से कैसे चुनें', 'बाली में किराए पर Honda PCX160, Honda ADV160 और Yamaha Nmax की तुलना — अपनी ज़रूरत के हिसाब से कौन-सा स्कूटर चुनें।'
  FROM articles a WHERE a.slug = 'pcx160-vs-adv160-vs-nmax-how-to-choose'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Honda PCX160——舒适与大容量储物兼得的日常之选', 'honda-pcx160-review', 'Honda PCX160 是追求舒适又不想牺牲储物空间的租客最万能的选择,情侣出行、或是带着行李箱旅行的客人最常选这款车型。', 'Honda PCX160 是追求舒适骑行体验、又不愿在储物空间上妥协的租客最万能的选择。情侣出行、或是拖着行李箱、大背包旅行的客人最常选这款车型。[在我们的车型库中查看 Honda PCX160](/zh-Hans/bikes?category=honda_pcx160)。

**车辆参数:**
- 发动机:156.9cc,水冷,eSP+
- 功率:约15.8马力(8500转/分)
- 变速箱:CVT无级变速,无需换挡
- 座高:约764毫米——几乎适合任何身高的骑手
- 油箱容量:8.1升
- 座下储物空间:约30升——放得下一顶全盔,还能再塞一些随身物品
- 智能钥匙、全LED灯组、大功率USB充电口、数字仪表盘
- 我们这里还提供多种区别于官方标配色的定制车身颜色可选

**选装配件:** PCX160 可以加装 SHAD 44升后尾箱——如果座下储物空间不够用,这是很实用的补充。更多关于选装配件的介绍,请看我们的文章[《租车实用选装:头盔与舒适尾箱》](/zh-Hans/blog/rental-extras-worth-adding-helmets-and-the-comfort-box)。

**车主怎么说:** 车主反馈中的真实油耗大约在每升40-50公里,几乎让环岛骑行的油费可以忽略不计。这款车的可靠性口碑近乎传奇——论坛里车主常把 PCX 比作割草机:发动、上路,常年不出幺蛾子。对租客来说还有一个实用细节:智能钥匙用起来很方便,但一旦丢失,补办大约要花100万印尼盾,所以钥匙最好别弄丢——关于它的具体使用方法,可以看我们的文章[《如何启动车辆及使用钥匙扣》](/zh-Hans/blog/how-to-start-and-use-your-rental-scooters-smart-key)。载人时高速超车的加速储备会明显下降——市区骑行没问题,但上大路时要多留意。

**在巴厘岛哪里表现最好:** 14英寸前轮让它在柏油路面上很稳,在芝安古、水明漾、沙努尔都骑得很舒服,日常往返登巴萨代步也完全胜任。', 'Honda PCX160——舒适与大容量储物兼得的日常之选', '巴厘岛Honda PCX160租赁详解:参数配置、真实油耗、车主评价及选装配件,看看它适合去哪里、适合什么样的租客。'
  FROM articles a WHERE a.slug = 'honda-pcx160-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Honda ADV160——征服颠簸路面,适合长途出行', 'honda-adv-review', 'Honda ADV160 搭载与 PCX160 相同的可靠发动机,但车身完全不同:坐姿更高,离地间隙更大,在坑洼路面和土路上骑起来更有信心。', 'Honda ADV160 搭载和 PCX160 一样可靠的发动机,只是换了完全不同的车身:坐姿更高、离地间隙更大,在坑洼路面和土路路段骑起来更加从容。[在我们的车型库中查看 Honda ADV160](/zh-Hans/bikes?category=honda_adv160)。

**车辆参数:**
- 发动机:156.9cc,水冷,eSP+(与PCX160同款)
- 功率:约15.8马力
- 变速箱:CVT无级变速
- 座高:约795毫米——比城市通勤款车型更高,更适合身材高一些、喜欢更高坐姿的骑手
- 离地间隙约165毫米——明显高于标准水平
- 座下储物空间:约30升——放得下一顶全盔,还能再塞一些随身物品
- 可调节风挡——两档位置:上扬(运动)和下压(城市)
- 半液晶仪表盘、大功率USB充电口、智能钥匙
- 我们这里还提供多种区别于官方标配色的定制车身颜色可选

**选装配件:** 和 PCX160 一样,ADV160 也可以加装 SHAD 44升后尾箱。详情请看我们的文章[《租车实用选装:头盔与舒适尾箱》](/zh-Hans/blog/rental-extras-worth-adding-helmets-and-the-comfort-box)。

**车主怎么说:** 省油是这台发动机的第二大优势:车主反馈中的真实油耗大约在每升34-38公里——即使骑得比较猛,加油也不用太频繁。而且尽管发动机和PCX160完全相同(只是调校不同),ADV160却是PCX-Nmax-ADV这条产品线里动力表现最灵活的一款。离地间隙在土路和坑洼路段确实派上用场,但车主也坦言:这终究是城市探险风格,不是真正的越野车——遇上大石块和严重颠簸路段,离地间隙还是不够用。

**在巴厘岛哪里表现最好:** 乌布及周边(梯田、乡间小路)、文都及瀑布区、乌鲁瓦图和布吉半岛的丘陵路段——这些地方的地形和路面质量各不相同,ADV160 比城市通勤款更能包容路况,但真正严重的越野路段并非它的强项。', 'Honda ADV160——征服颠簸路面,适合长途出行', '巴厘岛Honda ADV160租赁攻略:参数配置、真实油耗与车主评价,看看这款城市探险风车型在哪里最能发挥实力。'
  FROM articles a WHERE a.slug = 'honda-adv-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Yamaha Nmax——New(第二代)、Neo(第三代)与Turbo版全解析', 'yamaha-nmax-review', '车队里的 Nmax 并不是单一车型,而是同一个名字下的好几代产品和配置:New、Neo 和 Turbo。我们来分析它们到底有什么区别。', '车队里的"Nmax"并不是单一车型,而是同一个名字下的好几代产品和配置。New 和 Neo 在发动机和变速系统上其实是同一套技术,只是车系的不同世代(第二代和第三代)。而 Turbo 版则是另一回事,采用了不同的电子变速调校。[在我们的车型库中查看 Yamaha Nmax](/zh-Hans/bikes?category=yamaha_nmax155)。

**Nmax New(第二代):**
- 发动机:155cc,Blue Core,VVA可变气门,SOHC 4气门
- 功率:约15马力(8000转/分)
- 变速箱:经典滚轮式CVT无级变速
- 车重:约132公斤
- 油箱容量:7.1升

**Nmax Neo(第三代):**
- 发动机排量和结构与 New 完全相同,同样是155cc Blue Core VVA——区别只在外观、车系世代和配置等级,并非内在机械不同
- 功率:约15马力(8000转/分)
- 变速箱:经典CVT无级变速
- 车重:约130公斤
- 两个版本:Neo(标准版)和 Neo S(+智能钥匙系统)

**Nmax"Turbo":**
- 发动机排量与 New/Neo 相同
- 最大的区别是 YECVT(Yamaha电子无级变速):本质上还是同一套无级变速结构,只是改用电子控制取代纯机械滚轮。这更多是关于操控感受的营销卖点和电子骑行设定,而不是完全不同的传动系统
- 两种骑行模式 T-Mode/S-Mode,再加上虚拟"档位"Y-Shift(低/中/高)——模拟汽车换挡的感觉
- 车重:约133-135公斤,视版本而定
- 三个版本:Turbo(标准版)、Turbo Tech Max(TFT彩色仪表、USB-C接口、专属座椅)、Turbo Tech Max Ultimate(顶配版)
- 需要说明的是:车名里的"Turbo"指的是电子系统和骑行反馈,并不是发动机真的加装了涡轮增压
- 我们这里还提供多种区别于官方标配色的定制车身颜色可选

**车主怎么说:** 不管是哪一代,发动机在车主口中都被称为"打不坏"——可靠性是整个系列公认的强项。省油同样是它的优势之一:和同系列的 PCX160、ADV160 一样经济的155cc发动机,在实际骑行中油耗表现很稳定,不用频繁加油。储物空间有个有意思的细节:官方标注的容积看着不小,但储物槽的形状导致全盔不一定每次都放得进去。值得一提的是左侧转向灯壳下方有个专门放手机和钱包的小格子。巴厘岛租客的评价里特别提到上坡时的动力储备("tanjakan")和适合长途骑行的柔软悬挂——比如去乌鲁瓦图的路上。多篇面向游客的攻略还专门点名 ABS 和宽幅无内胎轮胎是加分项,原因是巴厘岛热带暴雨频繁,路上还常有狗之类的突发状况——紧急刹车时轮胎不会锁死打滑。

**在巴厘岛哪里表现最好:** 在市区车流(芝安古、水明漾)里应付自如,中长途骑行也没问题,包括去乌鲁瓦图的路线——弯道和雨天的操控稳定性都不错。这一点在所有版本上表现基本一致——它们之间的几何尺寸和坐姿差别很小。', 'Yamaha Nmax——New(第二代)、Neo(第三代)与Turbo版全解析', '巴厘岛Yamaha Nmax租赁指南:New、Neo和Turbo版本有什么区别,详细参数和真实车主评价一次看懂。'
  FROM articles a WHERE a.slug = 'yamaha-nmax-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Yamaha XMAX250——Connected与Tech Max:同样的机械素质,不同的配置等级', 'yamaha-xmax250-review', 'Yamaha XMAX250 是车队里动力最强的踏板车,长途和市区骑行都很出色。车队里有 Connected 和 Tech Max 两个版本,机械部分完全一致。', 'Yamaha XMAX250 是车队里动力最强的踏板车。很多人特别喜欢这台大家伙,大家都认同它跑长途很出色,但对不少人来说,哪怕只是市区短途骑行,它也是无可替代的选择。车队里有两个版本——Connected 和 Tech Max,这里要说明一点:两者在机械层面完全是同一台车,差别只在配置和装饰。[在我们的车型库中查看 Yamaha XMAX250](/zh-Hans/bikes?category=yamaha_xmax250)。

**车辆参数(Connected 和 Tech Max 完全一致——发动机和底盘相同):**
- 发动机:250cc,单缸,水冷,SOHC 4气门,Blue Core,一体式锻造曲轴
- 功率:16.8千瓦(7000转/分)
- 扭矩:24.3牛·米(5500转/分)
- 变速箱:CVT无级变速
- 座高:795毫米
- 车重:约181公斤
- 油箱容量:13升
- 座下储物空间:44.9升——空间非常大,实际能放下两顶全盔外加一些随身物品。有个小细节:有时需要把全盔按特定角度摆放才能放得进去
- ABS防抱死、牵引力控制(TCS)、紧急制动警示灯(Emergency Stop Signal,急刹时尾灯自动闪烁提醒后方)、带寻车回应系统(Answer Back System)的智能钥匙、手机充电电源接口
- Connected 版风挡固定,不可调节。风挡可调是 Tech Max 的专属配置(见下文)
- 印尼雅马哈官方质保——车架、燃油系统部件、气缸和活塞享5年/5万公里质保

**Y-Connect App——值得特别向租客说明的一个细节:**

XMAX Connected 版本支持连接该App:

📱 下载地址:
https://apps.apple.com/app/id1495921872
https://apps.apple.com/app/id1585591110

连接后可以实现:
• 在车把上接听来电
• 在车把上切换音乐
• 导航支持中文语音提示
• 与手机顺畅联动

**Connected 与 Tech Max——区别在哪:**

最重要也最"值钱"的区别是座椅。Tech Max 的座椅不只是"缝线不一样"那么简单,而是由 MBK(雅马哈旗下的法国品牌,专注欧洲市场踏板车)专门设计的座椅,官方称为"Comfort Seat(舒适座椅)"。内部采用高密度泡棉,两侧带有支撑侧翼(bolster),专为长时间骑行设计:能稳定坐姿、减轻长途骑行时腰部的疲劳,而不只是摸起来更软。表层是带绒面拼接和金线缝线的仿皮材质,再加一块镀铬装饰条。车主在评价中特别提到,正是这张座椅让他们觉得多花钱买 Tech Max 值得,而不是颜色或车标。

其余差异虽然也是真实存在的,但在价格占比和重要性上都不如座椅:
- 专属车色(早期车型为熔岩黑 Magma Black,2025年起改为陶瓷灰 Ceramic Grey)
- 座下杂物格盖板采用仿皮加绒面材质并配金线缝线(与座椅呼应)
- 铝合金脚踏板、镀铬装饰条、Tech Max 专属车标和把手纹理
- 2025款 Tech Max 上出现了唯一一个功能性(而非仅是外观)的区别——电动可调风挡(Electric Adjustable Screen),行驶中也能操作,可以快速调整到自己想要的角度,同时配备了升级版TFT彩色仪表;而如前所述,Connected 版的风挡完全不可调节

在印尼市场,Tech Max 版本的价格大约贵500万印尼盾左右,而这笔差价首先就是花在那张座椅上。

**车主怎么说:** 发动机在100-110公里/小时区间拉起来很轻松,再往上就开始"喘不上气"了——这不是一台追求极限加速的车,而是适合稳定巡航节奏的车。印尼XMAX车友会早在2017年就在巴厘岛组织了新车型的首次环岛骑行活动——路线是登巴萨→乌布→金塔玛尼→佩萨基→格隆隆→吉安雅→Ida Bagus Mantra收费公路,再原路返回;在乌布和金塔玛尼的弯道路段,车友们测试了牵引力控制系统的表现,而在Ida Bagus Mantra收费公路的直线路段,车速一度飙到140公里/小时。

巴厘岛骑士们自己总结出的几条 XMAX250 经典路线:南部海岸线——芝安古→乌鲁瓦图(经Jalan Bali Cliff)→潘达瓦海滩→GWK;山区路线——登巴萨→乌布→金塔玛尼→巴杜尔湖→文都;东部路线——沙努尔→昌迪达萨→西德门→处女海滩(Virgin Beach)。详细路线和地图标点,请看我们博客里的文章《骑行布吉半岛》《金塔玛尼:巴杜尔火山看日出》和《骑行巴厘岛东部》(文中也会介绍处女海滩)——即将发布。

**适合谁:** 适合环岛一日游或多日游,尤其是需要充足动力应付超车和爬坡的路段,以及长途骑行中的舒适性。日常代步同样出色——这是游客和常驻巴厘岛的外国人都特别青睐的一款车。

**在巴厘岛哪里表现最好:** 南部以外的路线——金塔玛尼和巴杜尔火山、阿梅德、洛维娜、西德门、东部海岸线。不过这终究是个人喜好问题——也有不少车主就是喜欢骑着这台车队里最大的旅行探险车,哪怕是在芝安古堵车,这样的爱好者其实不在少数。', 'Yamaha XMAX250——Connected与Tech Max:同样的机械素质,不同的配置等级', '巴厘岛Yamaha XMAX250租赁详解:Connected与Tech Max版本的区别、详细参数、Y-Connect互联App以及环岛骑行路线推荐。'
  FROM articles a WHERE a.slug = 'yamaha-xmax250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Yamaha MT-25——第二代与第三代:外观不同,发动机不变', 'yamaha-mt25-review', 'Yamaha MT-25 是一款紧凑型街车,适合想体验摩托车加速感和操控回馈的骑手。车队里既有第二代车型,也有2025年改款后的第三代车型。', 'Yamaha MT-25 是一款紧凑型街车,适合想真正感受摩托车加速和操控回馈的骑手,而不只是把它当作代步工具。这台车确实很有个性——不少专业车手和摩托爱好者都把它列为同级别里最喜欢的车型之一,无论是动力表现、骑姿还是外观设计。手动变速箱和激进的骑姿,正是这款车与车队里的踏板车最本质的区别。2025年,印尼雅马哈推出了一次明显的改款("第三代"),所以车队里可能会看到同一款车名下,新旧两种外观的车同时存在。[在我们的车型库中查看 Yamaha MT-25](/zh-Hans/bikes?group=motorcycle&model=yamaha_mt25)。

**车辆参数(通用——发动机本身两代之间没有变化):**
- 发动机:249.55cc,水冷,DOHC,并列双缸,8气门
- 功率:约35.5马力(12000转/分)
- 扭矩:约22.6牛·米(10000转/分)
- 变速箱:6速手动
- 座高:约780毫米
- 油箱容量:约14升

**第二代(约2019年改款——最经典、最容易辨认的MT-25外观):**
- 前刹为单碟
- 无辅助/滑动离合器,无ABS
- 车重:约165-167公斤

**第三代(2025年改款,雅马哈印尼官网将其定位为"Hypernaked超级街车"):**
- 全新犀利大灯造型,延续MT-07/R系列的设计语言——棱角分明、极具"外星感"的灯组,与圆形大灯的第一代不同(第二代已经不再是圆灯造型,但第三代的线条更加凌厉)
- ABS——MT-25首次配备ABS就是在第三代上
- 辅助/滑动离合器——急降挡时换挡更平顺
- Y-Connect(蓝牙互联App)通过CCU模块实现——这是印尼组装摩托车上首次搭载此类技术
- Big Bike Switch三合一开关——参考雅马哈"大排量车型"风格的紧凑集成开关组
- 全液晶仪表,带最佳换挡时机提示灯(shift timing light)
- 电子设备充电接口
- 车重:约169公斤——因为新增配置,比第二代略重

**在巴厘岛哪里表现最好:** 芝安古和水明漾——市区车流里短促有力的加速,以及沿海滨大道的夜骑,这些场景最能展现这款车的个性。', 'Yamaha MT-25——第二代与第三代:外观不同,发动机不变', '巴厘岛Yamaha MT-25租赁指南:第二代与第三代有什么区别、发动机参数详解,以及这款街车在哪些路段最能展现本色。'
  FROM articles a WHERE a.slug = 'yamaha-mt25-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Kawasaki Ninja ZX-25R——唯一一款搭载直列四缸发动机的量产250cc跑车', 'kawasaki-ninja-zx-25r-review', 'Kawasaki Ninja ZX-25R 是唯一一款搭载直列四缸发动机的量产250cc跑车,高转速性格鲜明,原厂标配快速换挡器。', 'Ninja ZX-25R 在250cc级别里的地位独一无二:它是唯一一款搭载直列四缸发动机的量产跑车(所有竞争对手都是单缸或双缸)。这也造就了它标志性的高转速声浪,以及对转速的高要求。[在我们的车型库中查看 Kawasaki Ninja ZX-25R](/zh-Hans/bikes?group=motorcycle&model=kawasaki_zx25r)。

**车辆参数:**
- 发动机:249cc,水冷,DOHC,直列四缸——同级别中极为罕见的配置
- 功率:约45马力(印尼版无Ram Air进气系统,15500转/分),红线转速高达17000转/分
- 变速箱:6速手动
- 座高:约785毫米
- 车重:约183公斤
- 油箱容量:约15升
- 全整流罩车身,标准跑车骑姿
- 原厂快速换挡器(Quick Shifter)——升挡无需收油离合,降挡自动补油

**车主怎么说:** 250cc级别配四缸发动机这件事本身就非常罕见,以至于川崎当年专门放出过一段这台发动机在测功机上的声浪视频——评论区把这声音形容为对这么小排量来说"凶悍""疯狂"。一些经验丰富的车手提到,原厂快速换挡器(带降挡自动补油)表现出色,能让巴厘岛的日常车速也骑出真正的乐趣——不用飙到赛道速度就能享受换挡的快感。缺点方面有人提到:身高180厘米以上的骑手骑一天下来腿部会比较累,悬挂调校也偏城市取向而非赛道取向。峰值动力要到15500转/分才会出现,习惯低转速骑行的人在转速拉起来之前会觉得这台车有点绵软。

**适合谁:** 适合骑行经验丰富、想在250cc级别里获得最强烈驾驶乐趣、并愿意把转速拉高的骑手——这不是一台适合低转速悠闲骑行的车。

**在巴厘岛哪里表现最好:** 这台车更多是关于驾驶体验和个性,而不是针对某条具体路线——和 MT-25 一样,在市区、海滨大道都能骑出乐趣,还能上邻岛龙目岛那条世界级的曼达利卡赛道。并不是所有租车行都允许这样的出行,但我们可以安排。这是车队里对骑手要求最高的一款车——不适合摩托车新手,对身材高大的骑手来说,骑一整天也不算理想。', 'Kawasaki Ninja ZX-25R——唯一一款搭载直列四缸发动机的量产250cc跑车', '巴厘岛Kawasaki Ninja ZX-25R租赁介绍:罕见的250cc直列四缸发动机、快速换挡器配置,以及这款跑车适合什么样的骑手。'
  FROM articles a WHERE a.slug = 'kawasaki-ninja-zx-25r-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Yamaha XSR155——带着复古气质的咖啡赛车', 'yamaha-xsr-155-review-retro-style', 'Yamaha XSR155 是一款新复古风摩托车:圆形大灯、低把手、咖啡赛车骑姿,搭载同系列155cc发动机,针对手动变速做了更强的动力调校。', 'Yamaha XSR155 是一款新复古风摩托车:圆形大灯、低把手、典型的咖啡赛车骑姿。发动机和系列踏板车共用同一套155cc家族发动机,但针对手动变速版本调校得更有力。[在我们的车型库中查看 Yamaha XSR155](/zh-Hans/bikes?group=motorcycle&model=yamaha_xsr)。

**车辆参数:**
- 发动机:155cc,水冷,SOHC,VVA可变气门——与Nmax155同源,但针对手动变速做了不同调校
- 功率:约19.3马力(10000转/分)
- 变速箱:6速手动
- 座高:约815毫米——典型的咖啡赛车低坐姿
- 车重:约131-134公斤
- 油箱容量:约10升

**车主怎么说:** XSR155 的车架借用自跑车 R15,所以整车轻巧、操控反应很灵敏。油门控制得当的话,真实油耗能达到每升50公里左右。想带人骑双载的话要注意一点:后座偏小偏硬,不少版本上也没有像样的乘客扶手。一位真实的巴厘岛租客给这款车留下了很有代表性的评价:尽管排量只有155cc,这台车在巴厘岛的路上却"骑得很带劲",性价比调校得很到位,在本地柏油路上的稳定性甚至让他觉得在同样的弯道上不输 Yamaha R3——租车行专门把车骑了三个小时送到阿梅德,车子一路表现稳定,没掉链子。

**适合谁:** 适合想要摩托车的造型和个性、但又不需要过剩动力的骑手——是从踏板车过渡到手动挡车型的舒适选择。

**在巴厘岛哪里表现最好:** 芝安古和水明漾——复古造型和当地氛围很搭;不过从评价来看,应付去阿梅德这样更长、弯道更多的路线也完全没问题。', 'Yamaha XSR155——带着复古气质的咖啡赛车', '巴厘岛Yamaha XSR155租赁介绍:详细参数、车主评价,以及这款配手动变速箱的新复古摩托车适合什么样的骑手。'
  FROM articles a WHERE a.slug = 'yamaha-xsr-155-review-retro-style'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Kawasaki Versys-X 250——为土路留足余量的旅行车', 'kawasaki-versys-x250-review', 'Kawasaki Versys-X 250 是一款越野旅行车,坐姿高、悬挂行程长、油箱容量更大,适合想探索岛上乡间小路的骑手。', 'Kawasaki Versys-X 250 是一台越野旅行车:坐姿高、悬挂行程长、油箱容量加大。适合那些不只想在柏油路上骑行,还想探索岛上乡间小路的骑手。[在我们的车型库中查看 Kawasaki Versys-X 250](/zh-Hans/bikes?group=motorcycle&model=kawasaki_versys)。

**车辆参数:**
- 发动机:249cc,水冷,DOHC,并列双缸
- 功率:约27马力(9700转/分)
- 变速箱:6速手动
- 座高:约845毫米——明显高于车队里的其他车型
- 车重:约184公斤
- 油箱容量:约17升——车队里数一数二的大油箱,续航更充足
- 风挡、越野脚踏杆、可站立/可坐骑的双重骑行姿态

**车主怎么说:** 时速105公里以内平稳骑行时的真实油耗大约在每升27-30公里(巴厘岛当地租车行的独立反馈也接近这个数字,约每百公里3-4升),配合17升油箱,不加油能跑相当长的距离。越野能力也不只是宣传噱头:在一次早期试驾中,车辆稳稳通过一段泥泞路段,悬挂全程没有触底。原厂座椅刚开始偏硬,需要一段"磨合期"。这台车在80-110公里/小时区间骑起来最舒服。巴厘岛真实租客反馈,这台车曾轻松把人送到偏远的山区村庄,手动挡版本在一次雨天北上的行程中表现也很出色。租车行自己总结的经典路线包括:巴厘岛南部→乌布→金塔玛尼,北部山区道路,以及一直延伸到阿梅德和图蓝奔的东部海岸线。

**适合谁:** 适合环岛多日游,以及想在土路或坑洼路段骑得更有信心的骑手。详细路线请看我们博客的文章:《骑行巴厘岛东部》《金塔玛尼:巴杜尔火山看日出》《贝杜古—文都—洛维娜》。

**在巴厘岛哪里表现最好:** 长途路线——金塔玛尼、岛屿的北部和东部(包括阿梅德和图蓝奔)、主要旅游路线之外的乡间小路。', 'Kawasaki Versys-X 250——为土路留足余量的旅行车', '巴厘岛Kawasaki Versys-X 250租赁介绍:详细参数、续航能力、车主评价,以及这款越野旅行车最适合的骑行路线。'
  FROM articles a WHERE a.slug = 'kawasaki-versys-x250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Suzuki V-Strom 250——注重舒适与挡风性能的旅行车', 'suzuki-v-strom-250-review', 'Suzuki V-Strom 250 是一款注重长途骑行舒适性的冒险旅行车:宽大风挡、笔直坐姿、柔软悬挂。', 'Suzuki V-Strom 250 是一台专注长途骑行舒适性的冒险旅行车:宽大的风挡、恰到好处的笔直坐姿、柔软的悬挂,长途骑行不容易疲劳。[在我们的车型库中查看 Suzuki V-Strom 250](/zh-Hans/bikes?group=motorcycle&model=suzuki_vstrom250)。

**车辆参数:**
- 发动机:248cc,水冷,DOHC,并列双缸
- 功率:约25马力(8000转/分)
- 变速箱:6速手动
- 座高:约800-835毫米,视版本而定
- 油箱容量:12升

**车主怎么说:** 车主评价里常把这台发动机比作缝纫机——平顺、安静、省油又可靠。几乎所有人都提到座椅填充扎实、坐姿"像大排量车",操控起来却轻松得多。实际骑行油耗在每升32到48公里之间。巴厘岛最有代表性的使用案例之一:有位租客租了40多天的V-Strom,骑着它往返了一趟弗洛勒斯岛。另一位巴厘岛租客也留下了一个实用的经验教训:原厂后货架挂包在路上不太牢靠——后来换成了带正规侧箱的 Versys;结论是,如果计划带很多行李,侧箱比后货架上绑绳子靠谱得多。租客们特别推荐往西德门、巴杜尔山方向以及巴厘岛最东端周边的道路骑行,并提到只有在乌鲁瓦图、芝安古和乌布这几个地方才会明显感觉到车流拥堵——再往外就是梯田、丛林和海景了。

**适合谁:** 适合首先看重长途舒适性、而不是运动性能的骑手。详细路线请看我们博客的文章:《骑行巴厘岛东部》《西库姆普与巴厘岛中北部瀑布群》《骑行巴厘岛火山》。

**在巴厘岛哪里表现最好:** 和 Versys-X250 属于同一类定位——长途路线、西德门、巴杜尔山、东部海岸线。如果行李比较多,提前告诉我们就行,我们会给车加装侧箱。', 'Suzuki V-Strom 250——注重舒适与挡风性能的旅行车', '巴厘岛Suzuki V-Strom 250租赁介绍:详细参数、真实油耗以及租客关于环岛长途骑行的真实反馈。'
  FROM articles a WHERE a.slug = 'suzuki-v-strom-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'TVS Ronin 225——介于新复古与滑胎车之间', 'tvs-ronin-225-review', 'TVS Ronin 225 是一款带有滑胎车气质的现代经典摩托车:圆形LED大灯、较高的把手位置,在市区和土路岔道上都能骑得很自信。', 'TVS Ronin 225 是一台带有滑胎车气质的现代经典摩托车:圆形LED大灯、较高的把手位置,车身几何设计很全面,在市区和大路旁的土路岔道上都能应付自如。所有版本均标配ABS。[在我们的车型库中查看 TVS Ronin 225](/zh-Hans/bikes?group=motorcycle&model=tvs_ronin225)。

**车辆参数:**
- 发动机:225.9cc,油冷,单缸,SOHC,4气门
- 功率:约20.4马力(7750转/分)
- 扭矩:约19.9牛·米(3750转/分)——低转速就有拉力,不用刻意拉高转速
- 变速箱:5速手动
- 座高:约795毫米
- 车重:约159公斤
- 油箱容量:约14升
- 全系标配ABS(入门版为单通道,高配版为双通道)

**可靠性:** TVS 是一个在印度历史悠久的品牌(从上世纪80年代就开始生产两轮车),Ronin 虽然是相对较新的车型(2022年才推出),但经过这几年的实际使用,已经积累了很扎实的可靠性口碑:在行驶里程超过10000公里的车主评价中,发动机被描述为依然保持出厂般的平顺,金色USD倒置前叉展现出很强的耐用性,即使在不同路面上骑行一年后,车身装配也没有出现松旷或异响。在独立车主评分榜单中,Ronin 的可靠性和保养成本评分一直稳居同级别前列。

**车主怎么说:** 发动机启动时会发出复古摩托车特有的、带点沙哑感的浑厚声浪。强劲的低扭让这台车在拥堵的市区车流中骑起来格外轻松。车主评价中的真实油耗是每升35-45公里。悬挂调校偏软——能很好地过滤市区路面的颠簸。部分版本配有骑行模式,其中包括针对雨天优化的模式——考虑到巴厘岛的气候,这项配置很实用。动力表现和外观造型也经常被车主评价提及,是这款车的强项之一。

**适合谁:** 适合想要一台全能日常摩托车的骑手——没有跑车那种激进感,但在土路路段也有足够的信心储备。

**在巴厘岛哪里表现最好:** 凭借新复古造型,在芝安古/水明漾一带同样出彩,通往梯田的土路岔道也照样能应付。', 'TVS Ronin 225——介于新复古与滑胎车之间', '巴厘岛TVS Ronin 225租赁介绍:详细参数、可靠性表现,以及车主对这款带滑胎车个性的新复古摩托车的评价。'
  FROM articles a WHERE a.slug = 'tvs-ronin-225-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Keeway Road Falcon 250——入门级价位的经典巡航车', 'keeway-road-falcon-250-review', 'Keeway Road Falcon 250 是一款以入门级价格提供经典巡航车体验的车型:车身修长,坐姿低矮。这是一款2026年才正式推出的新车。', 'Keeway Road Falcon 250 车身修长,坐姿低矮,低调的黑色车身,神韵借鉴自美式大排量巡航车,但底盘紧凑,排量只有250cc。这款车在市场上非常新——2026年才推出,所以目前几乎还没有用户和巴厘岛租车反馈。[在我们的车型库中查看 Keeway Road Falcon 250](/zh-Hans/bikes?group=motorcycle&model=keeway_roadfalcon250)。

**车辆参数:**
- 发动机:248cc,并列双缸,四冲程,4气门,SOHC,水冷
- 功率:约24.6马力(8000转/分)
- 扭矩:约23.4牛·米(6500转/分)
- 变速箱:6速手动,配滑动离合器
- 座高:约698毫米——车队里最低的坐姿之一
- 离地间隙:约186毫米
- 油箱容量:14升
- 刹车:前300毫米碟刹(双活塞卡钳),后260毫米碟刹
- 5英寸TFT彩色仪表,内置蓝牙音箱——同级别中很少见的配置
- 仪表盘可直接显示导航——和XMAX250一样,这款车完全不需要手机支架

**车主怎么说:** 这款车经常被直接拿来和 Harley-Davidson 风格车型以及 Honda Rebel 比较——车头标志性的"油箱隆起"造型和整体车身轮廓,明显是在向美式大排量巡航车致敬,印尼媒体上也确实能看到 Road Falcon 与 Honda Rebel 的正面对比评测。车把上内置的蓝牙音箱,在这个级别的巡航车里相当罕见。滑动离合器让降挡更加平顺——在巴厘岛的丘陵路段很实用。另外值得一提的是,这台车异常灵活,转弯半径出乎意料地小——对于这么修长的巡航车身来说不太容易想到,但实际骑起来确实能感觉到。

**适合谁:** 适合想要经典巡航车造型和放松坐姿的骑手——座椅非常低,对身材不高的骑手尤其友好。

**在巴厘岛哪里表现最好:** 悠闲的沿海路线——沙努尔、努沙杜瓦——但不止于此:我们也有客人骑着它去了通常属于 Versys、V-Strom 这类经典越野旅行车才会去的地方,也就是说,尽管顶着巡航车的外形,它同样能拿下巴厘岛北部海岸线的长途骑行。', 'Keeway Road Falcon 250——入门级价位的经典巡航车', '巴厘岛Keeway Road Falcon 250租赁介绍:详细参数、与Honda Rebel的对比,以及这款巡航车适合什么样的骑手。'
  FROM articles a WHERE a.slug = 'keeway-road-falcon-250-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Morbidelli C252V——挂着意大利名字的V型双缸巡航车', 'morbidelli-c252v-review', 'Morbidelli C252V 是车队里的第二款巡航车,但它采用真正的V型双缸发动机而非并列双缸,并配备皮带传动。', '这是车队里的第二款巡航车,但和 Road Falcon 在性格上截然不同:Morbidelli 搭载真正的V型双缸发动机,而不是并列双缸,由此带来更加"低沉浑厚"的声浪和震动,许多巡航车骑手反而把这种震动视为乐趣的一部分。Morbidelli 这个品牌名来自意大利,有着真实的赛车历史(1970年代拿过125cc和250cc级别摩托车世锦赛冠军),2024年起其品牌权归属与 Keeway 同一个集团——所以这并不是同名蹭热度,而是一个在全新技术基础上正式复活的品牌。[在我们的车型库中查看 Morbidelli C252V](/zh-Hans/bikes?group=motorcycle&model=morbidelli_c252v)。

**车辆参数:**
- 发动机:249cc,V型双缸(V-twin),四冲程,8气门,SOHC,水冷
- 功率:约25.5马力(9000转/分)
- 扭矩:25牛·米(5500转/分)
- 变速箱:6速手动,配滑动离合器
- 传动方式:皮带传动(belt drive)——同级别中很少见。实际意义是:不像链条那样需要定期上油和调整松紧,皮带也不会被雨水锈蚀
- 座高:690毫米——车队里最低的坐姿之一
- 车重:约200公斤
- 油箱容量:15.5升
- 离地间隙:173毫米
- 刹车:前320毫米碟刹(四活塞卡钳),后260毫米碟刹(双活塞卡钳);标配双通道博世ABS和牵引力控制
- 前叉为37毫米倒置前叉(USD),行程115毫米;后悬挂为双减震器,预载可调5档
- 官方公布最高时速:125公里/小时

**车主怎么说:** 这款车在市场上非常新,所以还没有多年使用的口碑积累,但媒体的早期试驾评测都提到,以这么长的轴距来说,操控意外地轻盈——转弯半径完全看不出车身的实际尺寸。V型发动机被形容为视觉效果很抢眼(在油箱下方清晰可见,带有仿散热片造型和镀铬装饰),声浪也明显比典型的250cc并列双缸更加低沉。

**适合谁:** 适合就是想要V-twin巡航车个性的骑手(不是Road Falcon那种并列双缸)——更明显的震动感和低沉的发动机声浪,再加上皮带代替链条——不用上油调整,雨天也不生锈。

**在巴厘岛哪里表现最好:** 和 Road Falcon 属于同一定位——悠闲的沿海路线、沙努尔、努沙杜瓦;皮带传动加上低矮坐姿,特别适合想要轻松巡航车风格、又不想操心链条保养的骑手。', 'Morbidelli C252V——挂着意大利名字的V型双缸巡航车', '巴厘岛Morbidelli C252V租赁介绍:V型双缸发动机、皮带传动、详细参数,以及这款巡航车与Road Falcon的区别。'
  FROM articles a WHERE a.slug = 'morbidelli-c252v-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Honda CBR250RR——全整流罩车身,车队里最“赛道范”的跑车', 'honda-cbr250rr-review', 'Honda CBR250RR 是车队里唯一一款全整流罩跑车,车队里的这台是配备快速换挡器和ABS的顶配版本,是印尼250cc级别里技术最领先的车型之一。', '作为车队里唯一一款全整流罩跑车(不同于MT-25和ZX-25R这类"裸车"街车/斗士车)——Honda CBR250RR自2016年首发以来,一直被认为是印尼250cc级别里技术最领先的车型之一。[在我们的车型库中查看 Honda CBR250RR](/zh-Hans/bikes?group=motorcycle&model=honda_cbr250rr)。

**车辆参数(车队里配备的是带快速换挡器和ABS的SP顶配版本):**
- 发动机:249.7cc,水冷,DOHC,并列双缸,8气门,顶配版专属升级(轻量化曲轴、全新气门弹簧、改良缸头)
- 功率:约41马力(13000转/分)
- 扭矩:约25牛·米(11000转/分)
- 变速箱:6速手动
- 座高:约790毫米
- 车重:约168公斤
- ABS防抱死、全LED灯组、数字仪表盘、电子油门(throttle-by-wire,无需拉线的电子节气门)
- 快速换挡器,可设置4种模式(升降挡皆可、仅升挡、仅降挡、关闭)——换挡无需收油离合
- 辅助/滑动离合器
- 前叉为SFF-Big Piston型倒置前叉(USD)
- 3种骑行模式:舒适(Comfort)、运动(Sport)、运动+(Sport+)
- 官方公布0-200米加速8.65秒,最高时速可达172公里/小时

**车主怎么说:** CBR250RR 一直被认为是印尼250cc级别里"配置最堆料"的车型之一——配快速换挡器的版本能带来真正的赛道级驾驶感受,这在这个排量级别里相当罕见。

**适合谁:** 适合想要完整跑车体验的骑手——整流罩车身、趴在油箱上的运动骑姿,以及媲美MotoGP的快速换挡技术。

**在巴厘岛哪里表现最好:** 和 ZX-25R 一样——市区、海滨大道,更多是关于驾驶体验和个性,而不是针对某条具体路线;考虑到它的赛道血统,在龙目岛的曼达利卡赛道上同样能充分发挥实力。', 'Honda CBR250RR——全整流罩车身,车队里最“赛道范”的跑车', '巴厘岛Honda CBR250RR租赁介绍:配快速换挡器的顶配版本、详细参数,以及完整跑车体验适合什么样的骑手。'
  FROM articles a WHERE a.slug = 'honda-cbr250rr-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'Honda CB150X——搭载150cc发动机的入门级探险车', 'honda-cb150x-review', 'Honda CB150X 是通往探险风格的经济之选,搭载150cc发动机,拥有同级别中相当出色的悬挂配置,是车队所有摩托车里最轻的一款。', 'CB150X 和250cc的 Versys-X250、V-Strom250不是一回事:它是通往探险风格的经济之选,只搭载一台朴素的150cc单缸发动机,但底盘配置在同级别里相当扎实(离地间隙几乎接近更大排量的CB500X)。得益于作为一台摩托车来说非常轻的车重(139公斤),150cc的动力已经绰绰有余——这台车很容易就能抬起前轮,而且在全速度区间内都能保持不错的动态表现,并不像单缸小排量给人的印象那样只在低速时够用。[在我们的车型库中查看 Honda CB150X](/zh-Hans/bikes?group=motorcycle&model=honda_cb150x)。

**车辆参数:**
- 发动机:149.16cc,单缸,水冷,DOHC 4气门
- 功率:约15.6马力(9000转/分)
- 扭矩:约13.8牛·米(7000转/分)
- 变速箱:6速手动
- 座高:817毫米
- 离地间隙:181毫米——几乎接近排量大得多的CB500X
- 车重:约139公斤——车队里最轻的摩托车(不含踏板车)
- 油箱容量:12升
- 前叉为Showa SFF-BP 37毫米倒置前叉(USD),后悬挂为Pro-Link单减震
- 前后均为波浪状刹车碟盘
- 全液晶仪表,实时显示油耗

**适合谁:** 适合想要探险车造型和较高坐姿、但又不想应付满血250cc旅行车重量和动力的骑手——是从城市通勤车型过渡到更硬核车型的不错台阶。

**在巴厘岛哪里表现最好:** 和 ADV160 逻辑相同——乡间小路、不太平整的柏油路面,但在骑姿和性格上,这已经是一台完整的手动挡摩托车,而不是踏板车。', 'Honda CB150X——搭载150cc发动机的入门级探险车', '巴厘岛Honda CB150X租赁介绍:详细参数、离地间隙,以及这款经济型探险摩托车适合什么样的骑手。'
  FROM articles a WHERE a.slug = 'honda-cb150x-review'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();
INSERT INTO article_translations (article_id, language_code, title, slug, excerpt, content, seo_title, seo_description)
  SELECT a.id, 'zh-Hans', 'PCX160 vs ADV160 vs Nmax——三款车之间该怎么选', 'pcx160-vs-adv160-vs-nmax-how-to-choose', 'PCX160、ADV160 和 Nmax——车队里最受欢迎的三款踏板车该怎么选:储物空间、动力表现和坐姿上到底有什么不同。', '说实话,这三款车之间的差异主要在于外观和骑手个人的骑行习惯——说白了,更多是个人喜好问题。真正重要的实际差异里,第一位是储物空间大小:如果你愿意为了喜欢的坐姿和动态表现而牺牲一部分储物容量,那么 Nmax 适合你。而单论动态表现,我们内部经常开玩笑说:真正想要"Turbo"那种响应感的人,其实应该在这条产品线里选 ADV——主观感受上它比名字里带"Turbo"的那款更灵活。

理想情况下,在决定长租哪一款之前,最好每款都骑上5天到一个月,才能真正感受出区别。1-3天往往还不够真正了解一台车。

车型详情:[Honda PCX160](/zh-Hans/bikes?category=honda_pcx160)、[Honda ADV160](/zh-Hans/bikes?category=honda_adv160)、[Yamaha Nmax](/zh-Hans/bikes?category=yamaha_nmax155)。', 'PCX160 vs ADV160 vs Nmax——三款车之间该怎么选', '巴厘岛Honda PCX160、Honda ADV160与Yamaha Nmax租赁对比:根据自己的需求该选哪款踏板车。'
  FROM articles a WHERE a.slug = 'pcx160-vs-adv160-vs-nmax-how-to-choose'
  ON CONFLICT (article_id, language_code) DO UPDATE SET
    title = EXCLUDED.title, slug = EXCLUDED.slug, excerpt = EXCLUDED.excerpt,
    content = EXCLUDED.content, seo_title = EXCLUDED.seo_title, seo_description = EXCLUDED.seo_description,
    updated_at = now();

COMMIT;
