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
Публичный URL: `https://pub-92229917b7c74364afcdf15e1d1cff99.r2.dev`
(`NEXT_PUBLIC_PHOTO_BASE_URL` на проде указывает сюда — dev-режим,
Custom Domain ещё не подключён, это отдельный техдолг).

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
  --content-type image/webp --delete --dryrun --profile r2

# если план выглядит разумно (не тысячи неожиданных удалений) — тот же
# командой без --dryrun
aws s3 sync frontend/public/bikes/ s3://mdb-platform-media/bikes/ \
  --endpoint-url https://3c3d58a73ee90534807282e5c9c708be.r2.cloudflarestorage.com \
  --content-type image/webp --delete --profile r2
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
  --content-type image/webp --profile r2
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
  https://pub-92229917b7c74364afcdf15e1d1cff99.r2.dev/reviews/<id>.webp
```

Затем: удалить объект из `frontend/src/data/reviews.json`, удалить локальный
файл `frontend/public/reviews/<id>.webp`, удалить запись из `SOURCES` в
`prep_reviews.mjs` (иначе следующий прогон скрипта зальёт его обратно),
закоммитить и задеплоить фронт.

## R2: переезд с dev-URL на Custom Domain

Сейчас медиа отдаётся с `pub-92229917b7c74364afcdf15e1d1cff99.r2.dev` —
это Public Development URL, Cloudflare сам режет ему скорость и не рекомендует
для боевого трафика. Целевой адрес — `cdn.bikebalirent.com`.

Шаги 1-2 делаются **только в дашборде Cloudflare** — S3-ключи из профиля `r2`
таких прав не дают (это отдельный Cloudflare API, не S3).

1. Cloudflare → R2 → бакет `mdb-platform-media` → Settings → Custom Domains →
   Connect Domain → `cdn.bikebalirent.com`. DNS-запись Cloudflare создаст сам,
   зона уже на этом аккаунте.
2. Дождаться выпуска сертификата (обычно минуты).
3. Coolify → сервис `mdb-platform-frontend` → Environment Variables →
   `NEXT_PUBLIC_PHOTO_BASE_URL` = `https://cdn.bikebalirent.com`
4. **Redeploy фронта именно с ребилдом.** `NEXT_PUBLIC_*` вшивается в бандл на
   этапе сборки, а не читается в рантайме — без ребилда в HTML останется старый
   r2.dev-адрес. На этом уже спотыкались при первой миграции на R2.
5. Проверить, что в HTML живого сайта появились ссылки на новый домен:

```bash
curl -s https://bikebalirent.com/en | grep -o 'https://[^"]*\.webp' | head -3
```

Старый r2.dev-адрес после переезда продолжит работать — отключать его
отдельно не нужно, но и ссылаться на него больше негде.
