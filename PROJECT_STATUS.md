# PROJECT_STATUS.md — снимок состояния MDB Platform

_Обновлено: 2026-07-09 (чанк SEO enrichment layer закрыт по Шаг 2 из 3: аудит →
metadataBase/hreflang/canonical/sitemap/robots/OG/JSON-LD Product+LocalBusiness.
Ранее — чанк Photos (648 фото, рендер) и чанк Specs (family_specs). Плюс всё
предыдущее: каркас + каталог + продукт/калькулятор + заявка + контентные страницы;
двуязычный сайт RU+EN; номер заявки BR-00001).
Карта состояния для продолжения в будущих сессиях.
Бизнес-правила и архитектурные решения — в `CLAUDE.md`, дублировать не нужно._

## 1. Что готово

Монорепо: `backend/` (Node.js/Express + PostgreSQL) и `frontend/` (Next.js 14).
Локальная БД `mdb_platform` поднята, все миграции применены (001–027), `/health` отвечает.

- Стек: Express + `pg` (без ORM), кастомный SQL-раннер миграций
  (`src/db/migrate.js`, трекинг в таблице `schema_migrations`).
- `GET /health` — `src/server.js`, проверяет соединение с БД.
- Парсер CRM: `exceljs` (не `xlsx` — у того непропатченные CVE).

### API-эндпоинты (read-only витрина + калькулятор)

| Метод | Путь | Назначение |
|-------|------|------------|
| GET | `/api/products` | каталог (фильтр `?category=`, `?lang=`), превью-цена 30 дней |
| GET | `/api/products/:idOrSlug` | карточка: specs, фото, цены 1–30, страховки |
| GET | `/api/families` | линейки моделей |
| GET | `/api/categories` | категории для чипов фильтра (счётчики через M2M) |
| GET | `/api/equipment` | доп-опции (оборудование + страховка) для чекбоксов на сайте |
| POST | `/api/quote` | **полный калькулятор**: база+доставка+страховка+оборудование+депозит |
| POST | `/api/delivery/quote` | доставка отдельно (подмножество `/api/quote`) |
| POST | `/api/bookings` | **приём заявки**: пересчёт сервером, сохранение, эскалация менеджерам |

**Rental Engine (расчёт стоимости) завершён**: база аренды, доставка (по сроку),
страховка (целыми месяцами), оборудование (per_rental/per_month), депозит
(возвращаемый, отдельно), shadow-сбор статистики по локации.

**Booking v1 завершён**: заявки больше НЕ stateless — сохраняются в `bookings`
(+ снимок расчёта `quote_snapshot`, `total_payable_idr`) и `customers`, с записью
в `booking_status_history`. Цену считает сервер заново (фронту не доверяет).
Эскалация — в **2 Telegram-аккаунта менеджеров** (массив `manager_telegram_chat_ids`:
1593619177 / 7257636963), по одной fire-and-forget записи `notifications` на каждого;
заявка сохраняется даже при недоступности Telegram. Без онлайн-оплаты, подтверждение вручную.
**Реальная доставка проверена** через бот `MDB_tugas_approver_bot` (оба менеджера нажали
Start) — тестовая заявка дала 2/2 `sent`. Токен — в `backend/.env` (`TELEGRAM_BOT_TOKEN`).
**Короткий номер заявки** `BR-00001` (`bookings.booking_number`, миграция 018) —
единый во всех каналах: в уведомлении менеджеру и в подтверждении клиенту
(`/api/bookings` отдаёт `booking_number` + `booking_ref`). Текст уведомления —
построчная разбивка (аренда/доставка/угон/повреждения/оборудование явно), итог
и депозит отдельно, контакты кликабельны (wa.me/t.me/tel), формат тысяч.
**Уведомление целиком на языке заявки** (`bookings.locale`, фронт шлёт `locale`):
шапка/подписи — из серверного словаря `notifyDict` (en+ru), названия
оборудования — из `equipment_type_translations`, плюс строка «🌐 Язык/Language».

### Frontend (Website Phase 1) — `frontend/`

Next.js 14 (App Router, SSR/SSG, mobile-first). Запуск на :3001, backend на :3000.

- **i18n** заложен на 7 языков, **активны `en` + `ru`** (`src/i18n/config.js`, флаг
  `enabled`; русский — приоритетный рынок). Сегмент `[locale]`, middleware-редирект
  на дефолт. Все строки — через словари (`en.json` + `ru.json`, полный перевод).
  Категории фильтра локализованы через `dict.cat` (по `code`, fallback на имя из API).
