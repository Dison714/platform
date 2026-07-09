-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 10_equipment_mounting.sql
-- Крепления (Bracket/Baseplate/Backrest) — третий вид equipment_units
-- =====================================================================

-- В отличие от шлемов, крепление стоит на байке полупостоянно (не "катается"
-- с каждой арендой), поэтому нужен статус "установлено" с привязкой к
-- конкретному fleet_item, а не только available/lost.
ALTER TYPE equipment_unit_status ADD VALUE 'installed';

-- Крепление подходит только к своей модели байка — отдельный тип на модель,
-- по аналогии с отдельными кодами шлемов (helmet_kyt_hf/ff). Цены/списание по
-- этому оборудованию в CRM/ТЗ не зафиксированы — оставлены NULL/0, не угадываем тариф.
INSERT INTO equipment_types (code, name, tracks_units, charge_basis, rental_price_idr, deposit_deduction_idr, deduction_note) VALUES
    ('bracket_nmax', 'Bracket Nmax', TRUE, 'per_rental', 0, NULL, NULL),
    ('bracket_adv160', 'Bracket ADV160', TRUE, 'per_rental', 0, NULL, NULL),
    ('bracket_xmax', 'Bracket Xmax', TRUE, 'per_rental', 0, NULL, NULL),
    ('bracket_mt25', 'Bracket MT25', TRUE, 'per_rental', 0, NULL, NULL),
    ('bracket_xsr', 'Bracket XSR', TRUE, 'per_rental', 0, NULL, NULL),
    ('bracket_pcx160', 'Bracket PCX160', TRUE, 'per_rental', 0, NULL, NULL),
    ('baseplate', 'Baseplate', TRUE, 'per_rental', 0, NULL, NULL),
    ('backrest', 'Backrest', TRUE, 'per_rental', 0, NULL, NULL);
