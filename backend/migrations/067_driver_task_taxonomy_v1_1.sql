-- =====================================================================
-- 067_driver_task_taxonomy_v1_1.sql
-- CRM v1.1 — реконсиляция task_types с реальной таксономией задач
-- водителей (аудит Telegram-архива, решения зафиксированы 2026-09-26,
-- см. CLAUDE.md §3.6 и таксономический документ Дмитрия) + инвестор/
-- сплит + цена деталей склада + цепочка реплаев задач.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. task_types — новые коды таксономии (005_driver_ops.sql, 24 строки,
-- реконсилирован 26.09.2026). Существующие коды НЕ переиспользуются под
-- новый смысл — только добавление и явное переименование.
--
-- Сверено по факту (не по памяти) перед фиксацией состава: из пяти
-- кодов, поднятых ревью как "новые" (menjemput_motor_dari_rudy/_kanza/
-- _dealer_resmi, copot_shad, potong_odo) — ТРИ (rudy/kanza/dealer_resmi)
-- отсутствуют среди исходных 24 строк 005_driver_ops.sql и добавлены
-- ниже как новые INSERT. ДВА (copot_shad, potong_odo) уже существуют в
-- исходных 24 строках 005_driver_ops.sql:
--   ('copot_shad','Copot kotak SHAD','Снятие SHAD', FALSE, TRUE, '{}')
--   ('potong_odo','Potong odo','Сброс одометра (внутр.)', FALSE, TRUE, '{"odometer"}')
-- Оба активны (is_active по умолчанию TRUE, ни разу не деактивированы) и
-- семантически совпадают 1:1 с тем, что просит таксономия (copot_shad —
-- уже буквально "снятие SHAD", закрывающая пара к pasang_shad; potong_odo
-- — уже буквально "скрутка одометра"). Повторный INSERT с тем же code
-- упадёт на PRIMARY KEY (task_types.code) — технически невозможен и не
-- нужен: код+смысл уже на месте с первого дня схемы. Если у продукта
-- есть в виду ДРУГАЯ, отличная от текущей запись под тем же именем —
-- это отдельный код с другим именем, не переиспользование существующего
-- (см. правило выше "существующие коды не переиспользовать"); нужна явная
-- формулировка, чем новая сущность отличается от уже существующей.
-- ---------------------------------------------------------------------
INSERT INTO task_types (code, name_id, name_ru, needs_customer, needs_fleet_item, default_photos) VALUES
    -- STNK-логистика (раздел Д таксономии): реплай-пара, вторая — реплай
    -- на первую (replies_to_task_id). Продление STNK — доп.расход,
    -- сумма приходит позже от Wayan — финансовая проводка отложена.
    ('bawa_stnk_ke_wayan','Bawa STNK ke Wayan','Отвезти STNK Ваяну на продление', FALSE, TRUE, '{}'),
    ('ambil_stnk_dari_wayan','Ambil STNK dari Wayan','Забрать STNK у Ваяна после обработки', FALSE, TRUE, '{}'),
    -- Забор байка после стороннего сервиса — как правило реплай на
    -- соответствующий service_rudy/service_kanza/service_dealer_resmi.
    ('menjemput_motor_dari_rudy','Menjemput motor dari Rudy','Забрать байк у Rudy (после покраски)', FALSE, TRUE, '{}'),
    ('menjemput_motor_dari_kanza','Menjemput motor dari Kanza','Забрать байк у Kanza (после сервиса рамы)', FALSE, TRUE, '{}'),
    ('menjemput_motor_dari_dealer_resmi','Menjemput motor dari dealer resmi','Забрать байк у официального дилера', FALSE, TRUE, '{}'),
    -- Склад/дилер: пополнение расходников, не привязано к конкретному байку.
    ('menjemput_oli_dari_dealer','Menjemput oli dari dealer','Забрать масло у дилера (пополнение склада)', FALSE, FALSE, '{}'),
    ('ambil_barang_dari_dealer_resmi','Ambil barang dari dealer resmi','Забрать товар у офиц. дилера (пополнение склада)', FALSE, FALSE, '{}'),
    ('bertemu_pengiriman_dari_dealer_motor_baru_di_gudang','Bertemu pengiriman motor baru di gudang','Встретить поставку нового байка на складе', FALSE, FALSE, '{}'),
    ('beli_barang_di_pasar_barang_secon','Beli barang di pasar barang secon','Купить товар на барахолке (вторичка)', FALSE, FALSE, '{}'),
    ('pesan_plat_nomor_baru','Pesan plat nomor baru','Заказать новый номерной знак', FALSE, TRUE, '{}'),
    -- Обслуживание, не покрытое существующими типами.
    ('service_bayu_sticker','Service Bayu (sticker)','Оклейка у Bayu (стикеры/наклейки)', FALSE, TRUE, '{}'),
    ('pasang_surf_rack','Pasang surf rack','Установка серф-рэка', FALSE, TRUE, '{}'),
    ('service_gps','Service GPS','Обслуживание GPS', FALSE, TRUE, '{}'),
    -- Подготовка/фото/тест (раздел В таксономии) — вспомогательные события.
    ('mempersiapkan','Mempersiapkan','Подготовка и комплектация перед доставкой', FALSE, TRUE, '{}'),
    ('foto_motor_di_tempat_foto','Foto motor di tempat foto','Фотосъёмка байка в фотостудии', FALSE, TRUE, '{"studio_photos"}'),
    ('foto_dan_video_motor_di_tempat_foto_sendiri','Foto dan video motor di tempat foto sendiri','Фото и видео байка на своей точке съёмки', FALSE, TRUE, '{"studio_photos"}'),
    ('pakai_motor_untuk_cek','Pakai motor untuk cek','Использовать байк для проверки (тест)', FALSE, TRUE, '{}'),
    -- Мульти-байк аренда / доставка с ожиданием фотосессии — доп.действия
    -- в рамках уже открытой аренды, не новый цикл rentals.
    ('menjemput_kunci_dan_foto_motor','Menjemput kunci dan foto motor','Забрать ключ и сфотографировать байк (2-й байк в мульти-байк аренде)', TRUE, TRUE, '{"key_photo","motor_photo"}'),
    ('pengiriman_dan_foto_di_tempat_klien','Pengiriman dan foto di tempat klien','Доставка с ожиданием фотосессии у клиента', TRUE, TRUE, '{"odometer","equipment_set"}');

