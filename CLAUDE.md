# CLAUDE.md — MDB Platform

Единая точка входа для любой сессии разработки в этом репозитории. Прочитай
полностью перед написанием кода. Бизнес-правила здесь зафиксированы намеренно
конкретно — не выводи их заново и не угадывай.

## 0. Контекст

Дмитрий — владелец MDB Motor Rental (PT. Modern Development Bali), аренда
мотоциклов на Бали. Работает через Claude Code без разработчиков, 4-6 ч/день.
Если просьба в моменте противоречит разделу 3 этого файла — не переписывай
файл молча. Спроси прямо: "это меняет принятое решение из CLAUDE.md, уверен?"

## 1. Что такое Platform

Операционная платформа бизнеса, не сайт аренды. Website — один из интерфейсов.
Полная архитектура с первого дня: единая БД под все домены, API-слой,
версионируемые правила. На v1.0 пользователю виден только Website; остальное
существует в БД/API, но скрыто за feature_flags.

**Platform ≠ Bike Bali** (ТЗ п.13.1). Ядро не зависит от Indonesia/мотоциклов.
Поэтому в схеме есть `companies`, и доменные таблицы несут `company_id` —
новая страна/бизнес = строка + данные, без миграции схемы.

## 2. Принципы решений (к каждой задаче)

1. **Конфигурация или функционал?** Решаемо через админку — делаем конфигом
   (Configuration First, ТЗ п.12). Иначе — код.
2. **Три вопроса**: проще клиенту? проще сотрудникам? помогает масштабироваться
   через год? «Нет» на 2 из 3 — не делать.
3. **Не усложнять**: оценивать против простой альтернативы. Один универсальный
   механизм лучше N специализированных — кроме переводов (см. 3.8, осознанное
   исключение).
4. **AI снижает ручную работу**, а не переносит её в красивый UI.

## 3. Зафиксированные решения (НЕ менять без веской причины)

### 3.1 Каталог: Product Family → Product → Fleet Item (ТЗ п.3.1)
- Family — линейка (Honda ADV); Product — модель+цвет (Honda ADV Purple,
  бронирует клиент, своя карточка); Fleet Item — физический байк.
- Каждый цвет — отдельный Product. Family нужен для агрегатной аналитики.
- Замена: тот же Product → другой цвет той же Family → `replacement_matrix`
  (граф, не полная матрица) → ручное решение.
- **`vehicle_categories` vs `replacement_groups` — два разных понятия,
  разнесены намеренно (миграция 028+029):**
  `vehicle_categories` — чисто UI-фильтр каталога (что показывается на
  сайте под каждым фильтром на `/bikes`), не несёт смысловой нагрузки для
  замены байка. Взаимозаменяемость для будущей Replacement Matrix (ещё не
  закодирована, замена сейчас — ручное решение менеджера) — через
  `product_families.replacement_group_id` → `replacement_groups`, независимо
  от того, как модели сгруппированы в фильтрах каталога. До 028 они случайно
  совпадали 1:1 (`scooter_160` = ADV/PCX/Vario/Nmax и как фильтр, и как
  группа замены) — разбивка фильтра каталога на 5 моделей это совпадение
  устранила, поэтому группа замены вынесена в отдельный справочник.
  **Состав группы скорректирован миграцией 035** (Vario → Xmax):
  `scooter_replacement_pool` — Honda ADV, Yamaha Xmax, Honda PCX, Yamaha
  Nmax (ТЗ п.6.5, граф ADV → XMAX → PCX → NMAX; согласуется с правилом
  «Xmax — нормальный апгрейд» из §4 ниже). Vario остаётся в каталоге и в
  своих фильтрах, просто вне группы функциональной взаимозаменяемости.
  Когда будет строиться Replacement Matrix — опираться на
  `replacement_group_id`, не на `vehicle_categories`/фильтры.
