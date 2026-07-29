import { notFound } from 'next/navigation';
import { isEnabledLocale } from '../../../../i18n/config.js';
import { getDictionary } from '../../../../i18n/getDictionary.js';
import { apiGet, formatIdr } from '../../../../lib/api.js';
import { resolvePhotoUrl, pickHero, galleryPhotos, resolveVideoUrls } from '../../../../lib/photos.js';
import { ogTwitter, hreflangAlternates, breadcrumbJsonLd } from '../../../../lib/seo.js';
import { absoluteUrl } from '../../../../lib/site.js';
import { resolveSpecs } from '../../../../lib/specs.js';
import Link from 'next/link';
import Calculator from '../../../components/Calculator.jsx';
import ProductGallery from '../../../components/ProductGallery.jsx';
import ProductVideo from '../../../components/ProductVideo.jsx';

export const dynamic = 'force-dynamic';

async function loadProduct(slug, locale) {
  try {
    return (await apiGet(`/api/products/${encodeURIComponent(slug)}?lang=${encodeURIComponent(locale)}`)).data;
  } catch {
    return null;
  }
}

export async function generateMetadata({ params }) {
  const dict = await getDictionary(params.locale);
  const product = await loadProduct(params.slug, params.locale);
  if (!product) return { title: dict.brand.name };
  const title = `${product.name} — ${dict.brand.name}`;
  const description = product.description || `${product.name} — ${dict.brand.tagline}`;
  const url = `/${params.locale}/bikes/${product.slug}`;
  // Hero — то же фото, что рендерится на странице (pickHero: is_hero → min
  // sort_order → первое). Нет фото → ogTwitter возьмёт дефолтное брендовое.
  const hero = pickHero(product.photos);
  const heroUrl = hero ? resolvePhotoUrl(hero, 'hero') : undefined;
  return {
    title,
    description,
    // slug единый для всех локалей (не per-locale) — hreflang просто меняет
    // сегмент локали в пути, доп. lookup не нужен.
    alternates: { canonical: url, languages: hreflangAlternates(`/bikes/${product.slug}`) },
    ...ogTwitter({ title, description, url, image: heroUrl, imageAlt: product.name }),
  };
}

