import { isEnabledLocale } from '../../../i18n/config.js';
import { getDictionary } from '../../../i18n/getDictionary.js';
import { apiGet } from '../../../lib/api.js';
import { categoriesInGroup, groupOfCategory } from '../../../lib/categoryGroups.js';
import CategoryFilter from '../../components/CategoryFilter.jsx';
import GroupFilter from '../../components/GroupFilter.jsx';
import ModelFilter from '../../components/ModelFilter.jsx';
import BikeCard from '../../components/BikeCard.jsx';
import { notFound } from 'next/navigation';
import { ogTwitter, hreflangAlternates, breadcrumbJsonLd } from '../../../lib/seo.js';

// Каталог рендерится на сервере (SSR) — Google видит контент. Живые данные
// из backend, поэтому всегда свежо.
export const dynamic = 'force-dynamic';

export async function generateMetadata({ params }) {
  const dict = await getDictionary(params.locale);
  const title = `${dict.catalog.title} — ${dict.brand.name}`;
  const description = dict.brand.tagline;
  const url = `/${params.locale}/bikes`;
  // canonical ВСЕГДА базовый /bikes без query — любой ?category= канонизируется
  // на немодифицированный URL (страница с фильтром остаётся индексируемой,
  // не noindex, просто не плодит дубли по каждой категории в индексе).
  return {
    title,
    description,
    alternates: { canonical: url, languages: hreflangAlternates('/bikes') },
    ...ogTwitter({ title, description, url }),
  };
}

export default async function BikesPage({ params, searchParams }) {
  const { locale } = params;
  if (!isEnabledLocale(locale)) notFound();
  const dict = await getDictionary(locale);
  const category = searchParams?.category ?? null;
  // group (Блок A) — верхний таб "Скутеры"/"Мотоциклы". Резолвится в список
  // конкретных категорий здесь же (маппинг целиком на фронте, см.
  // lib/categoryGroups.js) — бэкенд просто фильтрует по списку кодов, ничего
  // не знает про группы. Явный category (клик по нижнему чипу) главнее group.
  const groupKey = searchParams?.group ?? null;
  const activeGroupKey = groupKey ?? groupOfCategory(category);
  // model (Блок A, третья строка, П.20) — конкретная линейка внутри "Мотоциклы".
  // Своя ось фильтра (product_families.code), не пересекается с category —
  // при активном model категорийный фильтр не применяем, модель уже
  // однозначно определяет продукты (см. catalog.js listProducts).
  const model = activeGroupKey === 'motorcycle' ? (searchParams?.model ?? null) : null;
  const filterCodes = category ? [category] : (groupKey ? categoriesInGroup(groupKey) : null);
  const categoryQuery = model ? null : (filterCodes ? filterCodes.join(',') : null);

  const [productsRes, categoriesRes, familiesRes] = await Promise.all([
    apiGet(
      `/api/products?lang=${encodeURIComponent(locale)}` +
      (categoryQuery ? `&category=${encodeURIComponent(categoryQuery)}` : '') +
      (model ? `&model=${encodeURIComponent(model)}` : '')
    ),
    apiGet(`/api/categories?lang=${encodeURIComponent(locale)}`),
    apiGet(`/api/families?lang=${encodeURIComponent(locale)}`),
  ]);
  const products = productsRes.data ?? [];
  const categories = categoriesRes.data ?? [];
  const families = familiesRes.data ?? [];
  const activeGroup = activeGroupKey ? { key: activeGroupKey, codes: categoriesInGroup(activeGroupKey) } : null;
  // Третья строка — только модели, чья категория входит в группу "Мотоциклы".
  const motorcycleFamilies = activeGroupKey === 'motorcycle'
    ? families.filter((f) => categoriesInGroup('motorcycle').includes(f.category.code))
    : [];
  // Breadcrumb только при активном фильтре (Home → Bikes → [Category]) — без
  // category одна ступень не несёт смысла. Имя категории уже локализовано
  // на бэкенде (vehicle_category_translations).
  const activeCategory = category ? categories.find((c) => c.code === category) : null;
  const breadcrumbLd = activeCategory
    ? breadcrumbJsonLd([
        { name: dict.nav.home, path: `/${locale}` },
        { name: dict.nav.bikes, path: `/${locale}/bikes` },
        { name: activeCategory.name, path: `/${locale}/bikes?category=${category}` },
      ])
    : null;

  return (
    <div className="container">
      {breadcrumbLd ? (
        <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbLd) }} />
      ) : null}
      <div className="page-head">
        <h1 className="display page-title">{dict.catalog.title}</h1>
        <p className="page-sub">
          {dict.catalog.subtitle.replace('{count}', String(products.length))}
        </p>
      </div>

      <GroupFilter locale={locale} active={activeGroupKey} dict={dict} />

      <CategoryFilter
        locale={locale}
        categories={categories}
        active={category}
        allLabel={dict.catalog.all}
        group={activeGroup}
      />

      {motorcycleFamilies.length > 0 ? (
        <ModelFilter
          locale={locale}
          families={motorcycleFamilies}
          active={model}
          allLabel={dict.catalog.all}
        />
      ) : null}

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
