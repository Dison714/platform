import { enabledLocales, DEFAULT_LOCALE } from '../i18n/config.js';
import { absoluteUrl } from './site.js';

// alternates.languages для generateMetadata: en/ru на ту же страницу +
// x-default → DEFAULT_LOCALE (en). suffix — часть пути ПОСЛЕ сегмента
// локали (например '/bikes/<slug>', '/about', '' для homepage) — общая для
// всех локалей, т.к. slug у продукта единый (не per-locale). Относительные
// пути — metadataBase резолвит в абсолютные (как и canonical).
export function hreflangAlternates(suffix) {
  const languages = {};
  for (const loc of enabledLocales()) {
    languages[loc] = `/${loc}${suffix}`;
  }
  languages['x-default'] = `/${DEFAULT_LOCALE}${suffix}`;
  return languages;
}

// Дефолтный og:image (превью при шаринге ссылки в WhatsApp/Telegram/соцсетях)
// для страниц без собственного фото (homepage/каталог/About/FAQ) — не
// продуктовое фото из product_photos/R2, а отдельный статический файл
// (frontend/public/og-preview.webp, владелец выбрал конкретный кадр из
// «Проф» — сgeneral, не привязан к какому-то одному Product). НЕ логотип
// (файла нет в репозитории) и НЕ сток. Относительный путь — metadataBase в
// root layout резолвит в абсолютный URL автоматически (как и alternates.canonical).
export function defaultOgImageUrl() {
  return '/og-preview.webp';
}

// openGraph+twitter блок для generateMetadata. Canonical/hreflang НЕ входят
// сюда — каждая страница собирает alternates отдельно (см. hreflangAlternates).
//
// og:type всегда 'website', включая product page: типизированный Metadata API
// Next 14.2 не принимает 'product' (падает с "Invalid OpenGraph type: product"
// в рантайме — проверено), а og:type=product по спецификации ещё и требует
// xmlns:product на <html>, которого нет. Google для индексации типа не
// использует — берёт Product JSON-LD (обогащается в Шаге 5).
export function ogTwitter({ title, description, url, image, imageAlt }) {
  const img = image || defaultOgImageUrl();
  const alt = imageAlt || title;
  return {
    openGraph: {
      title,
      description,
      url,
      type: 'website',
      siteName: 'Bike Bali Rent',
      images: [{ url: img, width: 1200, height: 900, alt }],
    },
    twitter: {
      card: 'summary_large_image',
      title,
      description,
      images: [img],
    },
  };
}

// BreadcrumbList JSON-LD — рендерится страницей как <script type=
// "application/ld+json">, не через generateMetadata, поэтому item нужно
// делать абсолютным вручную (absoluteUrl), как и в Product JSON-LD.
// items: [{ name, path }], path — относительный (/en, /en/bikes, ...).
export function breadcrumbJsonLd(items) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((it, i) => ({
      '@type': 'ListItem',
      position: i + 1,
      name: it.name,
      item: absoluteUrl(it.path),
    })),
  };
}
