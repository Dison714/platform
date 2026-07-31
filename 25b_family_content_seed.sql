-- =====================================================================
-- 25b_family_content_seed.sql — data seed, not a schema migration.
-- English content_html for all 19 product_families (family_content_translations),
-- plus family_specs for the 4 models that had none (Kawasaki D-Tracker 250,
-- Keeway Road Falcon 250, Yamaha Byson 150, Yamaha Scorpio 225) sourced
-- from the same kind of open manufacturer/dealer data as the existing rows.
-- Frankenstein intentionally gets NO family_specs (one-off custom build,
-- no factory numbers to cite) but does get content_html explaining that.
-- Idempotent: safe to re-run (upsert on the natural keys).
-- =====================================================================

-- ---- family_specs for the 4 previously-unspecced real models ----
INSERT INTO family_specs (family_id, spec_key, spec_value, source, sort_order)
SELECT id, v.spec_key, v.spec_value, v.source, v.sort_order
FROM product_families pf
CROSS JOIN LATERAL (VALUES
    ('engine_cc','249','bikeinfobd.com',0),
    ('power','23.7','bikeinfobd.com',1),
    ('fuel_tank','7.7','bikeinfobd.com',2),
    ('transmission','manual','bikeinfobd.com',3),
    ('seat_height','860','bikeinfobd.com',4),
    ('seats','2','bikeinfobd.com',5),
    ('curb_weight','139','bikeinfobd.com',6)
) AS v(spec_key, spec_value, source, sort_order)
WHERE pf.brand = 'Kawasaki' AND pf.model_name = 'D-Tracker 250'
ON CONFLICT (family_id, spec_key) DO UPDATE SET spec_value = EXCLUDED.spec_value, source = EXCLUDED.source;

INSERT INTO family_specs (family_id, spec_key, spec_value, source, sort_order)
SELECT id, v.spec_key, v.spec_value, v.source, v.sort_order
FROM product_families pf
CROSS JOIN LATERAL (VALUES
    ('engine_cc','248','oto.com',0),
    ('power','24.7','oto.com',1),
    ('fuel_tank','14','oto.com',2),
    ('transmission','manual','oto.com',3),
    ('seat_height','698','oto.com',4),
    ('seats','2','oto.com',5)
) AS v(spec_key, spec_value, source, sort_order)
WHERE pf.brand = 'Keeway' AND pf.model_name = 'Road Falcon 250'
ON CONFLICT (family_id, spec_key) DO UPDATE SET spec_value = EXCLUDED.spec_value, source = EXCLUDED.source;

INSERT INTO family_specs (family_id, spec_key, spec_value, source, sort_order)
SELECT id, v.spec_key, v.spec_value, v.source, v.sort_order
FROM product_families pf
CROSS JOIN LATERAL (VALUES
    ('engine_cc','150','zigwheels.co.id',0),
    ('power','12.8','zigwheels.co.id',1),
    ('fuel_tank','12','zigwheels.co.id',2),
    ('transmission','manual','zigwheels.co.id',3),
    ('seat_height','790','zigwheels.co.id',4),
    ('seats','2','zigwheels.co.id',5),
    ('curb_weight','133','zigwheels.co.id',6)
) AS v(spec_key, spec_value, source, sort_order)
WHERE pf.brand = 'Yamaha' AND pf.model_name = 'Byson 150'
ON CONFLICT (family_id, spec_key) DO UPDATE SET spec_value = EXCLUDED.spec_value, source = EXCLUDED.source;

INSERT INTO family_specs (family_id, spec_key, spec_value, source, sort_order)
SELECT id, v.spec_key, v.spec_value, v.source, v.sort_order
FROM product_families pf
CROSS JOIN LATERAL (VALUES
    ('engine_cc','225','en.wikipedia.org',0),
    ('power','18.0','en.wikipedia.org',1),
    ('fuel_tank','12','en.wikipedia.org',2),
    ('transmission','manual','en.wikipedia.org',3),
    ('seat_height','770','en.wikipedia.org',4),
    ('seats','2','en.wikipedia.org',5),
    ('curb_weight','136','en.wikipedia.org',6)
) AS v(spec_key, spec_value, source, sort_order)
WHERE pf.brand = 'Yamaha' AND pf.model_name = 'Scorpio 225'
ON CONFLICT (family_id, spec_key) DO UPDATE SET spec_value = EXCLUDED.spec_value, source = EXCLUDED.source;

