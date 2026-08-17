# PROJECT_STATUS.md — снимок состояния MDB Platform

_Обновлено: 2026-08-12, продолжение (сессия: **Задача 7 — краш языкового
переключателя на странице статьи блога (фикс+фикс первопричины) + Задача 8 —
WhatsApp/Telegram-ссылки в 8 статьях deposit-safety (72 ссылки, dev→prod)**).

**Задача 7** (коммит `5905b34`, запушен в `origin/main`): переключатель
языка (`Header.jsx`) делал raw pathname-substitution — верно для
`/bikes/[slug]` (slug единый), но не для `/blog/[slug]`
(`article_translations.slug` per-locale) — переключение языка на статье
обычно вело на несуществующий slug → `notFound()`, а в **отсутствие
`not-found.js` где-либо под `app/`** (root-layout'а нет намеренно, только
`[locale]/layout.js`) дефолтный Next-фоллбек ломал DOM
(`HierarchyRequestError`) → белый экран вместо 404. **Фикс**: новый backend
роут `/api/blog/posts/:slug/translations` (slug статьи на всех языках по
`article_id`) + BFF-прокси + `Header.jsx` резолвит slug целевого языка на
странице статьи вместо подстановки префикса (fallback на `/{locale}/blog`,
если перевода нет) + `app/[locale]/not-found.js` — локализованный 404
(8 языков) внутри `[locale]`-layout, закрывает первопричину сайтвайд, не
только для блога. Проверено реальными кликами по всем парам с разным slug
(en↔fr/es/it/de/ru, en→ja и en→ru→ja, en↔ar с RTL-проверкой в обе стороны)
и прямыми заходами на несуществующий slug (en/ru/ar) — консоль чистая
везде. **⚠️ На проде код ещё СТАРЫЙ** (редеплой backend+frontend в Coolify
UI не выполнялся в этой сессии) — баг с крашем переключателя всё ещё живой
на bikebalirent.com до ручного редеплоя Дмитрием.

**Задача 8** (данные, без изменений в коде/коммитов — `gen_blog_sync.mjs`
переиспользован как есть): в 7 из 8 статей deposit-safety финальный CTA
("Ask us on **WhatsApp** or **Telegram**") был жирным markdown без ссылки;
статья про аварию — вообще обычным текстом в двух местах (Step 3 CTA
+ хвостовой CTA). По контактам из `frontend/src/lib/contacts.js`
(`wa.me/6282146433303`, `t.me/Bali_rent_main`, уже живые на сайте) и
переводам сообщения по 8 языкам (`{title}` — заголовок перевода той же
строки) сгенерированы 72 ссылки (56 в исходных CTA + 16 в двух местах
статьи-про-аварию) — разовый скрипт в scratchpad (не в репозитории,
одноразовая контентная правка, не переиспользуемая инфраструктура в
отличие от `gen_*_sync.mjs`). Явно проверено, что литеральная замена не
трогает несвязанные упоминания бренда текстом (в `deposit-scams` есть
фраза про "a WhatsApp number" мошенника — не задета). Применено на dev
(72/72, byte-exact decode-preview для ar/ja), проверено живым рендером
(en/ru/ar `deposit-scams` — реальные `<a href>`, RTL для ar), синхронизировано
на prod через уже существующий `backend/scripts/gen_blog_sync.mjs`
(перегенерирован `blog_deposit_safety_sync.sql`, **не менялся** —
подтверждено построчно: `status` в апсерте `articles` — жёсткий литерал
`'published'`, не читается из dev, поэтому locale draft-статус пилар-статьи
на dev не откатил уже опубликованную версию на проде). `pg_dump`-бэкап
перед применением, `docker exec psql -v ON_ERROR_STOP=1`, 72/72 подтверждено
на prod БД напрямую и живым decode на bikebalirent.com. Известная
особенность на заметку: `how-the-deposit-works-when-renting-a-bike-in-bali`
(единственная `is_pillar=true` в категории) на **dev** сейчас `status='draft'`,
на **prod** — `published` (с прошлого чанка) — не баг, `gen_blog_sync.mjs`
спроектирован это учитывать, но при следующей ручной проверке на dev не
удивляться, что пилар не отдаётся публичным API.

Подробности обеих задач — раздел «Сессия 2026-08-12 (продолжение)» и ниже
в п.4.

_Предыдущее обновление: 2026-08-12 (сессия: **чанк Blog, категория "Депозит и
безопасность" — схема → admin CRUD → контент на 8 языках → прод**, три
коммита `98c2080`/`c560070`/`a4c6c46`). Новые таблицы `article_categories`/
`articles`/`article_translations`/`article_category_translations`
(ТЗ п.4.15, pillar+cluster, миграции `047_blog.sql`+`048_blog_seed.sql`,
заменили мёртвый скаффолд из `007_website_content.sql`). Шестой раздел
Configuration First-панели — `/internal/blog`. 8 статей категории
deposit-safety (5 из исходного сида + 3 новые) переведены и опубликованы
на всех 8 языках сайта (en/ru/de/fr/es/it/ja/ar) — 64 `article_translations`,
внутренние ссылки между статьями резолвлены в реальные markdown-ссылки с
переведённым anchor text на каждом языке. Markdown-рендеринг статьи
(`react-markdown`+`remark-gfm`) добавлен — нужен был для GFM-таблицы
тарифов. Пункт "Blog" добавлен в header-меню всех 8 языков, RTL для `ar`
зеркалится браузером автоматически (без спецкода). **Найден и исправлен
реальный баг** — задвоенные/утроенные URL в 5 markdown-ссылках из-за
ложного срабатывания idempotency-проверки в одноразовом скрипте резолва
ссылок (поймано ручной построчной проверкой Дмитрия, подтверждено
исчерпывающим regex-сканом всех 64 переводов, исправлено в dev БД до
применения на прод). Полный цикл деплоя на prod (Contabo/Coolify) проведён
вручную: редеплой кода в Coolify UI, миграции через SSH+`psql`
(с `pg_dump`-бэкапом), контент синхронизирован новым
`backend/scripts/gen_blog_sync.mjs` (апсерт по `slug`, не по `id`, по
паттерну `gen_catalog_sync.mjs`). **Попутно опровергнуто предположение
из записи 2026-08-10**: автодеплоя по git push на проекте нет — проверено
напрямую (тег образа контейнера = git SHA коммита, сверено через
`git cat-file -t`). Остальные 4 категории блога (legal/bike-models/routes/
digital-nomads, 24 статьи) — всё ещё draft-заглушки, следующий чанк.
Подробности — раздел «Сессия 2026-08-11/12» в п.4 ниже.)

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
Локальная БД `mdb_platform` поднята, все миграции применены (001–048 на
момент 2026-08-12 — сверять `npm run migrate:status`, не читать число как
факт, см. п.4 ниже про расхождения dev/prod), `/health` отвечает.

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

- **i18n** — Phase 1 (8 языков, `src/i18n/config.js`, все `enabled: true`,
  по состоянию на 2026-08-12): `en`/`ru`/`de`/`fr`/`es`/`it`/`ja`/`ar`
  (арабский — RTL, `dir="rtl"` на `<html>`, зеркалится браузером
  автоматически). Сегмент `[locale]`, middleware-редирект на Accept-Language
  на голом домене (см. «Сессия 2026-08-10, продолжение»), фолбэк — `en`.
  Все строки — через словари (`frontend/src/i18n/dictionaries/*.json`, по
  файлу на язык). Категории фильтра локализованы через `dict.cat` (по
  `code`, fallback на имя из API).
- **Бренд-тема** (эволюция bikebalirent.com): navy `#1C2C6E` / red `#D52125`,
  шрифты Teko (заголовки) / Poppins (текст) через `next/font`.
- **Каркас:** Header (логотип, меню, рабочий переключатель языка EN|RU —
  меняет сегмент локали в текущем пути, гамбургер), Footer (контакты,
  брендовые иконки WhatsApp/Telegram/Instagram/Email, сетка 2 колонки),
  плавающая кнопка WhatsApp/Telegram в правом нижнем углу на всех страницах
  (`FloatingContactButton.jsx`, монтируется в `[locale]/layout.js`,
  локализованная подпись-приглашение, см. «Сессия 2026-08-16»).
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
  менеджерам шлёт backend — фронт не дублирует. Поля WhatsApp/Telegram — с
  «залипающим» префиксом `+`/`@` (курсор после фокуса сразу за ним, серый
  пример формата гаснет при вводе, `PrefixInput.jsx`). Экран успеха — вместо
  пассивного текста 2 CTA-кнопки (WhatsApp/Telegram, единая формулировка,
  отличается только имя мессенджера), предзаполненное сообщение несёт номер
  заявки + модель/даты (см. «Сессия 2026-08-16»).
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

### Чанк Визуальный редизайн главной + фикс фильтров (ЗАВЕРШЁН)

**Блок A — фильтры каталога.** Investigate показал расхождение с
описанием задачи: текущая структура была ОДНОЙ строкой (10 плоских
чипов `vehicle_categories`, `overflow-x:auto` скролл), не двумя —
верхнего уровня «Мотоциклы/Скутеры» в коде не существовало вовсе
(похоже, описание из планирования, ещё не реализованное). Добавлен
верхний таб (Все/Скутеры/Мотоциклы) — группировка жёстко во frontend
(`lib/categoryGroups.js`, фиксированная таксономия типа кузова, не
бизнес-правило через Config First). Yamaha Xmax 250 (макси-скутер) —
в «Скутеры», ровно 5/5 к «Мотоциклы». Клик по табу реально фильтрует
товары — backend расширен на фильтр по НЕСКОЛЬКИМ категориям разом
(`category=a,b,c`), сам не знает про понятие «группа». Нижний ряд —
`flex-wrap` вместо скролла.

**Блок B — hero-фон.** Реальное фото (Suzuki V-Strom, тропический фон)
+ фирменный navy-градиент. Взят оригинал в высоком разрешении
(5712×4284 HEIC) напрямую с Google Drive, а не апскейл уже уменьшенной
R2-версии (1200w) — качество заметно лучше. Заодно поправлены карточки
виджета доступности (Блок 5) — увеличиваются под свободное место на
широких экранах (480px → 620px), раньше оставались мелкими фиксированного
размера.

**Блок C — полоска доверия** (доставка/страховка/депозит/поддержка
08:00–19:00) — формулировки взяты из существующих FAQ/footer, не
выдуманы.

**Блок D — «Как это работает»** — 4 шага, визуальный язык как у
«Почему мы».

**Блок E — витрина 6 моделей** — жёстко зафиксированный список
slug'ов, критерий отбора — РАЗНООБРАЗИЕ парка (эконом-скутер →
макси-скутер → турист-эндуро → круизер → спорт → нейкед-классика), не
«популярность»: реальных данных о частоте бронирований пока нет
(CRM — v1.1+). Переиспользует существующий `BikeCard.jsx`.

**Блок F — отзывы (ПЛЕЙСХОЛДЕР).** `data/reviews.placeholder.json` —
4 примера EN/RU, явно помечены `_note` в файле. Без формы/админки —
добавление вручную Claude Code по мере поступления реальных отзывов
от Дмитрия (папка со скриншотами ожидается отдельно). Instagram/Meta
API — сознательно не подключено, отложено.
**УСТАРЕЛО с 2026-08-03** — плейсхолдер заменён реальными отзывами,
см. раздел «Сессия 2026-08-03» ниже.

Верифицировано по всем блокам: desktop + мобильная эмуляция, EN + RU,
консоль чистая, фото карточек грузятся. `MDB_Platform_TZ.docx` (п.3.2/4.11)
обновлён заранее в этой сессии — реализация сверена по факту, расхождений
кроме уже озвученного (структура фильтров) не найдено.

### Чанк HTTPS на временных доменах + пропущенный редеплой backend (НАЙДЕНО И ИСПРАВЛЕНО)

**Баг 1 — HTTPS вообще не работал (не только на `/internal`, а на всём
сайте).** Симптом: "no available server" (Traefik) на любом HTTPS-запросе;
plain HTTP при этом работал. Корневая причина — найдена напрямую в БД
Coolify (`applications.fqdn`): оба приложения (`mdb-platform-frontend`,
`mdb-platform-backend`) были сохранены со схемой `http://`, а не
`https://`. Coolify по этому полю решает, генерировать ли Traefik-роутер
с TLS и запрашивать ли сертификат Let's Encrypt — при `http://` роутер
для HTTPS не создаётся вообще (не "сертификат не выпустился", а "его
никто не просил"). Перезапуск `coolify-proxy` ничего не менял (ожидаемо
— проблема не в Traefik, а в отсутствующих Docker-лейблах). Исправлено
Дмитрием через Coolify UI: домен обоих apps переключён на `https://`,
после чего Coolify сам создал HTTPS-роутер и Let's Encrypt выдал
сертификат. **Проверено напрямую на сервере, не по статусу "healthy" в
Coolify** (см. грабли ниже): `acme.json` вырос с 0 байт до ~28KB,
`openssl s_client` подтверждает реальный сертификат (`issuer=Let's
Encrypt`, valid до 2026-10-22), прямые HTTPS-запросы с правильным SNI
(`--resolve ...:443:127.0.0.1`) к главной/каталогу/карточке товара на
обоих доменах — 200.

**Баг 2 — после пуша Блоков A-F закреплён только frontend, backend
остался на старом коммите.** Дмитрий обновил только
`mdb-platform-frontend` в Coolify; `mdb-platform-backend` продолжал
работать на коммите `e41b0b5` (до Блока A). Новый двухуровневый фильтр
каталога (Блок A) отправляет `?category=code1,code2,...` (несколько
категорий разом) — старый backend такого не понимает, валидирует всю
строку как один код, отдаёт 400, а необработанное исключение в
Server Component превращается в "Application error: a server-side
exception has occurred" на фронте. Старые (одиночные) фильтры работали
все это время, потому что этот путь в коде не менялся — отсюда и
путаница "часть фильтров работает, часть нет". Исправлено редеплоем
`mdb-platform-backend`. Оба контейнера подтверждены на актуальном
коммите (`79b5a2b`) через `docker ps --format`, фильтр проверен напрямую
через `/api/products?category=...` внутри контейнера (200, count:55).

**Итоговый статус на конец сессии:** HTTPS работает на обоих временных
sslip.io-доменах, оба приложения на актуальном коде, фильтры каталога
(включая новые "Скутеры"/"Мотоциклы") подтверждены рабочими. **DNS
cutover на боевой домен (`bikebalirent.com` или похожий) — отдельная,
всё ещё не начатая задача**, не путать с тем, что HTTPS теперь в принципе
работает на промежуточных доменах.

### Грабли / нюансы (на будущее)

- **Coolify "Running (healthy)" НЕ означает, что HTTPS реально работает** —
  это статус контейнера/health-check приложения, не проверка
  TLS-роутинга Traefik. Домен приложения должен быть сохранён как
  `https://` (не `http://`) в настройках Coolify, иначе HTTPS-роутер и
  сертификат не создаются вообще — симптом снаружи "no available
  server", а UI при этом продолжает показывать зелёный healthy.
  Проверять фактически: `acme.json` не пустой + `openssl s_client
  -servername <домен>` показывает реальный issuer, либо прямой
  HTTPS-запрос с `--resolve <домен>:443:127.0.0.1`.
