-- =====================================================================
-- 070_replacement_groups_motorcycles.sql
-- Мотоциклетные Replacement Groups (источник: MDB_Agent_Knowledge_Base.docx
-- §5.2). Тот же паттерн, что 029/035 (CLAUDE.md §3.1): replacement_group_id
-- независим от vehicle_categories/каталожных фильтров, задел под будущую
-- Replacement Matrix, сегодня замена всё ещё ручное решение менеджера.
-- =====================================================================

INSERT INTO replacement_groups (code, name) VALUES
    ('touring_replacement_pool', 'Эндуро/туристы — пул замены'),
    ('naked_classic_replacement_pool', 'Классики/ретро — пул замены'),
    ('sport_replacement_pool', 'Спортбайки — пул замены');

UPDATE product_families SET replacement_group_id =
    (SELECT id FROM replacement_groups WHERE code = 'touring_replacement_pool')
    WHERE code IN ('suzuki_vstrom250', 'kawasaki_versys');

UPDATE product_families SET replacement_group_id =
    (SELECT id FROM replacement_groups WHERE code = 'naked_classic_replacement_pool')
    WHERE code IN ('yamaha_xsr', 'tvs_ronin225');

UPDATE product_families SET replacement_group_id =
    (SELECT id FROM replacement_groups WHERE code = 'sport_replacement_pool')
    WHERE code IN ('kawasaki_zx25r', 'honda_cbr250rr');

-- yamaha_mt25 группы не получает — по документу это одна модель, разные
-- цвета, не межмодельная замена (то же обоснование, что у Vario после 035:
-- взаимозаменяемость внутри одного family не требует записи в
-- replacement_groups).
