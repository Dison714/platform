# MDB Platform — backend

Node.js + Express + `pg`. Миграции — обычные `.sql`-файлы из корневой схемы
(`01_foundation.sql` … `08_triggers_audit_flags.sql`), применяются по порядку
своим минимальным раннером (`src/db/migrate.js`), без внешних ORM/фреймворков.

## Локальная установка

1. **Postgres.app** (нужен Homebrew — `brew install --cask postgres-app`,
   либо скачать с https://postgresapp.com). Запусти, создай дефолтный сервер
   на порту 5432.
2. Скопируй `.env.example` → `.env`, проверь `DATABASE_URL`.
3. `npm install`
4. `npm run db:create` — создаст базу `mdb_platform`, если её нет.
5. `npm run migrate` — применит миграции 001…008.
6. `npm run dev` — поднимет API на `http://localhost:3000`, проверка:
   `curl http://localhost:3000/health`.

## Структура

```
backend/
  migrations/        001..008 — копии 01..08_*.sql из корня репозитория
  src/
    config/env.js    переменные окружения
    db/pool.js        пул соединений pg
    db/migrate.js      раннер миграций (up/status)
    db/create-database.js   создаёт БД, если её нет
    server.js          Express-приложение, /health
```

Корневые `0N_*.sql` — источник правды по схеме (правь их, затем
синхронизируй `backend/migrations/` копией файла, не наоборот).
