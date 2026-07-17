import { SITE_URL, IS_PRODUCTION } from '../lib/site.js';

// Нативный App Router robots (→ /robots.txt). Открываем весь публичный сайт,
// закрываем только BFF-прокси /api/* (route handlers /api/quote, /api/bookings —
// не контент, индексировать нечего). Ссылка на sitemap — абсолютным URL.
//
// До финального DNS cutover на bikebalirent.com (SITE_ENV != production —
// Coolify-стейджинг/IP/дефолтный поддомен) — полный Disallow, без sitemap.
export default function robots() {
  if (!IS_PRODUCTION) {
    return { rules: { userAgent: '*', disallow: '/' } };
  }
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/api/'],
    },
    sitemap: `${SITE_URL}/sitemap.xml`,
  };
}