export default async function ProductPage({ params, searchParams }) {
  const { locale, slug } = params;
  if (!isEnabledLocale(locale)) notFound();
  const dict = await getDictionary(locale);

  // Путь фильтра, которым клиент пришёл на карточку (см. bikes/page.js
  // cardFilterQuery → BikeCard href) — если задан, строим полный breadcrumb
  // (Байки → группа → категория/модель → товар) вместо голого "Все байки",
  // иначе точно тот же поход клиента не восстановить.
  const groupKey = searchParams?.group ?? null;
  const categoryCode = searchParams?.category ?? null;
  const modelCode = searchParams?.model ?? null;

  const [product, equipmentRes, categoriesRes, familiesRes] = await Promise.all([
    loadProduct(slug, locale),
    apiGet(`/api/equipment?lang=${encodeURIComponent(locale)}`),
    categoryCode ? apiGet(`/api/categories?lang=${encodeURIComponent(locale)}`) : Promise.resolve({ data: [] }),
    modelCode ? apiGet(`/api/families?lang=${encodeURIComponent(locale)}`) : Promise.resolve({ data: [] }),
  ]);
  if (!product) notFound();

  const fromPrice = product.pricing?.days?.[0]?.price_idr;
  const hero = pickHero(product.photos);
  const gallery = galleryPhotos(product.photos, hero, 8); // hero + до 8 в галерее
  const showPlaceholder = product.need_photos || !hero;
  const resolvedSpecs = resolveSpecs(product.specs, dict); // общий резолв для UI и JSON-LD
  // JSON-LD (Product/Offer) для SEO — данные из API, не выдуманные.
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: product.name,
    category: product.category?.name,
    brand: { '@type': 'Brand', name: product.family?.name?.split(' ')[0] || dict.brand.name },
    ...(product.description ? { description: product.description } : {}),
    ...(hero ? { image: absoluteUrl(resolvePhotoUrl(hero, 'hero')) } : {}),
    ...(resolvedSpecs.length
      ? {
          additionalProperty: resolvedSpecs.map(({ label, value }) => ({
            '@type': 'PropertyValue',
            name: label,
            value: String(value),
          })),
        }
      : {}),
    offers: fromPrice
      ? {
          '@type': 'Offer',
          priceCurrency: product.pricing.currency,
          price: fromPrice,
          availability: 'https://schema.org/InStock',
        }
      : undefined,
  };
  // Home → Bikes → [группа] → [категория|модель] → [Product name] — ровно
  // путь фильтров, которым клиент пришёл (см. groupKey/categoryCode/modelCode
  // выше). Без фильтра — просто Home → Bikes → Product, как раньше.
  const trail = [
    { name: dict.nav.home, path: `/${locale}` },
    { name: dict.nav.bikes, path: `/${locale}/bikes` },
  ];
  if (groupKey === 'scooter' || groupKey === 'motorcycle') {
    const groupLabel = groupKey === 'scooter' ? dict.catalog.group_scooter : dict.catalog.group_motorcycle;
    trail.push({ name: groupLabel, path: `/${locale}/bikes?group=${groupKey}` });
  }
  if (categoryCode) {
    const cat = categoriesRes.data?.find((c) => c.code === categoryCode);
    if (cat) {
      trail.push({
        name: cat.name,
        path: `/${locale}/bikes?category=${categoryCode}${groupKey ? `&group=${groupKey}` : ''}`,
      });
    }
  } else if (modelCode) {
    const fam = familiesRes.data?.find((f) => f.code === modelCode);
    if (fam) trail.push({ name: fam.name, path: `/${locale}/bikes?group=motorcycle&model=${modelCode}` });
  }
  trail.push({ name: product.name, path: `/${locale}/bikes/${product.slug}` });
  const breadcrumbLd = breadcrumbJsonLd(trail);

  return (
    <div className="container product-wrap">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbLd) }} />

      <nav className="breadcrumb" aria-label="Breadcrumb">
        {trail.map((step, i) =>
          i === trail.length - 1 ? (
            <span key={step.path} className="breadcrumb-current">{step.name}</span>
          ) : (
            <span key={step.path} className="breadcrumb-step">
              <Link href={step.path}>{step.name}</Link>
              <span className="breadcrumb-sep">/</span>
            </span>
          )
        )}
      </nav>

      <div className="product-grid">
        <div className="product-media">
          <ProductGallery
            hero={hero}
            gallery={gallery}
            productName={product.name}
            showPlaceholder={showPlaceholder}
            placeholderText={dict.placeholder?.photo_soon ?? dict.product.gallery_soon}
          />
          {resolveVideoUrls(product.slug).map((src) => (
            <ProductVideo key={src} src={src} />
          ))}
        </div>

        <div className="product-info">
          <div className="pill-row">
            {product.category?.name ? <span className="pill">{product.category.name}</span> : null}
            {product.archived_color ? <span className="badge-rare">{dict.badge?.rare_colour}</span> : null}
          </div>
          <h1 className="display product-title">{product.name}</h1>
          {product.print_name ? <div className="badge-print">{dict.badge?.print}{product.print_name}</div> : null}
          {fromPrice ? (
            <p className="product-from">
              {dict.catalog.from_month}: <b className="display">{formatIdr(product.pricing.days[product.pricing.days.length - 1].price_idr)}</b>
            </p>
          ) : null}

          {product.description ? (
            <section className="info-block">
              <h2>{dict.product.description_title}</h2>
              <p>{product.description}</p>
            </section>
          ) : null}

          {resolvedSpecs.length ? (
            <section className="info-block">
              <h2>{dict.product.specs_title}</h2>
              <dl className="spec-grid">
                {resolvedSpecs.map((s) => (
                  <div className="spec" key={s.key}>
                    <dt>{s.label}</dt><dd>{s.value}</dd>
                  </div>
                ))}
              </dl>
            </section>
          ) : null}
        </div>
      </div>

      <Calculator
        slug={product.slug}
        locale={locale}
        equipment={equipmentRes.data.equipment}
        insuranceOptions={equipmentRes.data.insurance}
        dict={dict}
      />
    </div>
  );
}