-- ---- family_content_translations (en), one row per family ----

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Honda ADV 160 is Bali's favourite adventure-style scooter &mdash; tall ground clearance and rugged looks on a genuinely easy CVT scooter platform, at home on the island's mixed road surfaces and steep hillside villa driveways.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>Confident stance</strong>: a tall 780mm seat height and generous suspension travel soak up rough tarmac and speed bumps without drama.</li>
<li><strong>Effortless CVT</strong>: twist-and-go automatic transmission, no clutch or gear shifting to think about.</li>
<li><strong>Efficient 160cc engine</strong>: 15.8 hp is plenty for two-up riding on Bali's hills, with real-world fuel economy.</li>
<li><strong>Practical fuel range</strong>: an 8.1-litre tank keeps refuelling stops infrequent even on longer day trips.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>Use the wide, flat footboard to shift your weight forward on steep inclines around Ubud and the Bukit.</li>
<li>The tall seat height makes this a great pick for taller riders who find standard scooters cramped.</li>
<li>Keep an eye on tyre pressure before long rides &mdash; the ADV's weight rewards properly inflated tyres with sharper handling.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the Honda ADV good for beginners?</strong> Yes &mdash; the CVT automatic transmission means no clutch or gear changes, so it is approachable even if you have never ridden a manual bike.</li>
<li><strong>Can two people ride the ADV 160 comfortably?</strong> Yes, it is rated for two seats and the suspension is tuned to handle two-up riding on Bali's roads.</li>
<li><strong>Is the ADV suitable for longer rentals?</strong> Definitely &mdash; its fuel efficiency and comfortable seating make it a popular choice for week- and month-long rentals.</li>
</ul>
$html$, 'written in-house from family_specs (ultimatespecs.com, powersports.honda.com, honda.co.id)'
FROM product_families WHERE brand='Honda' AND model_name='ADV'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Honda CB150X pairs a manual-transmission 150cc engine with trail-inspired styling &mdash; for riders who want a bit more engagement than a scooter, wrapped in a bike that shrugs off Bali's uneven backroads.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>Manual gearbox feel</strong>: gives riders more control over power delivery on winding roads than an automatic scooter.</li>
<li><strong>Long-travel suspension and an 817mm seat height</strong>: built for broken tarmac and unpaved village lanes.</li>
<li><strong>12-litre fuel tank</strong>: one of the largest in its class, so you can go further between fill-ups.</li>
<li><strong>Light 139kg kerb weight</strong>: easy to manage at low speed and when parking.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>The taller seat height suits riders 175cm and up; shorter riders may want to check reach at pickup.</li>
<li>Use the manual gearbox's engine braking on Bali's steep descents to save your brake pads.</li>
<li>The trail-tuned suspension rewards smooth, steady throttle inputs on rough sections.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Do I need manual gearbox experience to ride the CB150X?</strong> Yes &mdash; it has a standard manual transmission, so previous experience riding a geared motorcycle is recommended.</li>
<li><strong>Is the CB150X good for exploring beyond the main roads?</strong> It is built with trail-styled suspension for rough tarmac and gravel access roads, though our rental terms require staying on public roads.</li>
<li><strong>How does it compare to a scooter for a first-time Bali rider?</strong> It gives more control and a sportier ride than an automatic scooter, but needs comfort with a manual clutch and gears.</li>
</ul>
$html$, 'written in-house from family_specs (ultimatespecs.com, oto.com)'
FROM product_families WHERE brand='Honda' AND model_name='CB150X'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Honda CBR250RR is a full-fledged sportbike &mdash; a 250cc parallel-twin with real power, a proper fairing, and the riding position to match, for guests who want performance, not just transportation.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>40.2 hp twin-cylinder engine</strong>: among the most powerful 250cc bikes available to rent in Bali.</li>
<li><strong>Sport riding position and full fairing</strong>: aerodynamic and purposeful, built for spirited road riding.</li>
<li><strong>14.5-litre tank</strong>: long range for coastal touring days.</li>
<li><strong>Manual 6-speed gearbox</strong>: precise, close-ratio shifting for engaging riding.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>This is a performance bike &mdash; a valid license and real riding experience are strongly recommended.</li>
<li>Warm the engine for a minute before pushing it hard; the high-revving twin likes to be up to temperature.</li>
<li>The firm sport suspension is happiest on smooth tarmac &mdash; take it easy on rougher backroads.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the CBR250RR suitable for beginners?</strong> No &mdash; this is a performance sportbike best suited to riders with prior experience on geared motorcycles.</li>
<li><strong>What license do I need?</strong> A valid motorcycle driver's license is required for every rental; for the CBR250RR we recommend genuine riding experience as well.</li>
<li><strong>Can I take the CBR250RR on a long day trip?</strong> Yes, its fairing and fuel range make it comfortable for full-day rides around the island on paved roads.</li>
</ul>
$html$, 'written in-house from family_specs (en.wikipedia.org)'
FROM product_families WHERE brand='Honda' AND model_name='CBR250RR'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Honda PCX is Honda's flagship premium scooter &mdash; the same smooth 160cc CVT engine as the ADV, in a lower, sleeker package built for effortless city and coastal riding.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>Low 764mm seat height</strong>: one of the most accessible bikes in our fleet, comfortable for shorter riders.</li>
<li><strong>Smooth 160cc CVT engine</strong>: 15.8 hp with refined, quiet power delivery.</li>
<li><strong>Light 132kg kerb weight</strong>: easy to handle in traffic and tight parking.</li>
<li><strong>Under-seat storage</strong>: enough room for a helmet and daily essentials.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>The low seat height makes the PCX an easy first bike to get comfortable on if you are new to riding in Indonesia.</li>
<li>Use the under-seat storage for your rain poncho &mdash; Bali showers arrive fast.</li>
<li>The smooth CVT is happiest with gradual throttle &mdash; this is a comfort scooter, not a sport bike.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the PCX a good choice for beginners?</strong> Yes &mdash; the low seat height and fully automatic CVT make it one of the easiest bikes in our fleet to start on.</li>
<li><strong>How much storage does the PCX have?</strong> Enough under-seat space for a full-face helmet plus a small bag.</li>
<li><strong>Is the PCX comfortable for two riders?</strong> Yes, it is rated for two seats and rides comfortably two-up around town and on short trips.</li>
</ul>
$html$, 'written in-house from family_specs (ultimatespecs.com, bikedekho.com, honda.co.id)'
FROM product_families WHERE brand='Honda' AND model_name='PCX'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Honda Vario 160 is a light, everyday scooter &mdash; the practical choice for guests who just want simple, efficient transport around Bali without extra size or weight.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>Very light 115kg kerb weight</strong>: the easiest bike in our fleet to handle at a stop and while parking.</li>
<li><strong>Efficient CVT engine</strong>: strong real-world fuel economy for day-to-day riding.</li>
<li><strong>Compact size</strong>: easy to filter through Bali's busy traffic.</li>
<li><strong>Comfortable 778mm seat height</strong>: suits most rider heights.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>Because it is light, the Vario is a great pick for nervous or first-time scooter riders.</li>
<li>The compact size makes parking in busy Canggu and Seminyak areas much easier.</li>
<li>Keep the smaller 5.5-litre tank in mind on longer day trips and plan a fuel stop.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the Vario a good first scooter to try in Bali?</strong> Yes &mdash; it is light, easy to balance, and simple to ride.</li>
<li><strong>How far can I go on one tank?</strong> The 5.5-litre tank is best suited to daily riding around town; plan a refuel for longer trips.</li>
<li><strong>Is the Vario suitable for two riders?</strong> Yes, though it is best suited to lighter loads given its compact size.</li>
</ul>
$html$, 'written in-house from family_specs (oto.com, 91wheels.com)'
FROM product_families WHERE brand='Honda' AND model_name='Vario'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Kawasaki D-Tracker 250 is a supermoto-styled single &mdash; a tall, light, manual-geared bike built around a punchy 250cc engine, for riders who want a sharper, sportier feel than a typical trail bike.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>249cc single-cylinder engine</strong>: real punch for its size, in a light 139kg package.</li>
<li><strong>Tall 860mm seat height and supermoto stance</strong>: a confident, upright riding position.</li>
<li><strong>6-speed manual gearbox</strong>: precise control over the engine's power delivery.</li>
<li><strong>Nimble handling</strong>: quick to turn and easy to place on winding roads.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>The tall seat suits taller riders best; check your reach to the ground at pickup if you are under 170cm.</li>
<li>The supermoto-tuned suspension is firmer than a typical scooter &mdash; expect a sportier, more direct feel over bumps.</li>
<li>With a compact 7.7-litre tank, plan fuel stops a little more often on longer rides.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Do I need manual riding experience for the D-Tracker?</strong> Yes, it has a full manual gearbox and clutch, so prior experience on a geared motorcycle is recommended.</li>
<li><strong>Is the D-Tracker good for tall riders?</strong> Yes, its 860mm seat height suits taller riders particularly well.</li>
<li><strong>Is this a good bike for winding roads?</strong> Yes &mdash; its light weight and supermoto geometry make it quick and confident through corners.</li>
</ul>
$html$, 'written in-house from family_specs (bikeinfobd.com)'
FROM product_families WHERE brand='Kawasaki' AND model_name='D-Tracker 250'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Kawasaki Versys-X 250 is a proper adventure-touring twin &mdash; comfortable upright ergonomics, a big fuel tank, and enough power for confident two-up touring around the island.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>249cc parallel-twin engine with 33.5 hp</strong>: smooth, torquey power delivery unusual at this size.</li>
<li><strong>Large 17-litre fuel tank</strong>: one of the longest ranges in our fleet, ideal for full-day touring.</li>
<li><strong>Upright touring riding position</strong>: comfortable over long distances.</li>
<li><strong>Confident 815mm seat height</strong> with adventure-tuned suspension for Bali's varied road surfaces.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>The big tank means fewer fuel stops &mdash; plan a full day loop around the island without worrying about range.</li>
<li>The twin-cylinder engine likes a few minutes to warm up before hard riding.</li>
<li>Use the midrange torque rather than revving hard &mdash; it is a touring engine, not a screamer.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the Versys-X 250 good for long-distance touring in Bali?</strong> Yes &mdash; its fuel range and comfortable seating position are built exactly for that.</li>
<li><strong>Can two people ride the Versys comfortably?</strong> Yes, it is designed with two-up touring in mind.</li>
<li><strong>Do I need riding experience for this bike?</strong> Yes, a manual gearbox and real weight mean prior motorcycle experience is recommended.</li>
</ul>
$html$, 'written in-house from family_specs (en.wikipedia.org, oto.com)'
FROM product_families WHERE brand='Kawasaki' AND model_name='Versys'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Kawasaki ZX-25R is the most serious performance machine in our fleet &mdash; a genuine inline-four 250cc sportbike with a screaming top end and a 190 km/h top speed, built for riders who want the real supersport experience.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>Inline-four 249.8cc engine producing 46 hp</strong>: unmatched power-to-displacement in the 250cc class.</li>
<li><strong>190 km/h top speed</strong>: genuine supersport performance.</li>
<li><strong>Full fairing and aggressive riding position</strong>: track-bike looks and feel on the road.</li>
<li><strong>6-speed manual gearbox</strong> tuned for high-rev performance riding.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>This is an experienced-rider-only bike &mdash; a valid license and real riding background are essential.</li>
<li>The engine makes its best power high in the rev range; short-shifting under-uses what makes this bike special.</li>
<li>Sport suspension and tyres are tuned for smooth tarmac &mdash; take extra care on rougher roads.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the ZX-25R suitable for beginners?</strong> No &mdash; this is a high-performance sportbike intended for experienced riders only.</li>
<li><strong>What makes the ZX-25R different from other 250cc bikes?</strong> Its inline-four engine is unusual at this displacement and gives it a much higher rev ceiling and top speed.</li>
<li><strong>Can I rent the ZX-25R for a day trip around Bali?</strong> Yes, though its sport-focused setup is best enjoyed on smooth main roads rather than rough backroads.</li>
</ul>
$html$, 'written in-house from family_specs (en.wikipedia.org)'
FROM product_families WHERE brand='Kawasaki' AND model_name='ZX-25R'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Keeway Road Falcon 250 brings big-cruiser looks to a 250cc platform &mdash; a parallel-twin engine, a very low seat, and classic cruiser styling for relaxed, easy-going rides.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>248cc parallel-twin engine with a slipper clutch</strong>: smooth, confident downshifts.</li>
<li><strong>Very low 698mm seat height</strong>: one of the most accessible bikes in our fleet, especially for shorter riders.</li>
<li><strong>14-litre fuel tank</strong>: solid range for cruiser-style day trips.</li>
<li><strong>Classic cruiser styling</strong> with modern EFI reliability.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>The low seat height makes this an easy bike to plant both feet flat at every stop.</li>
<li>Cruiser ergonomics favour a relaxed, steady riding style rather than aggressive cornering.</li>
<li>The slipper clutch smooths out downshifts &mdash; use it to your advantage on Bali's hillier routes.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the Road Falcon 250 good for shorter riders?</strong> Yes &mdash; its low 698mm seat height is one of the most accessible in our fleet.</li>
<li><strong>Do I need manual gearbox experience?</strong> Yes, it has a 6-speed manual transmission with clutch.</li>
<li><strong>Is this a good bike for relaxed sightseeing?</strong> Yes, its cruiser riding position and low seat are built exactly for that kind of ride.</li>
</ul>
$html$, 'written in-house from family_specs (oto.com)'
FROM product_families WHERE brand='Keeway' AND model_name='Road Falcon 250'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Morbidelli C252V is a retro-styled cafe-racer cruiser &mdash; a 249cc single with classic lines, for guests who want a distinctive, characterful ride rather than a mainstream commuter bike.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>Distinctive retro styling</strong>: stands out from the typical scooters and commuter bikes on Bali's roads.</li>
<li><strong>249cc single-cylinder engine with 25 hp</strong>: enough character and pull for relaxed rides.</li>
<li><strong>15.5-litre fuel tank</strong>: solid range for day trips.</li>
<li><strong>Manual gearbox</strong> for a more engaging, classic riding feel.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>The low 690mm seat height makes this an easy, confident bike to handle at every stop.</li>
<li>Its retro riding position suits a relaxed pace rather than aggressive cornering.</li>
<li>At 200kg it has real presence at a standstill &mdash; take a little extra care with balance when parking on a slope.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the C252V a good choice for a distinctive rental?</strong> Yes &mdash; its retro styling stands out from the usual scooter crowd.</li>
<li><strong>Do I need manual gearbox experience?</strong> Yes, it has a full manual transmission and clutch.</li>
<li><strong>Is the seat height beginner-friendly?</strong> Yes, at 690mm it is one of the more accessible seat heights in our fleet.</li>
</ul>
$html$, 'written in-house from family_specs (morbidelli.com)'
FROM product_families WHERE brand='Morbidelli' AND model_name='C252V'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Suzuki V-Strom 250 is built for riders who want adventure, efficiency, and comfort in one package &mdash; a lightweight touring bike that stays composed on Bali's busy streets and scenic coastal routes alike.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>Efficient 248cc engine</strong>: reliable performance with genuinely good fuel economy for a touring bike.</li>
<li><strong>Comfortable touring ergonomics</strong>: upright seating and suspension tuned for longer rides.</li>
<li><strong>6-speed transmission</strong>: smooth shifting and efficient cruising at speed.</li>
<li><strong>Large 17.3-litre tank</strong>: long range between fuel stops.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>Use the upright seating position and wide bars to stay relaxed on longer coastal rides.</li>
<li>The 25 hp engine rewards smooth, steady throttle rather than aggressive acceleration.</li>
<li>Use the midrange for efficient, comfortable cruising rather than chasing revs.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the V-Strom 250 suitable for beginners?</strong> With manageable power, light handling, and a forgiving chassis, it works well for newer riders and commuters alike.</li>
<li><strong>Can I take the V-Strom 250 on long-distance trips?</strong> Yes &mdash; its fuel range and upright comfort make it well-suited to touring.</li>
<li><strong>How fuel-efficient is this motorcycle?</strong> It offers strong mileage for its class, good for daily rides and longer journeys without frequent stops.</li>
</ul>
$html$, 'written in-house from family_specs (en.wikipedia.org, motorcyclespecs.co.za)'
FROM product_families WHERE brand='Suzuki' AND model_name='V-Strom 250'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The TVS Ronin 225 is a neo-retro roadster &mdash; modern underpinnings with classic naked-bike styling, for riders who want character without giving up everyday usability.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>225.9cc engine with 20.1 hp</strong>: a lively, torquey ride for a naked roadster.</li>
<li><strong>Neo-retro styling</strong>: distinctive looks that stand apart from typical commuter bikes.</li>
<li><strong>14-litre fuel tank</strong>: solid range for day trips around the island.</li>
<li><strong>Manual gearbox</strong> for an engaging, direct riding feel.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>The upright naked-bike riding position is comfortable for both short city rides and longer day trips.</li>
<li>At 795mm the seat height suits most rider heights comfortably.</li>
<li>The 159kg kerb weight is manageable at low speed, but take care with balance when fully loaded.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the Ronin 225 good for first-time renters in Bali?</strong> It requires manual gearbox experience, but its manageable power and weight make it approachable for confident newer riders.</li>
<li><strong>Does the Ronin 225 suit longer rentals?</strong> Yes, with a comfortable seating position and solid fuel range it works well for week-long and longer rentals.</li>
<li><strong>What makes the Ronin different from other bikes in this class?</strong> Its neo-retro roadster styling gives it a distinctive look not found on typical scooters or commuter bikes.</li>
</ul>
$html$, 'written in-house from family_specs (tvsmotor.com, 91wheels.com)'
FROM product_families WHERE brand='TVS' AND model_name='Ronin 225'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Yamaha Byson 150 is a muscular naked streetfighter &mdash; a manual 150cc bike with bold styling, for riders who want a bit more attitude than a standard commuter.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>150cc engine with 12.8 hp</strong>: enough power for confident city and day-trip riding.</li>
<li><strong>Streetfighter styling</strong>: bold, muscular looks that stand out on the road.</li>
<li><strong>12-litre fuel tank</strong>: solid range for its class.</li>
<li><strong>5-speed manual gearbox</strong> for direct, engaging control.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>The upright naked riding position is comfortable for both commuting and longer day rides.</li>
<li>At 133kg it is light and easy to manage in traffic and when parking.</li>
<li>The front disc / rear drum brake setup means leaving a bit more following distance at speed.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Do I need manual gearbox experience for the Byson?</strong> Yes, it has a standard 5-speed manual transmission and clutch.</li>
<li><strong>Is the Byson 150 good for city riding?</strong> Yes, its light weight and manageable power make it easy to handle in traffic.</li>
<li><strong>Is the Byson suitable for longer trips?</strong> Yes, its fuel tank and upright seating position work well for full-day rides.</li>
</ul>
$html$, 'written in-house from family_specs (zigwheels.co.id)'
FROM product_families WHERE brand='Yamaha' AND model_name='Byson 150'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Yamaha MT-25 is a naked sportbike built around a punchy 249cc twin &mdash; aggressive styling and real performance, for riders who want a sportier daily ride without a full fairing.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>249cc parallel-twin engine with 35.5 hp</strong>: strong performance for a naked bike in this class.</li>
<li><strong>179 km/h top speed</strong>: genuine sportbike performance.</li>
<li><strong>Aggressive MT-series styling</strong>: sharp, modern naked-bike looks.</li>
<li><strong>14-litre fuel tank</strong>: solid range for day trips and touring.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>The twin-cylinder engine likes to be worked through the mid-to-high revs &mdash; short-shifting leaves performance on the table.</li>
<li>Manual gearbox and real power mean prior riding experience is strongly recommended.</li>
<li>Naked bikes have less wind protection than faired sportbikes &mdash; a good jacket helps on longer, faster rides.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the MT-25 suitable for beginners?</strong> It has real power and a manual gearbox, so prior experience on a geared motorcycle is recommended.</li>
<li><strong>How does the MT-25 compare to a fully-faired sportbike?</strong> It shares the same punchy twin-cylinder engine as its faired siblings but with an upright naked riding position instead of a sport crouch.</li>
<li><strong>Is the MT-25 good for day trips around Bali?</strong> Yes, its fuel range and performance make it a strong choice for spirited day rides.</li>
</ul>
$html$, 'written in-house from family_specs (ultimatespecs.com, zigwheels.my, yamaha-motor.co.id)'
FROM product_families WHERE brand='Yamaha' AND model_name='MT-25'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Yamaha Nmax 155 is one of the most popular scooters in Southeast Asia &mdash; a comfortable, efficient CVT scooter that balances a sporty look with genuinely easy everyday riding.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>Smooth 155cc CVT engine</strong>: efficient and easy to ride for riders of any experience level.</li>
<li><strong>Comfortable 765mm seat height</strong>: works well for most rider heights.</li>
<li><strong>Light 127kg kerb weight</strong>: easy to manage in traffic and parking.</li>
<li><strong>Sporty, modern styling</strong> with a comfortable, upright seating position.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>The fully automatic CVT makes the Nmax a great choice if you have never ridden a manual motorcycle before.</li>
<li>Use the under-seat storage for your helmet and daily essentials when you park up.</li>
<li>The 7.1-litre tank is best topped up regularly on longer day trips around the island.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the Nmax a good choice for beginners?</strong> Yes &mdash; it is fully automatic and one of the easiest scooters in our fleet to ride confidently from day one.</li>
<li><strong>Is the Nmax comfortable for two riders?</strong> Yes, it is rated for two seats and rides comfortably two-up around town and on day trips.</li>
<li><strong>How far can I go on one tank?</strong> The 7.1-litre tank suits daily city riding well; plan a refuel stop on longer trips.</li>
</ul>
$html$, 'written in-house from family_specs (ultimatespecs.com, yamaha-motor.co.id)'
FROM product_families WHERE brand='Yamaha' AND model_name='Nmax'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Yamaha Scorpio 225 is a classic naked single &mdash; a simple, torquey air-cooled engine in an upright, no-nonsense roadster, for riders who like straightforward mechanical character.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>225cc air-cooled single-cylinder engine with 18 hp</strong>: simple, torquey, and easy to understand.</li>
<li><strong>Classic naked-bike styling</strong>: an upright, no-nonsense roadster look.</li>
<li><strong>12-litre fuel tank</strong>: solid range for day trips.</li>
<li><strong>5-speed manual gearbox</strong> for direct, engaging control.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>The air-cooled single has a distinct, torquey character &mdash; let the engine breathe rather than revving hard.</li>
<li>At 770mm the seat height suits most rider heights comfortably.</li>
<li>Use the strong low-end torque rather than chasing high revs.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Do I need manual gearbox experience for the Scorpio 225?</strong> Yes, it has a full manual transmission and clutch.</li>
<li><strong>Is the Scorpio 225 good for relaxed riding?</strong> Yes, its torquey single-cylinder engine and upright position suit a relaxed pace well.</li>
<li><strong>Is this a good bike for day trips?</strong> Yes, its fuel range and comfortable seating make it well suited to full-day rides.</li>
</ul>
$html$, 'written in-house from family_specs (en.wikipedia.org)'
FROM product_families WHERE brand='Yamaha' AND model_name='Scorpio 225'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Yamaha XSR is a neo-classic roadster &mdash; modern 155cc underpinnings dressed in retro styling, for riders who want a distinctive look without giving up everyday reliability.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>155cc engine with 18.4 hp</strong>: lively performance for its class.</li>
<li><strong>Neo-classic styling</strong>: retro looks with modern reliability and EFI.</li>
<li><strong>10-litre fuel tank</strong>: solid range for day trips.</li>
<li><strong>Manual gearbox</strong> for an engaging, direct riding feel.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>At 810mm the seat height suits taller riders particularly well.</li>
<li>The retro-styled suspension is tuned for a comfortable ride on typical road surfaces rather than aggressive cornering.</li>
<li>Use the mid-range torque for smooth, confident city riding.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the XSR good for taller riders?</strong> Yes, its 810mm seat height suits taller riders comfortably.</li>
<li><strong>Do I need manual gearbox experience?</strong> Yes, it has a standard manual transmission and clutch.</li>
<li><strong>Is the XSR a good choice for a distinctive-looking rental?</strong> Yes &mdash; its neo-classic styling stands out from typical scooters and naked bikes alike.</li>
</ul>
$html$, 'written in-house from family_specs (oto.com, bikedekho.com)'
FROM product_families WHERE brand='Yamaha' AND model_name='XSR'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Yamaha Xmax 250 is a premium maxi-scooter &mdash; more power and presence than a typical scooter, with genuine touring comfort and a fully automatic CVT for effortless riding.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>250cc CVT engine with 22.5 hp</strong>: noticeably stronger than typical 150-160cc scooters.</li>
<li><strong>Premium maxi-scooter comfort</strong>: confident, planted highway manners.</li>
<li><strong>13-litre fuel tank</strong>: strong range for touring and day trips.</li>
<li><strong>Comfortable 795mm seat height</strong> with generous legroom.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>The Xmax's extra power makes it a comfortable choice for two-up riding and longer day trips.</li>
<li>Fully automatic CVT means no clutch or gear changes &mdash; easy to ride even without manual gearbox experience.</li>
<li>Use the extra under-seat storage for a full-face helmet and daily essentials.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the Xmax a good upgrade from a standard scooter?</strong> Yes &mdash; it offers noticeably more power and comfort than a typical 150-160cc scooter, while remaining fully automatic.</li>
<li><strong>Is the Xmax good for two riders?</strong> Yes, its size and power make it comfortable for two-up riding.</li>
<li><strong>Is the Xmax suitable for longer rentals?</strong> Yes, its comfort and fuel range make it a popular choice for week- and month-long rentals.</li>
</ul>
$html$, 'written in-house from family_specs (yamahamotorsports.com, zigwheels.my)'
FROM product_families WHERE brand='Yamaha' AND model_name='Xmax'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;

