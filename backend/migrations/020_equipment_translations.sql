-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 20_equipment_translations.sql
-- Переводы названий оборудования — пилот архитектуры переводов на сущность
-- (зеркало product_translations). equipment_types.name остаётся fallback.
-- =====================================================================

CREATE TABLE equipment_type_translations (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    equipment_type_id UUID NOT NULL REFERENCES equipment_types(id) ON DELETE CASCADE,
    language_code     TEXT NOT NULL REFERENCES languages(code),
    name              TEXT NOT NULL,
    UNIQUE (equipment_type_id, language_code)
);
COMMENT ON TABLE equipment_type_translations IS 'Локализованные названия оборудования (ТЗ п.4.9.4: переводы отдельной таблицей на сущность). Резолв: COALESCE(перевод[lang] → перевод[en] → equipment_types.name). Источник имени для сайта (en/ru) и уведомления менеджеру.';

-- en + ru для 6 клиентских допов (финальные имена, согласованы с Дмитрием).
INSERT INTO equipment_type_translations (equipment_type_id, language_code, name)
SELECT et.id, v.lang, v.name
FROM equipment_types et
JOIN (VALUES
    ('helmet_biasa',  'en', 'Basic helmet'),
    ('helmet_biasa',  'ru', 'Обычный шлем'),
    ('helmet_kyt_hf', 'en', 'KYT half-face helmet'),
    ('helmet_kyt_hf', 'ru', 'Шлем KYT (открытый)'),
    ('helmet_kyt_ff', 'en', 'KYT full-face helmet'),
    ('helmet_kyt_ff', 'ru', 'Шлем KYT (закрытый)'),
    ('shad_box',      'en', 'SHAD top box'),
    ('shad_box',      'ru', 'Кофр SHAD'),
    ('phone_holder',  'en', 'Phone holder'),
    ('phone_holder',  'ru', 'Держатель телефона'),
    ('raincoat',      'en', 'Raincoat'),
    ('raincoat',      'ru', 'Дождевик')
) AS v(code, lang, name) ON v.code = et.code;
