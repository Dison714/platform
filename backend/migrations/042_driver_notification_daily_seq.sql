-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 042_driver_notification_daily_seq.sql
-- Сквозная нумерация карточек водителю за календарный день (поле "N."
-- в примере заявки водителя). НЕ переиспользует driver_tasks.seq_label —
-- та колонка про другое (пометка "N-"/"N+" для задач, вставленных вручную
-- ПОСЛЕ публикации уже готового списка) и нигде не заполняется кодом.
-- =====================================================================

CREATE TABLE driver_notification_daily_seq (
    company_id  UUID NOT NULL REFERENCES companies(id),
    seq_date    DATE NOT NULL,
    last_seq    INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (company_id, seq_date)
);
COMMENT ON TABLE driver_notification_daily_seq IS 'Счётчик карточек водителю за календарный день (company_id, дата) → следующий номер. Инкремент атомарный (UPSERT) в той же транзакции, что и создание booking. Сбрасывается сам по себе с началом нового seq_date.';
