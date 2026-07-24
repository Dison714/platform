# PROJECT_STATUS.md — снимок состояния MDB Platform

_Обновлено: 2026-07-24 (чанк **Deploy в процессе**: backend+frontend на Contabo
VPS + Coolify 4.1.2, оба `running:healthy`, миграции 34/34 применены; сидинг
CRM с dev-БД — ЗАВЕРШЁН, фото на R2 — ЗАВЕРШЁНО. DNS cutover — впереди, ждёт
отдельного OK. Дальше — 5 блоков доработок каталога, все ЗАВЕРШЕНЫ и
запушены в `main`: **Каталог: фильтры + матчинг цен + Keeway** (миграции
028-031), **Главное фото сбоку** (миграции 032-033, визуальный выбор hero
для 75 products), **Сезонный мультипликатор цены + первая админка**
(миграция 034, `/internal/pricing`, Basic Auth), **Видео карточки товара**
(Блок 3, client-side existence-check), **Photo lightbox** (Блок 4,
yet-another-react-lightbox), **Виджет доступных байков на главной** (Блок 5,
cookie-based ротация без серверного состояния). Дальше — **Коррекция
replacement_group ЗАВЕРШЕНА** (миграция 035, Vario→Xmax, переименование
в `scooter_replacement_pool`), чанк **Configuration First — расширение
`/internal/*` ЗАВЕРШЁН** (миграция 036: страховка/доставка/депозит/
replacement groups, общая навигация на 5 разделов). Ранее — чанк **SEO
enrichment layer ПОЛНОСТЬЮ ЗАКРЫТ** (Шаг 0→3), чанк Photos (657 фото/1971
файл, рендер), чанк Specs (family_specs). Плюс всё предыдущее: каркас +
каталог + продукт/калькулятор + заявка + контентные страницы; двуязычный
сайт RU+EN; номер заявки BR-00001).
Карта состояния для продолжения в будущих сессиях.
Бизнес-правила и архитектурные решения — в `CLAUDE.md`, дублировать не нужно._

## Конфигурация Claude Code — временная

