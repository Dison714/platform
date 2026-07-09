-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 22_family_specs.sql
-- Model-level specs per Family (specs identical across colors of a family).
-- Labels/units are rendered from frontend i18n by spec_key — no separate
-- translations table. getProduct resolves specs via the product's family_id.
-- =====================================================================

CREATE TABLE family_specs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id   UUID NOT NULL REFERENCES product_families(id) ON DELETE CASCADE,
    spec_key    TEXT NOT NULL,          -- engine_cc, top_speed, fuel_consumption, fuel_tank,
                                        -- transmission, seat_height, power, seats, curb_weight
    spec_value  TEXT NOT NULL,          -- language-neutral: number as text ("160") OR code ("cvt"/"manual");
                                        -- units are NOT stored here (they come from i18n)
    source      TEXT,                   -- open source used, for audit (e.g. "yamaha-motor.co.id")
    sort_order  SMALLINT NOT NULL DEFAULT 0,
    UNIQUE (family_id, spec_key)
);
COMMENT ON TABLE family_specs IS 'Model-level specs per Family from open manufacturer data. spec_value language-neutral (number or code); labels/units from frontend i18n by spec_key. source = open source used.';