- **После пуша — редеплоить ОБА приложения (frontend И backend), не
  только то, что визуально поменялось.** Фронтенд-изменение, которое
  зависит от нового backend-эндпоинта/параметра (как фильтр по
  нескольким категориям в Блоке A), молча ломается, если backend не
  подтянул новый код — старый backend отвечает 400/500, необработанное
  исключение всплывает как общий "Application error" без намёка на
  причину. Проверять коммит на обоих контейнерах: `docker ps --format
  '{{.Names}}\t{{.Image}}'` — тег образа = хэш коммита.
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
- **`app.use('/api', requireInternalToken, router)` в Express гейтует путь
  `/api` целиком, не конкретный `router`** — любой непойманный запрос,
  провалившийся через более ранние публичные роутеры, перехватывается
  ПЕРВЫМ таким гейтом, даже если реальный обработчик определён в более
  позднем, негейтованном роутере. Если в роутере есть хоть одна публичная
  ручка — гейтить `requireInternalToken` точечно на конкретных
  route-handler'ах, не через общий `app.use`, и монтировать роутер до
  первого такого гейта. См. разбор инцидента в чанке «Инцидент: коммит
  `4d500db`» выше — оттуда же правило: перед гейтингом существующего
  роутера целиком проверять `grep` по `frontend/src` на прямых публичных
  потребителей, и после деплоя auth-изменений проверять живой эндпоинт, а
  не то, что контейнер просто на нужном коммите.

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
- **Блог — категория deposit-safety ГОТОВА и задеплоена на прод** (сессия
  2026-08-11/12, подробности — раздел ниже): 8 статей × 8 языков (en/ru/de/
  fr/es/it/ja/ar), опубликованы, `/internal/blog` работает. WhatsApp/Telegram
  CTA во всех 8 статьях — теперь реальные кликабельные ссылки с prefill-
  сообщением на языке статьи (72 ссылки, сессия 2026-08-12 продолжение 2,
  Задача 8 — применено и на dev, и на prod). **Остаётся:**
  4 категории (legal/bike-models/routes/digital-nomads, 24 статьи) — на
  dev и prod всё ещё draft-заглушки (en title/slug из сида), нужен тот же
  цикл контент→перевод→ссылки→publish→sync, что прошла deposit-safety.
  Остальные 8 языков сайта (не только блог) — de/fr/es/it/ja/ar активны,
  словари заполнены (см. `frontend/src/i18n/dictionaries/*.json`).
- **⚠️ Языковой переключатель на странице статьи блога — краш пофикшен в
  коде (коммит `5905b34`, Задача 7, сессия 2026-08-12), но НЕ на проде** —
  редеплой backend+frontend в Coolify UI не выполнен, prod всё ещё крашится
  при переключении языка на `/blog/[slug]` (код там — `a4c6c46`). Первое,
  что стоит сделать в следующей сессии, если она про блог/прод.
- **SEO — ПОЛНОСТЬЮ ГОТОВО** (чанк SEO enrichment layer, Шаг 0→3, подробности —
  раздел выше): metadataBase, per-locale `<html lang>`, sitemap.xml, robots.txt,
  OpenGraph/Twitter, Product JSON-LD (image+specs), LocalBusiness JSON-LD,
  canonical каталога, hreflang, favicon/apple-touch-icon/manifest, BreadcrumbList.
- **Деплой — ЗАВЕРШЁН, включая DNS cutover** (чанк Deploy, подробности —
  раздел выше + «Сессия 2026-07-30» ниже): провайдер фактически **Contabo**
  (не Hetzner — та регистрация была отклонена), Coolify 4.1.2, self-hosted
  PostgreSQL 18. Backend и frontend оба **`running:healthy`**. **DNS cutover
  на `bikebalirent.com` — ЗАВЕРШЁН 2026-07-30**: NS на Cloudflare, A+AAAA на
  Contabo, реальные Let's Encrypt сертификаты на apex и `www` (подтверждено
  напрямую на сервере, не по статусу Coolify), `SITE_ENV=production`
  включён, индексация открыта, sitemap принят Search Console. Временные
  sslip.io-домены больше не в Domains (убраны перед первым выпуском
  сертификата боевого домена, во избежание ACME rate-limit). Email
  (MX/SPF/DKIM/DMARC) остаётся на Hostinger, не переносился. **WordPress на
  Hostinger физически ещё не отключён** — открытый вопрос, ждёт решения
  Дмитрия. Миграции 36/36 по коду — но этой
  цифре нельзя доверять вслепую: минимум `036` была применена руками мимо
  `migrate.js` в какой-то момент и не попала в `schema_migrations`,
  вскрылось только 25.07.2026 при обычном `npm run migrate` (тот же паттерн
  словили независимо и на dev). Перед тем как полагаться на "N/N применены"
  — перепроверять `npm run migrate:status`, не читать это как факт. CI/CD на
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
- **Визуальный редизайн главной + фикс фильтров — ГОТОВО**: двухуровневый
  фильтр каталога, hero-фон с реальным фото, полоска доверия, «Как это
  работает», витрина 6 моделей, отзывы (Блок F — плейсхолдер-данные,
  ждут реальных отзывов от Дмитрия).
- Боты (`MDB_drivers_bot` и др.) на запись через `api_clients` — позже; хостинг
  ботов (Render.com) отдельно от деплоя Platform, не в периметре этого чанка.
- **DNS cutover на bikebalirent.com — ЗАВЕРШЁН 2026-07-30**, подробности —
  раздел «Сессия 2026-07-30» ниже. Остаётся: Custom Domain для R2-бакета
  (замена Public Development URL — техдолг, см. раздел R2 медиа выше);
  решение по срокам отключения WordPress на Hostinger (открытый вопрос,
  не техдолг — ждёт решения владельца). Известный техдолг с деплоя — см.
  раздел выше (pricing_rule_set exception, output:standalone неэффективен
  под Nixpacks).

### Сессия 2026-07-29 — деплой пересборки фото + доводка каталога (ЗАВЕРШЕНО)

- **Прямой SSH на прод — рабочий, задокументирован** (см. CLAUDE.md §6):
  `~/.ssh/mdb_platform_new` → `root@169.58.60.244`, прямой `docker
  exec`/`docker cp` в контейнер Postgres (`xw6ykwjdrdmtly2qg8kbd16m`). До
  этого использовали R2 (`_deploy_tmp/` префикс в `mdb-platform-media`) как
  курьер файлов через Coolify-браузер-терминал — рабочий запасной вариант,
  если SSH недоступен, но SSH напрямую сильно проще.
- **Redeploy на `fd1da26` — сделан** (backend+frontend, Coolify UI), затем ещё
  один на `dc7758e` (breadcrumb, см. ниже) — оба `running:healthy`.
- **R2-синк фото — повторный, после пересборки прошлой сессии**: 1715 файлов
  (было 1971 — часть дублей снесена), `aws s3 sync --delete`. Найден и
  исправлен баг: `--content-type image/webp` ставился всем файлам синком,
  включая 35 `.mp4` — перезалиты отдельно с `video/mp4`.
  `backend/scripts/gen_catalog_sync.mjs` — генератор SQL-снапшота
  `product_families`/`products` (апсерт по `id` — ОК, id стабильны) и
  `product_photos` (**полная замена** `DELETE`+`INSERT` без `ON CONFLICT` —
  id фото genereruются заново при каждой локальной пересборке, апсерт по id
  между машинами никогда не совпадёт). Итог на проде: 19 families / 101
  products / 560 photos — 1:1 с dev.
- **Ловушка при синке**: у части сущностей (Keeway family+product,
  созданных вручную на каждой стороне независимо — см. CLAUDE.md §3.1) id
  разошлись между dev и prod несмотря на одинаковый бизнес-ключ
  (`company_id`+`code` / `slug`) — руками сопоставлены и remap'нуты один раз
  перед синком. На будущее: если появится новая сущность, заведённая
  вручную на проде отдельно от обычного dev→prod потока — проверять этот
  же класс проблемы.
- **Цены заполнены — 22 продукта, которых не было при первом сидинге
  каталога** (Frankenstein/D-Tracker/Scorpio/Byson/MT-25-варианты/ADV
  white-варианты/PCX white+pink-teal+dark-pink-abs/Versys-topbox/Ronin-2):
  у 21 из них в БД был constructed-anchor stub (5 дней из 30 — 3/7/14/21/30,
  подобранные вручную под конкретный донор в прошлой сессии), у одного
  (`honda-pcx-dark-pink-abs`) — вообще 0 строк (новый продукт, прод не видел
  его раньше). Донора для каждого определили программно (сверка полных
  30-дневных кривых, не только 5 точек) — три реальных тарифных «уровня»
  переиспользуются между моделями (MT-25/V-Strom, Honda ADV/Yamaha XSR,
  Honda PCX) плюс 2 модели с собственным уровнем (Versys, Ronin).
  `backend/scripts/fill_missing_prices.mjs` (локально) +
  `gen_price_sync.mjs` (генератор апсерта на прод по бизнес-ключу
  `rule_set_id+product_id+rental_days`, НЕ по id). Применено и локально, и
  на проде — 101/101 products с полными 30 днями на обеих сторонах.
- **Breadcrumb на карточке товара — ЗАВЕРШЁН и задеплоен** (коммит
  `dc7758e`): раньше кнопка "назад" с карточки всегда вела на `/bikes` без
  фильтра. Теперь `BikeCard` прокидывает активный `group`/`category`/`model`
  в ссылку карточки, страница товара строит полный путь (Главная → Байки →
  группа → категория|модель → товар) кликабельными шагами — под каждым
  уровнем можно вернуться. `BackLink.jsx` (router.back()-эвристика) удалён
  как избыточный.
- **7 переименований карточек** (см. чат за 2026-07-29 за деталями по
  каждой) — правки `products.color_name`/`variant`/`print_name`, применены
  локально и на проде тем же прямым SQL через SSH.
- **OG-превью фото заменено** на `photo_2024-06-17_03-32-55.jpg` из папки
  «Проф» (Drive) — пересжато в `frontend/public/og-preview.webp` (1200×900,
  webp q82, тем же пайплайном sharp, что и обычные фото).
- **Известный баг, не исправлен — видео без звука.** Причина найдена:
  `backend/scripts/resync_lib.mjs` → `attachVideo()` вызывает `ffmpeg` с
  флагом `-an` (явно "no audio") при конвертации исходников под сайт — звук
  вырезается на каждой пересборке. Фикс тривиальный (убрать `-an`, добавить
  `-c:a aac`), но применение — на 35 видео, для каждого нужно найти исходный
  файл (у видео, в отличие от фото, нет `source_url`-записи в БД — маппинг
  собирался вручную в прошлой сессии и не сохранился; ближайший источник —
  та же папка на Drive, что и фото продукта, через
  `product_photos.source_url`). **Осознанно отложено в отдельный чат** —
  большой объём, не связан с остальными задачами сессии.

### Сессия 2026-07-30 — Telegram/аналитика + DNS cutover + открытие индексации (ЗАВЕРШЕНО)

- **Telegram-хендл сайта исправлен** (коммит `592da3a`): `@rents_manager`
  был неверным, везде заменён на `@Bali_rent_main`
  (`frontend/src/lib/contacts.js`, `Footer.jsx` — оба места, где хендл был
  захардкожен отдельно от `contacts.js`). Заодно добавлена сноска "24/7 by
  planned request" к часам работы — на About-странице (через новый экспорт
  `HOURS_NOTE` из `contacts.js`, отдельно от `HOURS`, чтобы не сломать
  формат `openingHours` в LocalBusiness JSON-LD) и в футере (переведено на
  все 8 языков, новый ключ `footer.hours_note` в словарях).
- **Google Ads conversion tag добавлен** (коммит `b365253`):
  `gtag.js` для `AW-17065885486` в `[locale]/layout.js` через `next/script
  (strategy="afterInteractive")`, без привязки conversion action —
  Дмитрий линкует сам в кабинете Google Ads. Подтверждено рабочим через
  Google Tag Assistant (события "Просмотр страницы"/"Ремаркетинг" уходят).
  Попутно обнаружено (не наш код, факт аккаунта): к этому Google Ads
  аккаунту на уровне Google уже привязаны GA4-свойство `G-S6RSSC9KFW` и
  ещё два Google tag контейнера (`GT-KDB22DZQ` — старый, с WordPress через
  Site Kit; `GT-MJJMJZM7`) — пригодится, если будем добавлять GA4 на
  платформу отдельно.
- **DNS cutover на `bikebalirent.com` — ЗАВЕРШЁН.** Хронология и реальные
  баги по пути (не гипотетические — каждый подтверждён логами/`openssl`
  напрямую на сервере):
  - NS делегирован на Cloudflare (`kirk.ns.cloudflare.com` +
    `elinore.ns.cloudflare.com`), пропагация подтверждена быстро (низкий
    TTL). A-запись → `169.58.60.244` (Contabo), режим DNS only (без
    Cloudflare proxy/orange cloud) — намеренно, чтобы Traefik сам управлял
    TLS через Let's Encrypt.
  - **Баг 1 — протухшая AAAA-запись.** При переключении A на Contabo про
    AAAA (IPv6) забыли — она всё ещё указывала на Hostinger
    (`whois` подтвердил `netname: HOSTINGER-HOSTING`). Раскопано только
    потому, что IPv4-happy-eyeballs клиенты не показали бы проблему явно,
    а IPv6-приоритетные — молча продолжали бы видеть старый WordPress.
    Нашли настоящий публичный IPv6 Contabo-сервера через SSH
    (`ip -6 addr show scope global` на `eth0`): **`2a02:c207:2345:9293::1`**
    (не путать со вторым адресом на интерфейсе `br-...` — это
    docker-мост, `fd85:...`, приватный ULA, не публичный). Подтвердили,
    что Traefik слушает и файрвол не блокирует (`ss -tlnp`, `ufw`/
    `ip6tables` — оба открыты) прежде чем прописывать. AAAA обновлена на
    этот адрес в Cloudflare.
  - **Баг 2 — первый ACME-запрос на боевой домен провалился именно
    из-за бага 1.** При первом Redeploy с доменом `bikebalirent.com` в
    Coolify Traefik попытался пройти Let's Encrypt HTTP-01 challenge —
    и, как положено по стандарту, сначала через IPv6, который на тот
    момент ЕЩЁ указывал на Hostinger → получил `404` от WordPress на
    challenge-файл → сертификат не выпустился, Traefik откатился на
    самоподписанный `TRAEFIK DEFAULT CERT`. Причина найдена не гаданием, а
    прямым чтением `docker logs coolify-proxy` (`ERR Unable to obtain ACME
    certificate ... 404`). После фикса AAAA — второй Redeploy выпустил
    настоящий сертификат с первого раза (использована 1 из 5 попыток
    Let's Encrypt failed-validation лимита за час — фактор осознанно
    держали в уме перед повторными Redeploy).
  - **Баг 3 — `www.bikebalirent.com` не заработал сам по себе.** Даже
    после того как apex-домен получил нормальный сертификат, `www`
    продолжал отдавать `TRAEFIK DEFAULT CERT`. Настройка Coolify
    "Direction: Allow www & non-www" в dropdown уже стояла правильно, но
    сама по себе роутер под `www` не создавала — потребовалось отдельно
    (а) дописать `https://www.bikebalirent.com` в поле Domains через
    запятую и (б) нажать отдельную кнопку **Set Direction** (с
    типизированным подтверждением Application URL) — это два разных
    действия в Coolify UI, а не одно. После обоих — `www` получил свой
    собственный Let's Encrypt сертификат.
  - **Важный нюанс на будущее — сеть песочницы агента ненадёжна именно
    для домена `bikebalirent.com`.** В процессе диагностики `curl
    --resolve bikebalirent.com:443:169.58.60.244 ...` из Bash-песочницы
    агента один раз показал "настоящий" Let's Encrypt сертификат и
    контент WordPress — хотя реальный ACME-стор на сервере (`acme.json`)
    в этот момент вообще не содержал сертификата для этого домена. Похоже,
    что-то в исходящей сети песочницы делает SNI-based перехват именно
    для этого реального публичного домена, игнорируя `--resolve`, и
    подключает к боевому Hostinger-сайту вместо указанного IP.
    **Единственный надёжный способ проверки для этого домена — SSH
    напрямую на сервер (`ssh -i ~/.ssh/mdb_platform_new root@169.58.60.244`)
    и `curl`/`openssl s_client` оттуда**, не из собственной сети агента.
    Для sslip.io-доменов такой проблемы не было.
  - `SITE_ENV=production` выставлен в Coolify **только у frontend**
    (backend эту переменную вообще не читает) → `IS_PRODUCTION=true` в
    `site.js` → `robots.txt` теперь `Allow: /` вместо `Disallow: /`,
    индексация открыта.
  - **Баг 4 — забытая `NEXT_PUBLIC_SITE_URL` ломала sitemap.xml.** Ещё с
    этапа стейджинга в Coolify была отдельно выставлена переменная
    `NEXT_PUBLIC_SITE_URL` на sslip.io-адрес — она имеет приоритет над
    дефолтным `https://bikebalirent.com` в `site.js` и не связана с
    `SITE_ENV`. Из-за неё все 840 URL в `sitemap.xml` указывали на
    `http://<sslip.io-домен>/...`. Найдено проверкой содержимого
    sitemap, не предположением. Переменная удалена из Coolify (не
    заменена — дефолт в коде и так верный), после Redeploy все 840 URL
    стали `https://bikebalirent.com/...`.
  - **Google Search Console — сабмит sitemap падал трижды подряд**
    ("Недопустимый адрес файл Sitemap"), хотя все серверные проверки
    (редиректы, `Content-Type: application/xml`, ответ под User-Agent
    Googlebot) были чистыми на 100%. Оказалось — проблема интерфейса
    Search Console: относительный путь `sitemap.xml` в поле формы
    мгновенно (без реальной попытки скачивания) отклонялся как
    невалидный для Domain property. Сабмит **полного URL**
    (`https://bikebalirent.com/sitemap.xml`) прошёл с первого раза.
    Полезно помнить для будущих доменов/проектов.
  - Email (MX → `mx1/mx2.hostinger.com`, `autoconfig`/`autodiscover`,
    3×DKIM CNAME, SPF TXT, DMARC TXT) **сознательно не тронут**, остаётся
    на Hostinger — перенос почты не входил в объём этой сессии,
    независимая будущая задача.