Permissions временно в режиме `bypassPermissions` (без подтверждений) на
период активной разработки — решение владельца от 23.07.2026, файл
`.claude/settings.local.json` (личный, не в git). **После запуска сайта в
прод (DNS cutover) — вернуться к более узкому набору правил.** Целевая
конфигурация на потом (уже согласована, просто применить):

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(npm run *)"
    ],
    "ask": [
      "Bash(git push *)",
      "Bash(docker exec *)",
      "Bash(ssh *)"
    ],
    "deny": [
      "Read(.env)",
      "Read(secrets/**)",
      "Bash(rm -rf *)"
    ]
  }
}
```

Не забыть про этот пункт при работе над DNS-чанком деплоя — это
естественный момент вернуться и переключить.

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

### Применённые миграции (001–034)

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
| 028 | scooter_filter_split | "Scooter 160cc"/"Maxi Scooter" → 5 фильтров по модели (Honda ADV/PCX/Vario 160, Yamaha Nmax 155/Xmax 250); MT-25 доп. членство Sport+Naked/Classic; Cruiser переименован в "Cruiser / Bobber / Chopper" |
| 029 | replacement_groups | Новый справочник `replacement_groups` + `product_families.replacement_group_id` — группа взаимозаменяемости для будущей Replacement Matrix, отделена от `vehicle_categories` (см. §3.1 CLAUDE.md) |
| 030 | price_matching | 37 products без `price_rules` получили цену "донора" (та же Family, тот же/ближайший цвет) |
| 031 | keeway_road_falcon | Новый байк Keeway Road Falcon 250 — Family/Product/цена (=Morbidelli), без Fleet Item (в заказе, не приехал) |
| 032 | side_view_hero | `product_photos.is_hero` проставлен визуально для 75 products (боковой профиль вместо произвольного sort_order=1) |
| 033 | side_view_hero_fix | Исправление 7 из 75 — на мелкой сетке контрольного листа спутаны 3/4 спереди/сзади с профилем |
| 034 | seasonal_multipliers | Новая таблица `seasonal_multipliers` (глобальные/per-rule_set периоды, пересечения запрещены триггером); применяется в `computeBaseRental()` по дате начала аренды, округление ВВЕРХ до 50к |
| 035 | replacement_group_composition_fix | Коррекция состава группы взаимозаменяемости: Vario → Xmax (ADV/PCX/Nmax/Xmax); переименована `scooter_econ_160` → `scooter_replacement_pool` |
| 036 | delivery_fee_rules_no_overlap | `EXCLUDE USING gist` на `delivery_fee_rules` (rule_set_id + int4range тира) — защита от пересекающихся тиров доставки, тот же паттерн, что `rentals.no_overlapping_active_rentals` |

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

### Чанк SEO enrichment layer (Шаг 0 → Шаг 3, ПОЛНОСТЬЮ ЗАКРЫТ)

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

**Шаг 3 — favicon/manifest + BreadcrumbList (последний шаг чанка):**
- **Favicon/apple-touch-icon/manifest** — файловая конвенция App Router,
  без ручного `<link>`-инжекта: `frontend/src/app/icon.png` (32×32),
  `apple-icon.png` (180×180), `frontend/public/icon-192.png`/`icon-512.png` +
  `frontend/src/app/manifest.js` (`name`/`short_name` = «Bike Bali Rent»/«BBR»,
  `theme_color`/`background_color` — реальные `--navy`/`--bg` из `globals.css`,
  `start_url` через `absoluteUrl('/')`). Источник — `frontend/assets/brand/
  bbr-logo-source.svg`: реальный бренд-лого (силуэт мотоциклиста + «BBR»,
  navy/red), скачан с живого `bikebalirent.com`, затем **заменён на high-res
  версию** (`BBR__5_-removebg-preview.svg`, 253×245px растр внутри SVG,
  фон уже удалён — прислал владелец), заметно чётче при апскейле до 512px.
  Source-SVG **закоммичен как есть** (не gitignored, в отличие от bulk-фото
  байков) — маленький (~75 КБ), не регенерируется скриптом ниоткуда, это
  master-актив бренда. `favicon.ico` сознательно не генерировали — sharp не
  умеет в ICO, а новую зависимость ради легаси-IE не оправдано.
  `middleware.js` matcher расширен третий раз — `manifest.webmanifest`
  (реальный путь Next, не `manifest.json`) редиректился без исключения.
- **BreadcrumbList JSON-LD** — helper `breadcrumbJsonLd(items)` в `lib/seo.js`
  (абсолютные `item` через `absoluteUrl`, как и остальной JSON-LD). Product
  page — всегда, Home → Bikes → [Product name] (то же имя, что в Product
  JSON-LD/`<title>`). Каталог — только при активном `?category=` (без фильтра
  одна ступень не нужна); имя категории резолвится **тем же способом**, что
  уже в `CategoryFilter.jsx` (`dict.cat[code] ?? API name`), новый маппинг не
  заводили. Названия ступеней Home/Bikes — из `dict.nav` (уже используемые
  строки навигации).

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
| `911da7d` | docs: PROJECT_STATUS.md + SEO_AUDIT.md (батч после Шага 2) |
| `419e42e` | feat(seo): favicon, apple-touch-icon, PWA manifest |
| `a76d0cb` | feat(seo): BreadcrumbList JSON-LD (product + filtered catalog) |
| `065ec76` | docs: PROJECT_STATUS.md — чанк закрыт (Шаг 0-3) |

15 коммитов (сверено по `git log --oneline c0db3b8..HEAD`), каждый live-проверен
(curl/view-source) перед коммитом. Чанк SEO enrichment layer закрыт полностью (Шаг 0 → Шаг 3).

### Чанк Deploy — Contabo + Coolify (в процессе, Шаг 3.3 + сидинг данных + R2 медиа закрыты)

**Инфраструктура (фактическая, не Hetzner — регистрация Hetzner была отклонена):**
провайдер **Contabo**, сервер `169.58.60.244` (Cloud VPS 4: 4 vCPU/8GB/100GB,
Ubuntu 24.04.4 LTS), Coolify **4.1.2** самохостится там же. Проект в Coolify —
`mdb-platform` (переименован из дефолтного «My first project»). БД — **self-hosted
PostgreSQL 18** внутри Coolify-контейнера (не Supabase — выбор сделан фактом
разворачивания, вопрос (а) из предыдущего маркера закрыт).

**PostgreSQL:** ресурс `postgresql-database-xw6ykwjdrdmtly2qg8kbd16m` (образ
`postgres:18-alpine`), база `mdb_platform` создана вручную (Coolify не подхватил
её как `Initial Database` — `POSTGRES_DB` в контейнере остался `postgres`, известный
баг/недосмотр конфигурации). **Миграции 001–027 применены полностью (27/27)**,
`schema_migrations` таблица создана и заполнена вручную (гоняли через `docker exec
psql`, не через `migrate.js` — значит бэкенд при следующем `npm run migrate` увидит
всё как уже применённое и корректно не тронет ничего).
Попутно найден и исправлен реальный баг миграций: `010_equipment_mounting.sql`
дублировал `009_fleet_amendments.sql` (тот же `ALTER TYPE ... ADD VALUE 'installed'`
+ те же 8 INSERT'ов) — на чистой БД это падало (`enum label already exists`).
Локально коллизии не было только потому, что дублирующий код добавили в `009`
уже ПОСЛЕ того, как файл был отмечен применённым (раннер трекает по имени файла,
не по содержимому) — по факту в локальной истории этот SQL исполнился только
через `010`. Пофикшено: `010` превращён в no-op (комментарий, код закомментирован),
`009` не трогали (коммит `061f82d`).

**Сервер:** ребут выполнен (накопленные апдейты ядра `6.8.0-124`→`6.8.0-136`)
после проверки restart policy на всех контейнерах (`unless-stopped`/`always`);
`coolify-sentinel` был без policy — исправлено на `unless-stopped`. Все 7
контейнеров (Postgres + весь Coolify-стек) пережили ребут автостартом.

**Backend** (`mdb-platform-backend`, Nixpacks, `base_directory=/backend`) —
**`running:healthy`**, домен `uy845drxpx5z6t5qf0c8voa8.169.58.60.244.sslip.io`,
коммит `061f82d`. Env: `DATABASE_URL` (внутренний, host = alias контейнера, см.
ниже), `NODE_ENV`, `PORT=3000`, `TELEGRAM_BOT_TOKEN` (реальный боевой токен —
осознанное решение владельца для сквозного теста, не заглушка).

**Frontend** (`mdb-platform-frontend`, Nixpacks, `base_directory=/frontend`) —
**`running:healthy`**, домен `odke6aycqzy4zybnkutq8qbm.169.58.60.244.sslip.io`,
коммит `061f82d`. Env: `NEXT_PUBLIC_SITE_URL` (sslip.io-домен), `NEXT_PUBLIC_PHOTO_BASE_URL`
(пусто — фото ещё локальные), `API_BASE_URL` (внутренний адрес backend'а),
`NODE_ENV`, `PORT=3000`. **`SITE_ENV` НЕ выставлен** — сайт намеренно закрыт от
индексации на этом этапе (`Disallow: /`, пустой sitemap, `noindex,nofollow` —
проверено live).

**Найдено при деплое: app-ресурсы Coolify не имеют стабильного internal-хоста
по умолчанию.** В отличие от Database-ресурса (где имя контейнера случайно
совпало с UUID), Application-контейнеры получают случайный суффикс к имени,
который **меняется при каждом передеплое** — попытка захардкодить `<uuid>`
как internal host для backend не сработала (frontend → backend упал сетевой
таймаут). Исправлено штатным полем Coolify API `custom_network_aliases`:
backend получил постоянный alias `mdb-backend`, `API_BASE_URL` фронтенда
указывает на `http://mdb-backend:3000` — пережило повторный передеплой backend'а
(суффикс контейнера сменился, alias — нет). **Правило на будущее:** для
Application-ресурсов Coolify всегда явно задавать `custom_network_aliases`
при межсервисном обращении, не полагаться на имя контейнера.

