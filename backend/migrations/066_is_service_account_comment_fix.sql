-- =====================================================================
-- 066_is_service_account_comment_fix.sql
-- COMMENT ON COLUMN users.is_service_account (001_foundation.sql) named
-- 'Bali_Rent_Manager_bot' as one of the three bots this column is for.
-- The actual current roster (confirmed 2026-09-25/26, API layer v1.0
-- session, seeded in 065_api_clients_seed.sql) is mdb_drivers_bot,
-- mdb_tugas_approver_bot, mdb_drver_noapi_bot (AI Sales Manager) —
-- Bali_Rent_Manager_bot does not appear there. Cosmetic (COMMENT, not
-- DDL) — reissued via a new migration rather than editing
-- 001_foundation.sql in place, per project convention (see
-- 033/043/056/059/064 for the same fix-forward pattern on DDL bugs;
-- applied here to a comment for consistency, not because a comment
-- carries schema risk). Idempotent — COMMENT ON COLUMN safely re-runs.
-- =====================================================================

COMMENT ON COLUMN users.is_service_account IS 'TRUE для ботов (mdb_drivers_bot, mdb_tugas_approver_bot, mdb_drver_noapi_bot / AI Sales Manager). Решение D3: боты пишут в Platform DB через API уже на v1.0/v1.1.';
