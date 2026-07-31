// Общий секрет между Next.js BFF (/api/admin/*, за Basic Auth в
// frontend/src/middleware.js) и backend admin-роутами (delivery/insurance/
// deposit/replacement-groups/seasonal-multipliers). Basic Auth в
// middleware.js защищает браузер, но НЕ сам backend — у него есть
// собственный публичный адрес (Coolify выдаёт домен каждому приложению),
// и до этой правки ни один из этих 5 роутеров не проверял вообще ничего
// на уровне Express (подтверждено: `curl` на прод-бэкенд напрямую отдавал
// тарифы доставки без единого пароля, 2026-08-01). Fail closed — не
// сконфигурирован токен → доступ закрыт по умолчанию, тот же принцип, что
// уже был в checkBasicAuth() на фронтенде.
export function requireInternalToken(req, res, next) {
    const expected = process.env.INTERNAL_ADMIN_TOKEN;
    if (!expected || req.get('X-Internal-Admin-Token') !== expected) {
        return res.status(401).json({ error: 'unauthorized' });
    }
    next();
}
