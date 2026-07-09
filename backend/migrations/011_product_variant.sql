-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 11_product_variant.sql
-- ABS/CBS и Road Sync — часть идентичности Product (видны клиенту)
-- =====================================================================

-- Пересмотр прежнего решения: ABS/CBS и комплектация Road Sync теперь
-- различают сам Product (отдельная карточка на сайте + своя цена), а не
-- остаются только скрытым полем has_abs на байке. Это нужно, потому что в
-- реальной CRM версии одного цвета имеют РАЗНЫЕ цены (ABS дороже CBS;
-- Road Sync дороже обычной), и слияние их в один product теряло часть цен.
--
-- Family остаётся ОБЩЕЙ (honda_adv, honda_pcx, ...) — variant разделяет
-- только Product, поэтому аналитика "все ADV" по family не ломается.
-- has_abs на fleet_items сохраняется (нужен CRM) и дополнительно определяет
-- привязку байка к ABS- или CBS-продукту.
ALTER TABLE products ADD COLUMN variant TEXT NOT NULL DEFAULT '';
COMMENT ON COLUMN products.variant IS 'Различие внутри одного цвета, влияющее на цену и карточку: ABS/CBS (где обе версии сосуществуют) или Road Sync. Пусто — единственный вариант этого цвета.';

-- Один цвет может теперь иметь несколько продуктов (ABS vs CBS) — старый
-- UNIQUE (family_id, color_name) это запрещал. Расширяем ключ на variant.
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_family_id_color_name_key;
ALTER TABLE products ADD CONSTRAINT products_family_color_variant_key
    UNIQUE (family_id, color_name, variant);
