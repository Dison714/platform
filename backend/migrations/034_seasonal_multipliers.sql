-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 34_seasonal_multipliers.sql
-- Сезонный мультипликатор цены (решение владельца, Блок 2). Применяется
-- в computeBaseRental() по ДАТЕ НАЧАЛА аренды (start_date), конец не
-- учитывается. NULL pricing_rule_set_id = глобальный период (для всех
-- rule_set'ов), не-NULL — только для конкретного rule_set. Округление
-- итоговой цены — CEIL(price×multiplier / 50000) × 50000, всегда вверх
-- (backend/src/services/pricing.js, roundUpTo50k()).
-- =====================================================================

CREATE TABLE seasonal_multipliers (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date_from           DATE NOT NULL,
    date_to             DATE NOT NULL,
    multiplier          NUMERIC(6,3) NOT NULL CHECK (multiplier > 0),
    pricing_rule_set_id UUID REFERENCES pricing_rule_sets(id) ON DELETE CASCADE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (date_to >= date_from)
);
COMMENT ON TABLE seasonal_multipliers IS 'Сезонный мультипликатор цены аренды. pricing_rule_set_id NULL = глобальный период (действует для всех rule_set), не-NULL = только для этого rule_set. Пересечения периодов запрещены триггером check_seasonal_multiplier_overlap (глобальные между собой, глобальный с любым scoped, scoped внутри одного rule_set между собой) — scoped-периоды РАЗНЫХ rule_set пересекаться могут, т.к. никогда не применяются к одному и тому же booking одновременно.';

CREATE TRIGGER trg_seasonal_multipliers_upd
    BEFORE UPDATE ON seasonal_multipliers
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Асимметричная проверка пересечений — обычный EXCLUDE-constraint не умеет
-- трактовать NULL-scope как "конфликтует со всем", поэтому триггер, не GiST.
CREATE OR REPLACE FUNCTION check_seasonal_multiplier_overlap() RETURNS TRIGGER AS $$
DECLARE
    conflict_count INT;
BEGIN
    IF NEW.pricing_rule_set_id IS NULL THEN
        SELECT count(*) INTO conflict_count
        FROM seasonal_multipliers
        WHERE id <> NEW.id
          AND daterange(date_from, date_to, '[]') && daterange(NEW.date_from, NEW.date_to, '[]');
    ELSE
        SELECT count(*) INTO conflict_count
        FROM seasonal_multipliers
        WHERE id <> NEW.id
          AND (pricing_rule_set_id IS NULL OR pricing_rule_set_id = NEW.pricing_rule_set_id)
          AND daterange(date_from, date_to, '[]') && daterange(NEW.date_from, NEW.date_to, '[]');
    END IF;

    IF conflict_count > 0 THEN
        RAISE EXCEPTION 'seasonal_multipliers: период % — % пересекается с существующим периодом в той же области действия', NEW.date_from, NEW.date_to;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_seasonal_multiplier_overlap
    BEFORE INSERT OR UPDATE ON seasonal_multipliers
    FOR EACH ROW EXECUTE FUNCTION check_seasonal_multiplier_overlap();