- **Открытый вопрос на конец сессии: когда физически отключать
  WordPress-хостинг на Hostinger.** DNS больше на него не указывает, но
  сам сайт там ещё жив и отвечает — решение (отключать сразу или подождать
  несколько дней, пока Google переиндексирует boевой домен и не останется
  "хвостов" старой версии в поиске) осталось за Дмитрием, не принято.
- **Напоминание из раздела «Конфигурация Claude Code — временная» выше**:
  там прямо написано, что DNS cutover — естественный момент вернуться и
  сузить `bypassPermissions` до целевого набора правил. Cutover теперь
  завершён — переключение permissions всё ещё не сделано, ждёт решения
  Дмитрия (это его пункт, не должно делаться молча).

### Сессия 2026-08-03 — Блок F: реальные отзывы вместо плейсхолдера (ЗАВЕРШЕНО локально, деплой ждёт решения)

- **Удалены выдуманные отзывы.** `data/reviews.placeholder.json` (Emma, Lukas,
  Anastasia, James, 5★) стоял на проде под заголовком «Real trips, real bikes».
  Аудитория сайта включает de/fr/es/it — в ЕС фейковые отзывы прямо запрещены
  (Omnibus Directive), поэтому замена была не косметической.

- **Формат — гибрид: текст + оригинал по клику.** Обсуждался вариант «только
  скриншоты»; отклонён по трём причинам, которые стоит помнить, если вопрос
  вернётся: скриншот не переводится на 8 языков (обнуляет i18n), не
  индексируется (блок отзывов — самый keyword-плотный текст на главной) и
  весит ~290 КБ поверх LCP. Обратное — «только текст» — теряет единственное
  преимущество скриншота, достоверность. Итог: карточка несёт переведённый
  текст, кнопка «показать оригинал» открывает скриншот переписки в `<dialog>`.
  Картинки не грузятся до клика (проверено: 0 запросов при загрузке страницы).

- **Данные — `frontend/src/data/reviews.json`**, 7 отзывов × 8 языков.
  Структура полей намеренно повторяет будущие таблицы `reviews` +
  `review_translations` (§3.8), перенос в БД будет механическим. Порог для
  переезда в БД + раздел `/internal` — ~20-25 отзывов ИЛИ желание Дмитрия
  добавлять их самому; на 7 штуках админка = усложнение вопреки §2.3.
  Узкое место масштабирования — НЕ хранилище (R2 переварит тысячи), а перевод
  на 8 языков, ~10 минут ручной работы на отзыв.

- **Чего в данных сознательно нет.** `rating` — в WhatsApp клиент звёзд не
  ставит, 5★ были бы выдуманы; по той же причине блок не отдаёт Schema.org
  `Review`/`aggregateRating` (на собственных отзывах о себе Google всё равно
  не даёт rich-результатов — self-serving reviews). `name`/`date` заполнены
  только там, где реально известны из переписки (Manu, Fab) — остальные
  `null`. Дмитрий может дописать имена/даты из WhatsApp, это одна строка на
  отзыв в JSON.

- **Скриншоты — `backend/scripts/prep_reviews.mjs`** (кроп + WebP 900w,
  7 файлов / 292 КБ). Кроп двухрежимный: auto (граница ищется по дисперсии
  строки — градиентная подложка сторис однородна по X, чат нет) и manual
  для кадров, где надо вырезать НАШИ реплики: просьбу об отзыве и промо
  Instagram (IMG_2745), договорённость о возврате (IMG_2748), нашу реплику
  сверху (IMG_2749). Публикуем только то, что написал клиент.
  `IMG_2747` отброшен — сообщение про helmetsack, не отзыв.
  Файлы лежат в `frontend/public/reviews/` (в отличие от `bikes/` НЕ
  gitignored — 292 КБ, и это даёт same-origin fallback для локальной разработки).

- **Верифицировано** в браузере: DE/RU/AR + мобильная ширина, консоль чистая,
  RTL корректен (`margin-inline-start: auto`), лайтбокс закрывается по Esc и
  клику по подложке, горизонтального скролла нет. Раскладка — CSS `columns`,
  а не grid: отзывы от одной строки до 700 знаков, в grid короткие карточки
  растягивались до высоты длинной (613px против 160px). Текст клипается на
  12 строках — визуально, в DOM он целиком (индексируется, читается скринридером).

- **Залито и запушено:** скриншоты в R2 (`reviews/`, 7 объектов, все отдаются
  с CDN 200/`image/webp`), коммит `d4dbfc0` в `origin/main`. Остаётся Redeploy
  в Coolify UI — автодеплоя по пушу нет.

- **Процедуры добавления и удаления отзыва — в `DEPLOY_RUNBOOK.md`**, раздел
  «Постоянные процедуры». Ключевое в удалении: убрать объект из `reviews.json`
  НЕДОСТАТОЧНО — скриншот останется в R2 доступным по прямой ссылке навсегда,
  надо `aws s3 rm` + удалить запись из `SOURCES` в `prep_reviews.mjs` (иначе
  следующий прогон скрипта зальёт файл обратно).

### Аудит публичного доступа к R2 (2026-08-03)

Повод — вопрос Дмитрия «почему бакет публичный, не надо ли его закрыть».
Проверено фактически, не по документации:

| Проверка | Результат |
|---|---|
| Анонимный PUT / DELETE | 401 — закрыто |
| Листинг содержимого (r2.dev, `?list-type=2`, S3-endpoint) | 404 / 404 / 400 — закрыто |
| Посторонние файлы в бакете | нет: 1722 объекта, только `bikes/` и `reviews/`, все `.webp`/`.mp4` |
| Остатки `_deploy_tmp/` (использовался под перекидку данных) | вычищен, отсутствует |
| S3-ключи в репозитории | нет, только `~/.aws/credentials` |

**Вывод: дырки нет и «закрывать» бакет нельзя** — это origin картинок
публичного сайта, браузер анонимного посетителя обязан забирать их без ключей.
Публичен ровно доступ на чтение по известному ключу, что и требуется.
Техдолг остаётся один и он не про безопасность: переезд с r2.dev на
`cdn.bikebalirent.com` (процедура — в `DEPLOY_RUNBOOK.md`).

### Coolify: HTTPS включён, попутно НЕЧАЯННО обновлён 4.1.2 → 4.2.0 (2026-08-03)

**Сделано и работает:** `coolify.bikebalirent.com` (A-запись на Cloudflare,
DNS only) + поле `URL` в Settings → Configuration → General. Traefik выпустил
Let's Encrypt (CN=`coolify.bikebalirent.com`, до 2026-11-01), панель отдаётся
по HTTPS, вход проверен. **Пароль и сессионная кука больше не ходят открытым
текстом — исходная проблема закрыта.**

⚠️ **Coolify обновился с 4.1.2 до 4.2.0 незапланированно.** Причина —
`docker-compose.prod.yml:3`: `coolify:${LATEST_IMAGE:-latest}`, а `LATEST_IMAGE`
в `.env` НЕ задан. 22.07 при установке `latest` и был 4.1.2, за 11 дней тег
уехал вперёд. Команда `docker compose up -d` (запускалась ради привязки порта)
подтянула 4.2.0 и пересоздала контейнер. Миграции прошли, всё healthy, сайт не
пострадал. **Откат на 4.1.2 не делать** — миграции БД Coolify только вперёд,
даунгрейд после успешной миграции ломает панель сильнее, чем текущее состояние.

**Вывод на будущее: не трогать стек Coolify командами `docker compose` без
явного согласования.** Любой `up -d` на этом стеке = потенциальный апгрейд
control plane, потому что тег плавающий. Если апгрейд когда-то понадобится
управляемый — сначала прописать `LATEST_IMAGE=<версия>` в `.env`.

### ✅ R2 Custom Domain — `cdn.bikebalirent.com` (2026-08-03, ЗАВЕРШЕНО)

Медиа переехало с Public Development URL на собственный домен. Техдолг,
висевший с первой R2-миграции, закрыт.

**Проверено на живом сайте после редеплоя:**

```
главная:   23 ссылки на cdn.bikebalirent.com,   0 на r2.dev
каталог:  198 ссылок на cdn.bikebalirent.com,   0 на r2.dev
7 скриншотов отзывов → 200, размеры совпадают с локальными до байта
фото байков          → 200
старый r2.dev        → 200 (жив намеренно, страховка для отката)
сертификат           → Google Trust Services через Cloudflare, до 2026-11-01
DNS                  → 188.114.96.3 / 188.114.97.3 (анкаст, проксируется — верно)
```

**Правку БД не потребовалось делать:** в `product_photos` 560 строк и **ноль**
с заполненным `cdn_url` — все URL строятся из `NEXT_PUBLIC_PHOTO_BASE_URL` +
`storage_path`, поэтому смена одного env-значения покрыла и фото, и скриншоты
отзывов (`resolveReviewScreenshotUrl` использует ту же базу).

**Грабли, на которые наступили (описаны в `DEPLOY_RUNBOOK.md`):** в Coolify
каждая переменная существует ДВАЖДЫ — `is_preview=false` (Production) и
`is_preview=true` (Preview). Попытка добавить новую через «+ Add» с уже
существующим именем молча не сохраняется: значение осталось старым, и это
обнаружилось только прямым запросом в БД Coolify. Правильно — редактировать
существующую строку в секции Production. Проверять значение до редеплоя, а не
после: экономит целый цикл сборки.

**Minimum TLS поднят с 1.0 до 1.2** (сделано Дмитрием).

**✅ Кэш работает.** Проверено на холодном объекте: первый GET → `MISS`,
второй и третий → `HIT` с растущим `age`.

1. `Cache-Control` на объектах — `public, max-age=86400, s-maxage=604800` на
   всех 1722 объектах (сутки в браузере, неделя на CDN). Проверено по
   равномерной выборке 41 объекта, пропусков нет. Делалось ДВУМЯ проходами по
   типам файлов (`*.webp` → `image/webp`, `*.mp4` → `video/mp4`) — одним
   проходом с `--content-type image/webp` 35 видео получили бы тип картинки и
   сломались. Команды заливки в `DEPLOY_RUNBOOK.md` обновлены: в них добавлен
   `--cache-control`, иначе новые файлы приедут без заголовка.
2. Cache Rule `cdn-media-cache` в Cloudflare: `Hostname equals
   cdn.bikebalirent.com` → Eligible for cache, Edge TTL «use cache-control
   header if present», Browser TTL «respect origin».

⚠️⚠️ **ГЛАВНАЯ ЛОВУШКА ЭТОГО РАЗДЕЛА — как проверять кэш Cloudflare.**
`curl -sI` шлёт **HEAD**, а на HEAD Cloudflare отдаёт `cf-cache-status:
DYNAMIC` ВСЕГДА, лежит объект в кэше или нет. На этом я потерял время и
сделал неверный вывод «Cloudflare не кэширует, нужно правило». Проверять
только настоящим GET:

```bash
U=https://cdn.bikebalirent.com/bikes/<slug>/thumb/01.webp
curl -s -o /dev/null -D - "$U" | grep -iE 'cf-cache-status|^age'
```

**Была ли Cache Rule вообще нужна — не доказано.** У объекта, проверенного
сразу после создания правила, `age` был ~3200 секунд, то есть он попал в кэш
почти за час ДО появления правила — сразу после простановки `Cache-Control`.
Похоже, заголовка было достаточно. Правило оставлено намеренно: делает
поведение явным и не зависящим от умолчаний Cloudflare. Но если кто-то будет
повторять это на другом бакете — сначала проставить заголовок и проверить
GET-ом, возможно правило не понадобится.

⚠️ При замене фото по тому же пути обязателен **Purge Cache**, иначе на узлах
CDN до недели будет отдаваться старая картинка. Браузерный кэш (сутки) Purge
не чистит вообще — у уже заходивших посетителей старая версия проживёт сутки.

### ✅ Порты закрыты через Contabo Cloud Firewall (2026-08-03, ЗАВЕРШЕНО)

Файрвол `mdb-platform-firewall` **уже существовал** с 22.07 (создан вместе с
сервером), назначен на VPS, политика правильная — внизу неудаляемое
`Block all traffic / DROP / Any`. Проблема была не в отсутствии файрвола, а в
двух ACCEPT-правилах, написанных когда панель требовала прямого доступа:
`Coolify Dashboard` (8000) и `Coolify Realtime` (6001-6002). Оба удалены.

Итоговый набор — 4 правила: `HTTPS 443/TCP`, `HTTP 80/TCP`, `SSH 22/TCP`,
`Block all traffic`. Порт 8080 в списке никогда не значился, поэтому дропался
и раньше.

**Проверено снаружи по IPv4 после применения:**

```
8000 закрыт ✓   6001 закрыт ✓   6002 закрыт ✓   8080 закрыт ✓
сайт 200   панель 302   редирект :80 → 302   SSH работает ✓   9/9 контейнеров healthy
```

**IPv6 — ПРОВЕРЕНО ЭМПИРИЧЕСКИ, закрыто.** Файрвол Contabo покрывает IPv6.
Проверка внешним сканером (subnetonline.com, ходит со своей сети) с
двухуровневым контролем:

| Тест | Результат |
|---|---|
| `ipv6.google.com:443` — умеет ли инструмент в IPv6 | reachable ✓ |
| наш `2a02:c207:2345:9293::1:443` — дотягивается ли до нас | reachable ✓ |
| наш `…::1:8000` | offline/unreachable |
| наш `…::1:6001` | offline/unreachable |

Раз 443 на том же адресе отвечает, а 8000/6001 нет — это закрытые порты, а не
отсутствие связности. Причина в ответе — `Connection refused` (TCP RST), а не
таймаут: Contabo режет через REJECT, не DROP. На результат не влияет.

Совпадает с docs Contabo: Source `Any` = «Allows traffic from all IP addresses
(IPv4 and IPv6)».

⚠️ Для контекста: AAAA публикуются (`bikebalirent.com` и `www` →
`2a02:c207:2345:9293::1`), то есть IPv6-адрес сервера узнаётся одним `dig` —
поэтому проверка v6 тут не паранойя, порты были бы реально достижимы.

**Инструменты для проверки IPv6 снаружи (важно, часть не работает):**
`check-host.net` для этого НЕ годится — его TCP-проверка не резолвит AAAA
вообще, не дотягивается даже до `ipv6.google.com`, все узлы отдают
`Unknown host`. Годится `subnetonline.com/pages/ipv6-network-tools/online-ipv6-port-scanner.php`
(принимает IPv6 в обычной нотации, без скобок; форму submit'ить кликом по
кнопке — `form.submit` перекрыт полем с именем `submit`). Приём с
`<адрес-через-дефисы>.sslip.io` даёт имя только с AAAA, если инструмент
требует hostname.