**Известный техдолг (не блокер, фиксируется, не чинится сейчас):**
1. **`getActiveRuleSetId()` бросает необработанное исключение** (`Нет действующего
   pricing_rule_set`), когда `pricing_rule_sets` пуста — `/api/products` (и, вероятно,
   всё, что считает цену) отдаёт 500 вместо пустого каталога. После сидинга (см. ниже)
   `pricing_rule_sets` заполнена, баг больше не проявляется на проде — но сам резолвер
   не переписан (throw вместо graceful empty-state), почини отдельной задачей, когда
   понадобится держать окружение с пустой БД.
2. **`output: 'standalone'` в `next.config.mjs` не даёт эффекта под Nixpacks** —
   в логах `⚠ "next start" does not work with "output: standalone" configuration`.
   Приложение работает (Nixpacks копирует полный `.next`, не только standalone-папку),
   но настройка сейчас мертва для этого способа деплоя. Не трогали — не блокирует.
3. **Фото — ГОТОВО, перенесены на R2** (было: физически отсутствовали на проде;
   `frontend/public/bikes/` в `.gitignore`, никогда не коммитилась). Подробности —
   раздел «Чанк R2 медиа» ниже.
4. **Медиа отдаются через R2 Public Development URL, не production-домен** —
   `pub-92229917b7c74364afcdf15e1d1cff99.r2.dev` — Cloudflare сам маркирует этот
   механизм как preview/dev, не «Recommended for production use» (в отличие от
   Custom Domains). Работает корректно для текущего этапа (сайт ещё не на
   `bikebalirent.com`), но перед реальным запуском нужно подключить Custom Domain
   для бакета (например `cdn.bikebalirent.com`) и обновить
   `NEXT_PUBLIC_PHOTO_BASE_URL` — часть будущего DNS-чанка, не текущего.
5. **Разный `datlocprovider` локально и на сервере** — локальная БД (Postgres.app)
   инициализирована с ICU (`datlocprovider='i'`), серверная (`postgres:18-alpine`) —
   с libc (`datlocprovider='c'`). Не влияет на корректность перенесённых данных
   (подтверждено byte-level сравнением при сверке lookup-таблиц перед сидингом,
   см. раздел «Чанк Сидинг данных» ниже), но даёт разные результаты `(a,b,c)::text`-сериализации для строк с
   не-ASCII символами (composite-to-text quoting) и потенциально разный порядок
   сортировки в `ORDER BY` без явного `COLLATE`. Учитывать при любых будущих
   операциях, чувствительных к collation (текстовые индексы, кросс-окруженческое
   сравнение через композитный `::text`).

**Остаётся по плану деплоя:**
- DNS-подготовка (cutover на bikebalirent.com) — не начата, ждёт отдельного решения.
- SSL — автоматически через Traefik/Let's Encrypt после DNS, не начато.
- Custom Domain для R2-бакета (замена Public Development URL) — часть будущего
  DNS-чанка, см. техдолг выше.
- Боты (`@MDB_tugas_approver_bot` и др.) остаются на Render — вне периметра.

### Чанк Сидинг данных — Contabo (ЗАВЕРШЁН)

**Метод:** `pg_dump --data-only --disable-triggers -F c` с локальной dev-БД →
`pg_restore` на Contabo через `docker exec` (дамп передавался по SSH-пайпу,
без промежуточного хранения на хосте сервера — порт Postgres наружу не открыт,
только 22/80/443/8000/6001-6002). **Не через xlsx-ETL** (`seed-crm.js`) — тот
процесс остаётся рабочим и сохранён отдельно на будущее, если понадобится
пересидить каталог с нуля из CRM-таблицы, а не с dev-БД.

**Исключены из дампа (5 таблиц):** `bookings`, `customers`,
`booking_status_history`, `notifications` — тестовые артефакты в dev-БД
(вопреки первоначальному предположению "БД чистая", найдено и подтверждено
перед дампом), не годятся для прод-сидинга; `schema_migrations` — конфликт
PK (`filename`) с уже вручную заполненной серверной историей миграций.

**Верификация перед restore:** 8 pre-seeded lookup-таблиц (`roles`,
`event_types`, `task_types`, `languages`, `vehicle_categories`,
`finance_categories`, `companies`, `equipment_types`) заранее сверены
построчно (count + md5-хэш конкатенации колонок, без композитного
`::text`-каста — тот давал ложный мискмэтч на `finance_categories` из-за
разного `datlocprovider`, см. техдолг выше) — подтверждена побайтовая
идентичность на обеих средах.

**Инцидент — orphaned FK после restore (урок на будущее):**
- Симптом: 8 duplicate-key ошибок при restore — ровно на тех 8 pre-seeded
  таблицах, что и ожидалось (harmless, COPY откатился, но данные и так
  идентичны). Дополнительно, необнаруженное заранее: `fleet_items`,
  `product_families`, `warehouse_items`, `pricing_rule_sets`,
  `deposit_rules`, `delivery_shadow_stats`, `equipment_units` восстановились
  с `company_id`/`type_id`, ссылающимся на UUID, которого **не существует**
  в серверных `companies`/`equipment_types` (эти таблицы не были
  восстановлены из дампа — откатились по duplicate key на `code`, сервер
  сохранил свой собственный, независимо сгенерированный UUID). `feature_flags`
  и `equipment_type_translations` вместо ошибки задвоились (нет unique
  constraint, который поймал бы конфликт по FK-колонке).
- **Корневая причина:** `companies` и `equipment_types` — обе имеют
  недетерминированный PK (`id UUID DEFAULT gen_random_uuid()`) + отдельный
  unique constraint на смысловую колонку (`code`). При независимых прогонах
  миграций на двух окружениях UUID расходится, а `code` — нет. `pg_restore`
  ловит конфликт по `code`, откатывает `COPY` для этой таблицы целиком —
  но дочерние строки, ссылающиеся на UUID из дампа, уже вставлены без
  проверки, потому что `--disable-triggers` отключил FK-контроль.
- **Исправлено:** одна транзакция — `UPDATE company_id`/`type_id` с
  локального UUID на серверный (remap через `code`) для таблиц, которые были
  пусты до restore; `DELETE` дублей для `feature_flags`/`system_config`/
  `equipment_type_translations`, где сервер уже имел корректные строки от
  миграций. Проверено дважды: точечно (по известным 10 таблицам) и
  генерическим сканом по ВСЕМ FK-constraint'ам в схеме — других повреждений
  не найдено.
