import { notFound } from 'next/navigation';
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
// (п.4.9.3 — своя страница на язык, не JS-переключатель). content — обычный
// текст (без rich-text редактора на этом этапе, см. задачу), рендерим
// построчно как параграфы; полноценный дизайн/JSON-LD — следующий шаг.
export default async function BlogPostPage({ params }) {
  const { locale, slug } = params;
  if (!isEnabledLocale(locale)) notFound();

  const post = await loadPost(slug, locale);
  if (!post) notFound();

  const paragraphs = (post.content ?? '').split('\n').filter((p) => p.trim());

  return (
    <div className="container page">
      <h1 className="display page-h1">{post.title}</h1>
      {post.excerpt && <p className="lede">{post.excerpt}</p>}
      {paragraphs.map((p, i) => <p key={i}>{p}</p>)}
    </div>
  );
}
