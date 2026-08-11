import { notFound } from 'next/navigation';
import Link from 'next/link';
import { isEnabledLocale } from '../../../i18n/config.js';
import { apiGet } from '../../../lib/api.js';
import { ogTwitter } from '../../../lib/seo.js';

export const dynamic = 'force-dynamic';

export async function generateMetadata({ params }) {
  const title = 'Blog';
  const url = `/${params.locale}/blog`;
  return { title, alternates: { canonical: url }, ...ogTwitter({ title, url }) };
}

// Каркас (ТЗ п.4.15): полноценный дизайн карточек/SEO/JSON-LD — отдельный
// следующий шаг, здесь только рабочий список published-статей. Пока пусто —
// все 29 засеянных статей status='draft' (048_blog_seed.sql).
export default async function BlogIndexPage({ params }) {
  const { locale } = params;
  if (!isEnabledLocale(locale)) notFound();

  const { data: posts } = await apiGet(`/api/blog/posts?lang=${encodeURIComponent(locale)}`);

  return (
    <div className="container page">
      <h1 className="display page-h1">Blog</h1>
      {posts.length === 0 ? (
        <p className="lede">No articles published yet.</p>
      ) : (
        <ul style={{ listStyle: 'none', padding: 0, display: 'flex', flexDirection: 'column', gap: 24 }}>
          {posts.map((p) => (
            <li key={p.slug}>
              <h2 style={{ marginBottom: 4 }}>
                <Link href={`/${locale}/blog/${p.slug}`}>{p.title}</Link>
              </h2>
              {p.excerpt && <p style={{ margin: 0 }}>{p.excerpt}</p>}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