-- servis_besar привязан именно к bengkel biasa (тот же чек-лист Kerja:,
-- больше пунктов) — код не меняется, уточняется только название.
UPDATE task_types
SET name_id = 'Servis besar bengkel biasa',
    name_ru = 'Комплексное ТО в мастерской (bengkel biasa, расширенный чек-лист)'
WHERE code = 'servis_besar';

-- Работы, ставшие пунктами чек-листа Kerja: внутри разных сервисных
-- типов, а не отдельными задачами (аудит Telegram-архива 26.09.2026).
-- is_active=false, не DELETE — сохраняем историю уже созданных задач.
UPDATE task_types SET is_active = FALSE
WHERE code IN ('ganti_oli','ganti_baterai','ganti_ban','ganti_sim');

-- Отложено, вернёмся позже (решение Дмитрия 26.09.2026).
UPDATE task_types SET is_active = FALSE WHERE code = 'bawa_kunci';

COMMENT ON COLUMN task_types.is_active IS 'FALSE = не предлагать как новый тип задачи (стал пунктом Kerja: внутри другого типа, либо отложен), исторические driver_tasks с этим кодом не трогаются.';

-- ---------------------------------------------------------------------
-- 2. Цепочка реплаев driver_tasks — зеркалит реальную структуру ответов
-- в Telegram (pengiriman→tukar motor→menjemput, bawa→ambil, первый
-- сервис аренды — реплай на pengiriman/tukar motor, повторный — реплай
-- на предыдущий сервис, не на доставку).
-- ---------------------------------------------------------------------
ALTER TABLE driver_tasks ADD COLUMN replies_to_task_id UUID REFERENCES driver_tasks(id);
COMMENT ON COLUMN driver_tasks.replies_to_task_id IS 'Мирроринг Telegram reply_to: вторая задача пары — реплай на первую (bawa_stnk_ke_wayan→ambil_stnk_dari_wayan, pasang_shad→copot_shad, menjemput_motor_dari_rudy→service_rudy и т.п.). Не восстанавливается по времени/fleet_item_id — тянется напрямую из структуры переписки.';

