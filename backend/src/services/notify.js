import { pool } from '../db/pool.js';
import { env } from '../config/env.js';

// =====================================================================
// NOTIFY — доставка уведомления (fire-and-forget). Долговечная запись в
// notifications уже создана в booking-транзакции (status='queued'). Здесь
// только попытка доставки + апдейт статуса этой строки.
// ГАРАНТИИ: никогда не бросает в вызывающий код; заявка не теряется при
// недоступности канала — ошибка пишется в notifications.error.
//
// Notification Service мультиканальный (ТЗ п.15.3): сейчас активен только
// telegram; whatsapp/email/push/sms — зарезервированные ветки на будущее.
// =====================================================================

const TG_TIMEOUT_MS = 5000;

export function deliverNotification(notificationId) {
    return tryDeliver(notificationId).catch((err) =>
        console.error('[notify] unexpected error:', err?.message)
    );
}

async function tryDeliver(notificationId) {
    const { rows } = await pool.query(
        'SELECT channel, payload FROM notifications WHERE id = $1',
        [notificationId]
    );
    if (rows.length === 0) return false;
    const { channel, payload } = rows[0];

    let result;
    switch (channel) {
        case 'telegram':
            result = await sendTelegram(payload || {});
            break;
        // case 'whatsapp': требует WhatsApp Business API — отдельная задача.
        // case 'email' / 'push' / 'sms': на будущее.
        default:
            result = { ok: false, error: `channel_not_implemented: ${channel}` };
    }

    await pool
        .query('UPDATE notifications SET status = $2, sent_at = $3, error = $4 WHERE id = $1', [
            notificationId,
            result.ok ? 'sent' : 'failed',
            result.ok ? new Date() : null,
            result.error,
        ])
        .catch((e) => console.error('[notify] status update failed:', e?.message));

    return result.ok;
}

async function sendTelegram(payload) {
    const { text, chat_id: chatId, parse_mode: parseMode } = payload;
    const token = env.telegramBotToken;
    if (!token) return { ok: false, error: 'TELEGRAM_BOT_TOKEN not set' };
    if (chatId == null) return { ok: false, error: 'chat_id missing' };

    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), TG_TIMEOUT_MS);
    try {
        const res = await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                chat_id: chatId,
                text,
                parse_mode: parseMode || undefined,
                disable_web_page_preview: true,
            }),
            signal: ctrl.signal,
        });
        const data = await res.json().catch(() => ({}));
        if (res.ok && data.ok) return { ok: true, error: null };
        return { ok: false, error: `telegram_api: ${data.description || `HTTP ${res.status}`}` };
    } catch (e) {
        return { ok: false, error: e?.name === 'AbortError' ? 'network_timeout' : (e?.message || 'unknown_error') };
    } finally {
        clearTimeout(timer);
    }
}
