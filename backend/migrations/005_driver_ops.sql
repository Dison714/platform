-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 05_driver_ops.sql
-- Driver Profiles · Balances · Task Types · Driver Tasks · Maintenance
-- =====================================================================
-- driver_tasks — единая таблица под все типы задач (решение D4).
-- ТЗ п.8: Driver = роль, не сущность. Профиль — расширение users.
-- =====================================================================

CREATE TABLE driver_profiles (
    user_id              UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    zone                 TEXT,                   -- ubud_sanur, bukit, warehouse_standby
    is_lead              BOOLEAN NOT NULL DEFAULT FALSE,
    standby_from         TIME,                   -- Saiban с 14:00
    default_day_off      SMALLINT,               -- 0=Sun..6=Sat
    balance_idr          BIGINT NOT NULL DEFAULT 0,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE
);
COMMENT ON TABLE driver_profiles IS 'ТЗ п.8: Driver = роль. Состав: Hari (lead, Ubud/Sanur, вых. вс), Stefan (Букит), Saiban (склад, с 14:00). is_lead → может пополнять балансы других.';

CREATE TABLE driver_balance_movements (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount_idr      BIGINT NOT NULL,         -- + пополнение, - трата
    reason          TEXT NOT NULL,           -- fuel, wash, spare_part, topup
    driver_task_id  UUID,                    -- FK ниже
    performed_by    UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE driver_balance_movements IS 'Формат базы знаний: "353k - 205k Sisa: 147k". Пополняет владелец или Hari (lead).';

CREATE TABLE task_types (
    code                  TEXT PRIMARY KEY,
    name_id               TEXT NOT NULL,          -- индонезийское название
    name_ru               TEXT NOT NULL,
    needs_fleet_item      BOOLEAN NOT NULL DEFAULT TRUE,
    needs_customer        BOOLEAN NOT NULL DEFAULT FALSE,
    default_photos        TEXT[] NOT NULL DEFAULT '{}',
    is_active             BOOLEAN NOT NULL DEFAULT TRUE
);
COMMENT ON TABLE task_types IS 'Lookup для driver_tasks. Каждый код = шаблон базы знаний раздел 7. default_photos — основа динамического списка обязательных фото.';

INSERT INTO task_types (code, name_id, name_ru, needs_customer, needs_fleet_item, default_photos) VALUES
    ('pengiriman','Pengiriman','Доставка байка клиенту', TRUE, TRUE, '{"odometer","equipment_set"}'),
    ('menjemput','Menjemput','Забор байка от клиента', TRUE, TRUE, '{"odometer","damage_check"}'),
    ('tukar_motor','Tukar motor','Обмен байка', TRUE, TRUE, '{"odometer_old","odometer_new"}'),
    ('bergerak_motor','Bergerak motor','Перегон байка без клиента', FALSE, TRUE, '{}'),
    ('servis_bengkel_biasa','Servis bengkel biasa','ТО в мастерской (AG)', FALSE, TRUE, '{"work_photos"}'),
    ('servis_dealer_resmi','Servis dealer resmi','ТО у дилера', FALSE, TRUE, '{"work_photos"}'),
    ('servis_sendiri','Servis sendiri','Самостоятельное ТО', FALSE, TRUE, '{}'),
    ('servis_kanza','Servis Kanza','Правка рамы/руля/кузова', FALSE, TRUE, '{}'),
    ('bawa_motor_ke_rudy','Bawa motor ke Rudy','Покраска/пластик', FALSE, TRUE, '{}'),
    ('pasang_shad','Pasang kotak SHAD','Установка SHAD', FALSE, TRUE, '{}'),
    ('copot_shad','Copot kotak SHAD','Снятие SHAD', FALSE, TRUE, '{}'),
    ('ambil_uang','Ambil uang','Забрать деньги', TRUE, FALSE, '{}'),
    ('bawa_helm','Bawa helm','Доставка шлема', TRUE, TRUE, '{"helmet_number"}'),
    ('tukar_helm','Tukar helm','Замена шлема', TRUE, TRUE, '{"helmet_number_old","helmet_number_new"}'),
    ('bawa_kunci','Bawa kunci','Доставка ключа', TRUE, TRUE, '{}'),
    ('potong_odo','Potong odo','Сброс одометра (внутр.)', FALSE, TRUE, '{"odometer"}'),
    ('ganti_ban','Ganti ban','Замена шин', FALSE, TRUE, '{"odometer"}'),
    ('ganti_oli','Ganti oli','Замена масла', FALSE, TRUE, '{"odometer"}'),
    ('ganti_baterai','Ganti baterai','Замена аккумулятора', FALSE, TRUE, '{}'),
    ('pasang_gps','Pasang GPS','Установка GPS', FALSE, TRUE, '{"gps_device_number"}'),
    ('ganti_sim','Ganti SIM','Замена SIM GPS', FALSE, TRUE, '{}'),
    ('lepas_gps','Lepas GPS','Снятие GPS', FALSE, TRUE, '{}'),
    ('servis_besar','Servis besar','Комплексное ТО (чеклист)', FALSE, TRUE, '{"checklist_photos"}'),
    ('cuci_helm','Cuci helm','Мойка шлемов', FALSE, FALSE, '{"before","after"}');

CREATE TABLE driver_tasks (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id          UUID NOT NULL REFERENCES companies(id),
    type_code           TEXT NOT NULL REFERENCES task_types(code),
    seq_label           TEXT,                   -- '1','2+','3-' (база знаний: нумерация)
    booking_id          UUID REFERENCES bookings(id),
    rental_id           UUID REFERENCES rentals(id),
    fleet_item_id       UUID REFERENCES fleet_items(id),
    driver_id           UUID REFERENCES users(id),
    priority            task_priority NOT NULL DEFAULT 'planned',
    status              task_status NOT NULL DEFAULT 'pending',
    scheduled_date      DATE NOT NULL,
    scheduled_time      TIME,
    time_code           TEXT,                   -- KP, PAGI, LGNG, SKRG
    customer_contact    TEXT,                   -- whatsapp/telegram/key_in_drawer/...
    location_lat        NUMERIC(10,7),
    location_lng        NUMERIC(10,7),
    location_text       TEXT,
    payload             JSONB NOT NULL DEFAULT '{}',  -- peralatan, kerja, спец. поля типа
    comment             TEXT,
    photos              JSONB NOT NULL DEFAULT '[]',
    source              record_source NOT NULL,
    created_by          UUID REFERENCES users(id),
    acknowledged_at     TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE driver_tasks IS 'Решение D4: универсальная таблица под все типы. payload — поле Peralatan и спец. поля типа: {"peralatan":["helmet_ff","raincoat"],"kerja":"ganti oli"}. booking_id/rental_id nullable — операционные задачи (ТО, покраска, склад) без привязки к аренде.';
COMMENT ON COLUMN driver_tasks.seq_label IS 'Формат "N-"/"N+" для задач, вставленных после публикации списка (база знаний: нумерация и порядок).';

CREATE INDEX idx_tasks_driver_date ON driver_tasks(driver_id, scheduled_date);
CREATE INDEX idx_tasks_status ON driver_tasks(status);
CREATE INDEX idx_tasks_priority ON driver_tasks(priority) WHERE status NOT IN ('completed','cancelled');
CREATE INDEX idx_tasks_fleet ON driver_tasks(fleet_item_id) WHERE fleet_item_id IS NOT NULL;

ALTER TABLE stock_movements
    ADD CONSTRAINT fk_stock_task FOREIGN KEY (driver_task_id) REFERENCES driver_tasks(id);
ALTER TABLE driver_balance_movements
    ADD CONSTRAINT fk_balance_task FOREIGN KEY (driver_task_id) REFERENCES driver_tasks(id);

-- ---------------------------------------------------------------------
-- MAINTENANCE LOGS — питает триггеры ТО по odo/сроку (база знаний п.6)
-- ---------------------------------------------------------------------
CREATE TABLE maintenance_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fleet_item_id   UUID NOT NULL REFERENCES fleet_items(id) ON DELETE CASCADE,
    driver_task_id  UUID REFERENCES driver_tasks(id),
    service_date    DATE NOT NULL,
    odo_km          INTEGER NOT NULL,
    service_type    TEXT NOT NULL,          -- oil_change, cvt_clean, servis_besar, brake_pads
    checklist       JSONB,                  -- servis_besar: {"ganti_oli":true,"cek_v_belt":false,...}
    notes           TEXT,
    performed_by    UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE maintenance_logs IS 'База знаний п.6: масло и CVT обязательны всегда, свечи только если барахлит. Используется для расчёта следующего ТО из current_odo_km + пороги (system_config).';

CREATE INDEX idx_maint_fleet ON maintenance_logs(fleet_item_id, service_date DESC);
