-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 29_replacement_groups.sql
-- Разделяет два понятия, которые до миграции 028 случайно совпадали в
-- vehicle_categories: (а) UI-фильтр каталога, (б) группа взаимозаменяемости
-- байков для будущей Replacement Matrix (CLAUDE.md §3.1, ещё не закодирована).
-- После 028 (разбивка scooter_160 на 5 фильтров по модели) совпадение
-- пропало бы молча — вместо этого группа замены выносится в отдельный
-- справочник, независимый от фильтров каталога.
-- =====================================================================

-- Lookup-таблица (тот же паттерн, что vehicle_categories: SMALLSERIAL id,
-- TEXT code, CLAUDE.md §6).
CREATE TABLE replacement_groups (
    id   SMALLSERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL
);
COMMENT ON TABLE replacement_groups IS 'Функциональные классы байков для замены при поломке/недоступности (CLAUDE.md §3.1, Replacement Matrix). Независимо от vehicle_categories (тот — чисто UI-фильтр каталога). Не у каждой product_family обязана быть группа — NULL значит "группа замены пока не определена".';

INSERT INTO replacement_groups (code, name) VALUES
    ('scooter_econ_160', 'Эконом-скутеры 160cc');

ALTER TABLE product_families
    ADD COLUMN replacement_group_id SMALLINT REFERENCES replacement_groups(id);

-- Перенос данных 1:1: те же 4 модели, что раньше составляли scooter_160
-- (до миграции 028), — Honda ADV/PCX/Vario, Yamaha Nmax. Xmax сознательно
-- НЕ включён — до 028 он был отдельно в maxi_scooter (другой класс, не
-- эконом-скутер), группа замены для него пока не определена (NULL).
UPDATE product_families
SET replacement_group_id = (SELECT id FROM replacement_groups WHERE code = 'scooter_econ_160')
WHERE code IN ('honda_adv', 'honda_pcx', 'honda_vario', 'yamaha_nmax');
