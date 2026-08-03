# Deploy runbook — каталог 101 карточки (пересборка фото + новые байки)

Регенерировано 2026-07-29 (оригинал был в scratchpad прошлой сессии и потерян
при закрытии той сессии — scratchpad не переживает переход между сессиями,
в отличие от файлов в самом репозитории). Восстановлено из PROJECT_STATUS.md
и текущего состояния локальной БД/файлов, которые остались нетронуты.

Порядок шагов важен: **фото на R2 должны попасть раньше**, чем БД на проде
начнёт на них ссылаться (иначе — битые изображения на живом сайте).

## Шаг 1 — Redeploy в Coolify UI на коммит `fd1da26`

Коммит: `feat(catalog): model filter for motorcycle group (П.20) + static OG preview image`
(текущий HEAD main). В Coolify UI: проект `mdb-platform` → сервис
backend/frontend → Redeploy, убедиться что подтягивает именно этот коммит
(не более старый закэшированный). Дождаться `running:healthy` на обоих.

## Шаг 2 — Бэкап прод-БД (для страховки перед шагом 4)

Сервер: Contabo `169.58.60.244`. Postgres — self-hosted внутри Coolify
(`postgresql-database-xw6ykwjdrdmtly2qg8kbd16m`, образ `postgres:18-alpine`).

```bash
ssh <user>@169.58.60.244
docker ps | grep postgres          # найти точное имя контейнера
docker exec <container> pg_dump -U postgres -d mdb_platform -F c -f /tmp/prod_backup_2026-07-29.dump
docker cp <container>:/tmp/prod_backup_2026-07-29.dump ./prod_backup_2026-07-29.dump
```

Скачать `.dump` к себе локально (`scp`) прежде чем продолжать — если шаг 4
что-то сломает, восстановление: `pg_restore -d mdb_platform --clean prod_backup_2026-07-29.dump`.

## Шаг 3 — Фото на R2 (`--dryrun` сначала!)

Бакет: `mdb-platform-media` (Cloudflare R2), endpoint
`https://3c3d58a73ee90534807282e5c9c708be.r2.cloudflarestorage.com`.
Публичный URL: `https://cdn.bikebalirent.com` (Custom Domain, подключён
2026-08-03; `NEXT_PUBLIC_PHOTO_BASE_URL` на проде указывает сюда). Старый
dev-адрес `pub-92229917b7c74364afcdf15e1d1cff99.r2.dev` пока не отключён и
работает — оставлен как страховка для отката.

Локально сейчас: 1715 файлов, 740MB в `frontend/public/bikes/`
(структура `bikes/<slug>/{thumb,gallery,hero}/NN.webp` + иногда `video.mp4`,
ровно как строит `resolvePhotoUrl()` в `frontend/src/lib/photos.js`).
Это МЕНЬШЕ чем 1971 файл из прошлой миграции — часть исходных дублей была
снесена при пересборке в прошлой сессии, так что `sync` должен не только
залить новое, но и убрать то, чего больше нет локально → нужен `--delete`.

```bash
# сначала обязательно dry-run — посмотреть, что реально изменится
aws s3 sync frontend/public/bikes/ s3://mdb-platform-media/bikes/ \
  --endpoint-url https://3c3d58a73ee90534807282e5c9c708be.r2.cloudflarestorage.com \
  --content-type image/webp --cache-control "public, max-age=86400, s-maxage=604800" \
  --delete --dryrun --profile r2

# если план выглядит разумно (не тысячи неожиданных удалений) — тот же
# командой без --dryrun
aws s3 sync frontend/public/bikes/ s3://mdb-platform-media/bikes/ \
  --endpoint-url https://3c3d58a73ee90534807282e5c9c708be.r2.cloudflarestorage.com \
  --content-type image/webp --cache-control "public, max-age=86400, s-maxage=604800" \
  --delete --profile r2
```

Требует настроенного `aws configure --profile r2` (R2 Access Key/Secret из
Cloudflare dashboard → R2 → Manage API Tokens) — credentials из прошлой
сессии не сохранились на диске, нужно ввести заново.

## Шаг 4 — `catalog_sync.sql` на проде

Файл лежит в корне репозитория (`catalog_sync.sql`, untracked, регенерирован
скриптом `backend/scripts/gen_catalog_sync.mjs` из текущей локальной БД:
19 product_families, 101 products, 560 product_photos). Идемпотентный —
`INSERT ... ON CONFLICT (id) DO UPDATE`, безопасно перезапускать.

```bash
scp catalog_sync.sql <user>@169.58.60.244:/tmp/
ssh <user>@169.58.60.244
docker exec -i <container> psql -U postgres -d mdb_platform < /tmp/catalog_sync.sql
```

Проверка после применения — на живом сайте открыть несколько карточек из
новых/пересобранных (Morbidelli, Frankenstein/Byson/Scorpio/D-Tracker, Honda
ADV/PCX, Kawasaki ZX-25R) и убедиться, что фото не битые (это будет значить,
что шаг 3 отработал раньше и R2-объекты уже на месте).

