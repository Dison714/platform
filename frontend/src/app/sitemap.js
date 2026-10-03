import { apiGet } from '../lib/api.js';
import { SITE_URL, IS_PRODUCTION } from '../lib/site.js';
import { enabledLocales } from '../i18n/config.js';
import { categoriesInGroup, SINGLE_MODEL_CATEGORIES } from '../lib/categoryGroups.js';

// Нативный App Router sitemap (→ /sitemap.xml). Живые данные из API, поэтому
// не кэшируем на билде. hreflang-связки между локалями сюда НЕ добавляются
// (это отдельный Шаг 2 чанка) — каждая локаль как самостоятельный URL.
export const dynamic = 'force-dynamic';

// kind определяет, откуда берётся lastmod (см. staticLastmod ниже): раньше у
// всех статических страниц lastmod был "сейчас" (дата запроса) — Google видел,
// что главная/каталог "изменились только что" при каждом обходе.
const STATIC_PATHS = [
  { path: '', priority: 1.0, kind: 'home' },        // homepage
  { path: '/bikes', priority: 0.9, kind: 'bikes' }, // каталог
  // Индекс блога раньше отсутствовал в sitemap во всех локалях (аудит
  // 03.10.2026) — Google обходил его только по ссылкам из шапки/подвала.
  { path: '/blog', priority: 0.7, kind: 'blog' },
  { path: '/about', priority: 0.5, kind: 'static' },
  { path: '/faq', priority: 0.5, kind: 'static' },
];

// about/faq живут в i18n-словарях, а не в БД — реальной даты изменения в данных
// нет. Дата последнего коммита, трогавшего frontend/src/i18n/dictionaries,
// [locale]/about или [locale]/faq (4bd3881, 2026-09-19). Обновлять вручную при
// правке текста этих страниц; это честнее, чем "сейчас" при каждом запросе.
const STATIC_PAGES_LASTMOD = new Date('2026-09-19T05:46:27+08:00');

const maxDate = (values) =>
  values.filter(Boolean).map((v) => new Date(v)).reduce((a, b) => (!a || b > a ? b : a), null);

export default async function sitemap() {
  // До финального DNS cutover на bikebalirent.com — пустой sitemap, не 76×2
  // URL на стейджинге/IP/дефолтном Coolify-поддомене (см. robots.js/layout).
  // Локальная проверка: временно добавить SITE_ENV=production в
  // frontend/.env.local (файл в .gitignore, не коммитить), curl /sitemap.xml,
  // снять переменную после теста.
  if (!IS_PRODUCTION) return [];

  const locales = enabledLocales(); // ['en','ru']

  const entries = [];

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
        lastModified: p.updated_at ? new Date(p.updated_at) : undefined,
        changeFrequency: 'weekly',
        priority: 0.8,
      });
    }
  }

  // Модель-хаб URL (?category=<скутер-модель> / ?group=motorcycle&model=<family>)
  // × локали — та же логика "это однозначная модель" и то же условие
  // product_count > 0, что в bikes/page.js (resolveModelHub); product_count
  // не зависит от языка, поэтому список категорий/семей запрашивается один
  // раз, не по локали, как products/posts/location-pages выше.
  let hubQueries = [];
  try {
    const [{ data: allCategories }, { data: allFamilies }] = await Promise.all([
      apiGet('/api/categories'),
      apiGet('/api/families'),
    ]);
    const categoryHubs = allCategories
      .filter((c) => SINGLE_MODEL_CATEGORIES.includes(c.code) && c.product_count > 0)
      .map((c) => `category=${c.code}`);
    const motorcycleCodes = categoriesInGroup('motorcycle');
    // Next's built-in sitemap route (resolve-route-data.js) writes
    // `<loc>${url}</loc>` with NO XML-escaping at all — verified directly in
    // node_modules, not assumed. A raw `&` between query params (unlike the
    // single-param category= hubs above) breaks the XML (Googlebot/any
    // strict parser chokes on an un-escaped `&`), so it has to be escaped
    // here, once, ourselves.
    const modelHubs = allFamilies
      .filter((f) => motorcycleCodes.includes(f.category.code) && f.product_count > 0)
      .map((f) => `group=motorcycle&amp;model=${f.code}`);
    hubQueries = [...categoryHubs, ...modelHubs];
  } catch {
    // API недоступен — просто без хабов в sitemap, не падаем.
  }
  // lastmod хаба = самая свежая правка среди его товаров (раньше — "сейчас").
  // category=<код> → товары этой категории; model=<family> → товары семейства.
  const hubLastmod = (query) => {
    const cat = /^category=(.+)$/.exec(query)?.[1];
    const fam = /model=(.+)$/.exec(query)?.[1];
    const subset = products.filter((p) => (cat ? p.category?.code === cat : p.family?.code === fam));
    return maxDate(subset.map((p) => p.updated_at)) ?? undefined;
  };
  for (const loc of locales) {
    for (const query of hubQueries) {
      entries.push({
        url: `${SITE_URL}/${loc}/bikes?${query}`,
        lastModified: hubLastmod(query),
        changeFrequency: 'weekly',
        priority: 0.7,
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
        lastModified: post.updated_at ? new Date(post.updated_at) : undefined,
        changeFrequency: 'weekly',
        priority: 0.5,
      });
    }
  }

  // Районные SEO-страницы (/scooter-rental-<district>) × локали. Slug не
  // per-locale (в отличие от блога) — тот же суффикс на любом языке, но всё
  // равно запрашиваем per-locale список (не берём константный DISTRICTS из
  // lib/districts.js), чтобы sitemap не сослался на URL без реального
  // перевода — тот же принцип, что у продуктов/блога: источник правды БД,
  // не код (ТЗ п.4.9.4 дух правила про переводы).
  const locationPagesByLocale = await Promise.all(
    locales.map(async (loc) => {
      try {
        return { loc, pages: (await apiGet(`/api/location-pages?lang=${loc}`)).data ?? [] };
      } catch {
        return { loc, pages: [] };
      }
    })
  );
  for (const { loc, pages } of locationPagesByLocale) {
    for (const page of pages) {
      entries.push({
        url: `${SITE_URL}/${loc}/scooter-rental-${page.slug}`,
        lastModified: page.updated_at ? new Date(page.updated_at) : undefined,
        changeFrequency: 'weekly',
        priority: 0.6,
      });
    }
  }

  // Статические страницы × локали, lastmod по реальным данным (см. STATIC_PATHS).
  // Если API недоступен (нет данных) — lastModified не указываем вовсе, а не
  // подставляем "сейчас".
  const productsLast = maxDate(products.map((p) => p.updated_at));
  const staticEntries = [];
  for (const loc of locales) {
    const blogLast = maxDate((postsByLocale.find((x) => x.loc === loc)?.posts ?? []).map((post) => post.updated_at));
    const staticLastmod = {
      home: maxDate([productsLast, blogLast, STATIC_PAGES_LASTMOD]),
      bikes: productsLast,
      blog: blogLast,
      static: STATIC_PAGES_LASTMOD,
    };
    for (const { path, priority, kind } of STATIC_PATHS) {
      staticEntries.push({
        url: `${SITE_URL}/${loc}${path}`,
        lastModified: staticLastmod[kind] ?? undefined,
        changeFrequency: 'weekly',
        priority,
      });
    }
  }
  return [...staticEntries, ...entries];
}
