import { resolvePhotoUrl } from './photos.js';
import { enabledLocales, DEFAULT_LOCALE } from '../i18n/config.js';

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

// Дефолтный og:image для страниц без собственного фото (homepage/каталог/
// About/FAQ) — реальное отснятое фото байка из product_photos (Honda ADV
// Total Black), НЕ логотип (файла нет в репозитории) и НЕ сток. Собственность
// бизнеса. Относительный путь — metadataBase в root layout резолвит в
// абсолютный URL автоматически (как и alternates.canonical).
const DEFAULT_OG_PHOTO = { storage_path: 'bikes/honda-adv-total-black/01' };
export function defaultOgImageUrl() {
  return resolvePhotoUrl(DEFAULT_OG_PHOTO, 'hero');
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
