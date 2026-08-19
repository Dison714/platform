import { notFound } from 'next/navigation';
import Link from 'next/link';
import { isEnabledLocale } from '../../../i18n/config.js';
import { apiGet } from '../../../lib/api.js';
import { getDictionary } from '../../../i18n/getDictionary.js';
import { ogTwitter } from '../../../lib/seo.js';
import BlogCategoryTabs from '../../components/BlogCategoryTabs.jsx';

export const dynamic = 'force-dynamic';

export async function generateMetadata({ params }) {
  const title = 'Blog';
  const url = `/${params.locale}/blog`;
  return { title, alternates: { canonical: url }, ...ogTwitter({ title, url }) };
}

// Секции по категориям (ТЗ п.4.15): пилар + сетка кластерных статей,
// табы-якоря вверху (вариант 1 — скроллят к секции, не фильтруют). Категории
// и их порядок берутся из данных (article_categories.display_order), не
// хардкодятся — на третьей категории компонент переделывать не придётся.
export default async function BlogIndexPage({ params }) {
  const { locale } = params;
  if (!isEnabledLocale(locale)) notFound();

  const [{ data: posts }, t] = await Promise.all([
    apiGet(`/api/blog/posts?lang=${encodeURIComponent(locale)}`),
    getDictionary(locale),
  ]);

  const categoriesBySlug = new Map();
  for (const post of posts) {
    if (!categoriesBySlug.has(post.category_slug)) {
      categoriesBySlug.set(post.category_slug, {
        slug: post.category_slug,
        name: post.category_name,
        description: post.category_description,
        displayOrder: post.category_display_order,
        pillar: null,
        clusters: [],
      });
    }
    const category = categoriesBySlug.get(post.category_slug);
    if (post.is_pillar) category.pillar = post;
    else category.clusters.push(post);
  }
  const categories = [...categoriesBySlug.values()].sort((a, b) => a.displayOrder - b.displayOrder);

  return (
    <div className="container blog-page">
      <h1 className="display page-h1">Blog</h1>
      {categories.length === 0 ? (
        <p className="lede">No articles published yet.</p>
      ) : (
        <>
          <BlogCategoryTabs
            categories={categories.map((category) => ({
              slug: category.slug,
              name: category.name,
              total: category.clusters.length + (category.pillar ? 1 : 0),
            }))}
          />

          {categories.map((category) => (
            <section key={category.slug} id={category.slug} className="blog-category">
              <h2 className="blog-category-title">{category.name}</h2>
              {category.description && <p className="blog-category-sub">{category.description}</p>}

              {category.pillar && (
                <article className="blog-pillar">
                  <span className="blog-pillar-badge">{t.blog.pillar_badge}</span>
                  <h2>
                    <Link href={`/${locale}/blog/${category.pillar.slug}`}>{category.pillar.title}</Link>
                  </h2>
                  {category.pillar.excerpt && <p className="blog-pillar-excerpt">{category.pillar.excerpt}</p>}
                  <div className="blog-pillar-inside">
                    {(category.clusters.length === 1 ? t.blog.pillar_inside_one : t.blog.pillar_inside_other).replace(
                      '{n}',
                      String(category.clusters.length)
                    )}
                  </div>
                </article>
              )}

              {category.clusters.length > 0 && (
                <div className="blog-cluster-grid">
                  {category.clusters.map((post) => (
                    <Link key={post.slug} href={`/${locale}/blog/${post.slug}`} className="blog-cluster-card">
                      <h3>{post.title}</h3>
                      {post.excerpt && <p>{post.excerpt}</p>}
                    </Link>
                  ))}
                </div>
              )}
            </section>
          ))}
        </>
      )}
    </div>
  );
}