- **Бренд-тема** (эволюция bikebalirent.com): navy `#1C2C6E` / red `#D52125`,
  шрифты Teko (заголовки) / Poppins (текст) через `next/font`.
- **Каркас:** Header (логотип, меню, рабочий переключатель языка EN|RU —
  меняет сегмент локали в текущем пути, гамбургер), Footer (контакты).
- **Контентные страницы** (SSR, `generateMetadata`): главная `/[locale]`
  (hero, 3 преимущества, превью категорий из `/api/categories`, FAQ-выжимка, CTA),
  About `/[locale]/about` (о компании + блок контактов, якорь `#contact`),
  FAQ `/[locale]/faq` (аккордеон + FAQPage JSON-LD). Хедер Contact → `/about#contact`.
  Решение по ценам: суммы доставки/депозита/страховки на публичных страницах
  НЕ публикуются — словами «зависит от …, see exact price at checkout», точная
  цифра только в калькуляторе. ИСКЛЮЧЕНИЕ — оборудование: FAQ «что входит» прямо
  указывает 2 шлема бесплатно / апгрейд 150k / багажник 200k (фиксированные простые
  цены, по решению владельца). **Факты вшиты (EN+RU):** зона доставки (Букит,
  Чангу, Сесех, Убуд, Денпасар, Санур и рядом; прочее по запросу); документы —
  только фото паспорта; продление — оплата до конца текущего срока; срок аренды
  без мин/макс. Цены доставки/депозита/страховки по-прежнему словами.
  Локализация оборудования ВНЕДРЕНА (пилот архитектуры переводов): названия —
  из `equipment_type_translations` (en/ru), резолв `COALESCE(перевод[lang] →
  перевод[en] → base)`. `/api/equipment?lang=` и `/api/quote` (param `lang`,
  прокидывается через BFF) отдают имя в локали клиента; калькулятор шлёт `lang`.
- **Каталог** `/[locale]/bikes`: SSR-сетка из `/api/products`, фильтр категорий
  (`/api/categories`, `?category=`), lazy-фото + placeholder.
- **Страница продукта** `/[locale]/bikes/[slug]`: SSR (название с variant/комплектацией,
  категория, **hero-фото 1200w + галерея gallery-800w (lazy, cap 8, sort_order ASC)**,
  метки «Rare colour»/принт у заголовка, specs/описание data-driven, JSON-LD Product/Offer,
  `generateMetadata`). `need_photos=TRUE` → placeholder «Photo coming soon» на секцию фото.
- **Фото (чанк Photos):** резолв URL — `frontend/src/lib/photos.js`
  (`resolvePhotoUrl(photo,size)` = `cdn_url ?? ${NEXT_PUBLIC_PHOTO_BASE_URL}/bikes/<slug>/<size>/NN.webp
  ?? source_url`; `pickHero` = is_hero → min sort_order → первое; `galleryPhotos(...,8)`).
  Каталог: hero в thumb-400w. Метки: `archived_color` → «Rare colour / Редкий цвет»
  (деликатный бейдж), `print_name` → «Print: <имя> / Принт: <имя>» у названия;
  `partner_bike` в UI/API НЕ отдаётся (только внутренняя аналитика). Комплектация
  (`equipment_variant`) вшита в имя (`+ Box/+ Bracket/+ Crashbar/+ All boxes/− No boxes`),
  иначе «+box»-Product совпал бы с базовым. `middleware` matcher исключает `.webp` (иначе
  `/bikes/*.webp` редиректился на `/<locale>/…`).
- **Калькулятор** (клиентский, гидратация): собирает срок/страховку/допы → debounce
  POST `/api/quote` → разбивка из ответа сервера. Ноль ценовой логики на клиенте.
  Депозит показан отдельно от «к оплате». Skeleton/error+retry/sticky-summary.
  **Шлемы — правило «2 слота»:** ровно 2 слота, по умолчанию бесплатный шлем (0);
  апгрейд слота на премиум half/full = 150k; потолок 2 (UI + серверный guard
  `computeEquipment` ≤2 шлема группы `helmet`, иначе 400 — ловит и подделанное тело).
  Багажник (`shad_box` 200k, группа topcase) и прочее — обычные чекбоксы, вне лимита.
  Группировка — по `addon_group` из `/api/equipment`, не по именам кодов.
