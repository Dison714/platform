import { apiGet } from '../lib/api.js';
import { SITE_URL } from '../lib/site.js';
import { enabledLocales } from '../i18n/config.js';

// Нативный App Router sitemap (→ /sitemap.xml). Живые данные из API, поэтому
// не кэшируем на билде. hreflang-связки между локалями сюда НЕ добавляются
// (это отдельный Шаг 2 чанка) — каждая локаль как самостоятельный URL.
export const dynamic = 'force-dynamic';

const STATIC_PATHS = [
  { path: '', priority: 1.0 },        // homepage
  { path: '/bikes', priority: 0.9 },  // каталог
  { path: '/about', priority: 0.5 },
  { path: '/faq', priority: 0.5 },
];

export default async function sitemap() {
  const locales = enabledLocales(); // ['en','ru']
  const now = new Date();

  const entries = [];

  // Статические страницы × локали. lastmod = дата генерации (у этих страниц
  // нет записи в БД с updated_at — допущение зафиксировано здесь).
  for (const loc of locales) {
    for (const { path, priority } of STATIC_PATHS) {
      entries.push({
        url: `${SITE_URL}/${loc}${path}`,
        lastModified: now,
        changeFrequency: 'weekly',
        priority,
      });
    }
  }

  // Product pages × локали. lastmod = products.updated_at (через API); если по
  // какой-то причине нет — дата генерации.
  let products = [];
  try {
    products = (await apiGet('/api/products')).data ?? [];
  } catch {
    // API недоступен на билде/рантайме — отдаём хотя бы статические URL, не падаем.
  }
  for (const loc of locales) {
    for (const p of products) {
      entries.push({
        url: `${SITE_URL}/${loc}/bikes/${p.slug}`,
        lastModified: p.updated_at ? new Date(p.updated_at) : now,
        changeFrequency: 'weekly',
        priority: 0.8,
      });
    }
  }

  return entries;
}