**Полезный приём на будущее:** при проверке доступности по IPv6 всегда делать
контрольный тест на заведомо открытый порт того же адреса. Одинаковый
результат = тест невалиден (нет связности), разный = валиден.

### История: какие подходы к закрытию портов НЕ сработали

**Решение по версии Coolify: остаёмся на 4.2.0** (подтверждено Дмитрием
2026-08-03), откат не делаем.

Полный список того, что реально слушает наружу (`ss -tlnp` + `ss -ulnp`,
проверено — в первый раз часть портов пропустил, потому что грепал по
заранее заданному списку; правильный способ — смотреть весь вывод):

| Порт | Кто | Нужен снаружи? |
|---|---|---|
| 22 TCP | sshd | **да** |
| 80 TCP | coolify-proxy | **да** — редирект + обновление Let's Encrypt |
| 443 TCP + **UDP** | coolify-proxy | **да** (UDP — HTTP/3, легко забыть) |
| 8000 TCP | coolify (панель) | нет |
| 8080 TCP | coolify-proxy | нет |
| 6001, 6002 TCP | coolify-realtime | нет |

**Почему 6001/6002 не нужны, хотя это websocket панели.** После задания FQDN
Coolify сам сгенерировал роуты в `/data/coolify/proxy/dynamic/coolify.yaml`:
`coolify.bikebalirent.com` → `http://coolify:8080`, `/app` →
`http://coolify-realtime:6001`, `/terminal/ws` → `http://coolify-realtime:6002`.
Всё ходит по внутренней docker-сети через Traefik на 443 — опубликованные
host-порты браузеру не нужны.

⚠️ **IPv6.** У сервера есть `2a02:c207:2345:9293::1`, и все порты слушают ещё
и на `[::]`. Файрвол только по IPv4 оставит панель доступной по IPv6 на том же
8000 — правила обязательно дублировать для v6.

После переезда панели на HTTPS открытый 8000 — не дыра, а хвост: опасен ровно
настолько, насколько кто-то сам ходит по старому адресу. Срочности нет.

**Что НЕ работает и почему — два тупика, оба проверены на практике:**

1. **`ufw` бесполезен.** 8000 публикуется `docker-proxy`, Docker обрабатывает
   свои цепочки iptables (`FORWARD → DOCKER-USER`, цепочка пустая) РАНЬШЕ
   правил ufw. `ufw --force enable` отработает, `ufw status` покажет красивый
   вывод, порт останется открыт. Ложное чувство защищённости.
2. **`APP_PORT=127.0.0.1:8000` не проходит.** Переменная используется дважды:
   `ports: "${APP_PORT:-8000}:8080"` (сюда IP подошёл бы) и
   `expose: "${APP_PORT:-8000}"` (сюда нет — `expose` принимает только голый
   номер). Итог: `invalid start port '127.0.0.1:8000'`, контейнер не
   пересоздаётся. Через `APP_PORT` задача не решается в принципе.

**Рабочие варианты, по убыванию надёжности:**

1. **Contabo Cloud Firewall** — фильтрация вне сервера, Docker её не обходит,
   переживает апгрейды Coolify, риск для работающего сервера нулевой.
2. Правка `docker-compose.prod.yml:24` → `- "127.0.0.1:${APP_PORT:-8000}:8080"`,
   `expose` не трогать. Работает, но затирается при апгрейде Coolify.
3. Правило в `DOCKER-USER`: `iptables -I DOCKER-USER -p tcp -m conntrack
   --ctorigdstport 8000 -j DROP` (именно `--ctorigdstport`: после DNAT
   dport = 8080 контейнера, а не 8000 хоста). Переживает апгрейды, но требует
   `iptables-persistent`.

### История: как проблема была найдена (ИСПРАВЛЕНА, см. выше)

Повод — вопрос Дмитрия, почему браузер пишет «Не защищено» на
`http://169.58.60.244:8000`. Браузер прав, и это серьёзнее, чем вопрос про R2.

Проверено на сервере (`ss -tlnp`, `docker ps`, `ufw status`, curl снаружи):

- Порт **8000 → контейнер `coolify`** (админка, `coollabsio/coolify:4.1.2`),
  слушает `0.0.0.0` и `[::]`, снаружи отвечает `302` на логин. **TLS нет**,
  на `https://169.58.60.244:8000` соединение не устанавливается.
- FQDN инстанса Coolify **НЕ ЗАДАН** → сертификат не выпускается, редиректа
  на HTTPS нет. (Traefik при этом успешно держит сертификаты для самого сайта
  на 80/443 — проблема только у панели.)
- Порт **8080 → `coolify-proxy`** (Traefik), снаружи не отвечает (`000`) —
  отдельной проблемы не создаёт, но открыт.
- **`ufw status: inactive`** — файрвола нет вообще, порты открыты всему миру.

**Чем это плохо конкретно.** Пароль от Coolify и сессионная кука ходят
открытым текстом через весь интернет. Кто перехватил сессию — получил полный
контроль над сервером: Coolify умеет читать все env-переменные (пароль
Postgres, `INTERNAL_ADMIN_PASSWORD`), деплоить произвольные контейнеры и
открывать терминал на хосте. Дмитрий работает с Бали, в том числе из
кафе/коворкингов — то есть ровно из сетей, где перехват реалистичен.
Плюс страница логина доступна всему интернету для перебора и для эксплуатации
любой будущей CVE в Coolify.

**Как чинили (пункты 1-2 — сделаны 2026-08-03, см. раздел выше):**

1. Cloudflare DNS: A-запись `coolify.bikebalirent.com` → `169.58.60.244`,
   **DNS only / серое облако** (как apex и www — сертификатами управляет Traefik).
2. Coolify → Settings → Configuration → General → поле **`URL`** (в 4.1.2/4.2.0
   оно называется именно так, не «Instance's Domain») → `https://coolify.bikebalirent.com`.
   Traefik выпускает Let's Encrypt автоматически.

⚠️ Пункт 3 исходного плана предлагал закрыть 8000 через `ufw`. **Это не
работает** — Docker обходит ufw, подробности и рабочие варианты в разделе
«Порт 8000 всё ещё открыт» выше. Не следовать этому пункту.

Диагностическая заметка на будущее: `dig` с машины Дмитрия отдавал NXDOMAIN по
`coolify.bikebalirent.com` **без флага `aa`** — то есть запрос не доходил до
Cloudflare, его перехватывали на пути (провайдер). Системный резолвер и `curl`
при этом работали правильно. Проверять DNS в спорных случаях с сервера
(`ssh ... dig`), а не с локальной машины — там чистая сеть.

- **Отдельное наблюдение, важнее самого блока:** два скриншота (IMG_2749,
  IMG_2745) показывают клиентов, которые сами хотели оставить отзыв в Google
  и не нашли компанию («If you have a google business account (I did not find
  it) I would be happy to leave you a good review!»). Google Business Profile
  не заведён. Для локального SEO и доверия он даст больше, чем блок на сайте,
  и он бесплатный.

### Сессия 2026-08-01 — email/DNS-гигиена, Merchant Listing SEO, Family-контент, переводы (ЗАВЕРШЕНО)

- **Контактный email заменён** (коммит `b6a884c`): `support@bikebalirent.com` →
  `rentbalibike@gmail.com` (существующий Gmail компании, домен-почту не
  переносим и не настраиваем — решено Дмитрием). Найдено и заменено
  два места, где email был захардкожен независимо друг от друга —
  `frontend/src/lib/contacts.js` (единый источник для About/JSON-LD) и
  `Footer.jsx` (дублировал вручную, не импортировал `contacts.js`). Прод-БД
  проверена сканом всех `text`/`varchar` колонок всех таблиц `public`-схемы
  (включая `*_translations` на всех 8 локалях) на `support@`/`bikebalirent.com`
  — 0 совпадений, в БД email никогда не хранился. Проверено на проде на
  en/ru/ar: footer, About/Contact, `LocalBusiness` JSON-LD.
- **DNS домена задекларирован как non-mail** (Cloudflare, ручные правки в UI
  Дмитрием по моим инструкциям, не через API — токена с правом записи в DNS-зону
  в сессии не было). Подтверждено Дмитрием: почтовые ящики на домене никогда не
  создавались. Итоговый набор: `MX 0 .` (null MX, RFC 7505), `TXT: v=spf1 -all`
  (жёсткий fail вместо прежнего `~all` с Hostinger-инклюдом), `TXT _dmarc:
  v=DMARC1; p=reject; rua=mailto:rentbalibike@gmail.com` (вместо `p=none`,
  который ничего не блокировал). Удалено 5 неиспользуемых CNAME от Hostinger:
  `autoconfig`, `autodiscover`, `hostingermail-a/b/c._domainkey`. A/AAAA/CAA/`www`
  не тронуты.
- **GSC «Данные о товарах продавца» (Merchant Listing) — 3 из 4 пунктов закрыты
  честно, без выдумывания данных** (коммит `d07e58c`,
  `frontend/src/app/[locale]/bikes/[slug]/page.js`):
  - `category` — было `product.category?.name` (внутренний ярлык фильтра
    каталога типа "Naked / Classic", не валидная таксономия для Google).
    Заменено на фиксированную строку `Vehicles & Parts > Vehicles > Motor
    Vehicles > Motorcycles & Scooters` (Google Product Taxonomy ID 919 —
    единственный лист для мотобайков/скутеров, без разбивки на подкатегории).
    Меняется только в невидимом JSON-LD; видимый `pill` на карточке с
    ярлыком фильтра остался как был.
  - `hasMerchantReturnPolicy: MerchantReturnNotPermitted` — обосновано не
    рассуждением "это аренда", а прямым пунктом реального договора
    (`Agreement_MDB_final.docx`, п.4: оплата невозвратна при досрочном
    возврате байка), + `url` на новую `/terms`.
  - `shippingDetails` — 3 записи `OfferShippingDetails` из живого
    `/api/delivery-fee-rules` (тот же источник, что калькулятор: 1-6 дней
    150k, 7-14 дней 100k, 15+ бесплатно), не задублировано вручную. Явно
    отмечено (и проговорено с Дмитрием) — сама схема `OfferShippingDetails`
    рассчитана на доставку купленного товара, а не на аренду по сроку,
    это компромисс, не идеальное 1:1 соответствие семантики.
  - `description` (4-й пункт) — не поле в Offer, отдельная более крупная
    задача, см. ниже (Family-контент + короткие описания).
  - Побочная находка, вынесена в отдельный `spawn_task` (не сделано в
    рамках сессии): `deliveryAdminRouter`/`insuranceAdminRouter`/
    `depositAdminRouter`/`replacementGroupsAdminRouter` в
    `backend/src/server.js` смонтированы на голом `/api`, а не `/api/admin` —
    Basic Auth есть только на уровне Next.js `/internal/*` middleware,
    backend API этих разделов **не аутентифицирован вообще** на уровне
    Express. Требует отдельной сессии.
- **Новая публичная страница `/terms`** (`frontend/src/app/[locale]/terms/page.js`) —
  реальный текст договора аренды (21 пункт, без формы Renter/Motorbike Info и
  строки подписи — это часть печатного экземпляра, не публичной политики).
  Тихая ссылка в футере (`ftr-bottom`, не выделяется визуально), **не** в
  главной навигации/sitemap-приоритете. Переведена на все 8 языков
  (`frontend/src/data/terms.js`, не БД — статичный юридический текст того же
  уровня сложности, что About/FAQ) — в каждом non-en варианте есть переведённая
  сноска: при расхождении трактовки действует английский оригинал.
- **Family-level длинный контент** (коммит `6dbd28f`, миграция
  `25_family_content.sql` + сид `25b_family_content_seed.sql`): новая таблица
  `family_content_translations` (по образцу `family_specs` — общий для всех
  цветов Family, English-first с `COALESCE`-фолбэком на `en`, как у
  `product_translations.description`). Заполнены все 19 Family: интро-абзац +
  Key Benefits (4) + Expert Tips (3) + FAQ (3), текст написан заново (не
  скопирован с дилерских сайтов), опираясь на реальные `family_specs`.
  Заодно дозаполнены `family_specs` для 4 моделей, у которых их вообще не
  было (Kawasaki D-Tracker 250, Keeway Road Falcon 250, Yamaha Byson 150,
  Yamaha Scorpio 225 — цифры найдены и процитированы с источником). У
  Frankenstein (кастомная сборка, не заводская модель) — контент есть,
  `family_specs` **сознательно не выдуманы** (по факту это не серийная
  модель), в тексте это прямо объяснено, Royal Enfield Himalayan упомянут
  только как ориентир дизайна.
- **Короткое `description` заполнено для всех 101 активного продукта**
  (коммит `5e3fbc0`, `26_product_descriptions_seed.sql`) — переиспользован тот
  же intro-абзац, что написан для Family-контента (19 текстов на 101 продукт,
  не 101 отдельный). `product_translations` для локали `en` до этой сессии
  не имел ни одной строки вообще (только 6 non-en локалей, `ru`/`en` — 0 строк) —
  инсерт заодно завёл и `title` (то же значение, что `displayName()` и так
  вычислял по фолбэку — видимых изменений имён нет).
- **Восстановлено "custom bikes"**, потерянное при переезде с WordPress
  (коммит `9f6d4d9`/`5e3fbc0`): `<title>` на главной — теперь буквально старый
  заголовок ("Rent Motorbike and Scooter in Bali | Custom Motorbikes",
  новый ключ `brand.seo_title`, без префикса "Bike Bali Rent —", по прямой
  правке Дмитрия), переведён на все 8 языков. `brand.tagline` (шапка рядом с
  логотипом, скрыта на мобильных <900px, + footer) — отдельный ключ,
  тоже упоминает custom bikes, но короче/разговорнее, не тронут второй правкой.
- **WhatsApp/Telegram-ссылки с сайта — с предзаполненным сообщением**
  (`dict.contact.prefill_message`, `wa.me`/`t.me` оба поддерживают `?text=`):
  сначала было "Hi! I'm reaching out from the Bike Bali Rent website
  (bikebalirent.com)." — по следующей правке Дмитрия заменено на короткое
  "Hello! 🛵 I want to rent a motorbike." (коммит `a1abd9d`), переведено на
  все 8 языков. **Явно отмечено и принято Дмитрием**: новый текст больше не
  содержит маркер "с сайта" — по чистому тексту сообщения не отличить лид с
  сайта от того, кто написал сам по номеру из Google/визитки. Заодно
  `Footer.jsx` перестал дублировать контакты вручную и теперь тоже рендерит
  из `lib/contacts.js` (как уже делал About).
- **Разграничение блоков на карточке товара** (коммит `5e3fbc0`): длинный
  Family-контент визуально сливался с блоком калькулятора/брони над ним.
  Добавлен заголовок ("Get to Know This Bike", 8 языков) + карточка
  (`background: var(--surface)`, `border-radius: 12px`, `margin-top: 56px`) —
  явно читается как отдельная секция "почитать про байк" vs "закончить
  бронирование".
- **Все DB-изменения применены и на dev, и на проде напрямую через
  `ssh ... docker exec -i <container> psql -U postgres -d mdb_platform`**
  (см. CLAUDE.md §6) — три новых файла миграций/сидов
  (`25_family_content.sql`, `25b_family_content_seed.sql`,
  `26_product_descriptions_seed.sql`), без единого редеплоя БД (self-hosted
  Postgres не деплоится как код). Redeploy на Coolify нужен был только
  frontend+backend (backend — из-за нового SQL-запроса в `catalog.js` под
  Family-контент и `hasMerchantReturnPolicy`/`shippingDetails`).
- **Не сделано / следующий шаг**: перевод 19 Family-блоков (Key
  Benefits/Expert Tips/FAQ) и 101 короткого `description` на остальные 7
  языков — сейчас везде фолбэк на `en`. Не в рамках этой сессии (объём
  сопоставим с самой сессией, отдельная задача). Флаг про
  неаутентифицированные admin API-роуты (см. выше) — отдельная сессия,
  `spawn_task` создан, не выполнялся.

### Чанк Инцидент: коммит `4d500db` (admin auth) сломал ВСЕ карточки товара (НАЙДЕНО И ИСПРАВЛЕНО)

**Симптом:** через несколько часов после коммита `4d500db` (`fix(security):
require shared-secret auth on backend admin API routes` — реакция на флаг из
предыдущего чанка) каждая карточка товара на проде (`/[locale]/bikes/[slug]`)
стала отдавать "Application error: a server-side exception has occurred".
Каталог (`/bikes`) продолжал работать — сломались только страницы отдельных
байков. Обнаружено Дмитрием визуально, не мониторингом (мониторинга ошибок
на проде пока нет — см. "Что НЕ сделано").

**Корневая причина — двухслойная, обе части обязательны для понимания:**

1. `4d500db` навесил `requireInternalToken` на весь `deliveryAdminRouter`,
   включая `GET /api/delivery-fee-rules`. Но эту ручку дёргает не только
   `/internal/delivery` (админка) — **её же напрямую, без токена, читает сам
   продуктовый сайт** (`bikes/[slug]/page.js` — тарифы доставки для
   калькулятора и `shippingDetails` в Merchant Listing JSON-LD, добавлено
   чанком «SEO enrichment layer» выше). Автор коммита (предыдущая сессия)
   проверил только 4 из 5 роутеров на публичных потребителей, delivery
   пропустили.
2. **Более тонкая и более важная на будущее ловушка Express:**
   `app.use('/api', requireInternalToken, router)` навешивает
   `requireInternalToken` на путь `'/api'` целиком, а не на конкретный
   `router`. Express выполняет `app.use`-слои по порядку регистрации; если
   запрос не совпал ни с одним роутом в более ранних (публичных) роутерах,
   он проваливается в **первый попавшийся гейт**, даже если реальный
   обработчик пути определён в более позднем, негейтованном роутере. Первая
   попытка исправления (коммит `d3093be` — снять токен конкретно с GET
   внутри `deliveryAdmin.js`) **не сработала**, потому что
   `deliveryAdminRouter` был смонтирован ПОСЛЕ первого гейта
   (`seasonalMultipliersRouter`) — запрос к `/api/delivery-fee-rules`
   перехватывался и получал 401 на этом первом гейте, до того как вообще
   доходил до (уже исправленного) `deliveryAdminRouter`. Проверено вживую:
   после `d3093be` контейнер на проде подтверждённо содержал новый код
   (`docker exec ... grep requireInternalToken`), но `GET` всё ещё отвечал
   401 — то есть **сам факт актуального коммита в контейнере не доказывает,
   что баг исправлен**, нужен прямой запрос к живому эндпоинту.

**Фикс — два коммита:**
- `d3093be` — токен снят с `GET /delivery-fee-rules`, оставлен точечно на
  `POST`/`PUT`/`DELETE` внутри `deliveryAdmin.js` (недостаточно само по
  себе, см. выше).
- `1533586` — настоящий фикс: `app.use('/api', deliveryAdminRouter)`
  перенесён ДО первого `app.use('/api', requireInternalToken, ...)` в
  `server.js`. Публичный `GET` теперь match'ится раньше любого гейта;
  `POST`/`PUT`/`DELETE` остаются защищены — их `requireInternalToken`
  навешан прямо на конкретный route-handler внутри `deliveryAdmin.js`, а не
  на весь роутер через `app.use`, поэтому от порядка монтирования не
  зависит.

**Правило на будущее для любого нового admin-роутера с
`requireInternalToken`:** если хотя бы одна ручка внутри роутера должна
остаться публичной — не вешать токен через
`app.use('/api', requireInternalToken, router)` (гейтует чужой трафик по
пути, см. выше), а гейтить только конкретные route-handler'ы токеном
(`router.post('/x', requireInternalToken, handler)`), как уже сделано в
`deliveryAdmin.js`. Перед тем как гейтить существующий роутер целиком —
`grep` по `frontend/src` на прямые вызовы его путей вне `/api/admin/*`
(BFF-прокси), не только заглянуть в код самого роутера. И после любого
редеплоя, трогающего auth/middleware — не полагаться на "контейнер на
нужном коммите", а сделать реальный запрос к живому эндпоинту (в браузере
или `curl` с сервера).