- **Форма заявки** (раскрывается под CTA на той же странице, переиспользует выбор
  калькулятора): имя + ≥1 контакт (валидация), POST `/api/bookings`, экран
  подтверждения с номером заявки `BR-00001` (тот же, что у менеджера). Telegram
  менеджерам шлёт backend — фронт не дублирует.
- **CORS:** клиент ходит на свой origin через BFF-прокси `/api/quote` и `/api/bookings`
  (Next route handlers), адрес backend — серверный env `API_BASE_URL`.

### Применённые миграции (001–027)

| # | Файл | Содержимое |
|---|------|------------|
| 001 | foundation | extensions, enums, auth/roles, languages, system_config, companies |
| 002 | catalog_fleet | Product Family → Product → Fleet Item, replacement matrix, specs, i18n |
| 003 | pricing_warehouse | rule sets (версионирование), price_rules, delivery, insurance, equipment, warehouse |
| 004 | booking_rental | customers, bookings, rentals, events, deposit deductions |
| 005 | driver_ops | driver profiles, balances, task types, driver_tasks, maintenance |
| 006 | finance_notifications | finance journal, exchange rates, notification service |
| 007 | website_content | pages, articles, FAQ, landing pages (+переводы), analytics |
| 008 | triggers_audit_flags | `updated_at`-триггеры, audit log, feature flags |
| 009 | fleet_amendments | `fleet_items.has_abs` (NOT NULL), категория `cruiser` |
| 010 | equipment_mounting | статус `installed` в enum, equipment_types для креплений |
| 011 | product_variant | `products.variant` (ABS/CBS/Road Sync), `UNIQUE (family_id, color_name, variant)` вместо `(family_id, color_name)` |
| 012 | delivery | `bookings.location_link`, таблица `delivery_shadow_stats`, system_config `delivery_mode`/`delivery_base_coords`/`delivery_shadow_km_zones` |
| 013 | deposit_and_config | таблица `deposit_rules` (исключения депозита по family), запись координат базы + км-зон shadow для MDB Bali |
| 014 | booking_intake | `bookings.quote_snapshot` (JSONB) + `total_payable_idr`; config `manager_telegram_chat_id` (заменён в 015) |
| 015 | notify_recipients | `manager_telegram_chat_ids` (массив, эскалация в оба аккаунта) вместо одиночного chat_id |
| 016 | equipment_addon_flag | `equipment_types.is_customer_addon` — какие позиции клиент видит в `/api/equipment` |
| 017 | category_membership | категория `neo_retro_roadster`; M2M `family_filter_categories` (модель в нескольких категориях фильтра — TVS Ronin и в Naked/Classic, и в Neo-Retro) |
| 018 | booking_number | `bookings.booking_number` (sequence) — короткий номер заявки BR-00001 для менеджеров/клиента/CRM |
| 019 | equipment_addon_group | `equipment_types.addon_group` (helmet/topcase/other) — группировка допов для UI и правила «2 шлема»; цены не менялись |
| 020 | equipment_translations | `equipment_type_translations` (зеркало product_translations) + en/ru имена 6 клиентских допов; пилот архитектуры переводов |
| 021 | booking_locale | `bookings.locale` — язык заявки; уведомление менеджеру строится целиком на нём |
| 022 | family_specs | таблица `family_specs` (specs на уровне Family, одинаковы для всех цветов) |
| 023 | family_specs_seed | сид характеристик по 14 линейкам из открытых данных (source-audit); «не найдено» не выдумывается |
| 024 | family_specs_sort | порядок вывода specs на карточке (двигатель→…→снаряжённая масса) |
| 025 | product_variants | `products`: `equipment_variant` (TEXT+CHECK, не enum — участвует в COALESCE-индексе), `print_name`, `archived_color`, `partner_bike`, `need_photos`; identity → `UNIQUE (family_id, color_name, variant, COALESCE(equipment_variant,''), COALESCE(print_name,''))` |
| 026 | product_photos_storage | `product_photos`: `storage_path` (относительный, без размера), `is_hero`; частичный уникальный индекс «одно hero на продукт» |
| 027 | partner_identity | `partner_bike` добавлен в identity-индекс (партнёрский байк может совпадать с парковым по family+color — напр. Xmax Grey) |

## 2. Сидинг данных (реальные счётчики из БД)

