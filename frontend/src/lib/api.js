// Адрес backend — из env (локально :3000, на проде — Render URL). Не хардкод.
const BASE = process.env.API_BASE_URL || 'http://localhost:3000';

// Серверный fetch (вызывается из server components — SSR, без CORS, хорошо для SEO).
export async function apiGet(path) {
  const res = await fetch(`${BASE}${path}`, { cache: 'no-store' });
  if (!res.ok) throw new Error(`API ${path} -> ${res.status}`);
  return res.json();
}

// Цена IDR для людей: "Rp 2,500,000".
export function formatIdr(idr) {
  return `Rp ${Number(idr).toLocaleString('en-US')}`;
}