### Сессия 2026-08-08 — заявка водителю/менеджеру: время доставки, способ оплаты, упрощение контактов (ЗАВЕРШЕНО; бот-подтверждение клиенту — ТОЛЬКО ОБСУЖДЕНО, не в коде)

Три небольших, но накопительных доработки формы заявки и обеих Telegram-карточек (менеджер + водитель). Три коммита, обе миграции применены на проде.

- **Заявка водителю очищена от прочерков-заглушек** (`backend/src/services/booking.js`,
  `buildDriverText`): `Sopir: —`, `Pakai: —`, `Location: —`, `Komentar: —`
  заменены на пустое значение после двоеточия — диспетчер правит карточку
  руками в Telegram при каждой заявке, лишний "—" приходилось стирать перед
  тем как вписать реальное значение. Строка `Motor: ... — unit: —` лишилась
  `unit: —` целиком: это была заглушка под будущий справочник свободных
  байков/юнитов (админки ещё нет), Дмитрий подтвердил — просто убрать,
  вернуться к этому отдельным чанком, когда появится справочник.
- **Время доставки — новое поле на сайте** (`bookings.delivery_time`,
  **миграция 045**). Сначала сделан нативный `<input type="time">`, по
  живому фидбеку Дмитрия ("форма совсем не нравится") переделан на обычный
  `<select>` (тот же паттерн, что у выбора страховки/покрытия в
  калькуляторе) с фиксированными опциями **09:00–22:00 шагом 30 минут** +
  подпись "доставка вне этого окна — по запросу, уточняйте у менеджера".
  Прокинуто в обе карточки: водителю — `Memesan: pengiriman ДД.ММ.ГГГГ, jam
  HH:MM`, причём **слово "jam" пишется всегда**, даже без указанного
  времени (пусто после него) — та же логика "нечего стирать перед ручным
  вводом"; менеджеру — `🕒 HH:MM` рядом с датами.
- **Контакты в форме упрощены до WhatsApp + Telegram** — Email и Phone
  убраны из UI (`BookingForm.jsx`), это единственные два канала, которыми
  менеджер реально пользуется для связи с клиентом. Backend-валидация
  `CONTACT_FIELDS` не трогали (шире, для ботов на будущее) — сузили только
  форму на сайте и клиентскую проверку "хотя бы один контакт".
- **Способ оплаты — новое поле, чекбоксы** (`bookings.payment_preference
  TEXT[]`, **миграция 046**): наличные / банковский перевод / другое,
  можно несколько сразу. Показывается только менеджеру (`💳 Оплата: ...`,
  строка появляется, только если клиент что-то отметил) — водителю это поле
  не нужно, к оплате отношения не имеет.
- **`notifyDict.js`** дополнен ключами `payment`/`payment_cash`/
  `payment_bank_transfer`/`payment_other` для en/ru (карточка менеджера —
  только эти два языка, `SUPPORTED_LOCALES` в `booking.js`); i18n-словари
  сайта (`frontend/src/i18n/dictionaries/*.json`, все 8 языков) получили
  `delivery_time`/`delivery_time_ph`/`delivery_time_hint` и
  `payment_method`/`payment_cash`/`payment_bank_transfer`/`payment_other`,
  `contact_required` переформулирован под WhatsApp/Telegram.
- **Деплой:** три коммита (`fcc8533`, `c8f0e8f`, `fd319ea`), запушены в
  `origin/main`. Обе миграции (045, 046) применены на проде через прямой
  SSH+`docker exec psql` (см. CLAUDE.md §6) — **каждой предшествовал
  `pg_dump`-бэкап**, скачанный локально в scratchpad перед ALTER (для
  ALTER на боевых данных это не разовое требование конкретно от Дмитрия, а
  общее правило CLAUDE.md §6 "каждое изменение схемы проверять руками"; сам
  Дмитрий подтвердил, что регулярного бэкапа прод-БД сейчас **нет** — ни
  крона, ни Coolify Scheduled Backup, только этот разовый ритуал перед
  каждой ALTER). Redeploy backend+frontend в Coolify UI — **на момент
  записи ещё не подтверждён Дмитрием**, автодеплоя по пушу нет (см.
  DEPLOY_RUNBOOK.md), а API-токена Coolify в сессии не было, чтобы
  дёрнуть Redeploy программно.
- **Локальная dev-БД миграции 045/046 не получала** — тестировали вызовом
  `buildDriverText`/`buildManagerText` напрямую (`node --input-type=module
  -e`) в обход БД, плюс DOM-проверка формы в браузере без реальной отправки.
  При следующей локальной работе — не забыть `npm run migrate`, иначе
  локальный `POST /api/bookings` упадёт на отсутствующих колонках.
- **Обсуждали, но НЕ реализовали:** автоматическое подтверждение брони
  ботом клиенту. Telegram: бот не может написать первым, пока клиент сам не
  нажал Start — предложенная схема: кнопка/диплинк `t.me/<Bot>?start=<ref>`
  на экране успеха после отправки формы → бот ловит `chat_id` → дальше
  можно слать подтверждение/статус программно. Текст кнопки — не
  "связаться с менеджером" (эффект-ощущение усилия), а обещание конкретной
  мгновенной выгоды ("подтвердить заявку сейчас"/"получить статус").
  WhatsApp — только через официальный WhatsApp Business Platform (Cloud
  API): отдельный номер (нельзя параллельно с обычным приложением),
  верификация бизнеса в Meta Business Manager, первое сообщение вне 24-часового
  окна требует заранее одобренного Meta шаблона. Рекомендация — начать с
  Telegram (дёшево, без внешних согласований), WhatsApp Business API
  отложить до понимания, каким каналом клиенты реально пользуются чаще.
  **Ничего из этого не в коде** — чисто обсуждение, ждёт решения Дмитрия.

### Сессия 2026-08-10 — FAQ доставки, верификация Яндекс.Вебмастера, GA4 + Яндекс.Метрика (ЗАВЕРШЕНО; редеплой Coolify — за Дмитрием)

- **FAQ "Do you deliver the bike?" — полный список зон** (коммит `b86ae16`):
  расплывчатое "main tourist areas near Denpasar: Bukit, Canggu, Seseh,
  Ubud, Denpasar, Sanur and nearby" заменено на явный список 13 районов
  (Canggu, Seminyak, Kuta, Legian, Denpasar, Sanur, Ubud, Uluwatu, Jimbaran,
  Nusa Dua, Tabanan, Kerobokan, Umalas), единый с GBP (ТЗ п.4.12.1), по
  одной строке `faq.items[].a` на все 8 языков
  (`frontend/src/i18n/dictionaries/*.json`) — топонимы не переводятся,
  остаются на латинице везде. `/faq` рендерит тот же `dict.faq.items`, что
  и блок FAQ на главной — правка одним ключом закрыла оба места.
- **DNS TXT для верификации домена в Яндекс.Вебмастере** — добавлена вручную
  через Cloudflare dashboard (Claude in Chrome, залогинен под аккаунтом
  Дмитрия), не через код/git: `bikebalirent.com` TXT `@` →
  `yandex-verification: 4c43981840ad9980`, Proxy status DNS only. Существующие
  TXT на корне (`v=spf1 -all`, `google-site-verification=...`) и `_dmarc`
  не тронуты — TXT-записи одного типа складываются, не заменяют друг друга
  (см. CLAUDE.md §6 про non-mail DNS). Подтверждение в кабинете
  Яндекс.Вебмастера — за Дмитрием, ждёт клика "Подтвердить".
- **GA4 + Яндекс.Метрика установлены** (коммит `b0ce673`,
  `frontend/src/app/[locale]/layout.js` + новый
  `frontend/src/app/[locale]/analytics/RouteTracker.js`). GA4-свойство
  `G-S6RSSC9KFW` (см. сессию 2026-07-30 — было привязано на уровне Google
  к тому же Google Ads аккаунту, но не подключено на платформе) добавлено
  вторым `gtag('config', ...)` на уже загруженный для `AW-17065885486`
  dataLayer — gtag.js не задваивается. Яндекс.Метрика (счётчик `111448067`)
  — официальный сниппет с нуля, IIFE не менялась. Оба счётчика
  сконфигурированы без автоматического первого хита
  (`send_page_view:false` у GA4, `defer:true` у Метрики) — `RouteTracker`
  (клиентский компонент, `usePathname`+`useSearchParams`, обёрнут в
  `<Suspense>` в layout.js) шлёт `page_view`/`hit` вручную и на первом
  монтировании, и на каждой смене маршрута, чтобы не задвоить.
  Формат `ym(id, 'hit', url)` сверен с официальной страницей Яндекса про
  SPA (`yandex.ru/support/metrica/ru/code/counter-spa-setup`) — совпадает
  с тем, что попросил Дмитрий, менять не пришлось.
  **Находка при проверке**: при первом тесте SPA-переход на `/bikes`
  выглядел так, будто `RouteTracker` не срабатывает при смене маршрута —
  причина не в коде, а в том, что backend (`localhost:3000`) не был поднят
  в момент теста: RSC-рендер `/bikes` (тянет данные парка с бэкенда) уходил
  в бесконечный retry на `ECONNREFUSED`, и навигация никогда не
  коммитилась. После `npm run dev` в `backend/` всё заработало штатно — при
  локальной работе с фронтом всегда нужен поднятый бэкенд, иначе каталожные
  страницы (и всё, что от них зависит) будут вести себя как сломанные, хотя
  код рабочий.
  Финальная проверка сделана на **production-сборке** (`next build` +
  `.next/standalone/server.js`, статика/public докопированы вручную) — в
  `next dev` `page_view`/`hit` задваиваются на первой загрузке из-за
  `reactStrictMode: true` (React намеренно вызывает эффекты дважды при
  монтировании только в dev, это не баг). На проде: gtag.js — 1 загрузка,
  dataLayer — ровно 2 `config`, `ym.a` — ровно 1 `init`, 4 перехода подряд
  (`/en` → Bikes → About → FAQ) дали ровно 4 `page_view`/`hit`, один к
  одному.
- **Редеплой Coolify** — по договорённости делает сам Дмитрий, не входил в
  задачу сессии.

### Сессия 2026-08-10 (продолжение) — конверсионные GA4-события (WA/TG клики, заявка) + Accept-Language автодетект (ЗАВЕРШЕНО, запушено в main)

- **`whatsapp_click`/`telegram_click`** (коммит `7b22d49`): раньше клики по
  wa.me/t.me в Footer.jsx и `about/page.js` не трекались кодом вообще (только
  автосбор GA4 Enhanced Measurement под generic-именем `click`, без
  различения канала). Добавлен общий клиентский компонент
  `frontend/src/app/components/ContactLink.jsx` (Footer/about — оба
  server-компоненты, отдельный `'use client'`-компонент нужен из-за
  `onClick`): `gtag('event', \`${key}_click\`, {link_url})` для WhatsApp/
  Telegram-ссылок из `lib/contacts.js` (`CHAT_KEYS`/`trackChatClick`,
  Instagram/email не трекаются — просто ссылки). Заодно эти ссылки переведены
  на `target="_blank" rel="noopener noreferrer"` — раньше открывались в
  текущей вкладке, событие рисковало не успеть уйти в GA4 до навигации.
- **`booking_form_submit`** (тот же коммит): раньше вообще не было явного
  события для заявки — только автосборный `form_submit` (ловит любые сабмиты,
  включая неудачные попытки, без бизнес-параметров). Добавлен явный
  `gtag('event', 'booking_form_submit', {locale, product, start_date,
  end_date})` в `BookingForm.jsx`, **строго после успешного ответа**
  `POST /api/bookings` (не на raw submit) — считает только реально дошедшие
  заявки. Оба добавления проверены живым кликом/сабмитом на dev-сервере
  (`window.gtag`/`window.fetch` застаблены, чтобы не слать тестовые хиты в
  боевой GA4-property и не писать тестовую заявку в БД) — имена событий и
  параметры подтверждены, success-экран рендерится штатно.
