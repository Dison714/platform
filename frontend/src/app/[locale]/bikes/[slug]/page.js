import Link from 'next/link';
import { notFound } from 'next/navigation';
import { isEnabledLocale } from '../../../../i18n/config.js';
import { getDictionary } from '../../../../i18n/getDictionary.js';
import { apiGet, formatIdr } from '../../../../lib/api.js';
import { resolvePhotoUrl, pickHero, galleryPhotos } from '../../../../lib/photos.js';
import Calculator from '../../../components/Calculator.jsx';

export const dynamic = 'force-dynamic';

async function loadProduct(slug) {
  try {
    return (await apiGet(`/api/products/${encodeURIComponent(slug)}`)).data;
  } catch {
    return null;
  }
}

export async function generateMetadata({ params }) {
  const dict = await getDictionary(params.locale);
  const product = await loadProduct(params.slug);
  if (!product) return { title: dict.brand.name };
  const desc = product.description || `${product.name} — ${dict.brand.tagline}`;
  return {
    title: `${product.name} — ${dict.brand.name}`,
    description: desc,
    alternates: { canonical: `/${params.locale}/bikes/${product.slug}` },
  };
}

export default async function ProductPage({ params }) {
  const { locale, slug } = params;
  if (!isEnabledLocale(locale)) notFound();
  const dict = await getDictionary(locale);

  const [product, equipmentRes] = await Promise.all([
    loadProduct(slug),
    apiGet(`/api/equipment?lang=${encodeURIComponent(locale)}`),
  ]);
  if (!product) notFound();

  const fromPrice = product.pricing?.days?.[0]?.price_idr;
  const hero = pickHero(product.photos);
  const gallery = galleryPhotos(product.photos, hero, 8); // hero + до 8 в галерее
  const showPlaceholder = product.need_photos || !hero;
  // JSON-LD (Product/Offer) для SEO — данные из API, не выдуманные.
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: product.name,
    category: product.category?.name,
    brand: { '@type': 'Brand', name: product.family?.name?.split(' ')[0] || dict.brand.name },
    ...(product.description ? { description: product.description } : {}),
    offers: fromPrice
      ? {
          '@type': 'Offer',
          priceCurrency: product.pricing.currency,
          price: fromPrice,
          availability: 'https://schema.org/InStock',
        }
      : undefined,
  };

  return (
    <div className="container product-wrap">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />

      <Link href={`/${locale}/bikes`} className="back-link">← {dict.product.back}</Link>

      <div className="product-grid">
        <div className="product-media">
          <div className="gallery-main">
            {showPlaceholder ? (
              <div className="gallery-ph">
                <span aria-hidden="true" style={{ fontSize: 56 }}>🏍</span>
                <span className="hint">{dict.placeholder?.photo_soon ?? dict.product.gallery_soon}</span>
              </div>
            ) : (
              // hero — над сгибом, грузим eager (LCP); явные размеры против CLS.
              <img src={resolvePhotoUrl(hero, 'hero')} alt={product.name} loading="eager" width="1200" height="900" />
            )}
          </div>
          {gallery.length ? (
            <div className="gallery-thumbs">
              {gallery.map((ph) => (
                <div className="thumb" key={ph.sort_order}>
                  <img src={resolvePhotoUrl(ph, 'gallery')} alt="" loading="lazy" width="800" height="600" />
                </div>
              ))}
            </div>
          ) : null}
        </div>

        <div className="product-info">
          <div className="pill-row">
            {product.category?.name ? <span className="pill">{dict.cat?.[product.category.code] ?? product.category.name}</span> : null}
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

          {product.specs?.length ? (
            <section className="info-block">
              <h2>{dict.product.specs_title}</h2>
              <dl className="spec-grid">
                {product.specs.map((s) => {
                  const meta = dict.spec?.[s.key];
                  const label = meta?.label ?? s.key;
                  // transmission — код (cvt/manual/automatic) → локализованное слово;
                  // остальные — значение + единица из i18n (если есть).
                  const value = s.key === 'transmission'
                    ? (meta?.[s.value] ?? s.value)
                    : (meta?.unit ? `${s.value} ${meta.unit}` : s.value);
                  return (
                    <div className="spec" key={s.key}>
                      <dt>{label}</dt><dd>{value}</dd>
                    </div>
                  );
                })}
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
