import { isEnabledLocale } from '../../../i18n/config.js';
import { getDictionary } from '../../../i18n/getDictionary.js';
import { apiGet } from '../../../lib/api.js';
import CategoryFilter from '../../components/CategoryFilter.jsx';
import BikeCard from '../../components/BikeCard.jsx';
import { notFound } from 'next/navigation';
import { ogTwitter } from '../../../lib/seo.js';

// Каталог рендерится на сервере (SSR) — Google видит контент. Живые данные
// из backend, поэтому всегда свежо.
export const dynamic = 'force-dynamic';

export async function generateMetadata({ params }) {
  const dict = await getDictionary(params.locale);
  const title = `${dict.catalog.title} — ${dict.brand.name}`;
  const description = dict.brand.tagline;
  // canonical здесь намеренно не добавляем (есть query-фильтр ?category= —
  // нормализация дублей отдельным шагом, Шаг 2 чанка SEO).
  return {
    title,
    description,
    ...ogTwitter({ title, description, url: `/${params.locale}/bikes` }),
  };
}

export default async function BikesPage({ params, searchParams }) {
  const { locale } = params;
  if (!isEnabledLocale(locale)) notFound();
  const dict = await getDictionary(locale);
  const category = searchParams?.category ?? null;

  const [productsRes, categoriesRes] = await Promise.all([
    apiGet(`/api/products${category ? `?category=${encodeURIComponent(category)}` : ''}`),
    apiGet('/api/categories'),
  ]);
  const products = productsRes.data ?? [];
  const categories = categoriesRes.data ?? [];

  return (
    <div className="container">
      <div className="page-head">
        <h1 className="display page-title">{dict.catalog.title}</h1>
        <p className="page-sub">
          {dict.catalog.subtitle.replace('{count}', String(products.length))}
        </p>
      </div>

      <CategoryFilter
        locale={locale}
        categories={categories}
        active={category}
        allLabel={dict.catalog.all}
        catNames={dict.cat}
      />

      {products.length === 0 ? (
        <p style={{ padding: '24px 0', color: 'var(--muted)' }}>{dict.catalog.empty}</p>
      ) : (
        <div className="grid">
          {products.map((p) => (
            <BikeCard key={p.id} locale={locale} product={p} dict={dict} />
          ))}
        </div>
      )}
    </div>
  );
}