Источник — экспорт CRM `backend/seed-data/crm-source.xlsx` (**не в git**:
содержит телефоны/email/VIN). Скрипт — `src/db/seed-crm.js`, идемпотентен.

| Таблица | Кол-во |
|---------|--------|
| product_families | 14 |
| products | 76 (41 из CRM-сида + 33 в чанке Photos + `yamaha-xmax-green` из #13); флаги: 11 archived_color, 12 equipment_variant, 4 print_name, 8 partner_bike, 3 need_photos; все `is_bookable=TRUE` |
| product_photos | 648 (73 продукта × N; 3 продукта без фото — `need_photos`) |
| family_specs | ~100 (specs по 14 линейкам, чанк Specs) |
| fleet_items | 56 |
| price_rules | 1230 (41 продукт × 30 дней) |
| warehouse_items | 49 |
| insurance_plans | 5 (1 theft + матрица 2×2 damage) |
| delivery_fee_rules | 3 (<7д 150k / 7–14д 100k / >14д бесплатно) |
| deposit_rules | 2 (ZX25R, Morbidelli — исключения) |
| vehicle_categories | 7 (scooter_160, maxi_scooter, touring, naked_classic, sport, cruiser, neo_retro_roadster) |
| family_filter_categories | 15 (14 первичных + TVS Ronin доп. в neo_retro_roadster) |
| delivery_shadow_stats | накопительная (тестовые записи), не сидируется |
| equipment_units | 227 |

equipment_units по типам:

| Тип | Всего | available | installed |
|-----|-------|-----------|-----------|
| helmet_kyt_hf | 72 | 72 | — |
| helmet_kyt_ff | 26 | 26 | — |
| helmet_biasa | 84 | 84 | — |
| shad_box | 23 | 23 | — |
| bracket_nmax | 7 | 5 | 2 |
| bracket_adv160 | 4 | 2 | 2 |
| bracket_pcx160 | 3 | 3 | — |
| bracket_mt25 | 2 | 1 | 1 |
| bracket_xsr | 2 | — | 2 |
| bracket_xmax | 1 | 1 | — |
| baseplate | 2 | 2 | — |
| backrest | 1 | 1 | — |

## 3. Ключевые решения по данным

- **`has_abs`** — булево поле на `fleet_items` (NOT NULL): ABS/CBS относится к
  физическому байку. Значение из CRM + список «всегда ABS» моделей; ни один
  байк не остался без значения. С миграции 011 дополнительно определяет, к
  ABS- или CBS-продукту привязан байк (см. `variant` ниже).
- **`products.variant`** (ABS / CBS / Road Sync / пусто) — версии одного цвета
  с разной ценой = отдельные Product'ы (отдельные карточки на сайте). Family
  остаётся общей, аналитика «все ADV» по family не ломается. Разделение по
  ABS/CBS включается только там, где для цвета сосуществуют обе версии
  (определяется по данным, а не списком); Road Sync — всегда отдельный variant.
  10 из 41 продуктов имеют непустой variant.
- **Ценовое правило продукта** — цена = ценовой вектор, общий для наибольшего
  числа байков продукта; при равенстве берётся больший (по дню 30). Один
  механизм без хардкода: сохраняет наценки ABS/Road Sync после разнесения,
  реализует «год не влияет на каталог — берём максимум» (Nmax pink-blue) и
  гасит ошибочную цену #46 как редкий выброс внутри CBS-группы.
- **Оверрайды ошибок CRM в сидере** (источник-xlsx не правится — не в git):
  `#46` — тормоза в колонке были ABS, но имя «PCX CBS Pink» верно → CBS;
  `#41` — цвет «Green» исправлен на «Light green» (отдельный продукт).
- **Equipment не привязан к байкам постоянно.** Шлемы и SHAD-боксы — складские
  единицы без `fleet_item_id`; колонка «Motorbike» в CRM = временная пометка
  держателя, не структура. Связь оборудование↔байк↔клиент появится на уровне
  Rental при выдаче (ещё не реализовано).
- **Крепления — исключение:** стоят на байке полупостоянно. Статус
  `installed` + `fleet_item_id` по номеру байка из CRM («16.Nmax…» → №16);
  `Gudang` → `available`. Неоднозначные («Викин Nmax», 5 шт.) занесены как
  `available` без привязки — актуализировать руками после старта.
- **Шлемы по индивидуальным номерам** (`equipment_units.unit_number`,
  уникален в пределах типа), описание из CRM → `notes`.
- **Исторические секции CRM исключены.** На листах Helms/Box/Biasa маркер
  `Total`/`Продано` отделяет текущий остаток от списка проданных/пересданных
  позиций — всё после маркера в остатки не входит.
- Деньги конвертируются из «тысяч» CRM в IDR (×1000), хранятся BIGINT.
- **Страховка — матрица 2×2** (`insurance_plans`, 5 строк): theft 400k/мес
  (bali_only); damage = покрытие (1500k/4500k) × категория водителя
  (experienced/inexperienced), помесячные тарифы 500/750/700/1500k. Категория:
  `возраст < 33` (порог в system_config) ИЛИ нет прав ИЛИ малый стаж →
  inexperienced (любой критерий независимо). Считается целыми месяцами вверх
  (`ceil(дни/30)`). _Прежний сид имел 3 строки с monthly=покрытию — исправлено._
- **Допы для сайта** (`GET /api/equipment`) — только `equipment_types.is_customer_addon`
  = TRUE: сейчас `helmet_kyt_hf/ff`, `helmet_biasa`, `shad_box`, `raincoat`,
  `phone_holder` (6 шт.). Крепления/visor/cloth/helmet_bag скрыты (внутреннее).
  Флаг конфигурируемый — менеджер может включить/выключить позицию без кода.
- **Депозит** — база `system_config.standard_deposit_idr` (1 000 000);
  исключения в `deposit_rules` по `family_id` (FK, не строкой): ZX25R и
  Morbidelli при аренде ≤6 дней → 2 000 000. Возвращаемый, НЕ входит в «к оплате».
- **Доставка — по сроку** (`delivery_fee_rules`, config): <7д 150k / 7–14д 100k /
  >14д бесплатно. Режим `system_config.delivery_mode` = `by_duration` (фокус)
  с зарезервированной развилкой `by_distance` (по дорогам через Google Distance
  API, не реализовано).
- **Shadow-статистика по локации** (`delivery_shadow_stats`) — фоновый разворот
  ссылки + расстояние по прямой от базы + зона по км, для проверки гипотезы
  by_distance. На цену НЕ влияет, ответ не задерживает, ошибки пишутся как fail.
  Координаты базы и км-зоны заданы (миграция 013).
- **Идемпотентность сидера** — каталог, `insurance_plans`, `delivery_fee_rules`,
  `deposit_rules` чистятся перед заливкой (`resetCatalog` / DELETE), повторный
  прогон не плодит дубли. Причина для insurance: `ON CONFLICT` не дедупит theft
  (поля `driver_exp`/`coverage_idr` = NULL, а NULL ≠ NULL в unique-индексе).

### Чанк Photos — модель продукта и импорт (решения)

- **Каждая цвет-папка Drive = отдельный Product**; суффиксы комплектации
  (+box/+bracket/+crashbar/+all boxes/−no boxes) и принт-серии (Sky Pink/Anime/
  Blue Sky/Sticker Custom) — тоже отдельные Product'ы (identity через миграции 025/027).
  Архивные цвета (перекраска, которой нет в текущем парке) консолидированы: один
  Product на (family, color), фото из всех архивных папок в одну галерею, метка «Rare colour».
- **Ре-валидация archived_color по CRM** (не по имени папки): короткое имя папки
  (Pink) ⊂ полного цвета CRM (Pink Blue) → это ACTIVE, а не архив. Реальные перекраски
  → NEW archived Product; если такой цвет уже активен на другом байке — фото мержатся в него.
- **CRM-коррекции при сидинге Photos:** #52 Silver→archived, реальный текущий цвет
  «Green Blue» стал active + fleet #52 перепривязан (CRM — источник истины, БД была
  устаревшей); #13 разделён на `yamaha-xmax-green` (active, fleet #13) и
  `yamaha-xmax-green-blue-wheels` (archived, без fleet); #47 `print_name='Sticker Custom'`
  — нейтральное имя вместо товарного знака LV (в UI LV/Louis Vuitton не встречается).