- **Диагностика "`booking_form_submit` — 0 за 28 дней"**: код на проде
  подтверждён 1-в-1 с исходником (вытащен реальный JS-чанк
  `bikes/[slug]/page-*.js` с bikebalirent.com, строка совпадает дословно).
  Причина не в баге: по `source='website'` в `bookings` за деплоем
  (2026-08-10 08:43 UTC) на момент проверки (13:40 UTC) было ровно одно новое
  бронирование (`booking_number=13`, 10:07 UTC) — событию было ~3 часа,
  GA4 Standard Reports обычно обрабатывает свежепоявившееся имя custom event
  до 24 ч. Не баг, а недостаток данных/времени; рекомендация — смотреть
  Realtime/DebugView, не 28-дневный отчёт, для проверки в первые сутки.
- **Accept-Language автодетект на голом домене** (коммит `d9c51cb`):
  `middleware.js` раньше редиректил любой путь без `/xx`-префикса на
  `DEFAULT_LOCALE` (`en`) безусловно — немецко-/франко-/etc.-язычный
  посетитель, зашедший на голый `bikebalirent.com` (актуально для части
  Google Ads объявлений с Final URL на голый домен, без явного `/de`),
  всегда получал английскую версию. Теперь редирект берёт первый язык из
  `Accept-Language` браузера, который входит в 8 включённых локалей;
  на `DEFAULT_LOCALE` падает, только если в списке браузера вообще нет
  совпадения. Нюанс, подтверждённый тестом: если сам браузер перечисляет
  `en` как понижен-приоритетный фолбэк (`id;q=0.9,en;q=0.5`) — редирект
  корректно уходит на `en`, это стандартное content negotiation, не баг.
- **`web_events` — первый писатель** (тот же коммит): таблица `web_events`
  существовала в схеме без единого кода, который бы в неё писал. Добавлен
  `POST /api/web-events` (`backend/src/routes/webEvents.js` →
  `backend/src/services/webEvents.js`, allow-list на `event_code`, сейчас
  единственный код — `locale_autodetect_unmatched`, никогда не бросает).
  Middleware шлёт туда fire-and-forget (`event.waitUntil`, если платформа
  даёт) сырой сигнал `{browser_lang, accept_language, path}` каждый раз,
  когда язык браузера не входит в 8 локалей — материал для будущего решения
  "добавлять ли язык N" (CLAUDE.md §5, языки по `launch_phase`).
  Проверено на реальной dev-БД (не моками): de/fr совпадающие языки уходят
  на свою локаль, несовпадающий (`id`, без `en`-фолбэка в заголовке) уходит
  на `/en` и пишет строку в `web_events` — тестовые строки удалены после
  проверки.
- Оба коммита (`7b22d49`, `d9c51cb`) запушены в `origin/main`. Деплой на
  Coolify инициирован пушем (вебхук предполагается, отдельно не проверялся
  на этот раз) — обе части, и frontend (`middleware.js`), и backend
  (`server.js` + новые `routes/webEvents.js`/`services/webEvents.js`).

### Сессия 2026-08-11/12 — чанк Blog: категория deposit-safety end-to-end (схема → контент 8 языков → прод), header-меню (ЗАВЕРШЕНО, задеплоено на prod)

Три коммита в `main` (`98c2080` — схема/сиды/admin CRUD/публичный каркас,
`c560070` — контент+перевод категории deposit-safety, `a4c6c46` — пункт
"Blog" в header-меню), обе миграции и весь контент этой категории применены
и на dev, и на **prod** (bikebalirent.com живой). Юридическая категория и
остальные 3 категории блога — сознательно не тронуты, следующий чанк.

**Важная поправка к записи выше (Сессия 2026-08-10, продолжение):**
формулировка "Деплой на Coolify инициирован пушем (вебхук предполагается)"
была предположением, не проверенным фактом. **В этой сессии подтверждено
обратное: автодеплоя по git push на этом проекте нет.** Обнаружено так:
образы app-контейнеров на Contabo (`docker ps --format '{{.Image}}'`) несут
тег вида `<git-sha>` — сверка `git cat-file -t <тег>` показала, что
запущенный контейнер был собран с коммита `d9c51cb`, который на тот момент
был на 3 коммита позади `HEAD main` (весь чанк Blog из этой же сессии уже
лежал в `origin/main`, но не был выкачен на прод). Редеплой в Coolify UI —
ручное действие Дмитрия (см. `DEPLOY_RUNBOOK.md`, там это уже было
задокументировано верно, встроенное предположение в тексте сессии
2026-08-10 — единственное расхождение). Приём "тег образа = git SHA, сверить
через `git cat-file -t`" — быстрый способ узнать, какой коммит реально в
проде, без доступа к Coolify UI/API.

**Задача 1 — схема + admin CRUD + публичный каркас (`98c2080`, ТЗ п.4.15):**

- 4 таблицы: `article_categories` → `articles` → `article_translations`,
  `article_category_translations` (миграция `047_blog.sql`) — pillar+cluster
  по образцу конкурентного анализа, тот же паттерн перевода "своя таблица на
  сущность", что и `product_translations` (CLAUDE.md §3.8). Заменила мёртвый
  прототип `articles`/`article_translations` из `007_website_content.sql`
  (0 строк, не использовался ни одним route/service) — `DROP TABLE` внутри
  той же миграции, не `ALTER`.
- Сид `048_blog_seed.sql`: 5 категорий (`deposit-safety`, `legal`,
  `bike-models`, `routes`, `digital-nomads`) + 29 статей (en, `status=draft`,
  только title/slug). `related_product_family_id` проставлен там, где нашлось
  совпадение модели во флоте (`honda_adv`/`yamaha_nmax`/`honda_vario`/
  `yamaha_xsr`); Honda Scoopy и Honda Forza — не в текущем флоте, `NULL`, не
  ошибка.
- Admin CRUD `/internal/blog` — шестой раздел Configuration First-панели,
  тот же паттерн, что у остальных пяти: `backend/src/routes/blogAdmin.js`
  (list+edit, без create/delete — все статьи уже посеяны) за
  `requireInternalToken` → BFF-прокси `frontend/src/app/api/admin/blog/**` →
  клиентский компонент. Публичный каркас `backend/src/routes/blog.js`
  (только `status='published'`) → `/[locale]/blog` + `/[locale]/blog/[slug]`,
  резолв статьи по `(language_code, slug)` из `article_translations`, не по
  стабильному `articles.slug` (ТЗ п.4.9.3 — своя страница на язык).

**Задача 2 — контент и перевод категории deposit-safety, 8 языков
(`c560070`):**

- 8 статей: 5 из исходных 29 (`how-the-deposit-works-...` — pillar,
  `what-to-do-if-the-bike-gets-scratched-or-damaged`,
  `deposit-scams-how-to-spot-them`, `bike-insurance-whats-covered-and-whats-not`,
  `what-to-do-after-an-accident-on-a-rented-bike`) + 3 новые, добавленные в
  этой сессии (`how-to-brake-safely-on-balis-hills-and-mountain-roads`,
  `how-to-start-and-use-your-rental-scooters-smart-key`,
  `rental-extras-worth-adding-helmets-and-the-comfort-box`) — все с
  `category_id=deposit-safety`, `related_product_family_id=NULL`.
  Исходники — 16 md-файлов (en+ru), переданы Дмитрием в `Blog/`.
- Переведены на оставшиеся 6 языков платформы (de/fr/es/it/ja/ar) — чистый
  перевод, не пересказ: факты/цифры/бренды (SHAD, STNK, KYT, Smart Key,
  IDR) перенесены как есть. Итого 8 статей × 8 языков = 64
  `article_translations`. Все 64 md-файла (исходный en/ru + 48 новых)
  закоммичены в `Blog/*.md` — источник переводов, для трассируемости (не
  перезаписывается на будущих правках, правки делаются через
  `/internal/blog`).
- **Slug-конвенция закреплена** (нет устоявшейся на сайте — проверено на
  живых страницах, `products`/`page_translations` слага per-locale не
  имеют вовсе): ru — детерминированная транслитерация кириллицы (таблица
  символов); de/fr/es/it — ASCII-фолдинг диакритики из переведённого title;
  ja/ar — **фолбэк на EN slug**, осознанное решение Дмитрия: у японского и
  арабского нет единой детерминированной схемы латинизации (чтения кандзи
  неоднозначны без контекста, арабская романизация теряет краткие гласные) —
  в отличие от кириллицы, где буквенная транслитерация однозначна и
  общепринята.
- Markdown-рендеринг добавлен (`react-markdown` + `remark-gfm`,
  `frontend/package.json`) — раньше `content` рендерился построчным
  `<p>`, что не поддерживало таблицу тарифов в `blog-02` (GFM-таблица) и
  списки/bold. Стили — `.article-body` в `globals.css`.
- Внутренние ссылки между статьями батча (плейсхолдеры `[Title статьи]` в
  исходниках) резолвлены в реальные markdown-ссылки на локализованный slug
  цели, **anchor text переведён на каждом языке** (не английский текст на
  ссылку с slug на другом языке) — 48 ссылок всего (pillar → 2 исходящие,
  4 кластерные статьи → по 1 каждая). Один плейсхолдер (`bike-insurance...`
  → `[deposit and damage guide]`) был неоднозначен по тексту-источнику
  (могла иметь в виду и pillar, и `what-to-do-if-scratched`) — решение
  Дмитрия: указывает на статью про сам процесс обработки повреждения
  (`what-to-do-if-the-bike-gets-scratched-or-damaged`), не на pillar.

**Найден и исправлен баг: задвоенные/утроенные URL в markdown-ссылках.**
Дмитрий вручную построчно сверил все 8×8 ссылок в сгенерированном
dry-run SQL и нашёл 3 сломанные строки (`[text](url)(url)(url)` и
`(url)(url)`) — по программной проверке регэкспом по всем 64 переводам
подтверждено ровно 5 повреждённых ссылок, не больше (en×2 в pillar, ru×2
в pillar, en×1 в `blog-02`), 0 в de/fr/es/it/ja/ar и 0 в кластерных
статьях кроме одной. **Причина** — в уже удалённом одноразовом скрипте
замены плейсхолдеров: проверка идемпотентности `!content.includes(bracket)`
давала ложное срабатывание, потому что `[text]` — всегда подстрока уже
готовой ссылки `[text](url)`; при повторном запуске скрипта (правил баги
по ru-плейсхолдерам в несколько заходов) код не распознавал уже готовую
ссылку как обработанную и дописывал ещё один `(url)`. Проявилось только
там, где итоговый anchor text совпадал с исходным текстом плейсхолдера
буквально — для en всегда, и для части ru-ссылок, где anchor намеренно
оставлен равным исходной фразе ради сохранения падежа (например
"гиде по депозиту", предложный падеж). Для de/fr/es/it/ja/ar placeholder-
ключом всегда был английский канонический title, а anchor — перевод,
поэтому подстрока не совпадала и повторный прогон не портил их. **Фикс** —
regex-схлопывание `](url)(url)+` → `](url)` применён напрямую к dev БД
(источник истины), sync-файл перегенерирован из неё, повторная
исчерпывающая проверка — 0 повреждений по всем 64 строкам.

**Задача 3 — nav "Blog" в header-меню, 8 языков, RTL (`a4c6c46`):**

- `nav.blog` — новый ключ во всех 8 `frontend/src/i18n/dictionaries/*.json`
  (Blog/Блог/Blog/Blog/Blog/Blog/ブログ/المدونة), вставлен между Bikes и
  About в массиве `links` в `Header.jsx` — без хардкода строк, тот же
  паттерн, что у остальных пунктов меню.
- RTL для `ar` — **зеркалится браузером автоматически**, никакого
  спецкода не понадобилось: `.nav-desktop`/`.nav-mobile` — обычный flex
  без `flex-direction` override, `dir="rtl"` уже стоит на `<html>`
  (`[locale]/layout.js`, `isRtl`) — тот же механизм, что уже держал язык-
  переключатель. Проверено визуально на en/ru/ar: пункт встаёт в правильном
  месте reading order (Home → Bikes → **Blog** → About → FAQ → Contact),
  не механически в конец списка.

**Деплой на прод (ручной, без CI/CD — CLAUDE.md §6):**

1. Проверка состояния (до всех действий): `/en/blog` на проде отдавал
   настоящий Next.js 404 (код блога не задеплоен), таблицы
   `article_categories`/`article_category_translations` не существовали
   вовсе, `articles`/`article_translations` — старый мёртвый скаффолд из
   007-й (0 строк), 045/046 в `schema_migrations` уже были, 047/048 — нет.
2. Редеплой backend+frontend в Coolify UI — вручную Дмитрием, дождались
   `running:healthy`; подтверждено тегом образа = `a4c6c46` (см. поправку
   выше). `/en/blog` после этого — 500 (код есть, схемы ещё нет).
3. `pg_dump -F c` бэкап прод-БД в scratchpad (`prod_backup_2026-08-12_pre_blog.dump`,
   403KB) перед любым ALTER — ритуал CLAUDE.md §6. `047_blog.sql` +
   `048_blog_seed.sql` прогнаны через `ssh` → `docker cp` в контейнер →
   `docker exec -i psql -v ON_ERROR_STOP=1 -f`, оба чисто, вручную
   дописаны в `schema_migrations` (миграции гоняются мимо `migrate.js` на
   проде). `/en/blog` после этого — 200 (пусто, весь контент ещё draft).
4. Контент синхронизирован новым **`backend/scripts/gen_blog_sync.mjs`**
   (в репозитории, по паттерну `gen_catalog_sync.mjs`/`gen_price_sync.mjs`)
   → `blog_deposit_safety_sync.sql` (untracked, регенерируется тем же
   скриптом при следующей категории). Апсерт **по `slug`, не по `id`**
   (id независимо генерируются на dev/prod, никогда не совпадут) — только
   категория `deposit-safety`, 8 статей × 8 языков, `status='published'`,
   `published_at = COALESCE(articles.published_at, now())` (повторный
   прогон не сдвигает дату первой публикации). Легал/bike-models/routes/
   digital-nomads на проде не тронуты — остались как из сида, draft/en-only.
5. Верификация на живом bikebalirent.com: `/blog` на en/ru/ar — скриншоты,
   все 8 статей видны, ar — полный RTL включая пункт меню. Pillar-статья
   с починенными ссылками — визуально подтверждена (одна чистая ссылка,
   без хвостового `(url)`). `/internal/blog` — 401, идентично
   `/internal/pricing` (тот же `Content-Type`/заголовки) — гейт
   консистентен с остальными 5 разделами; **дальше не проверялось** — в
   сессии нет ни прод-пароля Basic Auth, ни прод-значения
   `X-Internal-Admin-Token` (сознательно не хранятся в файлах, CLAUDE.md §6).

**Что осталось по блогу** — категории `legal`/`bike-models`/`routes`/
`digital-nomads` (24 статьи) на dev и prod всё ещё `draft`, только en
title/slug из `048_blog_seed.sql` — им нужен тот же цикл, что прошла
deposit-safety (контент → 8 языков → резолв ссылок → publish → sync на
прод). Юридический пилар (`Blog/blog-09-legal-pillar.md` + `-ru.md`) уже
лежит в репозитории (untracked, от Дмитрия) — специально не тронут в этой
сессии. Rich-текстовый редактор в `/internal/blog` — по-прежнему обычная
`<textarea>` (content — markdown, не HTML), сознательное решение по
объёму задачи, не технический долг.

### Сессия 2026-08-12 (продолжение) — Задача 7: краш при переключении языка на странице статьи блога (ЗАВЕРШЕНО, запушено в main `5905b34`, редеплой на прод — за Дмитрием)

**Баг:** на `/{locale}/blog/{slug}` переключение языка через хедер давало
"Application error: a client-side exception has occurred". На остальных
страницах (`/bikes/[slug]` и т.д.) переключение работало нормально.

**Причина (две накладывающиеся):**

1. Языковой переключатель (`Header.jsx`, `switchLocaleHref`) делал raw
   pathname-substitution — менял только сегмент локали, оставляя slug как
   есть. Это верно для `/bikes/[slug]` (`products.slug` — единый на все
   локали), но не для `/blog/[slug]`: `article_translations.slug`
   per-locale (ru — транслитерация, de/fr/es/it — свои переводы, ja/ar —
   фолбэк на en-slug), поэтому подставленный слаг обычно не существовал
   на целевом языке → `notFound()`.
