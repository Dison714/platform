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

  const [product, equipmentRes, categoriesRes, familiesRes, deliveryTiersRes] = await Promise.all([
    loadProduct(slug, locale),
    apiGet(`/api/equipment?lang=${encodeURIComponent(locale)}`),
    categoryCode ? apiGet(`/api/categories?lang=${encodeURIComponent(locale)}`) : Promise.resolve({ data: [] }),
    modelCode ? apiGet(`/api/families?lang=${encodeURIComponent(locale)}`) : Promise.resolve({ data: [] }),
    apiGet('/api/delivery-fee-rules'),
  ]);
  if (!product) notFound();

  const fromPrice = product.pricing?.days?.[0]?.price_idr;
  const hero = pickHero(product.photos);
  const gallery = galleryPhotos(product.photos, hero, 8); // hero + до 8 в галерее
  const showPlaceholder = product.need_photos || !hero;
  const videoUrls = resolveVideoUrls(product.slug);
  const resolvedSpecs = resolveSpecs(product.specs, dict); // общий резолв для UI и JSON-LD
  // Google Merchant listing (структурированные данные, GSC "Данные о товарах
  // продавца") хочет валидный google_product_category, а не наш ярлык
  // фильтра каталога (vehicle_categories.name — "Naked / Classic" и т.п.,
  // это UI-фильтр, не таксономия). У мотобайков/скутеров в таксономии
  // Google один лист без разбивки на "скутер"/"мотоцикл" (ID 919):
  // https://productcategory.net/finder/vehicles-and-parts/vehicles/motor-vehicles/motorcycles-and-scooters/
  const GOOGLE_PRODUCT_CATEGORY = 'Vehicles & Parts > Vehicles > Motor Vehicles > Motorcycles & Scooters';
  // Тарифы доставки — из /api/delivery-fee-rules (тот же rule_set, что и
  // калькулятор), не задублированы вручную, чтобы не разъехаться при
  // изменении в /internal/delivery. shippingDetails — по одной записи на
  // тариф; сам rental-by-duration тариф не укладывается 1:1 в семантику
  // OfferShippingDetails (она про вес/сумму заказа, не срок аренды), но
  // числа реальные — компромисс согласован с владельцем.
  const deliveryTiers = deliveryTiersRes.data ?? [];
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: product.name,
    category: GOOGLE_PRODUCT_CATEGORY,
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
          // Договор аренды (п.4, Agreement_MDB_final.docx / /terms): оплата
          // невозвратна при досрочном возврате — возврата товара в смысле
          // merchant return тут в принципе нет, это аренда, а не покупка.
          hasMerchantReturnPolicy: {
            '@type': 'MerchantReturnPolicy',
            returnPolicyCategory: 'https://schema.org/MerchantReturnNotPermitted',
            url: absoluteUrl(`/${locale}/terms`),
          },
          ...(deliveryTiers.length
            ? {
                shippingDetails: deliveryTiers.map((t) => ({
                  '@type': 'OfferShippingDetails',
                  shippingRate: { '@type': 'MonetaryAmount', value: Number(t.fee_idr), currency: 'IDR' },
                  shippingDestination: { '@type': 'DefinedRegion', addressCountry: 'ID', addressRegion: 'Bali' },
                  deliveryTime: {
                    '@type': 'ShippingDeliveryTime',
                    handlingTime: { '@type': 'QuantitativeValue', minValue: 0, maxValue: 0, unitCode: 'DAY' },
                    transitTime: { '@type': 'QuantitativeValue', minValue: 0, maxValue: 1, unitCode: 'DAY' },
                  },
                })),
              }
            : {}),
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
          {/* Мобильный порядок видео (не трогаем): 1,2,3,4 сразу под галереей,
              как и было. На десктопе видео 1/3/4 скрываются здесь и вместо
              них рендерятся ниже, внутри .product-info (см. video-desktop-only) —
              так они реально лежат в блоке с текстом, а не делят grid-строку
              с фото (иначе высокая галерея утягивает их вниз общей строкой). */}
          {videoUrls.map((src, i) => (
            <ProductVideo
              key={`m-${src}`}
              src={src}
              className={`product-video-${i + 1}${i === 1 ? '' : ' video-mobile-only'}`}
            />
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

          {/* Десктопный порядок видео 1/3/4 — реальные узлы внутри .product-info
              (не просто CSS-переставленные), поэтому спокойно лежат сразу под
              текстом независимо от высоты галереи слева. Скрыты на мобильном
              (video-desktop-only) — там уже показаны копии выше, в .product-media. */}
          {videoUrls.map((src, i) => (
            i === 1 ? null : (
              <ProductVideo
                key={`d-${src}`}
                src={src}
                className={`product-video-${i + 1} video-desktop-only`}
              />
            )
          ))}
        </div>
      </div>

      <Calculator
        slug={product.slug}
        locale={locale}
        equipment={equipmentRes.data.equipment}
        insuranceOptions={equipmentRes.data.insurance}
        dict={dict}
      />

      {/* Длинный маркетинговый блок (Family-level, family_content_translations) —
          намеренно НИЖЕ калькулятора/брони, чтобы не мешать above-the-fold
          конверсии; короткий product.description выше (между ценой и
          Specifications) — это отдельное поле, не дублирует этот блок.
          Явный разделитель (заголовок + граница) — чтобы блок не сливался
          визуально с калькулятором/кнопкой бронирования над ним. */}
      {product.content_html ? (
        <section className="product-long-content-wrap">
          <h2 className="section-h2">{dict.product.more_details_title}</h2>
          <div className="product-long-content" dangerouslySetInnerHTML={{ __html: product.content_html }} />
        </section>
      ) : null}
    </div>
  );
}