- **Обязательный протокол на будущее для такого restore:**
  1. Перед дампом — `\d <table>` по каждой pre-seeded lookup-таблице; если
     PK ≠ unique constraint на смысловой колонке (типично: UUID PK +
     `code`/`slug` unique) — это кандидат на orphan-риск при
     `--disable-triggers`.
  2. Либо не выключать триггеры для таких таблиц (ценой более сложного
     восстановления в правильном топологическом порядке по зависимостям),
     либо — как сделали здесь — выключать, но **сразу после restore, до
     перехода к следующему шагу**, обязательно (не опционально) прогонять
     генерический orphan-скан по всем FK в схеме.

**Итоговая верификация:** все 55 таблиц дампа — точное совпадение `count(*)`
локально/сервер после фикса. Каталог проверен: `/en/bikes`, `/ru/bikes` и
2 карточки товара — 200 (баг `getActiveRuleSetId()` ушёл сам после заполнения
`pricing_rule_sets`, см. техдолг выше). Форма бронирования **не открывалась**
через UI (боевой `TELEGRAM_BOT_TOKEN` на бэкенде — реальное уведомление ушло
бы Сергею/Bali Rent в Telegram).

### Чанк R2 медиа-миграция (ЗАВЕРШЁН)

**Бакет:** `mdb-platform-media` (Cloudflare R2), создан через S3-совместимый API
(`aws s3api create-bucket`, endpoint `https://3c3d58a73ee90534807282e5c9c708be.r2.cloudflarestorage.com`).
Публичный доступ включён вручную владельцем в dashboard (R2 S3-ключи не дают
прав на управление публичным доступом — это отдельный Cloudflare API/dashboard-
уровень, не S3 API). Публичный URL (текущий, dev-режим — см. техдолг выше):
`https://pub-92229917b7c74364afcdf15e1d1cff99.r2.dev`.

**Аплоад:** `aws s3 sync frontend/public/bikes/ s3://mdb-platform-media/bikes/`
с `--content-type image/webp`, структура путей сохранена как есть
(`bikes/<slug>/{thumb,gallery,hero}/NN.webp`, совпадает с тем, что строит
`resolvePhotoUrl()` в `frontend/src/lib/photos.js`). **1971 файл** (657 фото ×
3 размера — фактическое число, не 648, как ошибочно упоминалось на старте
задачи; сверено с `product_photos`=657 строк в БД). Верифицировано двумя
независимыми способами (`list-objects-v2` count + `s3 ls --recursive | wc -l`) —
1971=1971 точное совпадение. Публичная доступность проверена curl на выборке —
200, `Content-Type: image/webp`.

**Деплой конфигурации:** `NEXT_PUBLIC_PHOTO_BASE_URL` выставлен через Coolify
API на публичный R2 URL, **выполнен полный redeploy с ребилдом**
(`POST /api/v1/deploy?force=true`, не простой restart) — обязательно, так как
`NEXT_PUBLIC_*` переменные инлайнятся в JS-бандл на этапе `next build`, restart
контейнера без ребилда продолжил бы использовать старое (пустое) значение.
Подтверждено: HTML после ребилда содержит реальные R2-ссылки, `running:healthy`,
фото визуально проверены владельцем на `/en/bikes` и карточках товара — отображаются.

**На будущее (часть DNS-чанка, не сейчас):** заменить Public Development URL на
Custom Domain (`cdn.bikebalirent.com` или похожий) перед реальным запуском на
`bikebalirent.com`, обновить `NEXT_PUBLIC_PHOTO_BASE_URL` соответственно.

### Чанк Каталог: фильтры + матчинг цен + Keeway (ЗАВЕРШЁН, миграции 028-031)

**Фильтры (028):** "Scooter 160cc"/"Maxi Scooter" разбиты на 5 фильтров
по модели — `honda_adv160`, `honda_pcx160`, `honda_vario160`,
`yamaha_nmax155`, `yamaha_xmax250` (числа в коде — маркетинговое
округление реального `engine_cc` из `family_specs`: 156.9→160 у Honda,
155/250 у Yamaha — точные). MT-25 получил двойное членство в
`family_filter_categories` — остаётся в Sport (первичная категория,
бейдж карточки не меняется) и дополнительно виден в Naked/Classic.
Cruiser переименован в "Cruiser / Bobber / Chopper" (en и ru).
Побочный итог — `vehicle_categories` (UI-фильтр) и `replacement_groups`
(группа взаимозаменяемости для будущей Replacement Matrix) разделены,
подробности и обоснование — CLAUDE.md §3.1.

**Матчинг цен (030):** 37 из 78 products не имели `price_rules`.
Принцип — "перекрашенный байк = та же цена" (решение владельца): цена
копируется с "донора" — уже оценённого продукта той же Family. Где
donor-цвет совпадает точно (тот же цвет, `box`/`bracket`/`partner`/
`crashbar` в названии — доп. оборудование, не новый цвет) — копирование
однозначное. Где у Family несколько разных ценовых тиров и точного
совпадения по цвету/варианту нет — решения владельца по каждой группе:
- **Yamaha Nmax**, 7 цветов без совпадения (Black, Blue, Dark Green,
  Neo Blue partner, Neo S Black partner, Neo S White partner, Red) →
  дешёвый тир 500 000 IDR/день (донор `yamaha-nmax-green`), не дорогой
  тир 600к (Light green/Pink Blue/Pink-purple).
- **Yamaha Xmax**, 6 цветов без совпадения (Black partner, Cartoon
  partner, Dark Green partner, Green, Pink, Red partner) → дешёвый тир
  900 000 IDR/день (донор `yamaha-xmax-silver`), не дорогой тир 1100к
  (Chameleon/Grey).
- **Honda PCX**, 2 цвета без совпадения (Red, Silver) → базовый тир
  (донор `honda-pcx-orange`, тот же тир что Green/Orange), не тир ABS
  (Yellow Green).