2. Нигде под `frontend/src/app` не было ни одного `not-found.js`, а
   `<html>/<body>` рендерятся только в `[locale]/layout.js` (multiple root
   layouts, root `app/layout.js` намеренно отсутствует). Дефолтный
   Next-фоллбек на `notFound()` рендерился в обход этого layout'а и ломал
   DOM — `HierarchyRequestError`/`NotFoundError`/`AggregateError` в
   консоли вместо чистой 404. Баг был не только в блоге — это была
   site-wide мина на любой `notFound()` (в т.ч. невалидный `/bikes/[slug]`),
   блог просто первым дал воспроизводимый рабочий сценарий.

**Фикс:**

- `backend/src/routes/blog.js` — новый роут
  `GET /api/blog/posts/:slug/translations?lang=xx`: по `article_id` отдаёт
  slug той же статьи на всех языках, где есть перевод.
- `frontend/src/app/api/blog/posts/[slug]/translations/route.js` — BFF-прокси
  (тот же паттерн, что `/api/quote`) — нужен потому что `Header.jsx`
  клиентский, не может звать backend напрямую (CORS/серверный
  `API_BASE_URL`).
- `Header.jsx`: на странице статьи (`/{locale}/blog/{slug}`, детект
  регэкспом) `switchLocaleHref` резолвит slug целевого языка фоновым
  `fetch` на прокси выше, а не подстановкой префикса. Пока перевод не
  подгружен или его действительно нет — fallback на `/{target}/blog`
  (список статей), не угадывание чужого slug'а. На остальных страницах
  поведение не изменилось.
- `frontend/src/app/[locale]/not-found.js` — новый файл, закрывает
  первопричину #2 сайтвайд, не только для блога. Рендерится ВНУТРИ
  `[locale]/layout.js` (тот же `<html>/<body>`, Header/Footer), не создаёт
  конкурирующий root-узел. `not-found.js` не получает `params` от Next
  14.2 — локаль читается из `pathname` (тот же приём, что в `Header.jsx`).
  Тексты на 8 языков захардкожены прямо в файле, не через
  `i18n/dictionaries/*.json` — блог сейчас каркас с английскими строками,
  отдельная инфраструктура переводов ради трёх строк 404-страницы была бы
  избыточной.

**Верификация (реальные клики по переключателю в браузере, свежая вкладка
на каждую цепочку, консоль проверялась после каждого клика):**
en↔fr, en↔es, en↔it, en↔de, en↔ru — целевая статья открывается на верном
per-locale slug, консоль чистая. en→ja и en→ru→ja (fallback-slug, текстуально
совпадает с en, но это реальная переведённая ja-строка в БД, не наш
`/blog`-фоллбек) — тоже чисто. en→ar и ar→en со страницы статьи — `dir`
корректно переключается `rtl`↔`ltr`, реальный AR-перевод, без крашей. Прямой
заход на несуществующий slug (`/en|ru|ar/blog/this-slug-does-not-exist`) —
чистая переведённая 404 вместо белого экрана, RTL для ar подтверждён через
`document.documentElement`.

**Деплой:** только `git push` в `origin/main` (коммит `5905b34`), редеплой
backend+frontend в Coolify UI не выполнялся в этой сессии — до него баг
воспроизводится и на проде (там ещё код `a4c6c46`).

### Сессия 2026-08-12 (продолжение, 2) — Задача 8: WhatsApp/Telegram-ссылки в статьях deposit-safety (ЗАВЕРШЕНО, применено на dev и prod; изменения только в данных, коммитов нет)

