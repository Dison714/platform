# SEO_AUDIT.md — аудит SEO-состояния frontend (Шаг 0, «как есть»)

_Дата: 2026-07-02. Чанк «SEO enrichment layer», Шаг 0 — чистый аудит, без изменений
кода. Ничего не чинится и не предлагается — только фиксация фактов и пробелов._

Метод: чтение кода `frontend/src/app/**` + инспекция реально отрендеренного `<head>`
на живом дев-сервере (`:3001`, App Router SSR). Локали активны: **en + ru**
(`src/i18n/config.js`; de/fr/es/it/ja — `enabled:false`).

Легенда путей: все пути относительны `frontend/`.

---

## 1. `<head>` / meta теги (title, description, viewport, charset)

| Страница | Роут-файл | title | description | статич/динам |
|---|---|---|---|---|
| Homepage | `src/app/[locale]/page.js` | ✅ `${brand.name} — ${brand.tagline}` | ✅ `home.hero_sub` | динам (`generateMetadata`, из словаря) |
| Каталог | `src/app/[locale]/bikes/page.js` | ✅ `${catalog.title} — ${brand.name}` | ✅ `brand.tagline` | динам |
| Product | `src/app/[locale]/bikes/[slug]/page.js` | ✅ `${product.name} — ${brand.name}` | ✅ `product.description` или `${name} — ${tagline}` | динам (из API) |
| About | `src/app/[locale]/about/page.js` | ✅ | ✅ `about.p1` | динам |
| FAQ | `src/app/[locale]/faq/page.js` | ✅ | ✅ `faq.intro` | динам |

- **viewport / charset:** ✅ присутствуют на всех страницах — эмитятся дефолтами Next
  App Router (`<meta charSet="utf-8">`, `<meta name="viewport" content="width=device-width, initial-scale=1">`).
  Явно в коде не заданы.
- **Дублирование между локалями:** title/description берутся из локале-словарей
  (`en.json`/`ru.json`), поэтому **тексты разные для en и ru** — дублей нет.
- **`<html lang>`:** ❌ жёстко `lang="en"` в `src/app/layout.js` (root) — на `/ru`
  тоже отдаётся `<html lang="en">` (проверено на живой странице). Не зависит от локали.

**Отсутствует:** локале-зависимый `<html lang>`; общий/дефолтный `metadata` в root-layout
(нет fallback-title/description и `metadataBase` — см. п.5).

---

## 2. OpenGraph / Twitter Card

| Тег | Homepage | Каталог | Product | About | FAQ |
|---|---|---|---|---|---|
| og:title / og:description | ❌ | ❌ | ❌ | ❌ | ❌ |
| og:image | ❌ | ❌ | ❌ (даже при готовом hero-фото) | ❌ | ❌ |
| og:type / og:url / og:site_name / og:locale | ❌ | ❌ | ❌ | ❌ | ❌ |
| twitter:card / twitter:* | ❌ | ❌ | ❌ | ❌ | ❌ |

- **Полностью отсутствуют** во всём приложении. В `generateMetadata` нет ключа
  `openGraph`/`twitter` ни на одной странице (проверено grep’ом + живым `<head>`).
- **Product `og:image`:** динамического og:image нет; дефолтной картинки-заглушки
  тоже нет. При этом hero-фото доступно (`pickHero(product.photos)` уже используется
  для рендера) — источник для динамического og:image есть, но не задействован.

**Где живёт:** нигде (файлов с OG нет). Точки, куда это встанет позже — `generateMetadata`
каждого роут-файла.

---

## 3. Schema.org / JSON-LD

