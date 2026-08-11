-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA
-- 048_blog_seed.sql
-- Блог: сид 5 категорий + 29 статей (en, status=draft, content/excerpt/SEO
-- пустые — только title/slug). Контент и переводы на остальные языки —
-- отдельный следующий этап (см. CLAUDE.md §4.15 задачу), не в этой миграции.
--
-- Ключ связи — slug, не id (тот же паттерн, что 039_product_category_
-- translations_seed.sql): article_categories.slug/articles.slug
-- детерминированы этим сидом и стабильны на любой БД, засеянной из него.
--
-- related_product_family_id проставлен там, где нашлось совпадение по
-- модели в product_families (honda_adv, yamaha_nmax, honda_vario,
-- yamaha_xsr). Honda Scoopy и Honda Forza в текущем флоте отсутствуют —
-- NULL, не ошибка (см. чат сессии 2026-08-11). Compare-статья Forza vs
-- XMAX и статья про кастомные байки тоже NULL — это не гайд по одной
-- модели (articles.related_product_family_id — для one-model гайдов,
-- ТЗ п.4.15), даже для XMAX половины сравнения.
-- =====================================================================

-- ---- article_categories ----
INSERT INTO article_categories (slug, display_order) VALUES
    ('deposit-safety',   1),
    ('legal',            2),
    ('bike-models',      3),
    ('routes',           4),
    ('digital-nomads',   5);

-- ---- article_category_translations (en) ----
INSERT INTO article_category_translations (category_id, language_code, name, slug)
SELECT ac.id, 'en', v.name, ac.slug
FROM article_categories ac JOIN (VALUES
    ('deposit-safety', 'Deposit & Safety'),
    ('legal',          'Legal Guide'),
    ('bike-models',    'Bike Model Guides'),
    ('routes',         'Routes & Itineraries'),
    ('digital-nomads', 'Long-Term & Digital Nomads')
) AS v(category_slug, name) ON v.category_slug = ac.slug;

-- ---- articles ----
-- v(article_slug, category_slug, is_pillar, family_code)
INSERT INTO articles (slug, category_id, is_pillar, related_product_family_id, status)
SELECT v.article_slug, ac.id, v.is_pillar, pf.id, 'draft'
FROM (VALUES
    -- deposit-safety
    ('how-the-deposit-works-when-renting-a-bike-in-bali',        'deposit-safety', TRUE,  NULL::text),
    ('what-to-do-if-the-bike-gets-scratched-or-damaged',         'deposit-safety', FALSE, NULL),
    ('deposit-scams-how-to-spot-them',                           'deposit-safety', FALSE, NULL),
    ('bike-insurance-whats-covered-and-whats-not',                'deposit-safety', FALSE, NULL),
    ('what-to-do-after-an-accident-on-a-rented-bike',             'deposit-safety', FALSE, NULL),
    -- legal
    ('bike-rental-laws-in-bali-2026',                             'legal', TRUE,  NULL),
    ('governors-ban-on-tourist-bike-rentals-what-it-actually-means', 'legal', FALSE, NULL),
    ('international-driving-permit-idp-for-bali-how-to-get-one', 'legal', FALSE, NULL),
    ('police-checkpoints-what-to-expect-and-how-to-respond',     'legal', FALSE, NULL),
    ('traffic-fines-in-bali-types-and-amounts',                  'legal', FALSE, NULL),
    ('renting-a-bike-without-a-license-risks-and-the-law',       'legal', FALSE, NULL),
    -- bike-models
    ('which-bike-should-you-rent-in-bali-model-guide',           'bike-models', TRUE,  NULL),
    ('honda-adv-review',                                         'bike-models', FALSE, 'honda_adv'),
    ('yamaha-nmax-review',                                       'bike-models', FALSE, 'yamaha_nmax'),
    ('honda-vario-review',                                       'bike-models', FALSE, 'honda_vario'),
    ('honda-scoopy-review-best-for-beginners',                   'bike-models', FALSE, NULL),
    ('yamaha-xsr-155-review-retro-style',                        'bike-models', FALSE, 'yamaha_xsr'),
    ('honda-forza-vs-yamaha-xmax-maxi-scooter-comparison',       'bike-models', FALSE, NULL),
    ('custom-bikes-in-bali-what-they-are-and-are-they-worth-it', 'bike-models', FALSE, NULL),
    -- routes
    ('best-bike-routes-in-bali-curated-list',                    'routes', TRUE,  NULL),
    ('ubud-route-rice-terraces-and-temples',                     'routes', FALSE, NULL),
    ('nusa-penida-on-a-bike-one-day-route',                      'routes', FALSE, NULL),
    ('uluwatu-coastal-route',                                    'routes', FALSE, NULL),
    ('canggu-seminyak-kuta-city-route',                          'routes', FALSE, NULL),
    ('sanur-easy-route-for-beginners',                           'routes', FALSE, NULL),
    -- digital-nomads
    ('long-term-bike-rental-in-bali-for-digital-nomads',         'digital-nomads', TRUE,  NULL),
    ('cost-of-living-in-bali-with-a-bike-budget-breakdown',      'digital-nomads', FALSE, NULL),
    ('monthly-vs-yearly-bike-rental-which-is-cheaper',           'digital-nomads', FALSE, NULL),
    ('which-bali-area-fits-your-lifestyle-and-what-bike-to-pair-with-it', 'digital-nomads', FALSE, NULL)
) AS v(article_slug, category_slug, is_pillar, family_code)
JOIN article_categories ac ON ac.slug = v.category_slug
LEFT JOIN product_families pf ON pf.code = v.family_code;