- **partner_bike** (8 Викиных) — партнёрский парк без `fleet_items`; `is_bookable=TRUE`
  (v1: показываем всё, физическую выдачу решает менеджер), в UI/API флаг скрыт.
- **Хранение:** относительный `storage_path` (`bikes/<slug>/NN`, без размера) + env
  `NEXT_PUBLIC_PHOTO_BASE_URL` → миграция Drive-URL→CDN без правки данных. `source_url` =
  Drive fileId (provenance/реимпорт), `cdn_url` = опц. абсолютный override.
- **Импорт keyless:** `build_manifest.js` перечисляет публичные папки через
  `embeddedfolderview` (HTML, без API-ключа) по встроенному маппингу папка→slug;
  `import_photos.js` качает по публичному HTTPS `uc?export=download`, sharp → WebP ×3
  (400/800/1200w, q82). Идемпотентность по `(product_id, source_url)`.
- **HEIC-фикс:** iPhone `.HEIC` превышают security-limit libheif внутри sharp
  («iref references > 16») → конвертим через macOS `sips` (→ JPEG) перед sharp.
  Работает локально; на диске уже WebP, для Linux-сервера sips не нужен.

### Чанк SEO enrichment layer (Шаг 0 → Шаг 2 из 3, закрыт)

**Шаг 0 — [SEO_AUDIT.md](../SEO_AUDIT.md) (read-only аудит, без кода).**
До чанка: title/description были на всех 5 страницах, canonical — на 4 из 5
(каталога не было), Product/FAQPage JSON-LD существовали, но Product — без
`image`/specs. Полностью отсутствовали: `metadataBase` (canonical/og:url
относительные), per-locale `<html lang>` (жёстко `en`), OpenGraph/Twitter Card,
`sitemap.xml`, `robots.txt`, hreflang, `Organization`/`LocalBusiness` schema,
favicon/manifest, `BreadcrumbList`. Аудит зафиксировал это как P0/P1/P2-gaps —
Шаг 1 закрыл все P0 + фундамент, Шаг 2 закрыл оставшийся P1 (canonical
каталога + hreflang).