**Что было:** в 7 из 8 статей категории финальный CTA-абзац содержал жирный
markdown `**WhatsApp**`/`**Telegram**` без реальной ссылки. Статья
`what-to-do-after-an-accident-on-a-rented-bike` — вообще без markdown,
обычным текстом, в двух отдельных местах (раздел "Step 3: Contact Us
Immediately" в середине статьи и свой CTA в конце) — не была затронута
первым проходом, добавлена по отдельному запросу Дмитрия в процессе.

**Контакты** — уже существующие, из `frontend/src/lib/contacts.js`
(`https://wa.me/6282146433303`, `https://t.me/Bali_rent_main`), давно живые
в футере/About/JSON-LD, ничего нового не заводили.

**Шаблоны сообщения** по 8 языкам (`{title}` = заголовок ТОЙ ЖЕ строки
`article_translations`, не en-оригинала) — согласованы с Дмитрием построчно,
включая исправление опечатки в немецком (закрывающая кавычка — `„…“`,
U+201E/U+201C, а не прямая `"`; проверено побайтово через кодпоинты после
правки, не на глаз).

**Замена** — литеральная, только точный `**WhatsApp**`/`**Telegram**`
(bold markdown), не любое текстовое упоминание бренда. Явно проверено на
ловушке: в `deposit-scams` есть фраза "a shop that only exists as a
WhatsApp number..." (про WhatsApp мошенника, не наш) — не в bold, regex её
не тронул. Итог: 56 ссылок в исходных 7 статьях + 16 в двух точечных
правках accident-статьи (Step 3 + хвостовой CTA, обе — точная замена
согласованного с Дмитрием предложения, подтверждённая посимвольным
сравнением с DB перед заменой) = **72 WhatsApp + 72 Telegram, 64 строки,
0 незамененных**.

**Скрипт** — разовый, `scratchpad/link_whatsapp_telegram.mjs` (dry-run по
умолчанию, `--apply` пишет в БД) — **не в репозитории**: это одноразовая
контентная правка, не переиспользуемая инфраструктура (в отличие от
`gen_*_sync.mjs`).

**Верификация на dev:** прямой SQL-count в БД (72/72, 0 unlinked) +
decode-roundtrip для ar/ja (`decodeURIComponent` итогового `?text=`
байт-в-байт совпал с исходным сообщением) + живой рендер
(`deposit-scams` на en/ru/ar через `document.querySelectorAll('a')` —
не скриншот, а прямой DOM-запрос: реальные `<a href>`, не сырой markdown;
ar — `dir="rtl"` подтверждён). Пилар-статья (`how-the-deposit-works...`)
живым рендером на dev **не проверялась** — на dev она `status='draft'`,
публичный API отдаёт 404; контент в БД всё равно обновлён (`UPDATE` без
фильтра по `status`), решение пропустить осознанное (см. ниже).

**Прод-синхронизация** — переиспользован существующий
`backend/scripts/gen_blog_sync.mjs` **без единой правки** (только перезапущен
после обновления content на dev). Перед этим отдельно подтверждено построчно
(не на слово, а чтением кода): в апсерте `articles` `status` — жёсткий
литерал `'published'` и в `INSERT`, и в `ON CONFLICT DO UPDATE`, не
`${esc(a.status)}` — значит черновой статус пилар-статьи на dev **не может**
откатить уже опубликованную версию на проде через этот скрипт, даже когда
dev и prod расходятся по `status`. Дальше — стандартный ритуал: `pg_dump -F c`
бэкап прод-БД в scratchpad (`prod_backup_2026-08-12_pre_wa_tg_links.dump`,
537KB) → `scp` + `docker cp` в контейнер `xw6ykwjdrdmtly2qg8kbd16m` →
`docker exec psql -v ON_ERROR_STOP=1 -f` — 72 upsert'а, чистый
`BEGIN`…`COMMIT`. Прямой SQL-count на prod БД после применения — 72/72,
0 unlinked (идентично dev). Финальная проверка живьём на
`bikebalirent.com/en/blog/deposit-scams-how-to-spot-them` — реальный `<a>`
на `wa.me`, `text=` декодирован обратно, совпадает с ожидаемым сообщением
байт-в-байт.

**Осознанно не сделано:** кастомный GA4-эвент (`whatsapp_click`/
`telegram_click`, как у `ContactLink.jsx` в футере/About —
`lib/contacts.js`, `trackChatClick`) для этих 72 ссылок внутри статей не
заводили — они обычные `<a>` из `react-markdown`, не через
`ContactLink.jsx`, поэтому явного клиентского трекинга на них нет; клики
по ним по-прежнему попадут в автосбор GA4 Enhanced Measurement как обычный
outbound-клик (без явного `whatsapp_click`/`telegram_click`, но не совсем
без данных). Если понадобится точный трекинг именно из статей — потребует
переноса рендера этих двух markdown-паттернов на `ContactLink.jsx` внутри
`react-markdown`, отдельная задача, не в объёме этой сессии.

**На заметку (не баг, известная особенность):**
`how-the-deposit-works-when-renting-a-bike-in-bali` (единственная
`is_pillar=true` в категории deposit-safety) на **dev** сейчас `status='draft'`,
на **prod** — `published` (опубликована в прошлом чанке, см. запись выше).
`gen_blog_sync.mjs` спроектирован это учитывать (см. про жёсткий литерал
`'published'` выше) — не воспринимать как рассинхрон, требующий починки,
но не удивляться при следующей ручной проверке через dev, почему пилар не
отдаётся публичным `/api/blog/posts/:slug`.

### Сессия 2026-08-15 — фото PCX Road Sync Pink + устранение дрейфа company_id dev/prod (ЗАВЕРШЕНО на dev; prod не тронут)

**Контекст.** При заливке фото/видео для `honda-pcx-pink-purple-road-sync` и
скрытии `honda-vario-white` (`is_active=FALSE`) обнаружилось, что штатный
`gen_catalog_sync.mjs` падает на FK-constraint: `product_families.company_id`
на dev (`d813b6be-41a1-41e7-9bb6-9d8bbedf5901`) не совпадал с id той же по
смыслу компании на prod (`37005782-1dec-4f77-9673-f4c85eac9d89`, `code
'mdb_bali'` на обеих сторонах). Причина — `INSERT INTO companies` в
`backend/migrations/001_foundation.sql` не хардкодил `id`, полагаясь на
`DEFAULT gen_random_uuid()`; миграция прогонялась независимо на dev и на
prod → два случайных UUID для одной строки. В моменте (для тех двух товаров)
обошли точечным SQL-патчем по `slug`/`id` продуктов, без `product_families` —
это и вскрыло проблему, не решило её.

**Аудит** (`information_schema` по `companies`, не по памяти о схеме) — 19
таблиц с `company_id`: `bookings, customers, delivery_shadow_stats,
deposit_rules, driver_notification_daily_seq, driver_tasks, faqs,
feature_flags, finance_transactions, fleet_items, landing_pages,
notifications, pages, pricing_rule_sets, product_families, system_config,
users, warehouse_items, web_events`. Проверено построчно: во всех таблицах с
данными 100% строк ссылались на dev-id, ни NULL, ни посторонних значений —
единственная компания, чистый сценарий.

**Найденный по ходу баг в первом варианте SQL-патча** (поймал Дмитрий, не
я): `companies.code` — `UNIQUE NOT NULL`. План
`INSERT новой строки с code='mdb_bali'` → `UPDATE 19 таблиц` →
`DELETE старой строки` уронил бы транзакцию на первом же `INSERT`, потому что
старая строка с тем же `code` всё ещё жива в этот момент. Фикс — один
`UPDATE companies SET code='mdb_bali_old_tmp' WHERE id=<dev-id>` перед
`INSERT` (код ничем не референсится по FK, только `id`, так что временно
освобождать его безопасно).

**Применено на dev** (бэкап `local_dev_backup_2026-08-15.dump` в scratchpad
перед стартом): `UPDATE code→tmp` → `INSERT` новой строки `companies` с
`id='37005782-…'` (id с прода) и остальными полями, скопированными с
dev-строки → 19×`UPDATE ... company_id` (счётчики совпали с аудитом
1:1 — 5/6/3/2/1/0/0/14/0/56/0/11/0/1/19/15/0/49/0) →
`DELETE FROM companies WHERE id=<dev-id>`. Одна транзакция, `COMMIT` прошёл
чисто. Прод не трогали ни на одном шаге.

**Причина устранена** — `backend/migrations/001_foundation.sql`: `INSERT INTO
companies` теперь явно указывает `id='37005782-1dec-4f77-9673-f4c85eac9d89'`
(значение с прода) вместо `DEFAULT gen_random_uuid()`. При пересоздании dev
БД с нуля (новая машина и т.п.) дрейф больше не повторится.

**Верификация** — `node backend/scripts/gen_catalog_sync.mjs` (только чтение
dev БД + генерация файла, prod не вызывается): в сгенерированном
`catalog_sync.sql` все 19 `product_families`-строк теперь несут
`company_id='37005782-…'`, вхождений старого dev-id — 0. Раз prod уже хранит
`companies.id=37005782-…`, апсерт с тем же значением — не операция, реальный
`gen_catalog_sync.mjs` → prod больше не упрётся в этот FK.

**Не в объёме этой сессии, на заметку:** в корне репозитория лежит
незакоммиченный параллельный набор файлов `00_full_schema.sql`,
`01_foundation.sql` … `26_product_descriptions_seed.sql` (шапка «MDB PLATFORM
— DATABASE SCHEMA (Opus build)») — `01_foundation.sql` до этой сессии был
байт-в-байт идентичен `backend/migrations/001_foundation.sql` (включая тот же
непрохардкоженный `INSERT INTO companies`), плюс там же есть `25_family_content.sql`,
`25b_family_content_seed.sql`, `26_product_descriptions_seed.sql` — миграции,
которых вообще нет в `backend/migrations/` (там пронумеровано до `048`, но
по другой схеме). Похоже на черновик реорганизации/консолидации миграций,
не тронут в рамках этой задачи — если этот набор когда-то станет
источником для bootstrap БД, тот же дрейф `company_id` повторится, пока туда
не перенесут аналогичный фикс.

### Сессия 2026-08-16 — чанк Contacts/CTA: плавающая кнопка, брендовые иконки, конверсионные CTA (ТЗ §4.16) (ЗАВЕРШЕНО, запушено в main `83e7cf4`; редеплой Coolify — за Дмитрием)

Реализованы все 5 пунктов ТЗ §4.16.1–4.16.5 (промпт собран в отдельном
стратегическом чате, зафиксирован в `MDB_Platform_Contacts_CTA_Handoff_2026-08-16.md`):

1. **Плавающая кнопка контактов** (`FloatingContactButton.jsx`, новый файл,
   монтируется один раз в `[locale]/layout.js`) — WhatsApp/Telegram в правом
   нижнем углу на всех страницах, локализованная подпись-приглашение (8
   языков, `dict.contact.floating_invite`), переиспользует `ContactLink`/
   `withPrefill`/`trackChatClick` — не дублирует логику префилла. GA4-клики
   размечены `source` (`floating_button`/`footer`/`contacts_page`/
   `success_screen`) — новый необязательный параметр
   `trackChatClick(key, href, source)` (`lib/contacts.js`) и `source` prop у
   `ContactLink`, обратно совместимо со старыми вызовами без него.
2. **Брендовые иконки** (`components/icons/BrandIcons.jsx`, новый файл) —
   WhatsApp/Telegram/Instagram/Email, кружок фирменного цвета + белый глиф
   поверх; заменяют текстовые глиф-символы (`✆✈◎✉`), которые были и мелкими,
   и цветом мимо бренда. WhatsApp-глиф — общеупотребимый путь официального
   логотипа (первая самодельная версия выглядела «страшновато» по фидбеку
   Дмитрия, заменена). Footer: сетка контактов 2 колонки вместо 1
   (`.ftr-contacts`), лейбл + значение у каждой иконки; добавлен
   `padding-bottom` на `.ftr-in`, чтобы плавающая кнопка не перекрывала
   последний ряд контактов на мобильных. Contacts (`/about#contact`) — та же
   иконка слева от каждого контакта, плюс Address/Hours для визуального
   выравнивания колонки (не брендовые — те же эмодзи, что уже были в Footer).
3. **Форма заявки** (`BookingForm.jsx`) — поля WhatsApp/Telegram живут с
   «залипающим» префиксом (`+`/`@`), курсор после фокуса — сразу за
   префиксом (`setSelectionRange`), санитайзер (`sanitizePrefixed`) не даёт
   задвоить символ, если клиент допечатает свой `+`/`@`; валидация/
   `buildBody` считают одиночный префикс пустым значением
   (`isBlankPrefixed`). Серый пример формата после префикса (`+62 812 3456
   789` / `username`) — новый компонент `PrefixInput.jsx`: скрытый
   span-«зеркало» меряет реальную ширину префикса в текущем шрифте (Poppins
   не моноширинный), подсказка гаснет, как только `value !== prefix`.
4. **Экран успеха** — пассивный текст «менеджер свяжется…» заменён на 2
   CTA-кнопки (WhatsApp/Telegram), единый шаблон текста на обе
   (`dict.booking.success_cta`, плейсхолдер `{messenger}` — формулировка
   одна и та же, отличается только имя мессенджера; исходный вариант с
   разными формулировками под WA/TG заменён по правке Дмитрия). Предзаполненное
   сообщение (`dict.booking.success_prefill`, плейсхолдеры `{ref}`/`{details}`)
   обязательно несёт номер заявки, при наличии quote — ещё и модель/даты
   (`{ref}{details}` → `BR-00007 (Honda ADV Pink-purple (ABS), Aug 16 – Aug
   23)`); номер заявки остаётся отдельно видимым текстом, как раньше.

**Верификация — живые заявки через dev, не только чтение кода.** EN
(`BR-00007`), RU (`BR-00008`), AR (`BR-00011`) — во всех трёх номер заявки,
модель и даты корректно легли в текст wa.me/t.me ссылки; для AR отдельно
проверено отсутствие bidi-мусора (латиница номера/модели не разъезжается
внутри RTL-предложения, месяцы «16 أغسطس – 23 أغسطس» отрендерились верно).
DE/FR/ES/IT/JA — только переведены в JSON и прогнаны через `JSON.parse`,
живой отправкой заявки не проверялись (не блокер по договорённости с
Дмитрием, дёшево прогнать при следующей правке этого экрана). Цвет/форма
иконок, ghost-текст в полях, RTL-раскладка футера и плавающей кнопки —
проверены скриншотами через Browser pane на desktop/mobile/EN/RU/AR.

**Не в объёме чанка (сознательно, по ТЗ):** логика Telegram-статусных
уведомлений на будущее (продление/возврат депозита, тот же диалог после
Start) — не трогали, только держали в уме, чтобы архитектура кнопки это не
блокировала.

**Файлы:** `frontend/src/app/components/{FloatingContactButton,PrefixInput}.jsx`
(новые), `components/icons/BrandIcons.jsx` (новый),
`components/{Footer,ContactLink,BookingForm}.jsx`,
`[locale]/{layout,about/page}.js`, `lib/contacts.js`, `globals.css`, все 8
`i18n/dictionaries/*.json`. Коммит `83e7cf4`, запушено в `origin/main`.
Автодеплоя нет (см. §6 CLAUDE.md) — редеплой backend/frontend в Coolify UI
остаётся ручным действием Дмитрия.

### Сессия 2026-08-16 (продолжение) — Backups (ЗАВЕРШЕНО)

**Резервное копирование Postgres** настроено через нативный scheduled backup
Coolify (не отдельный cron/pg_dump-скрипт) — расписание `0 19 * * *` UTC
(= 03:00 WITA), retention 14/14 (14 бэкапов локально на сервере + 14 в S3).

**S3-destination** — Cloudflare R2, бакет `mdb-platform-db-backups`
(отдельный от `mdb-platform-media`, где живут фото/видео каталога), Standard
storage class, scoped API-токен (только Object Read & Write, только этот
бакет — не общий R2-токен на все бакеты).

**Frontend/backend бэкап не настраивался осознанно** — оба контейнера
stateless (весь долгоживущий стейт — в Postgres и в R2, которые бэкапятся
отдельно), решение задокументировано, а не оставлено как открытый вопрос.

**Верификация** — вручную запущен Back up now → Success, дамп-файл
подтверждён в R2 (`pg-dump-postgres-*.dmp`).

Зафиксировано в `MDB_Platform_TZ.docx` §15.11.

### Сессия 2026-08-16 (продолжение, 3) — Google Ads native conversion tracking + IPv6-инцидент на проде (ЗАВЕРШЕНО, запушено в main `bd81ea7`; AAAA временно снята с DNS)

**Native conversion tracking** — поверх уже существующих GA4-событий
(`whatsapp_click`/`telegram_click`/`booking_form_submit`, см. «Сессия
2026-08-10 (продолжение)») добавлены отдельные вызовы
`gtag('event', 'conversion', { send_to: 'AW-17065885486/<label>' })` — свой
label на канал (WhatsApp/Telegram) и отдельный на заявку. Точечная правка,
GA4-события не тронуты: `trackChatClick` в `lib/contacts.js` (второй gtag-вызов
после существующего, gated по `CONVERSION_LABELS[key]`) и `BookingForm.jsx`
(сразу после `booking_form_submit`, тот же `if (typeof window.gtag ===
'function')`-guard). Без GTM — его на сайте нет и не нужен (только прямой
`gtag.js`, см. `[locale]/layout.js`).

**Верификация в dev — методологическая заметка на будущее:** штатный
`read_network_requests` в Browser pane НЕ видит cross-origin запросы (не
показал ни один googletagmanager.com/googleads.g.doubleclick.net/mc.yandex.ru
запрос, включая уже существующие до этой сессии) — реальная сеть снималась
через `PerformanceObserver({type:'resource'})` в странице. Отдельно:
синтетический клик через `computer`-тул по ссылкам с `target="_blank"`
(WhatsApp/Telegram кнопки) не долетал до React-обработчика в этой песочнице
(ни новой вкладки, ни сетевых вызовов) — обошли через
`el.dispatchEvent(new MouseEvent('click', {bubbles:true, cancelable:true}))`
на реальном DOM-узле, что действительно проходит через `ContactLink.jsx` →
`trackChatClick`, не подмена. Обычная submit-кнопка (форма бронирования)
кликается штатно через `computer`-тул без обхода. Все три пары (GA4-событие +
`conversion` с верной меткой) подтверждены с реальными данными из кода
(`ep.source=floating_button`, `ep.product=<slug>` и т.д.), консоль чистая,
`window.gtag` грузится штатно. Коммит `bd81ea7`, запушено в `origin/main`.
Редеплой на прод — судя по таймстампам контейнеров ниже, похоже, уже
выполнен Дмитрием вручную в Coolify (не подтверждено явно словами в чате).

**Файлы:** `frontend/src/lib/contacts.js`, `frontend/src/app/components/BookingForm.jsx`.
Без изменений в БД/backend.

---

**IPv6-инцидент (в той же сессии, сразу после пуша).** Дмитрий сообщил:
`bikebalirent.com` не грузится на новом устройстве/в инкогнито (бесконечная
загрузка), при этом уже открытые вкладки продолжают работать. Диагностика по
SSH (`~/.ssh/mdb_platform_new`):

- **Сервер полностью здоров**: `coolify-proxy` (Traefik) и оба
  app-контейнера — `Up ... (healthy)`, без recycling. Оба app-контейнера
  пересозданы за ~24–26 минут до сообщения об инциденте — по всей видимости,
  это и был ручной редеплой в Coolify (см. выше), не сам инцидент.
  CPU/RAM/PIDs — в пределах шума, открытых TCP-соединений всего 19 (1
  established на 443) — не похоже на исчерпание лимитов/соединений. В логах
  Traefik за 30 минут — ноль совпадений на `timeout`/`no healthy
  upstream`/`too many connections`. `ufw` неактивен, `fail2ban` не
  установлен, `iptables INPUT` без DROP-правил. `curl` с самого сервера на
  `https://bikebalirent.com` — чистый, быстрый (307 → `/en`).
- **Реальная причина — сеть, конкретно IPv6.** `curl -6` с внешней машины на
  `bikebalirent.com` — TLS handshake проходит успешно (валидный Let's
  Encrypt сертификат), но HTTP-ответ не приходит: 0 байт за 10 секунд.
  `curl -4` с той же машины — чисто, 1.4 сек. Тот же IPv6-запрос, но
  выполненный **с самого сервера** на его собственный публичный адрес
  (`2a02:c207:2345:9293::1`, обязательно с `--resolve` для правильного SNI —
  без этого Traefik фолбэкается на self-signed и создаёт ложное впечатление
  проблемы в конфиге) — отработал за 47мс без сбоев. Это доказывает: Traefik
  и приложение настроены правильно, проблема — в сетевом маршруте между
  интернетом и IPv6-адресом сервера (похоже на PMTU-blackhole или
  маршрутизацию на стороне Contabo, не диагностировалось глубже за пределами
  инфраструктуры сервера). Полностью объясняет симптом: браузер по Happy
  Eyeballs сначала пробует IPv6, TCP+TLS формально «успешны» → зависает
  вместо отката на IPv4; уже открытые вкладки держат более ранние (видимо,
  IPv4) соединения и продолжают работать.
- **Принятое решение (выполнено Дмитрием):** AAAA-запись `bikebalirent.com`
  временно удалена из Cloudflare DNS — сайт сейчас работает только на IPv4.
  Тикет отправлен в поддержку Contabo. **⚠️ Не возвращать AAAA, пока Contabo
  не подтвердит починку маршрута** — см. обновлённый пункт в CLAUDE.md §6
  (там же зафиксирован факт «A+AAAA → Contabo» из записи «Сессия
  2026-07-30» как временно неактуальный).

### Сессия 2026-08-17 — Enhanced Conversions for Leads (телефон) + Google Consent Mode v2 (ЗАВЕРШЕНО, запушено в main `fa1240f`/`75f922d`; задеплоено на прод — контейнер на коммите `949a5b9`, совпадает с `HEAD`)

**Enhanced Conversions for Leads.** Перед существующим
`gtag('event','conversion', {send_to:'AW-17065885486/BjtuCLjetuIcEK7-0sk_'})`
в `BookingForm.jsx` (стрелял только после успешного `POST /api/bookings`, см.
«Сессия 2026-08-16 (продолжение, 3)») добавлен
`gtag('set','user_data', {phone_number: <E.164>})` — телефон открытым
текстом, хеширует сам `gtag.js` на клиенте, вручную не хешируем. Источник —
поле WhatsApp (`whatsapp` state), оно уже гарантированно с `+` благодаря
«залипающему» префиксу (`sanitizePrefixed`), свой дефолт кода страны не
нужен. `normalizePhoneE164()` убирает пробелы/дефисы/скобки и требует
строгую форму `+`+7–15 цифр; если не подошло (поле пустое или мусор) —
`user_data` не шлётся вовсе, это осознанно (некорректный формат хуже
отсутствующего). Email не тронут, сам вызов `conversion` не менялся.

**Google Consent Mode v2 (MVP, приближение по locale).** В
`[locale]/layout.js`, внутри уже существующего инлайн-скрипта
`google-ads-gtag` (там же определяется сама функция `gtag`), перед первым
`gtag('js', ...)/gtag('config', ...)` добавлены два
`gtag('consent','default', ...)`: deny (`ad_storage`/`ad_user_data`/
`ad_personalization`/`analytics_storage`) с `region` — список стран
ЕЭЗ+Швейцария+UK, `wait_for_update: 500`; и общий grant без `region` —
применяется ко всем остальным регионам (включая Индонезию), баннер им не
нужен. Порядок вызовов внутри `dataLayer` подтверждён в dev
(`window.dataLayer.slice(0,6)`) — оба `consent` идут раньше `js`/`config`.

Нет реальной гео-детекции на v1.0 — приближение через `locale` страницы:
баннер показывается только на `de`/`fr`/`es`/`it` (остальные локали уже
`granted` по умолчанию из layout). Новый клиентский компонент
`CookieBanner.jsx`, смонтирован в layout рядом с `FloatingContactButton`:
при отсутствии сохранённого выбора в `localStorage['mdb_consent']` и
подходящей locale — показывает нижний баннер (не модальный оверлей, простой
MVP); клик «Принять»/«Отклонить необязательные» пишет выбор в localStorage и
шлёт `gtag('consent','update', {...granted|denied})`; при повторном визите с
сохранённым выбором — `update` уходит сразу при монтировании, баннер не
показывается повторно. Тексты `cookie_banner.{message,accept,decline}`
добавлены во все 8 словарей (не только целевые 4 locale) для консистентности
с остальными переводами (см. CLAUDE.md §3.8).

**Верификация в dev:** проверено вживую через preview-браузер на `/de` —
баннер показан с немецким текстом, `dataLayer` содержит оба `consent
default` раньше `js`/`config`; клик «Akzeptieren» → `localStorage.mdb_consent
= 'accept'`, `gtag('consent','update', {...granted})` ушёл, баннер скрылся;
перезагрузка `/de` — баннер не появляется повторно, `update` отправлен
автоматически при монтировании; на `/en` баннер не показан вовсе (locale вне
списка). Консоль без ошибок.

**Известный некритичный нюанс:** `CookieBanner` и `FloatingContactButton` —
оба `position: fixed` внизу экрана; на мобильном при показанном баннере
плавающая кнопка контактов может визуально перекрываться баннером (баннер
выше по z-index, сам по себе не ломается). Не исправлено — не запрошено,
чисто косметика для MVP.

**Файлы:** `frontend/src/app/components/BookingForm.jsx` (Enhanced
Conversions, коммит `fa1240f`); `frontend/src/app/[locale]/layout.js`,
`frontend/src/app/globals.css`, `frontend/src/app/components/CookieBanner.jsx`
(новый), `frontend/src/i18n/dictionaries/*.json` — все 8 (Consent Mode v2,
коммит `75f922d`). Без изменений в БД/backend.

---

**Первый деплой упал, ретрай прошёл (в той же сессии, сразу после пуша).**
После `git push` в Coolify вручную запущен редеплой на коммите `949a5b9`
(HEAD, включает оба фичевых коммита выше) — первая попытка **упала**
(`Failed`, 02m48s), вторая (сразу следом, без изменений в коде) прошла
штатно (`Success`, 03m07s).

Диагностика (SSH `~/.ssh/mdb_platform_new`, read-only): локальный
`npm run build` на том же коммите прошёл чисто — значит, дело не в коде.
Полный лог упавшего билда вытащен напрямую из Postgres Coolify
(`docker exec coolify-db psql -U coolify -d coolify -c "select logs from
application_deployment_queues where id=<N>"` — обходит обрезание, которое
показывает UI-панель логов) и обрывается сразу после `✓ Compiled
successfully` (24.95s), без единой строки дальше — ни «Generating static
pages», ни текста ошибки. `docker exec` вернул `exit code 255` — типичный
симптом того, что билд-контейнер умер снаружи, пока к нему было подключение,
не что сам `next build` упал с ошибкой. `journalctl`/`dmesg` за это окно
времени не показали записей OOM-killer (не удалось подтвердить впрямую), но
на сервере **обнаружено 0 swap** при несколько сервисах на борту (Postgres,
Traefik, Coolify, плюс сторонний Horizon/PHP-FPM) — вероятная причина:
кратковременный скачок памяти на самом тяжёлом этапе сборки (генерация 72
статических страниц), без swap-подушки резко убивающий процесс без следа в
логе приложения.

После успешного ретрая — сверка на живом проде: `docker ps` на сервере
показывает образ `odke6aycqzy4zybnkutq8qbm:949a5b97607a2f7d7a8d13662b8085070528958b`
(полный SHA = `git rev-parse HEAD` в репо, совпадает); через preview-браузер
на `https://bikebalirent.com/de` подтверждено вживую: баннер показывается,
`dataLayer` содержит оба `gtag('consent','default', ...)` раньше `js`/
`config` — новый код реально работает на проде, не только задеплоен.

**Рекомендация на будущее (не выполнено, решение за Дмитрием):** добавить
2–4 GB swap на сервере как страховку от повторения — не системная авария,
но если сбои деплоя по этому же паттерну (падает без ошибки сразу после
`Compiled successfully`) начнут повторяться чаще одного раза, это первое,
что стоит проверить/поправить.

---

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
