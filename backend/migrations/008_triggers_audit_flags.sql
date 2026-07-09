-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 08_triggers_audit_flags.sql
-- updated_at triggers · Audit Log · Feature Flags
-- =====================================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_upd        BEFORE UPDATE ON users        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_products_upd     BEFORE UPDATE ON products     FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_fleet_upd        BEFORE UPDATE ON fleet_items  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_customers_upd    BEFORE UPDATE ON customers    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_bookings_upd     BEFORE UPDATE ON bookings     FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_rentals_upd      BEFORE UPDATE ON rentals      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_tasks_upd        BEFORE UPDATE ON driver_tasks FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------
-- AUDIT LOG (ТЗ п.15.5)
-- ---------------------------------------------------------------------
CREATE TABLE audit_log (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name  TEXT NOT NULL,
    record_id   UUID NOT NULL,
    field_name  TEXT NOT NULL,
    old_value   TEXT,
    new_value   TEXT,
    changed_by  UUID REFERENCES users(id),
    changed_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE audit_log IS 'ТЗ п.15.5: кто/когда/что изменил (цена, страховка, SEO, перевод). Заполняется приложением при изменении конфигурационных таблиц, не триггерами БД — чтобы не шуметь на системных обновлениях.';

CREATE INDEX idx_audit_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_time ON audit_log(changed_at);

-- ---------------------------------------------------------------------
-- FEATURE FLAGS (ТЗ п.15.4) — поэтапный запуск (п.19.3)
-- ---------------------------------------------------------------------
CREATE TABLE feature_flags (
    company_id  UUID NOT NULL REFERENCES companies(id),
    code        TEXT NOT NULL,
    is_enabled  BOOLEAN NOT NULL DEFAULT FALSE,
    description TEXT,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (company_id, code)
);
COMMENT ON TABLE feature_flags IS 'ТЗ п.15.4: вкл/выкл модулей без удаления кода. Сид отражает план п.19.3. Per-company — разные страны на разных этапах.';

INSERT INTO feature_flags (company_id, code, is_enabled, description)
SELECT id, f.code, f.enabled, f.descr
FROM companies, (VALUES
    ('online_payments', FALSE, 'v1.0 — бронь это заявка, без онлайн-оплаты (п.19.1)'),
    ('insurance_on_website', FALSE, 'Страховка на сайте — после первых месяцев (п.19.4)'),
    ('equipment_on_website', FALSE, 'Доп. оборудование на сайте'),
    ('reviews', FALSE, 'Отзывы клиентов'),
    ('cars_vertical', FALSE, 'Аренда авто (п.13)'),
    ('boats_vertical', FALSE, 'Аренда лодок'),
    ('tours_vertical', FALSE, 'Экскурсии'),
    ('whatsapp_ai', FALSE, 'AI Customer Manager в WhatsApp'),
    ('telegram_ai', TRUE, 'Текущие Telegram-боты уже активны'),
    ('crm_module', FALSE, 'CRM как модуль Platform (v1.1)'),
    ('warehouse_module', FALSE, 'Warehouse как модуль (v1.2)'),
    ('finance_module', FALSE, 'Finance как модуль (v1.3)'),
    ('ai_customer_manager', FALSE, 'AI Customer Manager поверх Platform (v1.4)'),
    ('ai_operations_manager', FALSE, 'AI Operations Manager (v1.5)')
) AS f(code, enabled, descr);