- **Product может существовать без Fleet Item** (прецедент — Keeway Road
  Falcon 250, миграция 031): байк в заказе, физически ещё не приехал —
  заводим Family/Product/цену/фото/видео, чтобы карточка была на сайте, но
  Fleet Item (VIN/STNK/номер/пробег) создаётся только когда байк физически
  получен и зарегистрирован. Booking на такой Product создать можно
  (`fleet_item_assigned` наступит позже, вручную, как обычно) —
  `is_bookable` не завязан на наличие хотя бы одного Fleet Item.

### 3.2 Booking ≠ Rental (ТЗ п.6.8)
- Booking — коммерческий процесс до выдачи (статусы created→…→fleet_item_assigned→fulfilled).
- Rental — создаётся ТОЛЬКО при передаче байка; договор/фото/видео/депозит/пробег.
- **Продление = Event** (`rental_extended`), не сущность. `rentals.end_date`
  обновляется событием. Цепочка: Booking → Rental → Events → Return.

### 3.3 Боты пишут в Platform DB через API (решение D3)
- `MDB_drivers_bot`, `MDB_tugas_approver_bot`, `Bali_Rent_Manager_bot`
  мигрируют на запись через `api_clients` уже на v1.0/v1.1.
- `*.source` (record_source) обязателен — различает website/telegram_bot/manual.
- Боты = `users.is_service_account = TRUE`.

### 3.4 Pricing (ТЗ п.6.1.1, решение D1)
- Цена дней 1-30 — прямо из `price_rules`, без интерполяции. >30 дней:
  `price(30)/30 × N` — в коде, не в БД.
- Версионирование через `pricing_rule_sets` (valid_from/valid_to); единый
  rule_set покрывает цены/доставку/страховку согласованно. Booking фиксирует
  `rule_set_id` на момент создания (ТЗ п.6.7).
- Сид цен — лист "Prices by Day" текущей CRM, как есть.

### 3.5 Vehicle legal — поля, без истории (решение D2)
- STNK/BPKB/VIN/GPS/SIM/email — поля в `fleet_items`. Без отдельной таблицы
  документов и истории продлений на v1.0. История при нужде — через `events`.

### 3.6 Driver Tasks — универсальная таблица (решение D4)
- Все типы (полный список в `task_types`) в одной `driver_tasks`, тип = lookup,
  спец-поля (Peralatan, Kerja) в `payload JSONB`. Не плодить таблицы под тип.
- `booking_id`/`rental_id` nullable — операционные задачи (ТО, покраска, склад)
  без привязки к аренде.

### 3.7 Warehouse: два вида учёта (решение D5)
- `warehouse_items` — расходники по остаткам (масло, колодки, шины).
- `equipment_units` — индивидуальные экземпляры (шлемы, SHAD) с номером.
  `equipment_types.tracks_units` определяет нужность индивидуального учёта.

### 3.8 Переводы — отдельная таблица на сущность (ТЗ п.4.9.4)
- `product_translations`, `page_translations`, `article_translations`,
  `faq_translations`, `landing_page_translations`. Не единая универсальная.
  Это явное и осознанное исключение из «один механизм». Новый язык = строки
  в `languages` + переводы, без кода.

## 4. Бизнес-правила (живут в данных/конфиге, не в коде)

- **Депозит**: 1 000 000 IDR при первой аренде; повторная (без проблем) — без
  депозита; 4+ месяцев — в оплату при отсутствии задержек/повреждений.
  `system_config['standard_deposit_idr']`, `customers.rented_before_ok`.
- **Страховка**: theft (400k/мес, bali_only, единый); damage (1500k/4500k ×
  experienced/inexperienced). Категория: возраст<33 ИЛИ малый стаж →
  inexperienced; порог в `system_config`.
- **Доставка**: по СРОКУ аренды (не по расстоянию): <7 дней — 150k; 7-14 дней —
  100k; свыше 14 дней — бесплатно. Тарифы в `delivery_fee_rules` (config,
  версия в rule_set). Режим расчёта — `system_config['delivery_mode']`:
  `by_duration` (сейчас) | `by_distance` (позже, по дорогам через Google
  Distance API). Ссылку на локацию принимаем и храним для водителя
  (`bookings.location_link`), но калькулятор её не парсит и на цену не влияет.