Итог: 78/78 products с ценой. Полная донор→таргет таблица — миграция
`backend/migrations/030_price_matching.sql`.

**Keeway Road Falcon 250 (031):** новый байк, в заказе, физически ещё
не приехал. Заведён как Family/Product (без Fleet Item — см. CLAUDE.md
§3.1, паттерн "Product до физического прибытия"), категория фильтра —
Cruiser/Bobber/Chopper (тот же стилистический класс, что Morbidelli
C252V — круглая фара, посадка круизера, широкий руль, подтверждено по
фото), цена — идентична Morbidelli (решение владельца). 6 фото (2
реальных дилерских — Keeway/Morbidelli/Benelli/Benda шоурум на Бали, +
4 официальных маркетинговых от Keeway, решение владельца — использовать
все) обработаны тем же sharp-пайплайном (3 WebP-размера), залиты в R2.
Видео (`IMG_8559.MP4`) залито в R2 по пути `bikes/keeway-road-falcon-
250-black/video.mp4` — **рендер видео на карточке товара ещё не
реализован** (не баг, отдельная фронтенд-задача, файл готов и ждёт).
При заведении найден и исправлен баг в первой версии миграции 031 —
захардкоженный локальный `company_id` вместо lookup по `code`
(идентичный класс проблемы, что в orphaned-FK инциденте при сидинге,
см. выше) — до применения на сервере пойман и исправлен.

### Чанк Главное фото сбоку (ЗАВЕРШЁН, миграции 032-033)

Визуальный просмотр галерей всех 75 products (кроме Keeway, уже решён;
3 products без фото вообще не тронуты) — для каждого выбран кадр
"сбоку" (профиль байка) и помечен `is_hero=TRUE`; раньше thumb брался
по `sort_order=1` (произвольный кадр съёмки, не по смыслу). Технически:
контрольные листы-сетки (sharp-композит, все фото продукта на одном
изображении с номерами) вместо просмотра каждого фото по отдельности —
иначе 663 отдельных просмотра вместо ~76.

**Инцидент — 7 из 75 неверно выбраны, урок на будущее:** на мелкой
сетке (220px/ячейка) 3/4 спереди/сзади визуально путались с профилем,
когда общая композиция похожа (байк по диагонали, топкейс на багажнике,
одинаковый фон). Отличить можно только по деталям: номер+стоп-сигнал =
сзади, фара = спереди, ни то ни другое явно не видно = сбоку — при
мелком масштабе эти детали неразличимы. Владелец указал на 3 ошибки
визуально (`honda-adv-total-black-box`, `honda-adv-turquoise-box`,
`honda-pcx-green`); при пересборке сеток крупнее (380px, галерейный
размер вместо thumb) и повторной проверке всех 75 нашлись ещё 2 такие
же (`yamaha-xsr-black`, `suzuki-vstrom250-total-black-all-boxes`) и 2
уточнения к более чистому профилю. **На будущее: для визуальной сверки
множества фото — сразу крупная сетка (не экономить разрешение ради
компактности), к мелкой возвращаться только если объём совсем большой.**

Побочно найдены 2 аномалии данных в галереях (не исправлялись, ждут
отдельного решения владельца): `yamaha-nmax-pink-purple` (фото #3 —
другой байк, похоже на сток-фото), `yamaha-xmax-green-blue` (фото #1-2 —
банки с краской в магазине, не байк вообще).

### Чанк Сезонный мультипликатор цены + первая админка (ЗАВЕРШЁН, миграция 034)

**Схема:** `seasonal_multipliers` (`date_from`, `date_to`, `multiplier`,
`pricing_rule_set_id` nullable — NULL = глобальный период для всех
rule_set, не-NULL — только для конкретного). Пересечения периодов
запрещены триггером `check_seasonal_multiplier_overlap` (не обычным
`EXCLUDE`-constraint — тот не умеет асимметрично трактовать NULL-scope
как "конфликтует со всем"): глобальные между собой, глобальный с любым
scoped, scoped внутри одного rule_set между собой — scoped разных
rule_set пересекаться МОГУТ (никогда не применяются к одному booking
одновременно).

**Архитектурная находка при investigate:** весь калькулятор до этого
работал только через `rental_days` (длительность), без реальных
календарных дат — ни `/api/quote`, ни `buildQuote()` не знали
`start_date`, хотя `Calculator.jsx` уже собирал даты в state, а
`/api/bookings` уже получал `start_date` в запросе, просто не
прокидывал его в расчёт цены. **Решение владельца:** мультипликатор — по
дате НАЧАЛА аренды (конец не учитывается), без даты (каталог, форма без
выбранных дат) — множитель не применяется. `start_date` прокинут через
весь путь: `Calculator.jsx` → `/api/quote` → `buildQuote()` →
`computeBaseRental()`, и `/api/bookings`.

**Округление:** `CEIL(price × multiplier / 50000) × 50000`, всегда
вверх (`roundUpTo50k()` в `pricing.js`) — единая точка, бэкенд
единственный источник истины, фронт не дублирует.

**Админка `/internal/pricing` — первая в проекте, прецедент на
будущее:** Basic Auth в `middleware.js` (один общий пароль, env
`INTERNAL_ADMIN_PASSWORD`, не сконфигурирован → доступ закрыт по
умолчанию) на `/internal/*` и `/api/admin/*`. CRUD backend-роутер
(`seasonalMultipliers.js`) со scope-резолвингом (`global`/`current`
rule_set — клиент не оперирует UUID rule_set вручную), 409 на
пересечения (перехват DB-триггера). Next.js BFF-прокси на бэкенд, как и
остальные `/api/*`.

