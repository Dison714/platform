import { isEnabledLocale } from '../../../i18n/config.js';
import { getDictionary } from '../../../i18n/getDictionary.js';
import { apiGet } from '../../../lib/api.js';
import { categoriesInGroup, groupOfCategory, SINGLE_MODEL_CATEGORIES } from '../../../lib/categoryGroups.js';
import CategoryFilter from '../../components/CategoryFilter.jsx';
import GroupFilter from '../../components/GroupFilter.jsx';
import ModelFilter from '../../components/ModelFilter.jsx';
import BikeCard from '../../components/BikeCard.jsx';
import { notFound } from 'next/navigation';
import { ogTwitter, hreflangAlternates, breadcrumbJsonLd } from '../../../lib/seo.js';

// Каталог рендерится на сервере (SSR) — Google видит контент. Живые данные
// из backend, поэтому всегда свежо.
export const dynamic = 'force-dynamic';

// Из searchParams резолвит активные group/category/model одинаково для
// generateMetadata и самого компонента страницы (та же логика, что раньше
// жила только в BikesPage) — единая точка, чтобы обе половины не могли
// разъехаться в том, что считается активным фильтром.
function resolveFilters(searchParams) {
  const category = searchParams?.category ?? null;
  const groupKey = searchParams?.group ?? null;
  const activeGroupKey = groupKey ?? groupOfCategory(category);
  const model = activeGroupKey === 'motorcycle' ? (searchParams?.model ?? null) : null;
  return { category, groupKey, activeGroupKey, model };
}

// Модель-хаб (SEO-сессия 2026-09-15): ?category=<скутер-модель> или
// ?group=motorcycle&model=<family> изолируют РОВНО одну модель (все цвета) —
// достаточно конкретный URL под generic-запрос "<model> rental bali", в
// отличие от голого /bikes или смешанных категорий мотоциклов без model
// (там на одной странице несколько разных моделей). Раньше canonical здесь
// всегда указывал на голый /bikes — под generic-запрос Google ранжировать
// было нечего, кроме конкурирующих друг с другом цвет-вариантов (то и
// давало позиции 30-90+). product_count > 0 — обязательное условие: не
// индексировать пустой фильтр (сейчас это исключает honda_vario160 —
// единственный активный Vario-товар деактивирован; переиндексируется само,
// без правки кода, если Дмитрий вернёт Vario в продажу).
async function resolveModelHub({ locale, category, model }) {
  if (model) {
    const { data: families } = await apiGet(`/api/families?lang=${encodeURIComponent(locale)}`);
    const family = families.find((f) => f.code === model);
    if (!family || family.product_count <= 0) return null;
    return { name: family.name, query: `group=motorcycle&model=${model}` };
  }
  if (category && SINGLE_MODEL_CATEGORIES.includes(category)) {
    const { data: categories } = await apiGet(`/api/categories?lang=${encodeURIComponent(locale)}`);
    const cat = categories.find((c) => c.code === category);
    if (!cat || cat.product_count <= 0) return null;
    return { name: cat.name, query: `category=${category}` };
  }
  return null;
}

export async function generateMetadata({ params, searchParams }) {
  const dict = await getDictionary(params.locale);
  const { category, model } = resolveFilters(searchParams);
  const hub = await resolveModelHub({ locale: params.locale, category, model });

  if (hub) {
    const title = `${dict.catalog.model_hub_title.replace('{model}', hub.name)} — ${dict.brand.name}`;
    const description = dict.catalog.model_hub_description.replace('{model}', hub.name);
    const url = `/${params.locale}/bikes?${hub.query}`;
    return {
      title,
      description,
      alternates: { canonical: url, languages: hreflangAlternates(`/bikes?${hub.query}`) },
      ...ogTwitter({ title, description, url }),
    };
  }

  const title = `${dict.catalog.title} — ${dict.brand.name}`;
  const description = dict.brand.tagline;
  const url = `/${params.locale}/bikes`;
  // canonical на голый /bikes для всего, что НЕ однозначная модель (сам
  // /bikes, ?group=scooter без category, смешанные категории мотоциклов без
  // model) — фильтр остаётся индексируемым, не noindex, просто не плодит
  // дубли по каждой такой комбинации в индексе.
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
  // group (Блок A) — верхний таб "Скутеры"/"Мотоциклы". category/model — см.
  // resolveFilters выше (общая логика с generateMetadata). model (Блок A,
  // третья строка, П.20) — своя ось фильтра (product_families.code), не
  // пересекается с category — при активном model категорийный фильтр не
  // применяем, модель уже однозначно определяет продукты (см. catalog.js
  // listProducts).
  const { category, groupKey, activeGroupKey, model } = resolveFilters(searchParams);
  const filterCodes = category ? [category] : (groupKey ? categoriesInGroup(groupKey) : null);
  const categoryQuery = model ? null : (filterCodes ? filterCodes.join(',') : null);
  // Тот же фильтр, что уже в адресной строке этой страницы — прокидываем его
  // в ссылку каждой карточки, чтобы на карточке товара можно было построить
  // breadcrumb ровно по тому пути, которым сюда пришёл клиент (не хардкодить
  // "Все байки"). Сырые searchParams, а не resolved-переменные — чтобы
  // отражать URL как есть, включая случаи, когда category и group заданы вместе.
  const cardFilterParams = new URLSearchParams();
  if (searchParams?.group) cardFilterParams.set('group', searchParams.group);
  if (searchParams?.category) cardFilterParams.set('category', searchParams.category);
  if (searchParams?.model) cardFilterParams.set('model', searchParams.model);
  const cardFilterQuery = cardFilterParams.toString();

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
  // Тот же критерий "это модель-хаб", что и в generateMetadata выше
  // (resolveModelHub) — не второй источник правды, просто без лишнего
  // apiGet: categories/families уже под рукой из Promise.all выше.
  const hubFamily = model ? families.find((f) => f.code === model) : null;
  const hubName = model
    ? (hubFamily?.product_count > 0 ? hubFamily.name : null)
    : (category && SINGLE_MODEL_CATEGORIES.includes(category) && activeCategory?.product_count > 0
      ? activeCategory.name
      : null);
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
        <h1 className="display page-title">
          {hubName ? dict.catalog.model_hub_title.replace('{model}', hubName) : dict.catalog.title}
        </h1>
        <p className="page-sub">
          {hubName
            ? dict.catalog.model_hub_description.replace('{model}', hubName)
            : dict.catalog.subtitle.replace('{count}', String(products.length))}
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
            <BikeCard key={p.id} locale={locale} product={p} dict={dict} filterQuery={cardFilterQuery} />
          ))}
        </div>
      )}
    </div>
  );
}