- **ТО по пробегу**: у клиента 2900-3100 км (подменный байк); в парке 2300-2500.
  Масло и CVT — всегда; свечи — если барахлит.
- **Списание депозита**: тариф по оборудованию из `equipment_types`; повреждение
  байка — `individually_assessed=TRUE`, сумма вручную.
- **Замена байка**: даём что просит → аналог той же категории, которого больше
  свободно (баланс парка). Категории — `vehicle_categories`. Xmax — нормальный
  апгрейд, не крайний вариант.
- **AI объясняет замену** (`bookings.replacement_reason`).
- **Все задачи водителям — на индонезийском**, без русского в driver-facing.
- **Цены — формат тысяч** (1000к = 1 000 000 IDR) в UI/текстах для людей.

## 5. Этапы запуска

| Этап | Включается | Условие |
|------|------------|---------|
| v1.0 | Website (каталог, калькулятор, форма-заявка, 7 языков, без онлайн-оплаты) | — |
| v1.1 | CRM рабочая | сайт работает, есть заявки |
| v1.2 | Warehouse | CRM в работе |
| v1.3 | Finance | накоплены операции |
| v1.4 | AI Customer Manager | CRM накопила данные |
| v1.5 | AI Operations Manager | AI Customer Manager стабилен |

Включать модули через `feature_flags`, не комментировать/удалять код. Языки —
по `languages.launch_phase` (Phase 1: en, ru, de, fr, es, it, ja).

## 6. Технические договорённости

- PostgreSQL, snake_case, английские имена (термины — в данных, не в схеме).
- UUID PK везде, кроме lookup-таблиц (`roles`, `task_types`, `event_types`,
  `languages`, `vehicle_categories`, `finance_categories`) — там TEXT/SMALLSERIAL.
- Деньги IDR — BIGINT. Другие валюты — `amount_original` + `exchange_rate`.
- `company_id` на доменных таблицах — multi-company якорь (ТЗ п.13).
- Канал коммуникаций — через `notifications` (Notification Service, ТЗ п.15.3),
  не привязывать Booking к WhatsApp напрямую.
- Медиа: `product_photos.source_url` (Drive) → импорт → `cdn_url` (S3/R2+CDN),
  ТЗ п.15.2.
- БД-гарантия: `rentals.no_overlapping_active_rentals` (exclusion на gist) не
  даёт выдать один байк дважды на пересекающиеся даты — защита от гонок при
  параллельной записи ботом и сайтом.
- `updated_at` — триггер `set_updated_at()`; при новой таблице с этим полем
  дописать триггер в `08_triggers_audit_flags.sql`.
- Файлы пронумерованы по зависимостям (01→08). Новые таблицы — в файл по домену.
- **Configuration First-панель (ТЗ п.12) — `/internal/*`, Basic Auth** (`middleware.js`,
  один общий пароль в env `INTERNAL_ADMIN_PASSWORD`, временная защита на
  период разработки). Разделы: сезонные цены, страховка, доставка, депозит,
  replacement groups — общая навигация в `internal/layout.js`. Не в
  навигации сайта, не в sitemap, `noindex`. Паттерн на раздел: backend
  Router (validate → SQL → явные коды ошибок 409/404) → BFF-прокси
  `/api/admin/<resource>` → клиентский компонент (таблица + форма).
  Подробности каждого раздела — в PROJECT_STATUS.md.
- Деплой MDB Platform (backend + frontend): **Contabo VPS** (`169.58.60.244`,
  IPv6 `2a02:c207:2345:9293::1` — не путать с docker-мостом `fd85:...` на
  том же сервере, это приватный ULA) + Coolify 4.1.2, самохостится там же.
  БД — **self-hosted PostgreSQL 18** внутри Coolify-контейнера (не Supabase —
  зафиксировано фактом разворачивания), контейнер `xw6ykwjdrdmtly2qg8kbd16m`.
  Боты (`MDB_drivers_bot`, `MDB_tugas_approver_bot`, `Bali_Rent_Manager_bot`) —
  отдельно на Render.com, вне периметра деплоя Platform. Без CI/CD на старте:
  каждое изменение схемы проверять руками перед применением к боевой БД с
  данными.