## Если что-то пошло не так

`pg_restore -d mdb_platform --clean prod_backup_2026-07-29.dump` из шага 2.
Фото на R2 откатывать не нужно — `--delete` без `--dryrun` уже необратим для
удалённых объектов, но старые файлы физически не нужны (это то же самое, что
сейчас лежит в `frontend/public/bikes/` минус дубли).

## Как перегенерировать `catalog_sync.sql`, если каталог снова изменится

```bash
cd backend && node scripts/gen_catalog_sync.mjs
```

Скрипт остаётся в репозитории (`backend/scripts/gen_catalog_sync.mjs`) —
переживёт закрытие сессии, в отличие от файлов в scratchpad.

---

# Постоянные процедуры

Всё выше — разовый деплой каталога от 2026-07-29. Ниже — то, что повторяется
и не привязано к конкретной дате.

## Отзывы: добавить

1. Положить скриншот в папку исходников (`Фото байков для сайта/Reviews`).
2. Прописать файл в `SOURCES` в `backend/scripts/prep_reviews.mjs`: задать `id`
   (он же имя файла и ключ в JSON) и режим кропа. `auto` годится, когда в кадре
   только сообщения клиента; `manual` с явным box — когда надо вырезать НАШИ
   реплики (просьба об отзыве, промо Instagram, логистика возврата).
   **Публикуем только то, что написал клиент.**
3. `cd backend && node scripts/prep_reviews.mjs "<src-dir>" ../frontend/public/reviews`
4. Глазами проверить получившийся `.webp` — авто-кроп иногда срезает последнюю
   строку (так было с `best-service-ive-had-in-bali`, чинится высотой box).
5. Добавить объект в `frontend/src/data/reviews.json` с переводами на все 8
   языков. `rating` не ставим (в WhatsApp звёзд нет — любая оценка выдумана),
   `name`/`date` — только если реально известны из переписки.
6. Залить в R2 и задеплоить фронт.

```bash
aws s3 sync frontend/public/reviews/ s3://mdb-platform-media/reviews/ \
  --endpoint-url https://3c3d58a73ee90534807282e5c9c708be.r2.cloudflarestorage.com \
  --content-type image/webp --cache-control "public, max-age=86400, s-maxage=604800" \
  --profile r2
```

## Отзывы: удалить (напр. клиент попросил снять свой отзыв)

⚠️ **Двух шагов, и второй забывается.** Убрать объект из `reviews.json`
достаточно, чтобы отзыв пропал с сайта, но скриншот останется лежать в R2 и
будет доступен по прямой ссылке **навсегда**. Аудитория сайта включает ЕС, где
требование удалить свои данные законно, поэтому удалять надо оба.

```bash
# 1. Удалить объект из R2 (это и есть шаг, который забывают)
aws s3 rm s3://mdb-platform-media/reviews/<id>.webp \
  --endpoint-url https://3c3d58a73ee90534807282e5c9c708be.r2.cloudflarestorage.com \
  --profile r2

# 2. Проверить, что ссылка действительно умерла (ожидаем 404)
curl -s -o /dev/null -w "%{http_code}\n" \
  https://cdn.bikebalirent.com/reviews/<id>.webp
```

Затем: удалить объект из `frontend/src/data/reviews.json`, удалить локальный
файл `frontend/public/reviews/<id>.webp`, удалить запись из `SOURCES` в
`prep_reviews.mjs` (иначе следующий прогон скрипта зальёт его обратно),
закоммитить и задеплоить фронт.

## R2: переезд с dev-URL на Custom Domain (ВЫПОЛНЕНО 2026-08-03)

Медиа отдаётся с `https://cdn.bikebalirent.com`. Оставлено здесь как описание
процедуры — пригодится, если понадобится сменить домен ещё раз.

Шаги 1-2 делаются **только в дашборде Cloudflare** — S3-ключи из профиля `r2`
таких прав не дают (это отдельный Cloudflare API, не S3).

1. Cloudflare → R2 → бакет `mdb-platform-media` → Settings → Custom Domains →
   Connect Domain → `cdn.bikebalirent.com`. DNS-запись Cloudflare создаёт сам,
   зона уже на этом аккаунте. Запись будет **проксируемой (оранжевое облако)** —
   так и надо, через прокси работают кэш и WAF. Не путать с apex/www, которые
   намеренно DNS only.
2. Дождаться статуса Active (выпуск сертификата, минуты).
3. Coolify → `mdb-platform-frontend` → Environment Variables → секция
   **Production** → отредактировать существующую `NEXT_PUBLIC_PHOTO_BASE_URL`
   на `https://cdn.bikebalirent.com`.
   ⚠️ Именно **отредактировать**, а не «+ Add»: каждая переменная существует в
   Coolify дважды (Production + Preview), и попытка добавить новую с тем же
   именем молча не сохраняется. Проверить, что значение реально легло:

