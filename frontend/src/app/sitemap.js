import { apiGet } from '../lib/api.js';
import { SITE_URL, IS_PRODUCTION } from '../lib/site.js';
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
  // До финального DNS cutover на bikebalirent.com — пустой sitemap, не 76×2
  // URL на стейджинге/IP/дефолтном Coolify-поддомене (см. robots.js/layout).
  // Локальная проверка: временно добавить SITE_ENV=production в
  // frontend/.env.local (файл в .gitignore, не коммитить), curl /sitemap.xml,
  // снять переменную после теста.
  if (!IS_PRODUCTION) return [];

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

  // Blog posts × локали. В отличие от Product.slug (единый на все локали),
  // slug статьи per-locale (article_translations.slug, ТЗ п.4.9.3) — поэтому
  // не общий /api/products-паттерн (один запрос), а по запросу на локаль,
  // как отдаёт публичная витрина (GET /api/blog/posts?lang=xx, только
  // status='published'). lastmod — GREATEST(articles.updated_at,
  // article_translations.updated_at), поле есть в модели (047_blog.sql) —
  // не дата генерации. changeFrequency/priority — по той же шкале, что и
  // остальной sitemap: 'weekly' везде без исключений (см. STATIC_PATHS/
  // products выше), priority 0.5 — тот же уровень, что about/faq
  // (вспомогательный контент, не денежные страницы каталога/товара
  // 0.8-0.9) — своей отдельной ступени под блог в существующей шкале нет.
  const postsByLocale = await Promise.all(
    locales.map(async (loc) => {
      try {
        return { loc, posts: (await apiGet(`/api/blog/posts?lang=${loc}`)).data ?? [] };
      } catch {
        return { loc, posts: [] };
      }
    })
  );
  for (const { loc, posts } of postsByLocale) {
    for (const post of posts) {
      entries.push({
        url: `${SITE_URL}/${loc}/blog/${post.slug}`,
        lastModified: post.updated_at ? new Date(post.updated_at) : now,
        changeFrequency: 'weekly',
        priority: 0.5,
      });
    }
  }

  return entries;
}
