-- Дисклеймер про доставку (053/054/055) на деле не говорил "цена
-- ориентировочная, точную стоимость уточняйте у оператора" — только про
-- редкий случай удалённых адресов. Замечено Дмитрием при ревью перед
-- коммитом (2026-09-10). Переписан явно на всех 9 страницах.
UPDATE location_page_translations lpt
SET delivery_disclaimer = 'Delivery prices above are indicative for typical addresses in ' || dn.name || ' — always confirm your exact price and delivery time with our team on WhatsApp before booking. Very remote or hard-to-find locations may need manager approval.'
FROM location_pages lp
JOIN (VALUES
    ('canggu', 'Canggu'), ('seminyak', 'Seminyak'), ('ubud', 'Ubud'), ('uluwatu', 'Uluwatu'),
    ('jimbaran', 'Jimbaran'), ('sanur', 'Sanur'), ('kuta', 'Kuta'), ('nusa-dua', 'Nusa Dua'), ('denpasar', 'Denpasar')
) AS dn(slug, name) ON dn.slug = lp.slug
WHERE lpt.location_page_id = lp.id AND lpt.language_code = 'en';