| Тип | Где | Статус / замечания |
|---|---|---|
| `Product` + `Offer` | `src/app/[locale]/bikes/[slug]/page.js:46-62` | ✅ есть. Поля: `name`, `category`, `brand` (из первого слова family), `description` (опц.), `offers` (`priceCurrency`, `price` = цена дня-1, `availability: InStock`). |
| `FAQPage` | `src/app/[locale]/faq/page.js:22-30` | ✅ есть (mainEntity из `faq.items`). |
| `Organization` / `LocalBusiness` | — | ❌ отсутствует. Данные для него **есть в коде** (`src/lib/contacts.js`: WhatsApp/Telegram/Instagram/email, `ADDRESS`, `HOURS`), но рендерятся только как видимые ссылки, не как structured data. |
| `BreadcrumbList` | — | ❌ отсутствует. |
| `ItemList` (каталог) | — | ❌ отсутствует. |

- **Продуктовый Schema есть, но неполный:** ❌ нет `image` (хотя 648 фото готовы в
  `product_photos`), нет `sku`/`mpn`, нет `aggregateRating`/`review`, нет `url`,
  нет разбивки specs (доступны `family_specs`). `brand` вычисляется как
  `family.name.split(' ')[0]` (эвристика по первому слову).
- Оба JSON-LD инъектятся через `<script type="application/ld+json" dangerouslySetInnerHTML>`.

**Основной gap раздела:** Product schema есть, но без `image`/specs; и полностью
отсутствует сайт-уровневый `Organization`/`LocalBusiness` (важно для локального SEO
аренды на Бали).

---

## 4. hreflang

| Что | Статус |
|---|---|
| `<link rel="alternate" hreflang="en">` / `hreflang="ru">` между парными страницами | ❌ отсутствует (проверено grep + живой `<head>`) |
| `hreflang="x-default"` | ❌ отсутствует |

- Ни на одной странице нет `alternates.languages` в `generateMetadata`. При двух
  активных локалях (en/ru) с идентичной структурой URL (`/en/...` ↔ `/ru/...`)
  перекрёстные hreflang-ссылки не проставляются вообще.

**Где живёт:** нигде. Логичное место — `generateMetadata` (`alternates.languages`)
или общий helper (которого нет, см. п.8).

---

## 5. Canonical URLs

| Страница | canonical | значение |
|---|---|---|
| Homepage | ✅ | `/${locale}` |
| Каталог `/bikes` | ❌ **нет** | `generateMetadata` без `alternates.canonical` |
| Product | ✅ | `/${locale}/bikes/${slug}` |
| About | ✅ | `/${locale}/about` |
| FAQ | ✅ | `/${locale}/faq` |

- **Каталог без canonical** — и это именно та страница, где есть query-параметр
  фильтра `?category=` (`src/app/[locale]/bikes/page.js`, `searchParams.category`).
  Значит `/en/bikes`, `/en/bikes?category=sport`, `/en/bikes?category=cruiser` и т.д.
  — потенциальные дубли без canonical, нормализующего к `/en/bikes`.
- **Canonical относительные** (`/en/...`, а не абсолютные) — потому что **нет
  `metadataBase`** ни в одном layout. Next оставляет их относительными (Google это
  переваривает, но абсолютный canonical — best practice; для абсолютных og:url/canonical
  `metadataBase` обязателен).

**Где живёт:** `alternates.canonical` в `generateMetadata` четырёх из пяти страниц.

---

## 6. sitemap.xml

| Что | Статус |
|---|---|
| `app/sitemap.js`/`.ts` (Next-роут) | ❌ нет |
| `public/sitemap.xml` (статик) | ❌ нет (`public/` содержит только `bikes/`) |
| Любой `/sitemap*` роут | ❌ нет |

- **Sitemap отсутствует полностью.** Ни один из 76 Product page, ни контентные
  страницы, ни локали (en/ru) не перечислены. `lastmod` негде взять на уровне
  sitemap (в БД у продуктов есть `updated_at`, но это на будущее).

---

## 7. robots.txt

| Что | Статус |
|---|---|
| `app/robots.js`/`.ts` | ❌ нет |
| `public/robots.txt` | ❌ нет |

