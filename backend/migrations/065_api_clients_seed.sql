-- =====================================================================
-- 065_api_clients_seed.sql
-- API layer v1.0 (сессия 2026-09-25/26): подготовка identity для будущих
-- API-потребителей (CLAUDE.md §3.3, решение D3).
--
-- ВАЖНО, найдено при применении этой миграции (не по памяти из прошлой
-- сессии): `api_clients` и `users.is_service_account` уже существуют с
-- 001_foundation.sql — это часть исходной схемы ТЗ, а не новая
-- сущность. Предыдущий аудит ("api_clients не реализован") проверял
-- только backend/src (grep не нашёл потребителей кода), но не саму
-- схему — таблица физически была всегда, просто ничего её не
-- заполняло и не читало. Эта миграция НЕ создаёт таблицу, только
-- сеет строки в уже существующие `users`/`api_clients` по
-- задокументированному контракту (users.is_service_account=TRUE →
-- api_clients.user_id, см. COMMENT ON COLUMN users.is_service_account
-- в 001_foundation.sql).
--
-- 'website' (текущий единственный реальный потребитель POST
-- /api/v1/bookings) НЕ заводится как строка — он и есть отсутствие
-- X-Api-Key, ему не нужен ни users, ни api_clients ряд.
--
-- Остальные три — плейсхолдеры под будущую миграцию ботов на API,
-- ключи сгенерированы, но НИКОМУ не выданы/не используются до
-- отдельной задачи в репозиториях самих ботов (вне скоупа этого
-- чанка). api_key_hash = sha256(key) — машинный секрет фиксированной
-- энтропии, не пользовательский пароль, соль не нужна.
-- scopes оставлены '{}' (default) — ролевая модель/scopes не
-- проектируются в этом чанке (явно вне скоупа).
-- Идемпотентность: ON CONFLICT недоступен (users.full_name не
-- unique) — миграция сама по себе применяется ровно один раз через
-- schema_migrations, повторный ручной запуск не предполагается (как и
-- везде в проекте).
--
-- bookings.api_client_id — queryable-идентичность конкретного вызывающего
-- api_clients (не только грубая категория через record_source enum,
-- см. services/booking.js) для будущей CRM-отчётности "откуда узнал".
-- NULL для source='website' (нет api_clients-ряда на этот случай by
-- design). Ни одна колонка в схеме на это раньше не ссылалась (grep по
-- всем *.sql на REFERENCES api_clients — 0 совпадений до этой строки).
-- =====================================================================

WITH new_users AS (
    INSERT INTO users (company_id, full_name, is_service_account, is_active)
    SELECT c.id, v.full_name, TRUE, TRUE
    FROM companies c, (VALUES
        ('MDB Drivers Bot'),
        ('MDB Tugas Approver Bot'),
        ('AI Sales Manager (mdb_drver_noapi_bot)')
    ) AS v(full_name)
    RETURNING id, full_name
)
INSERT INTO api_clients (user_id, name, api_key_hash, is_active)
SELECT nu.id, x.client_name, x.api_key_hash, TRUE
FROM new_users nu
JOIN (VALUES
    ('MDB Drivers Bot', 'mdb_drivers_bot', '0ec951e4967aef54f9a9c1dad06f8e7f02efa8b6ef9daf55afc9000050b56588'),
    ('MDB Tugas Approver Bot', 'mdb_tugas_approver_bot', '628ff800cbe4aa010240f40d767b947f204110d8dd3748aeb7e27f2e703e1286'),
    ('AI Sales Manager (mdb_drver_noapi_bot)', 'mdb_drver_noapi_bot', '9989a2c71a2ef74092ed15b95a5b17aa9ec53996d5b035777d435698d4bf4349')
) AS x(full_name, client_name, api_key_hash) ON x.full_name = nu.full_name;

ALTER TABLE bookings ADD COLUMN api_client_id UUID REFERENCES api_clients(id);
