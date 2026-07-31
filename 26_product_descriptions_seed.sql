-- =====================================================================
-- 26_product_descriptions_seed.sql — data seed, not a schema migration.
-- Short product-card description (product_translations.description, 'en')
-- for all bookable products — reuses the same Family-level intro sentence
-- already written for family_content_translations (25b), applied to every
-- color variant of that family, per CLAUDE.md pattern (Family = model,
-- Product = model+color; description is about the model, not the paint).
-- title is set to the base name (brand+model+color) that displayName()
-- already falls back to when no translation exists — so no visible name
-- changes, only description gets filled in. Idempotent (safe to re-run).
-- =====================================================================

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Honda ADV 160 is Bali's favourite adventure-style scooter — tall ground clearance and rugged looks on a genuinely easy CVT scooter platform, at home on the island's mixed road surfaces and steep hillside villa driveways.$d$
)) AS v(description)
WHERE pf.brand='Honda' AND pf.model_name='ADV' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Honda CB150X pairs a manual-transmission 150cc engine with trail-inspired styling — for riders who want a bit more engagement than a scooter, wrapped in a bike that shrugs off Bali's uneven backroads.$d$
)) AS v(description)
WHERE pf.brand='Honda' AND pf.model_name='CB150X' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Honda CBR250RR is a full-fledged sportbike — a 250cc parallel-twin with real power, a proper fairing, and the riding position to match, for guests who want performance, not just transportation.$d$
)) AS v(description)
WHERE pf.brand='Honda' AND pf.model_name='CBR250RR' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Honda PCX is Honda's flagship premium scooter — the same smooth 160cc CVT engine as the ADV, in a lower, sleeker package built for effortless city and coastal riding.$d$
)) AS v(description)
WHERE pf.brand='Honda' AND pf.model_name='PCX' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Honda Vario 160 is a light, everyday scooter — the practical choice for guests who just want simple, efficient transport around Bali without extra size or weight.$d$
)) AS v(description)
WHERE pf.brand='Honda' AND pf.model_name='Vario' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Kawasaki D-Tracker 250 is a supermoto-styled single — a tall, light, manual-geared bike built around a punchy 250cc engine, for riders who want a sharper, sportier feel than a typical trail bike.$d$
)) AS v(description)
WHERE pf.brand='Kawasaki' AND pf.model_name='D-Tracker 250' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Kawasaki Versys-X 250 is a proper adventure-touring twin — comfortable upright ergonomics, a big fuel tank, and enough power for confident two-up touring around the island.$d$
)) AS v(description)
WHERE pf.brand='Kawasaki' AND pf.model_name='Versys' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Kawasaki ZX-25R is the most serious performance machine in our fleet — a genuine inline-four 250cc sportbike with a screaming top end and a 190 km/h top speed, built for riders who want the real supersport experience.$d$
)) AS v(description)
WHERE pf.brand='Kawasaki' AND pf.model_name='ZX-25R' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Keeway Road Falcon 250 brings big-cruiser looks to a 250cc platform — a parallel-twin engine, a very low seat, and classic cruiser styling for relaxed, easy-going rides.$d$
)) AS v(description)
WHERE pf.brand='Keeway' AND pf.model_name='Road Falcon 250' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Morbidelli C252V is a retro-styled cafe-racer cruiser — a 249cc single with classic lines, for guests who want a distinctive, characterful ride rather than a mainstream commuter bike.$d$
)) AS v(description)
WHERE pf.brand='Morbidelli' AND pf.model_name='C252V' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Suzuki V-Strom 250 is built for riders who want adventure, efficiency, and comfort in one package — a lightweight touring bike that stays composed on Bali's busy streets and scenic coastal routes alike.$d$
)) AS v(description)
WHERE pf.brand='Suzuki' AND pf.model_name='V-Strom 250' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The TVS Ronin 225 is a neo-retro roadster — modern underpinnings with classic naked-bike styling, for riders who want character without giving up everyday usability.$d$
)) AS v(description)
WHERE pf.brand='TVS' AND pf.model_name='Ronin 225' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Yamaha Byson 150 is a muscular naked streetfighter — a manual 150cc bike with bold styling, for riders who want a bit more attitude than a standard commuter.$d$
)) AS v(description)
WHERE pf.brand='Yamaha' AND pf.model_name='Byson 150' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Yamaha MT-25 is a naked sportbike built around a punchy 249cc twin — aggressive styling and real performance, for riders who want a sportier daily ride without a full fairing.$d$
)) AS v(description)
WHERE pf.brand='Yamaha' AND pf.model_name='MT-25' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Yamaha Nmax 155 is one of the most popular scooters in Southeast Asia — a comfortable, efficient CVT scooter that balances a sporty look with genuinely easy everyday riding.$d$
)) AS v(description)
WHERE pf.brand='Yamaha' AND pf.model_name='Nmax' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Yamaha Scorpio 225 is a classic naked single — a simple, torquey air-cooled engine in an upright, no-nonsense roadster, for riders who like straightforward mechanical character.$d$
)) AS v(description)
WHERE pf.brand='Yamaha' AND pf.model_name='Scorpio 225' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Yamaha XSR is a neo-classic roadster — modern 155cc underpinnings dressed in retro styling, for riders who want a distinctive look without giving up everyday reliability.$d$
)) AS v(description)
WHERE pf.brand='Yamaha' AND pf.model_name='XSR' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || pf.model_name || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Yamaha Xmax 250 is a premium maxi-scooter — more power and presence than a typical scooter, with genuine touring comfort and a fully automatic CVT for effortless riding.$d$
)) AS v(description)
WHERE pf.brand='Yamaha' AND pf.model_name='Xmax' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;

INSERT INTO product_translations (product_id, language_code, title, description)
SELECT p.id, 'en',
       trim(regexp_replace(pf.brand || ' ' || p.color_name, '\s+', ' ', 'g')),
       v.description
FROM products p
JOIN product_families pf ON pf.id = p.family_id
CROSS JOIN LATERAL (VALUES (
$d$The Frankenstein is a one-off custom build in our fleet — assembled and finished in-house rather than sold as a factory model, styled in the spirit of adventure-touring bikes like the Royal Enfield Himalayan.$d$
)) AS v(description)
WHERE pf.brand='Frankenstein' AND p.is_active = TRUE
ON CONFLICT (product_id, language_code) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description;
