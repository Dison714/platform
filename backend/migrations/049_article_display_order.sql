-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA
-- 049_article_display_order.sql
-- Ручной порядок кластерных статей внутри категории блога (ТЗ п.4.15) —
-- по конвенции article_categories.display_order. Пилар не участвует в
-- нумерации (is_pillar рендерится первым независимо от значения).
-- =====================================================================
-- Причина: ни published_at, ни created_at не годятся как сортировка
-- читательского порядка — все статьи сида (048_blog_seed.sql) получили
-- одинаковый created_at одним bulk INSERT, а published_at проставлялся
-- батчами при публикации категории (тоже одинаковый внутри категории) —
-- проверено вживую: сортировка по обоим полям даёт один и тот же
-- перевёрнутый порядок кластеров, не авторский. Источник истины —
-- нумерация исходников Blog/blog-NN-*.md, заданная при авторинге.
-- =====================================================================

ALTER TABLE articles ADD COLUMN display_order SMALLINT NOT NULL DEFAULT 0;
COMMENT ON COLUMN articles.display_order IS 'Порядок кластерной статьи внутри категории (пилар не участвует, рендерится первым по is_pillar). Источник — авторская нумерация Blog/blog-NN-*.md, не created_at/published_at (одинаковы внутри bulk-операций).';

-- deposit-safety (blog-01 pillar, 02..08 — кластеры)
UPDATE articles SET display_order = 1 WHERE slug = 'what-to-do-if-the-bike-gets-scratched-or-damaged';       -- blog-02
UPDATE articles SET display_order = 2 WHERE slug = 'deposit-scams-how-to-spot-them';                        -- blog-03
UPDATE articles SET display_order = 3 WHERE slug = 'bike-insurance-whats-covered-and-whats-not';            -- blog-04
UPDATE articles SET display_order = 4 WHERE slug = 'what-to-do-after-an-accident-on-a-rented-bike';         -- blog-05
UPDATE articles SET display_order = 5 WHERE slug = 'how-to-brake-safely-on-balis-hills-and-mountain-roads'; -- blog-06
UPDATE articles SET display_order = 6 WHERE slug = 'how-to-start-and-use-your-rental-scooters-smart-key';   -- blog-07
UPDATE articles SET display_order = 7 WHERE slug = 'rental-extras-worth-adding-helmets-and-the-comfort-box';-- blog-08

-- legal (blog-09 pillar, 10..14 — кластеры)
UPDATE articles SET display_order = 1 WHERE slug = 'governors-ban-on-tourist-bike-rentals-what-it-actually-means'; -- blog-10
UPDATE articles SET display_order = 2 WHERE slug = 'international-driving-permit-idp-for-bali-how-to-get-one';     -- blog-11
UPDATE articles SET display_order = 3 WHERE slug = 'police-checkpoints-what-to-expect-and-how-to-respond';         -- blog-12
UPDATE articles SET display_order = 4 WHERE slug = 'traffic-fines-in-bali-types-and-amounts';                      -- blog-13
UPDATE articles SET display_order = 5 WHERE slug = 'renting-a-bike-without-a-license-risks-and-the-law';           -- blog-14