- **DNS cutover на `bikebalirent.com` — ЗАВЕРШЁН (2026-07-30).** NS на
  Cloudflare, A+AAAA → Contabo (DNS only, без proxy), отдельные Let's
  Encrypt сертификаты на apex и `www`, `SITE_ENV=production` включён
  (индексация открыта). WordPress-хостинг на Hostinger физически ещё не
  отключён (решение за Дмитрием). Подробности хода cutover и найденных
  багов — `PROJECT_STATUS.md`, раздел «Сессия 2026-07-30».
- **Почтовых ящиков на домене `bikebalirent.com` никогда не было** (подтверждено
  Дмитрием, 2026-08-01) — контактный email компании живёт на отдельном Gmail
  (`rentbalibike@gmail.com`, `frontend/src/lib/contacts.js`), не на домене. DNS
  домена явно задекларирован как non-mail: null MX (`0 .`), `SPF: v=spf1 -all`,
  `DMARC: p=reject`. Не путать с почтой ботов/уведомлений — она вообще не
  проходит через этот домен. Подробности — `PROJECT_STATUS.md`, раздел
  «Сессия 2026-08-01».
- **Аналитика на сайте** (`frontend/src/app/[locale]/layout.js` +
  `analytics/RouteTracker.js`): Google Ads conversion tag `AW-17065885486`,
  GA4 `G-S6RSSC9KFW`, Яндекс.Метрика `111448067`. Один общий gtag.js/dataLayer
  на Google Ads + GA4 (второй раз библиотеку не грузить). `page_view`/`hit`
  шлются вручную из `RouteTracker` на маунте и на каждой смене маршрута
  (`send_page_view:false` у GA4, `defer:true` у Метрики — иначе задвоение).
  Домен также верифицирован в Яндекс.Вебмастере через DNS TXT
  (`yandex-verification: 4c43981840ad9980` на корне `bikebalirent.com`,
  Cloudflare, DNS only) — не в коде, чисто DNS-запись. Подробности —
  `PROJECT_STATUS.md`, разделы «Сессия 2026-07-30» и «Сессия 2026-08-10».
- **Доступ к проду и R2 — только по ссылке, без секретов в файлах.** SSH на
  сервер: ключ `~/.ssh/mdb_platform_new`, юзер `root`
  (`ssh -i ~/.ssh/mdb_platform_new root@169.58.60.244`) — даёт прямой `docker
  exec`/`docker cp` в Postgres-контейнер, R2-курьер через presigned URL не
  нужен. R2 (Cloudflare, бакет `mdb-platform-media`) — профиль `aws configure
  --profile r2` в `~/.aws/credentials` на машине разработчика (сами ключи —
  Cloudflare dashboard → R2 → Manage API Tokens, никогда не хранить в
  репозитории/CLAUDE.md/PROJECT_STATUS.md). Паттерн разовой синхронизации
  данных на прод: сгенерировать SQL из `backend/scripts/gen_catalog_sync.mjs`
  / `gen_price_sync.mjs` (апсерт по бизнес-ключу, НЕ по `id` — id генерируются
  заново на каждой стороне и никогда не совпадут между dev/prod) → `scp` +
  `docker cp` в контейнер → `psql -v ON_ERROR_STOP=1 -f`.

## 7. Источники для сидирования

- Парк/цены/документы — Google Sheets CRM:
  https://docs.google.com/spreadsheets/d/1IvsVi4ndlQLpeL9L331tgbTqz1HDMM79y--eAAzRAsM
- Операционные правила — База знаний агента-диспетчера (Google Doc).
- Термины/склад/мастерские — MDB Knowledge Base (Drive).
- Клиентские шаблоны (RU/EN) — отдельный Drive-документ.
Сверяться напрямую через Google Drive, не по пересказу.

## 8. Когда сомневаешься

Не выдумывай бизнес-правило. Сначала проверь этот файл и реальные данные в
CRM/Drive. Если правила нет — задай Дмитрию закрытый вопрос (да/нет или выбор),
не открытый «как лучше». Не переспрашивай уже решённое.