**Шаг 1 — P0 + фундамент (6 задач + 2 baseline-коммита):**
1. **`metadataBase` + per-locale `<html lang>`** — `frontend/src/lib/site.js`
   (`SITE_URL='https://bikebalirent.com'`, override через
   `NEXT_PUBLIC_SITE_URL`). `<html>/<body>` + шрифты перенесены из root
   layout в `[locale]/layout.js` (там есть `params.locale`) — `lang`
   резолвится на билде, без `headers()`, статика About/FAQ сохранена. Root
   layout стал сквозным (`return children`), держит только `metadataBase`.
2. **`sitemap.xml` + `robots.txt`** — нативные App Router роуты
   (`app/sitemap.js`/`app/robots.js`). Sitemap: 160 URL = (homepage + /bikes +
   About + FAQ + 76 продуктов) × (en, ru); `lastmod` продукта — реальный
   `products.updated_at` (докинут в `/api/products` отдельным полем), у
   статических страниц — дата генерации sitemap (допущение, в коде
   закомментировано). Robots: `Allow: /`, `Disallow: /api/`, ссылка на sitemap.
   Потребовалось расширить matcher `middleware.js` — без исключения
   `sitemap.xml|robots.txt|.webp` они редиректились на `/<locale>/…`.
3. **OpenGraph + Twitter Card на всех 5 страницах** — общий helper
   `frontend/src/lib/seo.js` (`ogTwitter()`). Дефолтный `og:image` — **своё**
   фото байка (`Honda ADV Total Black`, hero, из `product_photos`); логотипа
   в Drive нет, сток принципиально не использовали. Product page —
   динамический `og:image` = тот же hero, что рендерится на странице.
   `twitter:card = summary_large_image`.
4. **Product JSON-LD обогащён** — `image` (тот же hero, абсолютный URL через
   ручной `absoluteUrl()` — `metadataBase` резолвит относительные URL только
   внутри Metadata API, а JSON-LD это сырой `<script>`); `additionalProperty`
   (`PropertyValue[]`) из `family_specs`, локализовано. Логика label/value
   вынесена в `frontend/src/lib/specs.js` (`resolveSpec`/`resolveSpecs`) —
   общая для видимого UI и JSON-LD, не дублируется. `image` корректно
   отсутствует (не фабрикуется), если у продукта `need_photos=TRUE`.
