-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 036_delivery_fee_rules_no_overlap.sql
-- Configuration First (/internal/delivery) — защита от пересекающихся
-- тиров доставки внутри одного rule_set. byDuration() (services/delivery.js)
-- берёт первый подходящий тир по ORDER BY min_days LIMIT 1 — пересечение
-- тихо выбрало бы неверный тир для части дней, без ошибки.
--
-- В отличие от seasonal_multipliers (нужен был кастомный триггер из-за
-- асимметричной NULL-as-wildcard логики global/scoped) — здесь обычный
-- EXCLUDE USING gist: диапазоны целых чисел внутри одного rule_set, без
-- особых случаев. btree_gist уже подключён в 001 (используется для
-- rentals.no_overlapping_active_rentals, тот же паттерн).
-- =====================================================================

-- int4range с '[]' канонизируется в '[)' прибавлением 1 к верхней границе —
-- INT4_MAX (2147483647) в этот момент переполнился бы. 1000000 (≈2740 лет
-- аренды) — практическая "бесконечность" с запасом, без риска overflow.
ALTER TABLE delivery_fee_rules
    ADD CONSTRAINT no_overlapping_delivery_tiers
    EXCLUDE USING gist (
        rule_set_id WITH =,
        int4range(min_days, COALESCE(max_days, 1000000), '[]') WITH &&
    );
