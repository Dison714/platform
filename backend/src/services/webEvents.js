import { pool } from '../db/pool.js';
import { getCompanyId } from './config.js';

// web_events — общий сырой сток лёгких клиентских сигналов (event_code +
// metadata jsonb), уже был в схеме, но без единого писателя. Первый
// потребитель — locale-автодетект в frontend/src/middleware.js: несовпавший
// язык браузера на голом домене, материал для решения "добавлять ли язык N"
// (см. CLAUDE.md §5, языки идут по launch_phase). Allow-list ниже — не
// открытая помойка для произвольных event_code с фронта.
const ALLOWED_EVENT_CODES = new Set(['locale_autodetect_unmatched']);

// Никогда не бросает — вызывающий код (route) не должен зависеть от успеха
// записи статистики, это побочный сигнал, а не часть бизнес-процесса.
export async function recordWebEvent(eventCode, metadata = {}) {
    if (!ALLOWED_EVENT_CODES.has(eventCode)) return;
    try {
        const companyId = await getCompanyId();
        await pool.query(
            'INSERT INTO web_events (company_id, event_code, metadata) VALUES ($1, $2, $3::jsonb)',
            [companyId, eventCode, JSON.stringify(metadata)]
        );
    } catch (err) {
        console.error('[web-events] write failed:', err?.message);
    }
}