- **robots.txt отсутствует.** Нет ни allow/disallow-правил, ни ссылки на sitemap
  (которого тоже нет). По умолчанию сайт полностью краулится, но директив нет.
- Отдельно: `src/middleware.js` редиректит любой путь без локали на `/${DEFAULT_LOCALE}` —
  это поведение роутинга, не SEO-директива, но влияет на то, какие URL канонічны.

---

## 8. Прочее

| Пункт | Статус / факт |
|---|---|
| favicon | ❌ нет (`app/favicon.ico`, `app/icon.*`, `public/favicon.*` — отсутствуют; в `<head>` icon-линков нет) |
| apple-touch-icon | ❌ нет |
| `manifest`/PWA | ❌ нет `app/manifest.js`/`site.webmanifest` |
| Метод генерации меты | **App Router `generateMetadata`** (async, per-page). Старого `<Head>` нет. |
| `metadataBase` | ❌ не задан (ни root-, ни locale-layout) → относительные canonical/og-url |
| Общий helper меты | ❌ нет. Каждая страница формирует свой объект в `generateMetadata` вручную (дублируется паттерн `${...} — ${brand.name}` + `alternates.canonical`). Нет переиспользуемой функции — при добавлении OG/hreflang правится в 5 местах. |
| Дефолтный `metadata` в root-layout | ❌ нет (`src/app/layout.js` экспортирует только `RootLayout`, без `metadata`) |
| Источник фактов для Organization/LocalBusiness | ✅ есть в коде: `src/lib/contacts.js` (контакты, адрес, часы). Не выведены в structured data. |

---

## Gaps summary (приоритетно, без предложений реализации)

**P0 — критично для индексации/локального SEO:**
1. **Нет `sitemap.xml`** — 76 Product page + контентные страницы × 2 локали не поданы в индекс (п.6).
2. **Нет `robots.txt`** — нет директив и ссылки на sitemap (п.7).
3. **Нет OpenGraph/Twitter вообще** — все шеры (WhatsApp/Telegram/соцсети) без превью-карточки; для трафик-модели на мессенджерах это заметно (п.2).
4. **Product JSON-LD без `image`** (и без specs) — при 648 готовых фото и `family_specs`; главный «лёгкий» апгрейд Rich Result (п.3).
5. **Нет `Organization`/`LocalBusiness` schema** — данные уже в `contacts.js`, но не эмитятся; важно для локального поиска аренды на Бали (п.3).

**P1 — техническая гигиена индексации:**
6. **Каталог без canonical** при живом `?category=` фильтре → риск дублей (п.5).
7. **Нет hreflang** между en/ru + нет `x-default` — межъязыковые дубли не связаны (п.4).
8. **`<html lang>` жёстко `en`** на всех локалях, включая `/ru` (п.1).
9. **Нет `metadataBase`** → canonical/og-url остаются относительными (п.5, п.8).

**P2 — присутствие/полировка:**
10. **Нет favicon / apple-touch-icon / manifest** (п.8).
11. **Нет общего helper’а меты** — OG/hreflang/canonical придётся раскатывать по 5 страницам вручную; нет дефолтного `metadata` в root-layout (п.8).
12. **Нет `BreadcrumbList`** для каталог→продукт (п.3).

**Что уже сделано (базис, на чём строить Шаг 1+):**
- ✅ title/description на всех 5 страницах, динамические, локале-специфичные.
- ✅ canonical на 4/5 страниц.
- ✅ Product/Offer JSON-LD (нужно дообогатить) и FAQPage JSON-LD.
- ✅ SSR-контент (Google видит каталог/карточки), viewport/charset (дефолты Next).
- ✅ Готовые источники для обогащения: `product_photos` (image), `family_specs` (specs), `contacts.js` (Organization/LocalBusiness).

---

_СТОП. Отчёт «как есть». Кода не менял, роутов/миграций не добавлял. Жду OK Дмитрия
перед Шагом 1 (реализация)._