-- ---------------------------------------------------------------------
-- 3. Конвенция ключей driver_tasks.payload (JSONB, схема не меняется) —
-- зафиксировано 26.09.2026, чтобы имена не расходились между сессиями.
-- ---------------------------------------------------------------------
COMMENT ON COLUMN driver_tasks.payload IS 'Конвенция ключей (зафиксировано 26.09.2026): odo (int, универсален — пробег на любом типе задачи, не только ТО); bayar (int IDR, оплата клиентом — пишет строку в events/finance_transactions, event_types.code=''payment_received''); kembali_deposit (int IDR, реально возвращённая сумма депозита — events/finance_transactions, event_types.code=''deposit_returned''); gores_baru/gores_lama (bool, НЕЗАВИСИМЫЕ, могут быть true одновременно); tidak_ada_gores (bool); sudah_cat_mewarnai (bool); motor_aman (bool); sudah_cuci (bool); sudah_ganti_oli (bool, пассивный отчёт водителя, не отдельная задача); sudah_ganti_busa (bool, замена подкладки шлема внутри pengiriman); klien_tes_drive (bool); petrol_kurang/petrol_habis (bool); kampas_rem_status (TEXT-enum ''tebal''|''tipis''|''habis'' — ОДНО поле, не два флага. ''tebal'' = колодки в порядке: пишется факт проверки, никакого действия по списанию/замене НЕ триггерится. ''tipis'' ИЛИ ''habis'' = ОДНО И ТО ЖЕ действие — замена колодок (различается только формулировка степени износа, не поведение): триггерит списание со склада, либо прямую покупку в сервисе если детали нет на складе/водитель не взял с собой (см. правило Ж на warehouse_items.retail_price_idr), и в обоих случаях — запись в finance_transactions); sudah_ganti_grip (bool, замена ручек — то же правило Ж); peralatan_lengkap (bool); kunci_tidak_ada (bool, инцидент — если есть customer_contact, бот просит спросить у клиента, иначе берёт контакт из CRM); stang_bengkok (bool, инцидент — обычно ведёт к service_kanza либо замене руля на месте). Полный контекст — таксономический документ Дмитрия, сессия 2026-09-26.';

-- ---------------------------------------------------------------------
-- 4. Инвестор / сплит — поля на fleet_items, справочник investors.
-- Сплит 0,6/0,4 (инвестор/владелец) — глобальная константа в
-- system_config, НЕ хранится у инвестора (см. ниже).
-- ---------------------------------------------------------------------
CREATE TABLE investors (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id  UUID NOT NULL REFERENCES companies(id),
    name        TEXT NOT NULL,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE
);
COMMENT ON TABLE investors IS 'Инвесторы, финансирующие отдельные fleet_items. Сплит дохода/расходов 0,6/0,4 (инвестор/владелец) — глобальная константа в system_config[''investor_owner_split''], не поле этой таблицы: одна ставка на всех инвесторов сразу, per-investor override не предусмотрен (нет прецедента).';

ALTER TABLE fleet_items
    ADD COLUMN owner_type   TEXT NOT NULL DEFAULT 'company' CHECK (owner_type IN ('company','investor')),
    ADD COLUMN investor_id  UUID REFERENCES investors(id);

ALTER TABLE fleet_items ADD CONSTRAINT chk_fleet_items_investor_consistency CHECK (
    (owner_type = 'company' AND investor_id IS NULL) OR
    (owner_type = 'investor' AND investor_id IS NOT NULL)
);
COMMENT ON COLUMN fleet_items.owner_type IS 'company = обычный байк владельца; investor = профинансирован инвестором (investor_id обязателен). Сплит 0,6/0,4 — system_config[''investor_owner_split''], применяется к пачке (доход + расходы того же цикла из той же карточки байка), не к валовой цене. Исключение: bergerak_motor — доход 100% владельцу, без сплита (см. system_config[''bergerak_motor_fee_idr'']).';

-- ---------------------------------------------------------------------
-- 4b. Backfill fleet_items.owner_type/investor_id из реальных данных CRM
-- (backend/seed-data/crm-source.xlsx, лист Summary, колонка E "Owner" —
-- тот же источник и то же поле, что читает seedFleetAndProducts() в
-- seed-crm.js в fleet_items.owner_name; полные фамилии инвесторов сверены
-- дополнительно по листу "Инвестора" того же файла). Привязка по
-- (company_id, internal_number) — тот же естественный ключ, которым
-- seed-crm.js сопоставляет байк номеру, не по UUID.
--
-- ВАЖНО: источник содержит РОВНО 56 байков — seed-crm.js жёстко режет
-- диапазон `n < 1 || n > 56` при разборе листа "Prices by Day", и это
-- единственный путь, которым строки вообще попадают в fleet_items (ни
-- одна из миграций 001-066 не делает INSERT INTO fleet_items напрямую —
-- проверено grep'ом). Если в реальной БД сейчас больше строк (ревью
-- предполагало 59-60) — это байки, добавленные вручную уже после
-- исходного сида, этот backfill их не видит и не трогает; их нужно
-- поднять и проставить отдельно, не через этот файл.
--
-- Байк №56 ("Я+Свет" в CRM, TVS Ronin 225 ABS Black) — подтверждено
-- Дмитрием (26.09.2026): полностью его, совладельца-инвестора нет.
-- owner_type='company'/investor_id=NULL — уже дефолт колонки от ADD
-- COLUMN выше, отдельного UPDATE не требуется технически, но явный
-- SELECT-контроль ниже по этому конкретному байку — обязателен (см.
-- проверку в сессии), т.к. до подтверждения он был помечен как открытый
-- вопрос, а не как проверенное значение по умолчанию.
--
-- Байки №57-60 — тоже его (company), CRM-строки существуют, но их
-- fleet_items сейчас НЕ заводятся — отдельная задача позже (решение
-- Дмитрия 26.09.2026), не блокер этой миграции.
-- ---------------------------------------------------------------------
INSERT INTO investors (company_id, name)
SELECT c.id, v.name
FROM companies c, (VALUES
    ('Рясный'), ('Алсу'), ('Бунаков'), ('Киреев'),
    ('Мартынов'), ('Сердюков'), ('Штиль'), ('Мехряков')
) AS v(name)
WHERE c.code = 'mdb_bali';

