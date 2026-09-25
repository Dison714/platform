import crypto from 'node:crypto';
import { pool } from '../db/pool.js';

// Идентификация внешних потребителей API — отдельно от X-Internal-Admin-Token
// (тот — единый секрет для /internal/* админки, здесь — свой ключ на клиента,
// таблица api_clients существует с 001_foundation.sql, до этой сессии не
// использовалась ни одним route-handler'ом).
//
// Без заголовка — req.apiClient = null, поведение как раньше (сегодняшний
// единственный потребитель, сайт, ходит без ключа). Заголовок есть, но
// невалиден/отозван — 401, а не молчаливый fallback: раз клиент прислал
// ключ, он должен быть настоящим, иначе опечатка/протухший ключ у того, кто
// его сконфигурировал, останется незамеченной.
export async function resolveApiClient(req, res, next) {
    const key = req.get('X-Api-Key');
    if (!key) {
        req.apiClient = null;
        return next();
    }

    const hash = crypto.createHash('sha256').update(key).digest('hex');
    try {
        const { rows } = await pool.query(
            `SELECT ac.id, ac.name FROM api_clients ac
             WHERE ac.api_key_hash = $1 AND ac.is_active = TRUE`,
            [hash]
        );
        if (rows.length === 0) {
            return res.status(401).json({ error: 'invalid_api_key' });
        }
        req.apiClient = { id: rows[0].id, name: rows[0].name };
        // last_used_at — fire-and-forget, не задерживает запрос и не роняет
        // его при сбое (аналитическое поле, не критично для авторизации).
        pool.query('UPDATE api_clients SET last_used_at = now() WHERE id = $1', [rows[0].id])
            .catch((e) => console.error('[api-client] last_used_at update failed:', e?.message));
        next();
    } catch (err) {
        next(err);
    }
}
