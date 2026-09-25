// Адрес backend — из env (локально :3000, на проде — Render URL). Не хардкод.
const BASE = process.env.API_BASE_URL || 'http://localhost:3000';

// Серверный fetch (вызывается из server components — SSR, без CORS, хорошо для SEO).
// API layer v1.0: единая точка versioning-cutover — вызывающий код продолжает
// писать path как раньше ('/api/products' и т.п.), сюда прибавляется '/v1'
// после '/api', без правки ~20 call sites в sitemap.js/[locale]/page.js/etc.
export async function apiGet(path) {
  const res = await fetch(`${BASE}${path.replace(/^\/api/, '/api/v1')}`, { cache: 'no-store' });
  if (!res.ok) throw new Error(`API ${path} -> ${res.status}`);
  return res.json();
}

// Цена IDR для людей: "Rp 2,500,000".
export function formatIdr(idr) {
  return `Rp ${Number(idr).toLocaleString('en-US')}`;
}