UPDATE fleet_items fi
SET owner_type = 'investor',
    investor_id = inv.id
FROM investors inv
JOIN companies c ON c.id = inv.company_id AND c.code = 'mdb_bali'
WHERE fi.company_id = c.id
  AND (
    (inv.name = 'Рясный'   AND fi.internal_number IN (5,6,19,25,26)) OR
    (inv.name = 'Алсу'     AND fi.internal_number IN (7)) OR
    (inv.name = 'Бунаков'  AND fi.internal_number IN (16,17,18)) OR
    (inv.name = 'Киреев'   AND fi.internal_number IN (20,21)) OR
    (inv.name = 'Мартынов' AND fi.internal_number IN (22)) OR
    (inv.name = 'Сердюков' AND fi.internal_number IN (24)) OR
    (inv.name = 'Штиль'    AND fi.internal_number IN (28,29,30,31,32)) OR
    (inv.name = 'Мехряков' AND fi.internal_number IN (34,35,36,37,38,39,41,42,43,44,46,47,48))
  );

-- ---------------------------------------------------------------------
-- 5. warehouse_items — цены деталей (нужны для правила Ж: списание со
-- склада идёт по РОЗНИЧНОЙ цене, не закупочной).
-- ---------------------------------------------------------------------
ALTER TABLE warehouse_items
    ADD COLUMN cost_price_idr    BIGINT,
    ADD COLUMN retail_price_idr  BIGINT;
COMMENT ON COLUMN warehouse_items.retail_price_idr IS 'Правило Ж (кросс-доменное, зафиксировано 26.09.2026): замена детали (grip, тормозные колодки и т.п.) со склада — списывается 1 единица (stock_movements) + расход в finance_transactions по ЭТОЙ розничной цене (не по cost_price_idr). Если детали на складе нет или водитель не взял её с собой — деталь покупается прямо в сервисе: просто расход в finance_transactions по факту покупки, без складской проводки.';

-- ---------------------------------------------------------------------
-- 6. finance_transactions ↔ driver_tasks — без новой FK. Финансово
-- значимый сигнал на driver_task (bayar, kembali_deposit, замена
-- детали) пишет строку в events, finance_transactions ссылается на неё
-- через уже существующий event_id — тем же паттерном, что
-- bike_delivered/deposit_returned. Единственное недостающее звено —
-- event_type для замены детали (bayar/kembali_deposit уже покрыты
-- существующими payment_received/deposit_returned).
-- ---------------------------------------------------------------------
INSERT INTO event_types (code, description) VALUES
    ('part_replaced','Деталь заменена (со склада по розничной цене или прямой покупкой в сервисе)');

-- ---------------------------------------------------------------------
-- 7. bergerak_motor — тариф по прямой линии между 2 точками (решено
-- 26.09.2026), Configuration First — конфиг, не хардкод.
-- ---------------------------------------------------------------------
INSERT INTO system_config (company_id, key, value, description)
SELECT id, k.key, k.value::jsonb, k.descr
FROM companies, (VALUES
    ('investor_owner_split', '{"investor":0.6,"owner":0.4}', 'Сплит дохода/расходов инвестор/владелец, применяется к пачке того же цикла той же карточки байка. Искл.: bergerak_motor — 100% владельцу.'),
    ('bergerak_motor_fee_idr', '{"threshold_km":15,"under_idr":400000,"from_idr":500000}', 'Тариф перегона байка без клиента (bergerak motor), в рамках текущей аренды. Расстояние — по прямой между 2 ссылками Google Maps клиента, не по маршруту (решено для простоты подсчёта).')
) AS k(key, value, descr);
