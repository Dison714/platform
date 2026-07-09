import { SITE_URL } from '../lib/site.js';

// Нативный App Router robots (→ /robots.txt). Открываем весь публичный сайт,
// закрываем только BFF-прокси /api/* (route handlers /api/quote, /api/bookings —
// не контент, индексировать нечего). Ссылка на sitemap — абсолютным URL.
export default function robots() {
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/api/'],
    },
    sitemap: `${SITE_URL}/sitemap.xml`,
  };
}
