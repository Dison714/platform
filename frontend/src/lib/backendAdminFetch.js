// Общий helper для всех /api/admin/* BFF-роутов, вызывающих 5 защищённых
// admin-разделов backend'а (delivery/insurance/deposit/replacement-groups/
// seasonal-multipliers). Прикладывает X-Internal-Admin-Token — без него
// backend отвечает 401 (см. backend/src/middleware/internalAuth.js). Не
// process.env.NEXT_PUBLIC_* — токен не должен попасть в браузер, читается
// только на сервере (route handlers Next.js всегда server-side).
const BASE = process.env.API_BASE_URL || 'http://localhost:3000';

// API layer v1.0 — тот же приём, что в lib/api.js: call sites (13
// route-файлов /api/admin/*) продолжают передавать path без версии
// ('/api/delivery-fee-rules' и т.п.), префикс переписывается здесь одним
// местом.
export async function backendAdminFetch(path, options = {}) {
  return fetch(`${BASE}${path.replace(/^\/api/, '/api/v1')}`, {
    ...options,
    headers: { ...options.headers, 'X-Internal-Admin-Token': process.env.INTERNAL_ADMIN_TOKEN },
    cache: 'no-store',
  });
}
