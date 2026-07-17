// Канонический прод-домен сайта — основа для metadataBase, canonical, og:url,
// sitemap. Абсолютный URL без хвостового слэша. Финальный домен —
// bikebalirent.com (совпадает с текущим живым сайтом и email-доменом);
// при необходимости переопределяется переменной окружения NEXT_PUBLIC_SITE_URL.
export const SITE_URL = (process.env.NEXT_PUBLIC_SITE_URL || 'https://bikebalirent.com').replace(/\/$/, '');

// Next's metadataBase auto-resolves relative URLs only inside the Metadata API
// (generateMetadata/export const metadata). JSON-LD we inject ourselves via
// <script> is raw HTML — Next never touches it, so absolute URLs there need
// to be built by hand.
export function absoluteUrl(path) {
  if (!path) return null;
  return /^https?:\/\//i.test(path) ? path : `${SITE_URL}${path}`;
}

// Единая точка правды "это боевой прод-домен?" — читают robots.js, sitemap.js,
// [locale]/layout.js. Fail-closed по умолчанию: SITE_ENV не задан или не равен
// 'production' → сайт закрыт от индексации (noindex + robots disallow + пустой
// sitemap). Открывается явной установкой SITE_ENV=production при финальном
// DNS cutover на bikebalirent.com — до этого момента любой Coolify-стейджинг/
// IP/default-поддомен остаётся закрытым. NODE_ENV не подходит — next start
// сам всегда работает в production-режиме независимо от того, боевой это
// домен или нет.
export const IS_PRODUCTION = process.env.SITE_ENV === 'production';
