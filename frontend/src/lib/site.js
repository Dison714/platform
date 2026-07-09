// Канонический прод-домен сайта — основа для metadataBase, canonical, og:url,
// sitemap. Абсолютный URL без хвостового слэша. Финальный домен —
// bikebalirent.com (совпадает с текущим живым сайтом и email-доменом);
// при необходимости переопределяется переменной окружения NEXT_PUBLIC_SITE_URL.
export const SITE_URL = (process.env.NEXT_PUBLIC_SITE_URL || 'https://bikebalirent.com').replace(/\/$/, '');