**Побочный технический фикс — второй root layout:** `/internal`
потребовал свой `<html>/<body>` (не наследует из `[locale]`-дерева) —
общий `app/layout.js` (был чистым passthrough) убран, `[locale]` и
`internal` стали двумя независимыми root layout (Next.js "multiple root
layouts" — официально поддерживаемый паттерн, не хак). URL/поведение
существующего сайта не меняются — подтверждено production-сборкой (все
19 маршрутов на месте). `metadataBase` перенесён в оба layout'а.

**Побочный технический фикс — сериализация DATE:** node-pg по умолчанию
парсит колонки DATE в JS Date по ЛОКАЛЬНОМУ времени машины — при
сериализации в JSON это сдвигает дату на день назад для положительных
UTC-офсетов (Bali UTC+8: `2026-12-20` отдавался как
`2026-12-19T16:00:00.000Z`). Системная проблема, не только для этой
задачи — исправлено централизованно в `pool.js`
(`types.setTypeParser(1082, v => v)`, DATE как строка `YYYY-MM-DD`).
Проверено на регресс — весь остальной код читает даты из ЗАПРОСОВ
клиента (JS-строки), не из результатов DB-запросов, так что фикс не
задевает ничего существующего.

**Верификация:** полный CRUD-цикл (create → update → 409 на
пересечение → delete) подтверждён через реальный API endpoint
(идентичный код, что вызывает форма). Расчёт с мультипликатором и
округлением проверен на `/api/quote` (690000→700000 IDR, множитель
1.15). Клик по кнопкам формы в браузере не тестировался — автоматизация
не поддерживает нативный диалог HTTP Basic Auth (только embedded-credentials
в URL, что ломает `fetch()` со страницы по спецификации браузера) — логика
подтверждена эквивалентно (прямой fetch с explicit-заголовком из консоли
страницы). Рекомендуется владельцу пройти форму глазами после деплоя.

### Чанк Видео карточки товара (ЗАВЕРШЁН, Блок 3)

Без флага в схеме: если физически существует `bikes/<slug>/video.mp4` в R2 —
рендерится `<video controls>` (без autoplay — мобильный трафик клиентов)
под галереей; нет файла — секция не появляется, ничего не меняется для
остальных products. Проверка существования — на клиенте (`onError`), не
сервером: HEAD-запрос на каждый SSR-рендер был бы лишним для вторичной
фичи.

**Два реальных бага найдены и исправлены при верификации (не были видны
на этапе кода):**
1. Middleware-матчер (`/internal` из Блока 2) исключал из локали-редиректа
   `.webp/.svg/...`, но не `.mp4` — видео 404-илось, редиректясь на
   несуществующий `/en/bikes/.../video.mp4`. Добавлено `mp4` в исключения.
2. SSR-гонка: `src` прямо в JSX заставляет браузер начать грузить видео ещё
   до гидратации React — событие ошибки на 404 успевает произойти раньше,
   чем вешается `onError`, и молча теряется (для товаров без видео блок не
   скрывался бы). Исправлено: `src` ставится через `useEffect` после mount
   компонента `ProductVideo.jsx`.
3. UX-баг: портретное видео (478×850) без `max-height` растягивалось на
   всю ширину галереи — блок раздувался на 1000px+ по высоте. Добавлен CSS
   `max-height: 480px` на `.product-video video`.

### Чанк Photo lightbox (ЗАВЕРШЁН, Блок 4)

Клик по hero/миниатюре открывает fullscreen-просмотр через библиотеку
`yet-another-react-lightbox` (осознанный выбор — swipe-жесты на тач
(velocity/direction/touch-action, focus-trap для a11y) не самописные,
библиотека активно поддерживается, ~10-15kb). Swipe на тач, стрелки/
клавиатура и счётчик "N из M" на десктопе, закрытие по X/Esc/клику вне
(`closeOnBackdropClick` не включён по умолчанию в библиотеке — включено
явно). Видео (Блок 3) сознательно НЕ включено в общую ленту — у него уже
есть свой нативный fullscreen в контролах, решение обсуждено и подтверждено
отдельным вопросом, не молча.

`ProductGallery.jsx` — новый клиентский компонент, вынес разметку
hero+thumbs из `page.js` (была инлайн-серверной, без интерактивности).

### Чанк Виджет доступных байков на главной (ЗАВЕРШЁН, Блок 5)

На синем hero-блоке главной — 2 карточки продуктов с реально доступным
`fleet_item` прямо сейчас (`fleet_items.status = 'available'`).

**Архитектурная находка при investigate:** в проекте нигде не было и нет
проверки доступности байка по датам — калькулятор считает цену только по
`rental_days`, бронирование полагается на DB-констрейнт
`no_overlapping_active_rentals` на уровне `Rental` (создаётся только при
фактической выдаче, см. `CLAUDE.md` §3.2), а не на предварительный запрос
доступности. Для виджета это оказалось даже проще, чем в исходной
формулировке задачи ("переиспользовать проверку калькулятора") — раз
переиспользовать нечего, а у виджета нет дат от посетителя, нужен только
текущий статус fleet_item, не пересечение дат.

**Известный нюанс данных (обсуждено с владельцем, осознанно строим
дальше):** `fleet_items.status` сейчас никем не поддерживается — все 56
единиц парка числятся `'available'`, т.к. CRM (v1.1) ещё не в работе.
Виджет технически корректен, но фактически будет показывать почти весь
каталог в ротации, пока статусы не начнут обновлять вручную (или
автоматически, когда подключится CRM).

Ротация без серверного состояния: `hash(cookie mdb_cid + floor(now /
30 мин))` выбирает пару из доступных продуктов; ≤2 доступных — показываем
все без ротации. Cookie анонимная (UUID), ставится в `middleware.js` при
первом визите на любой странице (год жизни), один браузер видит стабильную
пару 30 минут. Проверено: стабильность при перезагрузке с той же cookie,
смена пары при новой cookie (симуляция другого посетителя), обе локали
(en/ru), мобильная раскладка (карточки под текстом, а не сбоку).

Backend: `catalog.js` → `listProducts({ available: true })` — необязательный
фильтр через `EXISTS` по `fleet_items`, никаких полей `fleet_items` наружу
(тот же принцип сокрытия внутреннего состояния флота, что и в остальной
выдаче каталога) — только сам факт наличия.

### Чанк Коррекция replacement_group (ЗАВЕРШЁН, миграция 035)

Исправление данных, отдельное от Configuration First (собственный
коммит). Миграция 029 включила в группу взаимозаменяемости Honda
ADV/PCX/Vario + Yamaha Nmax — неверный состав. По ТЗ п.6.5 (граф
ADV → XMAX → PCX → NMAX) и подтверждению владельца, взаимозаменяемы
ADV/Xmax/PCX/Nmax; Vario остаётся в каталоге и в своих фильтрах, просто
выходит из группы замены. Согласуется с уже существовавшим правилом
CLAUDE.md §4 «Xmax — нормальный апгрейд, не крайний вариант».

Группа переименована `scooter_econ_160` → `scooter_replacement_pool`
(состав больше не «4×160cc», а 3×160cc + 1×250cc maxi-scooter).
`seed-crm.js` обновлён на новый состав/код и сделан по-настоящему
идемпотентным (сначала снимает группу со всех текущих участников,
потом назначает заново) — иначе повторный полный ресид тихо вернул бы
Vario на место Xmax.

### Чанк Configuration First — расширение `/internal/*` (ЗАВЕРШЁН, миграция 036)

Расширение единственной на тот момент админки (`/internal/pricing`,
Блок 2) до полноценной Configuration First-панели (ТЗ п.12) — 5
разделов с общей навигацией вместо разрозненных страниц.

**Общий layout:** `internal/layout.js` рендерит `InternalNav.jsx` (табы)
+ `{children}`. Basic Auth уже был на весь `/internal/*` с Блока 2 —
расширять не потребовалось. `/internal` без раздела редиректит на
`/internal/pricing`.

**Страховка** (`/internal/insurance`) — редактируется только `monthly_idr`
для 5 существующих тарифов (theft + damage×2 категории×2 покрытия), без
add/delete: `computeInsurance()` ищет ровно эти 5 фиксированных
комбинаций, произвольная новая комбинация калькулятором не используется,
а удаление одной из пяти сломало бы расчёт для неё.

**Доставка** (`/internal/delivery`) — полный CRUD тиров (в отличие от
страховки, `byDuration()` — обычный range-запрос без фиксированных
комбинаций). Защита от пересекающихся тиров — `EXCLUDE USING gist`
(миграция 036), а не кастомный триггер (как у сезонных цен): здесь нет
асимметричной NULL-as-wildcard логики, обычный range overlap внутри
одного rule_set, `btree_gist` уже подключён в 001. При подборе
миграции найден и исправлен overflow: `int4range` с `'[]'`
канонизируется в `'[)'` прибавлением 1 к верхней границе — `INT4_MAX`
как сентинел "без верхней границы" переполнялся бы; заменён на `1000000`.

**Депозит** (`/internal/deposit`) — базовая сумма
(`system_config.standard_deposit_idr`, новый `setConfig()` в
`config.js`, UPSERT по `(company_id, key)`) + CRUD исключений по модели
(`deposit_rules`). Overlap-констрейнт не нужен: `computeDeposit()` уже
разрешает несколько подходящих правил через `priority DESC LIMIT 1` —
осознанный существующий механизм, не пробел.

**Replacement Groups** (`/internal/replacement-groups`) — справочник
групп (add/edit/delete) + управление членством моделей (select на
каждой из 15 families). `DELETE` группы блокируется FK-констрейнтом
(`product_families.replacement_group_id` без `ON DELETE` = `RESTRICT`
по умолчанию), перехвачено как понятный 409.

**Общий паттерн на раздел** (переиспользован от сезонных цен):
backend Router (validate → SQL → явные коды ошибок) → регистрация в
`server.js` → BFF-прокси `/api/admin/<resource>[/[id]]` → клиентский
компонент (таблица + форма, inline-style как у `PricingAdminClient`).

**Верификация** — для каждого раздела правка через API прогонялась
через реальный `/api/quote`/`/api/products` до и после изменения
тестового значения, значение возвращалось обратно:
- Страховка: theft 400k→450k→400k, отражается в `/api/quote`.
- Доставка: пересекающийся тир отклонён 409; фикс. тир 150k→175k→150k.
- Депозит: база 1M→1.2M→1M меняет расчёт для моделей без исключения
  (Honda ADV), не трогает модели с исключением (Morbidelli, 2M).
- Replacement Groups: round-trip назначения/снятия группы на Vario;
  `DELETE` занятой группы отклонён 409.

Клик по кнопкам через браузер не тестировался (тот же известный
предел автоматизации — HTTP Basic Auth не проходит через embedded-
credentials в URL, `fetch()` из такой страницы падает по спецификации
браузера) — логика подтверждена эквивалентно, через прямой `fetch` с
explicit-заголовком. Владельцу стоит пройти все 5 разделов глазами
после деплоя.

### Грабли / нюансы (на будущее)

- **`users`: при будущем сидинге/импорте НЕ полагаться на `ON CONFLICT` по
  `email` или `telegram_id`** — оба nullable, и NULL ≠ NULL в SQL приведёт к
  дублям (та же ловушка, что была в `insurance_plans`). Для дедупа
  пользователей использовать явную проверку существования или `COALESCE`,
  либо чистку перед сидингом. Сам sparse-unique на `users` корректен (много
  пользователей без email/telegram — это норма), схему не трогаем.
- **`pg_restore --disable-triggers` на data-only дампе с pre-seeded
  lookup-таблицами — риск orphaned FK**, если у таблицы-источника
  недетерминированный PK (UUID) при unique constraint на другую колонку
  (`code`). См. разбор инцидента в чанке «Сидинг данных» выше — там же
  обязательный протокол проверки на будущее.
- **node-pg парсит DATE (OID 1082) в JS Date по локальному времени
  машины** — сериализация в JSON сдвигает дату на день назад для
  положительных UTC-офсетов. Исправлено централизованно в `pool.js`
  (`types.setTypeParser`), см. чанк «Сезонный мультипликатор» выше.
  Держать в уме при добавлении любых новых DATE-колонок, отдаваемых
  клиенту напрямую.
- **Next.js App Router: страница вне `[locale]`-дерева, которой нужен
  свой `<html>/<body>`, требует убрать общий `app/layout.js`** (не может
  быть passthrough-корнем НАД несколькими независимыми root layout) —
  см. чанк «Сезонный мультипликатор» выше (`multiple root layouts`,
  официальный паттерн Next.js, не хак). Для любой будущей страницы вне
  `[locale]` (ещё одна админка, вебхук-страница и т.п.) — сразу
  проверять, нужен ли ей свой root layout, не пытаться "досоздать"
  `<html>` в дочернем layout поверх существующего passthrough-корня.
- **Визуальная сверка большого числа фото — сразу крупная сетка, не
  экономить разрешение.** См. разбор инцидента в чанке «Главное фото
  сбоку» выше — на мелких миниатюрах 3/4 спереди/сзади визуально
  неотличимы от профиля при похожей общей композиции (диагональ,
  топкейс, тот же фон).

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
- **Фото — ГОТОВО** (чанк Photos + чанк R2 медиа): 657 фото × 3 размера (1971 WebP-
  файл — уточнено при R2-миграции, ранее ошибочно фигурировало число 648) в
  `frontend/public/bikes/` (gitignored локально) и в R2-бакете `mdb-platform-media`
  (продакшен-источник, подробности в разделе Deploy выше). `product_photos`
  заполнена (657 строк), рендер hero+галерея с метками. Скрипты
  `backend/scripts/{build_manifest.js,import_photos.js}` + `photos_manifest.json`
  идемпотентны. `is_hero` пока везде FALSE (ручная разметка «главного» фото — позже).
- **Перевод названий ПРОДУКТОВ/категорий-описаний** — остаётся (Honda ADV Chameleon
  и т.п.); архитектура переводов обкатана на оборудовании. `product_translations` пуста —
  имена пока из конструкции (brand+model+color+variant+комплектация).
- **Фронтенд — остаётся:** блог; остальные языки (de/fr/es/it/ja — структура готова,
  нужны словари). Главная/About/FAQ готовы, RU+EN активны, оборудование локализовано.
- **SEO — ПОЛНОСТЬЮ ГОТОВО** (чанк SEO enrichment layer, Шаг 0→3, подробности —
  раздел выше): metadataBase, per-locale `<html lang>`, sitemap.xml, robots.txt,
  OpenGraph/Twitter, Product JSON-LD (image+specs), LocalBusiness JSON-LD,
  canonical каталога, hreflang, favicon/apple-touch-icon/manifest, BreadcrumbList.
- **Деплой — В ПРОЦЕССЕ** (чанк Deploy, подробности — раздел выше): провайдер
  фактически **Contabo** (не Hetzner — та регистрация была отклонена), Coolify
  4.1.2, self-hosted PostgreSQL 18. Backend и frontend оба **`running:healthy`**
  на sslip.io-доменах (до DNS cutover). Миграции 34/34 применены. CI/CD на
  старте нет — миграции на боевую БД проверяются руками. **Сидинг каталога —
  ГОТОВО** (чанк «Сидинг данных», подробности выше): 55 таблиц перенесены
  `pg_dump`/`pg_restore` с dev-БД, orphaned FK после restore найден и исправлен,
  каталог live-проверен (200 на `/en/bikes`, `/ru/bikes`, карточках товара).
  **Фото на CDN — ГОТОВО** (чанк «R2 медиа», подробности выше): 1971 файл в
  R2-бакете `mdb-platform-media`, `NEXT_PUBLIC_PHOTO_BASE_URL` выставлен на
  публичный r2.dev-URL (dev-режим, замена на Custom Domain — часть будущего
  DNS-чанка), фронтенд пересобран полным ребилдом, фото визуально подтверждены
  владельцем на живом сайте.
- **Каталог: фильтры + матчинг цен + Keeway — ГОТОВО** (чанк выше, миграции
  028-031): 5 фильтров по модели скутеров вместо 2 общих, `vehicle_categories`/
  `replacement_groups` разделены, 78/78 products с ценой (37 доматчены от
  донора), новый байк Keeway Road Falcon 250 заведён (Family/Product/цена/
  фото, без Fleet Item — в заказе).
- **Главное фото сбоку — ГОТОВО** (чанк выше, миграции 032-033): визуально
  выбран боковой профиль для 75 products (`is_hero`), 7 ошибок найдено и
  исправлено (мелкая сетка путала 3/4 спереди/сзади с профилем).
- **Сезонный мультипликатор цены + первая админка — ГОТОВО** (чанк выше,
  миграция 034): `/internal/pricing` (Basic Auth), округление ВВЕРХ до 50к,
  применяется по дате начала аренды. Побочно — второй root layout
  (`internal` независим от `[locale]`) и фикс сериализации DATE в `pool.js`.
- **Видео карточки товара — ГОТОВО** (Блок 3): `<video controls>` под
  галереей, если файл физически существует; 2 реальных бага найдены и
  исправлены при верификации (middleware не пропускал `.mp4`, SSR-гонка
  теряла `onError`).
- **Photo lightbox — ГОТОВО** (Блок 4): `yet-another-react-lightbox`,
  swipe/стрелки/Esc/клик вне, видео сознательно не включено в общую ленту.
- **Виджет доступных байков на главной — ГОТОВО** (Блок 5): cookie-based
  ротация без серверного состояния; нюанс — `fleet_items.status` пока
  никем не поддерживается (все 56 units 'available'), виджет корректен,
  но пока показывает почти весь каталог до появления живых статусов.
- **Коррекция replacement_group — ГОТОВО** (миграция 035): Vario → Xmax
  (ADV/PCX/Nmax/Xmax), переименование `scooter_econ_160` →
  `scooter_replacement_pool`, `seed-crm.js` обновлён и стал идемпотентным.
- **Configuration First — расширение `/internal/*` — ГОТОВО** (миграция
  036): страховка/доставка/депозит/replacement groups — 5 разделов с
  общей навигацией, `EXCLUDE USING gist` на тиры доставки.
- Боты (`MDB_drivers_bot` и др.) на запись через `api_clients` — позже; хостинг
  ботов (Render.com) отдельно от деплоя Platform, не в периметре этого чанка.
- **Дальше по плану деплоя (не начато, ждёт отдельного OK):** DNS cutover на
  bikebalirent.com; Custom Domain для R2-бакета (замена Public Development
  URL — техдолг, см. раздел R2 медиа выше); SSL (автоматически через Traefik
  после DNS). Известный техдолг с деплоя — см. раздел выше (pricing_rule_set
  exception, output:standalone неэффективен под Nixpacks).

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
