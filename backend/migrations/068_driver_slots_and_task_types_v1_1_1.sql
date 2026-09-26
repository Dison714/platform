-- =====================================================================
-- 068_driver_slots_and_task_types_v1_1_1.sql
-- CRM v1.1 — первый функциональный срез Booking→Rental (сессия
-- 2026-09-26, план согласован с Дмитрием в чате). Три независимые вещи:
--   1. Позиционные слоты водителей (drivers) — назначение по слоту 1/2/3,
--      не по конкретному users.id (решение Дмитрия: смена состава не
--      требует переписывать историю назначений, слот просто получает
--      нового человека).
--   2. bookings.assigned_driver_slot / driver_tasks.assigned_driver_slot —
--      колонки под назначение по слоту, независимые от существующих
--      legacy-полей bookings.assigned_driver / driver_tasks.driver_id
--      (UUID → users) — те создавались под другую, ещё не реализованную
--      модель (Driver = роль поверх users, ТЗ п.8) и не трогаются.
--   3. task_types: код menjemput_helm (уже внесён Дмитрием в рабочий
--      документ таксономии разделом А — здесь только код/схема).
-- Плюс мелкий комментарий-фикс driver_profiles (Stefan больше не
-- работает) — по прецеденту 066_is_service_account_comment_fix.sql.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. drivers — позиционные слоты. Без company_id: это lookup-таблица
-- того же рода, что task_types/event_types (CLAUDE.md §6 — lookup-
-- таблицы без UUID/company_id). Ровно 3 слота сегодня (CHECK), под
-- будущее расширение состава — не диапазон, а явный список значений,
-- расширяется отдельной миграцией при необходимости (сейчас не нужно).
-- ---------------------------------------------------------------------
CREATE TABLE drivers (
    driver_slot   SMALLINT PRIMARY KEY CHECK (driver_slot IN (1, 2, 3)),
    name          TEXT NOT NULL,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE
);
COMMENT ON TABLE drivers IS 'Позиционные слоты водителей для назначения в bookings/driver_tasks (решение Дмитрия, сессия 2026-09-26): назначаем слот, не человека — смена состава (напр. замена водителя в слоте) не переписывает историю задач задним числом, это осознанный трейд-офф. Не путать с driver_profiles/users (ТЗ п.8, Driver = роль) — та модель не реализована в коде и не используется этим срезом.';

INSERT INTO drivers (driver_slot, name, is_active) VALUES
    (1, 'Hari', TRUE),
    (2, 'Bayu', TRUE),
    (3, 'Saiban', TRUE);

-- ---------------------------------------------------------------------
-- 2. Колонки под назначение по слоту.
-- ---------------------------------------------------------------------
ALTER TABLE bookings
    ADD COLUMN assigned_driver_slot SMALLINT REFERENCES drivers(driver_slot);
COMMENT ON COLUMN bookings.assigned_driver_slot IS 'Назначение водителя на бронь по слоту (шаг confirmed→driver_assigned в booking_status_history, CRM v1.1). Независимо от legacy bookings.assigned_driver (UUID→users, из нереализованной модели ТЗ п.8) — то поле не используется.';

ALTER TABLE driver_tasks
    ADD COLUMN assigned_driver_slot SMALLINT REFERENCES drivers(driver_slot);
COMMENT ON COLUMN driver_tasks.assigned_driver_slot IS 'Назначение водителя на конкретную задачу по слоту (CRM v1.1). Независимо от legacy driver_tasks.driver_id (UUID→users) — то поле не используется.';

-- ---------------------------------------------------------------------
-- 3. task_types: menjemput_helm — забрать шлем у клиента БЕЗ замены
-- (отличается от tukar_helm, где происходит замена на другой шлем).
-- ---------------------------------------------------------------------
INSERT INTO task_types (code, name_id, name_ru, needs_customer, needs_fleet_item, default_photos) VALUES
    ('menjemput_helm', 'Menjemput helm', 'Забрать шлем у клиента (без замены)', TRUE, TRUE, '{"helmet_number"}');

-- ---------------------------------------------------------------------
-- 4. driver_profiles — комментарий устарел (Stefan больше не работает,
-- подтверждено Дмитрием в этой же сессии). Актуальный ростер для
-- назначения в bookings/driver_tasks — таблица drivers выше, не эта.
-- Сама driver_profiles/users-модель (ТЗ п.8) не реализована в коде и
-- этим срезом не трогается — правим только текст комментария, по
-- прецеденту 066_is_service_account_comment_fix.sql.
-- ---------------------------------------------------------------------
COMMENT ON TABLE driver_profiles IS 'ТЗ п.8: Driver = роль. Состав менялся (Stefan больше не работает, зафиксировано 2026-09-26) — эта таблица под нереализованную пока модель Driver=роль поверх users, в коде не используется. Актуальный ростер для назначения в bookings.assigned_driver_slot / driver_tasks.assigned_driver_slot (CRM v1.1) — таблица drivers (driver_slot), не эта.';
