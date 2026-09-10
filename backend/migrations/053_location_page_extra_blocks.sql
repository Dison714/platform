-- Расширение блочной структуры location_page_translations (051) под
-- 9-районный релиз: добавлены Popular Locations (заменяет неиспользуемый
-- Photos — ТЗ "Фото не добавлять нигде") и дисклеймер про ориентировочные
-- цены доставки в блоке Delivery. photos_note оставлен как есть (не
-- используется фронтендом, данных не теряем, лишняя ALTER TABLE DROP —
-- не в скоупе задачи).
ALTER TABLE location_page_translations
    ADD COLUMN popular_locations JSONB,       -- [{name, href}] — реальные места из отчёта по чату, без фото
    ADD COLUMN delivery_disclaimer TEXT;       -- пояснение про ориентировочность цены для удалённых точек (manager_approval, см. delivery_fee_rules)