```bash
ssh -i ~/.ssh/mdb_platform_new root@169.58.60.244 \
  'docker exec coolify php artisan tinker --execute="foreach (\App\Models\EnvironmentVariable::where(\"key\",\"NEXT_PUBLIC_PHOTO_BASE_URL\")->get() as \$e) echo \$e->id.\" \".(\$e->is_preview?\"Preview\":\"Production\").\" [\".\$e->value.\"]\".PHP_EOL;"'
```

4. **Redeploy** (не Restart!). `NEXT_PUBLIC_*` вшивается в бандл на этапе
   сборки, а не читается в рантайме — Restart переменную не подхватит, в HTML
   останется старый адрес. В Coolify Redeploy включает пересборку; в логе
   должно быть `Building docker image started` / `completed`.
5. Проверить, что в HTML живого сайта только новый домен:

```bash
curl -s https://bikebalirent.com/en | grep -c 'cdn.bikebalirent.com'
curl -s https://bikebalirent.com/en | grep -c 'r2.dev'   # должно быть 0
```

Старый r2.dev продолжает работать и намеренно НЕ отключён — страховка для
отката (вернуть переменную + redeploy). Отключается в Cloudflare → R2 →
бакет → Settings → Public Development URL → Disable, только когда уверены.

## Кэш на `cdn.bikebalirent.com`

Состоит из ДВУХ частей, и одной недостаточно — проверено на практике.

**Часть 1 — `Cache-Control` на объектах (СДЕЛАНО 2026-08-03).** Проставлено
`public, max-age=86400, s-maxage=604800` на все 1722 объекта: сутки в браузере,
неделя на узлах CDN. Проверено по равномерной выборке 41 объекта — пропусков
нет; `Content-Type` сохранён (два прохода: `*.webp` → `image/webp`,
`*.mp4` → `video/mp4`, иначе видео получило бы тип картинки).

Команды заливки выше уже содержат `--cache-control` — **не убирать его**,
иначе новые файлы приедут без заголовка. Если понадобится сменить срок на
всём бакете разом:

```bash
# ВНИМАНИЕ: перезаписывает метаданные. Обязательно двумя проходами по типам!
EP=https://3c3d58a73ee90534807282e5c9c708be.r2.cloudflarestorage.com
CC="public, max-age=86400, s-maxage=604800"
aws s3 cp s3://mdb-platform-media/bikes/ s3://mdb-platform-media/bikes/ --recursive \
  --metadata-directive REPLACE --exclude "*" --include "*.webp" \
  --content-type image/webp --cache-control "$CC" --profile r2 --endpoint-url $EP
aws s3 cp s3://mdb-platform-media/bikes/ s3://mdb-platform-media/bikes/ --recursive \
  --metadata-directive REPLACE --exclude "*" --include "*.mp4" \
  --content-type video/mp4 --cache-control "$CC" --profile r2 --endpoint-url $EP
```

**Часть 2 — Cache Rule `cdn-media-cache` (СДЕЛАНО 2026-08-03).**

Cloudflare → зона `bikebalirent.com` → Caching → Cache Rules
- Условие: `Hostname` equals `cdn.bikebalirent.com`
  (выражение: `(http.host eq "cdn.bikebalirent.com")`)
- Then: Cache eligibility → **Eligible for cache**
- Edge TTL: `Use cache-control header if present, bypass cache if not`
- Browser TTL: `Respect origin TTL`
- Остальные настройки (Cache key, Vary, Serve stale, ETags, Origin error
  pass-through) — не трогать, умолчания верны для статики.

Правило только разрешает кэширование, сроки берутся из заголовка объектов —
менять сроки можно командой выше, не трогая правило.

⚠️⚠️ **КАК ПРОВЕРЯТЬ КЭШ — читать обязательно, иначе потеряете час.**
`curl -sI` шлёт **HEAD**, а на HEAD Cloudflare отдаёт `cf-cache-status:
DYNAMIC` ВСЕГДА, независимо от того, лежит объект в кэше или нет. Проверять
только настоящим GET:

```bash
# ПРАВИЛЬНО — GET с выводом заголовков
U=https://cdn.bikebalirent.com/bikes/honda-adv-total-black/thumb/01.webp
curl -s -o /dev/null -D - "$U" | grep -iE 'cf-cache-status|^age'
curl -s -o /dev/null -D - "$U" | grep -iE 'cf-cache-status|^age'
# первый на холодном объекте → MISS, второй → HIT с растущим age

# НЕПРАВИЛЬНО — всегда DYNAMIC, ничего не показывает
curl -sI "$U" | grep -i cf-cache-status
```

Была ли Cache Rule строго необходима — не доказано: объект попал в кэш ещё
до её создания, сразу после простановки `Cache-Control` (`age` ~3200 с при
проверке сразу после создания правила). Похоже, заголовка достаточно.
Правило оставлено, чтобы поведение не зависело от умолчаний Cloudflare.

⚠️ **После замены фото по тому же пути — обязательно Purge Cache** в
Cloudflare (Caching → Configuration → Purge). Иначе на узлах CDN до недели
будет отдаваться старая картинка, хотя в R2 уже лежит новая.
