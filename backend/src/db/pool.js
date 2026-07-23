import pg from 'pg';
import { env } from '../config/env.js';

const { Pool, types } = pg;

// DATE (OID 1082) по умолчанию парсится node-pg в JS Date по ЛОКАЛЬНОМУ
// времени машины — при сериализации в JSON это сдвигает дату на день назад
// для положительных UTC-офсетов (напр. UTC+8 Bali: 2026-12-20 → отдаётся
// как 2026-12-19T16:00:00.000Z). Возвращаем как есть, строкой YYYY-MM-DD —
// правильно для чистых календарных дат (start_date аренды, периоды
// seasonal_multipliers и т.п., без времени суток).
types.setTypeParser(1082, (val) => val);

export const pool = new Pool({ connectionString: env.databaseUrl });