5. **`LocalBusiness` JSON-LD глобально** (`frontend/src/lib/organization.js`,
   рендерится в `[locale]/layout.js` — на каждой странице, не только
   homepage). Тип `LocalBusiness`, не `Organization` — есть операционная база
   и уже публичный адрес/часы на About/Footer. **По решению владельца** (бизнес
   принципиально не публикует точный адрес, упор на доставку): БЕЗ
   `streetAddress`/`geo` (точные координаты эквивалентны публикации адреса);
   `address` только `addressRegion: 'Bali'` + `addressCountry: 'ID'`;
   добавлен `areaServed: {Place, 'Bali'}` взамен. Телефон — не плоское поле
   `telephone`, а структурированный `contactPoint` (WhatsApp `url`,
   `availableLanguage: [English, Russian]`). `legalName` = «PT Modern
   Development Bali» (Knowledge Base MDB §22, через Drive MCP).
   `openingHours: 'Mo-Su 08:00-19:00'` — подтверждено владельцем.

**Шаг 2 — canonical каталога + hreflang:**
- **Canonical `/bikes`** — ВСЕГДА базовый URL без query, независимо от
  `?category=` (любого значения/лишних параметров). Страница остаётся
  индексируемой (не noindex), просто не плодит дубли по категориям.
- **hreflang (en/ru/x-default)** — общий helper `hreflangAlternates(suffix)`
  в `lib/seo.js`, встроен в тот же `alternates`, где живёт canonical, на всех
  5 страницах. `x-default` → `en`. Product page: у `products.slug` нет
  per-locale варианта (проверено по схеме БД) — hreflang просто меняет
  сегмент локали в пути, доп. lookup не требуется. Каталог: hreflang, как и
  canonical, указывает на чистый `/bikes` при любом `?category=`.

**Зафиксированное отклонение от ТЗ:** `og:type = 'website'` везде, включая
product page — типизированный Metadata API Next 14.2 падает в рантайме на
`openGraph.type: 'product'` (`Invalid OpenGraph type: product`), а по спеке
OG `product`-тип ещё и требует `xmlns:product` на `<html>`, которого Next не
эмитит. Google для индексации og:type не использует — работает по Product
JSON-LD (см. п.4 выше). Не тихая замена — согласовано с владельцем.

**Полный список коммитов чанка (хронологически, `c0db3b8..HEAD`):**
| Commit | Суть |
|---|---|
| `1289bf1` | chore: baseline commit frontend (снапшот до чанка) |
| `8ef7d96` | feat(seo): metadataBase + per-locale `<html lang>` |
| `4dc9c3e` | feat(seo): sitemap.xml + robots.txt |
| `ee08d93` | chore: baseline commit backend (снапшот до чанка) |
| `03868a3` | feat: `updated_at` в `/api/products` (для sitemap lastmod) |
| `bf5ac5e` | feat(seo): OpenGraph + Twitter Card на всех 5 страницах |
| `a0efe29` | feat(seo): Product JSON-LD — `image` + `additionalProperty` |
| `0e21058` | feat(seo): LocalBusiness JSON-LD глобально (первая версия) |
| `641cf59` | fix(seo): LocalBusiness — убраны streetAddress/geo, добавлены contactPoint+areaServed (правки владельца) |
| `f7bbbeb` | feat(seo): canonical на каталоге (схлопывает `?category=`) |
| `86f6b72` | feat(seo): hreflang на всех 5 страницах |

11 коммитов, каждый live-проверен (curl/view-source) перед коммитом.

**Остаётся в Шаге 3 (следующий этап, не начат):** favicon/apple-touch-icon +
`manifest.js`; `BreadcrumbList` JSON-LD (каталог → продукт).

### Грабли / нюансы (на будущее)

- **`users`: при будущем сидинге/импорте НЕ полагаться на `ON CONFLICT` по
  `email` или `telegram_id`** — оба nullable, и NULL ≠ NULL в SQL приведёт к
  дублям (та же ловушка, что была в `insurance_plans`). Для дедупа
  пользователей использовать явную проверку существования или `COALESCE`,
  либо чистку перед сидингом. Сам sparse-unique на `users` корректен (много
  пользователей без email/telegram — это норма), схему не трогаем.

## 4. Что НЕ сделано / следующий этап

- **Rental lifecycle (после заявки):** выдача (Rental создаётся при физической
  передаче, ТЗ 6.8), события (продление/возврат), выдача оборудования с привязкой
  к Rental и Deposit Deduction, ручное подтверждение/назначение байка менеджером.
  Booking приём готов (`/api/bookings`), но дальше статуса `created` ничего не
  двигает — это ручная работа менеджера / следующий модуль.