-- ---- article_translations (en) — title + slug only, rest NULL (draft) ----
INSERT INTO article_translations (article_id, language_code, title, slug)
SELECT a.id, 'en', v.title, a.slug
FROM articles a JOIN (VALUES
    ('how-the-deposit-works-when-renting-a-bike-in-bali',        'How the Deposit Works When Renting a Bike in Bali: Full Guide'),
    ('what-to-do-if-the-bike-gets-scratched-or-damaged',         'What to Do If the Bike Gets Scratched or Damaged'),
    ('deposit-scams-how-to-spot-them',                           'Deposit Scams: How to Spot Them'),
    ('bike-insurance-whats-covered-and-whats-not',                'Bike Insurance: What''s Covered and What''s Not'),
    ('what-to-do-after-an-accident-on-a-rented-bike',             'What to Do After an Accident on a Rented Bike'),
    ('bike-rental-laws-in-bali-2026',                             'Bike Rental Laws in Bali 2026: What You Need to Know'),
    ('governors-ban-on-tourist-bike-rentals-what-it-actually-means', 'The Governor''s Ban on Tourist Bike Rentals: What It Actually Means'),
    ('international-driving-permit-idp-for-bali-how-to-get-one', 'International Driving Permit (IDP) for Bali: How to Get One'),
    ('police-checkpoints-what-to-expect-and-how-to-respond',     'Police Checkpoints: What to Expect and How to Respond'),
    ('traffic-fines-in-bali-types-and-amounts',                  'Traffic Fines in Bali: Types and Amounts'),
    ('renting-a-bike-without-a-license-risks-and-the-law',       'Renting a Bike Without a License: Risks and the Law'),
    ('which-bike-should-you-rent-in-bali-model-guide',           'Which Bike Should You Rent in Bali: Model Guide'),
    ('honda-adv-review',                                         'Honda ADV Review'),
    ('yamaha-nmax-review',                                       'Yamaha NMax Review'),
    ('honda-vario-review',                                       'Honda Vario Review'),
    ('honda-scoopy-review-best-for-beginners',                   'Honda Scoopy Review: Best for Beginners'),
    ('yamaha-xsr-155-review-retro-style',                        'Yamaha XSR 155 Review: Retro Style'),
    ('honda-forza-vs-yamaha-xmax-maxi-scooter-comparison',       'Honda Forza vs Yamaha XMAX: Maxi-Scooter Comparison'),
    ('custom-bikes-in-bali-what-they-are-and-are-they-worth-it', 'Custom Bikes in Bali: What They Are and Are They Worth It'),
    ('best-bike-routes-in-bali-curated-list',                    'Best Bike Routes in Bali: Curated List'),
    ('ubud-route-rice-terraces-and-temples',                     'Ubud Route: Rice Terraces and Temples'),
    ('nusa-penida-on-a-bike-one-day-route',                      'Nusa Penida on a Bike: One-Day Route'),
    ('uluwatu-coastal-route',                                    'Uluwatu Coastal Route'),
    ('canggu-seminyak-kuta-city-route',                          'Canggu-Seminyak-Kuta City Route'),
    ('sanur-easy-route-for-beginners',                           'Sanur: Easy Route for Beginners'),
    ('long-term-bike-rental-in-bali-for-digital-nomads',         'Long-Term Bike Rental in Bali for Digital Nomads'),
    ('cost-of-living-in-bali-with-a-bike-budget-breakdown',      'Cost of Living in Bali with a Bike: Budget Breakdown'),
    ('monthly-vs-yearly-bike-rental-which-is-cheaper',           'Monthly vs Yearly Bike Rental: Which Is Cheaper'),
    ('which-bali-area-fits-your-lifestyle-and-what-bike-to-pair-with-it', 'Which Bali Area Fits Your Lifestyle (and What Bike to Pair With It)')
) AS v(article_slug, title) ON v.article_slug = a.slug;
