import { notFound } from 'next/navigation';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { isEnabledLocale, DEFAULT_LOCALE } from '../../../../i18n/config.js';
import { getDictionary } from '../../../../i18n/getDictionary.js';
import { apiGet } from '../../../../lib/api.js';
import { ogTwitter } from '../../../../lib/seo.js';
import Breadcrumb from '../../../components/Breadcrumb.jsx';

export const dynamic = 'force-dynamic';

async function loadPost(slug, locale) {
  try {
    return (await apiGet(`/api/blog/posts/${encodeURIComponent(slug)}?lang=${encodeURIComponent(locale)}`)).data;
  } catch {
    return null;
  }
}

async function loadTranslations(slug, locale) {
  try {
    return (await apiGet(`/api/blog/posts/${encodeURIComponent(slug)}/translations?lang=${encodeURIComponent(locale)}`)).data;
  } catch {
    return [];
  }
}

// hreflang для статьи — не lib/seo.js hreflangAlternates() (тот строит один
// и тот же suffix для всех локалей, годится для Product.slug, единого на
// все языки; article_translations.slug — per-locale, см. комментарий у
// BlogPostPage ниже). Alternates строим из /translations того же article_id
// (уже используется клиентским языковым переключателем в Header.jsx) — то же
// покрытие 8 языков, что и у остального сайта (ТЗ Задача 2, "не больше и не
// меньше"), но с правильным per-locale slug на каждую локаль.
function blogHreflangAlternates(translations) {
  const languages = {};
  for (const t of translations) languages[t.language_code] = `/${t.language_code}/blog/${t.slug}`;
  if (languages[DEFAULT_LOCALE]) languages['x-default'] = languages[DEFAULT_LOCALE];
  return languages;
}

export async function generateMetadata({ params }) {
  const post = await loadPost(params.slug, params.locale);
  if (!post) return { title: 'Blog' };
  const translations = await loadTranslations(params.slug, params.locale);
  const title = post.seo_title || post.title;
  const description = post.seo_description || post.excerpt || undefined;
  const url = `/${params.locale}/blog/${post.slug}`;
  return {
    title,
    description,
    alternates: { canonical: url, languages: blogHreflangAlternates(translations) },
    ...ogTwitter({ title, description, url, image: post.featured_image_url, imageAlt: post.title }),
  };
}

// Каркас (ТЗ п.4.15): резолв по (language_code, slug) из article_translations
// (п.4.9.3 — своя страница на язык, не JS-переключатель). content — markdown
// (таблицы/списки/bold/ссылки из исходных .md), rich-text редактора в админке
// пока нет (правится textarea), но рендер на публичной странице — полноценный
// markdown (remark-gfm — таблицы и авто-ссылки из GFM); полноценный дизайн/
// JSON-LD — следующий шаг.
export default async function BlogPostPage({ params }) {
  const { locale, slug } = params;
  if (!isEnabledLocale(locale)) notFound();

  const [post, dict] = await Promise.all([loadPost(slug, locale), getDictionary(locale)]);
  if (!post) notFound();

  // Home → Blog → [категория] → [заголовок статьи] — категория/её имя уже
  // приходят локализованными из /api/blog/posts/:slug (article_categories +
  // article_category_translations), тот же справочник, что группирует /blog
  // на табы-якоря (см. BlogCategoryTabs.jsx, id={category.slug}) — не заводим
  // отдельную таксономию под breadcrumb.
  const trail = [
    { name: dict.nav.home, path: `/${locale}` },
    { name: dict.nav.blog, path: `/${locale}/blog` },
    { name: post.category_name, path: `/${locale}/blog#${post.category_slug}` },
    { name: post.title, path: `/${locale}/blog/${post.slug}` },
  ];

  return (
    <div className="container page">
      <Breadcrumb trail={trail} />
      <h1 className="display page-h1">{post.title}</h1>
      {/* excerpt не дублируется здесь отдельным lede — он совпадает с первым
          абзацем content (см. Задачу 2 сессии), используется как teaser в
          /blog и как фолбэк seo_description в generateMetadata выше. */}
      <div className="article-body">
        <ReactMarkdown remarkPlugins={[remarkGfm]}>{post.content ?? ''}</ReactMarkdown>
      </div>
    </div>
  );
}
