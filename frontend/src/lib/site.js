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