INSERT INTO family_content_translations (family_id, language_code, content_html, source)
SELECT id, 'en', $html$
<p>The Frankenstein is a one-off custom build in our fleet &mdash; assembled and finished in-house rather than sold as a factory model, styled in the spirit of adventure-touring bikes like the Royal Enfield Himalayan.</p>
<h3>Key Benefits</h3>
<ul>
<li><strong>One-of-a-kind</strong>: this exact bike does not exist anywhere else in our fleet or on a showroom floor.</li>
<li><strong>Adventure-touring inspired build</strong>: upright seating and rugged looks in the same spirit as the Himalayan.</li>
<li><strong>Individually maintained</strong>: as a unique build, our team gives it particular attention between rentals.</li>
</ul>
<h3>Expert Tips</h3>
<ul>
<li>Because it is a custom build, ask our team about the maintenance history when you pick it up.</li>
<li>Treat it with the same care as a standard adventure bike &mdash; it does not have official factory service documentation.</li>
<li>If you would prefer a bike with published factory specifications, our Honda ADV or Kawasaki Versys-X 250 are close alternatives.</li>
</ul>
<h3>FAQ</h3>
<ul>
<li><strong>Is the Frankenstein a factory model?</strong> No &mdash; it is a one-off custom build assembled in-house, not a standard production motorcycle.</li>
<li><strong>Are official specifications available for the Frankenstein?</strong> Not in the same way as our other bikes; it is inspired by adventure-touring bikes like the Royal Enfield Himalayan but built individually.</li>
<li><strong>Can I see photos before booking?</strong> Yes, check the photo gallery on this page &mdash; what you see is the actual bike you will receive.</li>
</ul>
$html$, 'written in-house, one-off custom build, no factory specs (Royal Enfield Himalayan cited as design reference only per owner)'
FROM product_families WHERE brand='Frankenstein'
ON CONFLICT (family_id, language_code) DO UPDATE SET content_html = EXCLUDED.content_html, source = EXCLUDED.source;
