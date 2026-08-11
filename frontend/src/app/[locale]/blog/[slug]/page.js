import { notFound } from 'next/navigation';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { isEnabledLocale } from '../../../../i18n/config.js';
import { apiGet } from '../../../../lib/api.js';
import { ogTwitter } from '../../../../lib/seo.js';

export const dynamic = 'force-dynamic';

async function loadPost(slug, locale) {
  try {
    return (await apiGet(`/api/blog/posts/${encodeURIComponent(slug)}?lang=${encodeURIComponent(locale)}`)).data;
  } catch {
    return null;
  }
}

export async function generateMetadata({ params }) {
  const post = await loadPost(params.slug, params.locale);
  if (!post) return { title: 'Blog' };
  const title = post.seo_title || post.title;
  const description = post.seo_description || post.excerpt || undefined;
  const url = `/${params.locale}/blog/${post.slug}`;
  return { title, description, alternates: { canonical: url }, ...ogTwitter({ title, description, url, image: post.featured_image_url, imageAlt: post.title }) };
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

  const post = await loadPost(slug, locale);
  if (!post) notFound();

  return (
    <div className="container page">
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
