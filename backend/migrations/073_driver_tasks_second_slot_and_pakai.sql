-- =====================================================================
-- 073_driver_tasks_second_slot_and_pakai.sql
-- Раздел 5 (B+C), 2026-09-27 — задел под сценарий "два водителя на одну
-- задачу" (driverTaskTemplates.js уже предупреждал об этом при вводе
-- Pakai в v2, CRM v1.1 сессия 2026-09-26): второй слот водителя + Pakai
-- (байк, на котором ВОДИТЕЛЬ едет выполнять задачу и возвращается — не
-- тот же байк, что Motor, который сдаётся клиенту).
-- =====================================================================

ALTER TABLE driver_tasks
    ADD COLUMN assigned_driver_slot_2 SMALLINT REFERENCES drivers(driver_slot);
COMMENT ON COLUMN driver_tasks.assigned_driver_slot_2 IS 'Второй водитель на той же задаче (сценарий "везём/забираем на двух байках", напр. один сдаёт клиенту Motor, другой едет с ним на Pakai и оба возвращаются). Независим от assigned_driver_slot — тот же ростер drivers(driver_slot), nullable (штатно пусто для одиночного водителя).';

ALTER TABLE driver_tasks
    ADD COLUMN pakai_fleet_item_id UUID REFERENCES fleet_items(id);
COMMENT ON COLUMN driver_tasks.pakai_fleet_item_id IS 'Pakai — байк, на котором водитель едет выполнять задачу и возвращается (НЕ Motor — тот сдаётся/забирается у клиента). Взаимоисключим с pakai_text (форма — либо select по fleet_items, либо свободный текст, не оба сразу).';

ALTER TABLE driver_tasks
    ADD COLUMN pakai_text TEXT;
COMMENT ON COLUMN driver_tasks.pakai_text IS 'Pakai свободным текстом — когда байк не из парка (напр. личный транспорт водителя) или конкретный fleet_item ещё не определён. Взаимоисключим с pakai_fleet_item_id.';