- **WhatsApp-эскалация** — не реализована (нужен WhatsApp Business API). Канал
  заложен в notify (`switch (channel)`), но активен только telegram.
- **Specs — ГОТОВО** (чанк Specs): `family_specs` заполнена по 14 линейкам из
  открытых данных, рендерится на карточке продукта (label/unit/локализация КПП — i18n).
- **Фото — ГОТОВО** (чанк Photos): 648 WebP ×3 размера в `frontend/public/bikes/`
  (gitignored), `product_photos` заполнена, рендер hero+галерея с метками. Скрипты
  `backend/scripts/{build_manifest.js,import_photos.js}` + `photos_manifest.json`
  идемпотентны. `is_hero` пока везде FALSE (ручная разметка «главного» фото — позже).
- **Перевод названий ПРОДУКТОВ/категорий-описаний** — остаётся (Honda ADV Chameleon
  и т.п.); архитектура переводов обкатана на оборудовании. `product_translations` пуста —
  имена пока из конструкции (brand+model+color+variant+комплектация).
- **Фронтенд — остаётся:** блог; остальные языки (de/fr/es/it/ja — структура готова,
  нужны словари). Главная/About/FAQ готовы, RU+EN активны, оборудование локализовано.
- **SEO — Шаг 0–2 ГОТОВО** (чанк SEO enrichment layer, подробности — раздел выше):
  metadataBase, per-locale `<html lang>`, sitemap.xml, robots.txt, OpenGraph/Twitter,
  Product JSON-LD (image+specs), LocalBusiness JSON-LD, canonical каталога, hreflang.
  **Остаётся Шаг 3:** favicon/apple-touch-icon/manifest, `BreadcrumbList` JSON-LD.
- **Деплой:** backend → Render, PostgreSQL → Railway, frontend → Render/Vercel
  (в roadmap владельца рассматривается Hetzner+Coolify — не зафиксировано).
  На деплое: env (`API_BASE_URL`, `TELEGRAM_BOT_TOKEN`), решение по апгрейду Next
  (14.2.35 сейчас; `npm audit` чистится только на next@16 — мажор с async params).
  CI/CD на старте нет — миграции на боевую БД проверяются руками.
  **Фото на CDN:** выставить `NEXT_PUBLIC_PHOTO_BASE_URL` на URL R2/Cloudflare и
  перенести `frontend/public/bikes/**` в бакет — БД не трогается (`storage_path`
  size-agnostic, размер добавляет рендер; `cdn_url` — опц. абсолютный override).
- Боты (`MDB_drivers_bot` и др.) на запись через `api_clients` — позже.

## 5. Как запустить локально

```bash
# Backend (:3000)
cd backend
npm install                  # один раз
npm run db:create            # создать БД mdb_platform (если нет)
npm run migrate              # применить миграции 001–027
node src/db/seed-crm.js      # залить данные из seed-data/crm-source.xlsx
npm start                    # GET /health, /api/*

# Фото (чанк Photos, идемпотентно; публичные Drive-папки + macOS sips для HEIC):
node scripts/build_manifest.js                              # → scripts/photos_manifest.json
node scripts/import_photos.js --manifest scripts/photos_manifest.json

# Frontend (:3001) — в отдельном терминале
cd frontend
npm install                  # один раз
npm run dev                  # → http://localhost:3001/en/bikes
```

`npm run migrate:status` — показать, какие миграции применены.
Backend: `DATABASE_URL` + `TELEGRAM_BOT_TOKEN` в `backend/.env`
(БД по умолчанию `postgres://localhost:5432/mdb_platform`).
Frontend: `API_BASE_URL` в `frontend/.env.local` (по умолчанию `http://localhost:3000`).
`NEXT_PUBLIC_SITE_URL` (по умолчанию `https://bikebalirent.com`) — прод-домен для
`metadataBase`/canonical/og:url/sitemap; `NEXT_PUBLIC_PHOTO_BASE_URL` (по умолчанию
`''`, same-origin) — база для фото, при переезде на CDN меняется без правки БД.

⚠️ Полный пере-сид (`seed-crm.js`) сейчас падает, если в БД есть заявки
(`bookings.product_id` FK не даёт `resetCatalog` удалить продукты). Для пере-сида
сначала очистить bookings/notifications или доработать `resetCatalog`.
