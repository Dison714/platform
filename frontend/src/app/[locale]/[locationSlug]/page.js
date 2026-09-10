import { notFound } from 'next/navigation';
import Link from 'next/link';
import { isEnabledLocale, DEFAULT_LOCALE } from '../../../i18n/config.js';
import { getDictionary } from '../../../i18n/getDictionary.js';
import { apiGet } from '../../../lib/api.js';
import { ogTwitter } from '../../../lib/seo.js';
import { CONTACTS } from '../../../lib/contacts.js';
import { districtName } from '../../../lib/districts.js';
import Breadcrumb from '../../components/Breadcrumb.jsx';
import ContactLink from '../../components/ContactLink.jsx';
import FaqAccordion from '../../components/FaqAccordion.jsx';
import { BRAND_ICONS } from '../../components/icons/BrandIcons.jsx';

export const dynamic = 'force-dynamic';

// Next.js App Router не поддерживает частично-статичные сегменты папки
// (папка вида "scooter-rental-[district]" не матчит URL — проверено,
// params приходит undefined). Ловим ЛЮБОЙ первый сегмент под [locale] как
// [locationSlug] (литеральные папки /bikes, /blog, /about и т.д. имеют
// приоритет над этим catch-all на том же уровне — конфликта нет) и сами
// вручную требуем префикс "scooter-rental-", отбрасывая всё остальное.
const URL_PREFIX = 'scooter-rental-';

async function loadLocationPage(district, locale) {
  try {
    return (await apiGet(`/api/location-pages/${encodeURIComponent(district)}?lang=${encodeURIComponent(locale)}`)).data;
  } catch {
    return null;
  }
}

async function loadTranslations(district, locale) {
  try {
    return (await apiGet(`/api/location-pages/${encodeURIComponent(district)}/translations?lang=${encodeURIComponent(locale)}`)).data;
  } catch {
    return [];
  }
}

// Slug района не переводится по-locale (в отличие от статей блога) — тот же
// суффикс на всех языках, но hreflang строим только по факту существующих
// переводов (не hreflangAlternates() из lib/seo.js, тот предполагает ВСЕ
// enabled-локали заранее, а сейчас переведён только en) — см.
// blogHreflangAlternates в blog/[slug]/page.js для аналогичного паттерна с
// другой формой slug.
function locationHreflangAlternates(district, translations) {
  const languages = {};
  for (const t of translations) languages[t.language_code] = `/${t.language_code}/${URL_PREFIX}${district}`;
  if (languages[DEFAULT_LOCALE]) languages['x-default'] = languages[DEFAULT_LOCALE];
  return languages;
}

function fill(template, district) {
  return template.replace('{district}', district);
}

export async function generateMetadata({ params }) {
  if (!params.locationSlug.startsWith(URL_PREFIX)) return {};
  const district = params.locationSlug.slice(URL_PREFIX.length);
  const page = await loadLocationPage(district, params.locale);
  if (!page) return { title: 'Scooter Rental' };
  const translations = await loadTranslations(district, params.locale);
  const title = page.seo_title || page.h1;
  const description = page.seo_description || page.intro;
  const url = `/${params.locale}/${URL_PREFIX}${district}`;
  return {
    title,
    description,
    alternates: { canonical: url, languages: locationHreflangAlternates(district, translations) },
    ...ogTwitter({ title, description, url }),
  };
}

export default async function LocationPage({ params }) {
  const { locale, locationSlug } = params;
  if (!isEnabledLocale(locale)) notFound();
  if (!locationSlug.startsWith(URL_PREFIX)) notFound();
  const district = locationSlug.slice(URL_PREFIX.length);

  const [page, dict] = await Promise.all([loadLocationPage(district, locale), getDictionary(locale)]);
  if (!page) notFound();

  const lp = dict.location_page;
  const name = districtName(district, locale);
  const whatsapp = CONTACTS.find((c) => c.key === 'whatsapp');
  const telegram = CONTACTS.find((c) => c.key === 'telegram');
  const WhatsAppIcon = BRAND_ICONS.whatsapp;
  const TelegramIcon = BRAND_ICONS.telegram;

  const trail = [
    { name: dict.nav.home, path: `/${locale}` },
    { name: page.h1, path: `/${locale}/${URL_PREFIX}${district}` },
  ];

  // FaqAccordion принимает items={q, a} — a может быть JSX (ссылка на статью
  // блога/категорию), React рендерит любой node, не только строку (см.
  // FaqAccordion.jsx: {it.a} без приведения к строке). Для JSON-LD ниже
  // нужен отдельный plain-text вариант того же ответа (schema.org требует
  // text, не разметку).
  const faqItems = (page.faq ?? []).map((item) => ({
    q: item.q,
    a: item.link ? (
      <>
        {item.a} <Link href={item.link.href}>{item.link.label}</Link>
      </>
    ) : (
      item.a
    ),
  }));
  const faqJsonLd = {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: (page.faq ?? []).map((item) => ({
      '@type': 'Question',
      name: item.q,
      acceptedAnswer: { '@type': 'Answer', text: item.link ? `${item.a} ${item.link.label}` : item.a },
    })),
  };

  return (
    <div className="container page loc-page">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(faqJsonLd) }} />
      <Breadcrumb trail={trail} />

      <div className="loc-hero">
        <h1 className="display page-h1">{page.h1}</h1>
        <p className="lede">{page.intro}</p>
        <p className="loc-delivery-stat">{page.delivery_summary}</p>
        <div className="loc-hero-ctas">
          <ContactLink className="btn-cta loc-cta-btn" contact={whatsapp} prefillMessage={dict.contact.prefill_message} source={`location_page_${district}`}>
            <WhatsAppIcon size={18} /> {lp.book_whatsapp}
          </ContactLink>
          <ContactLink className="btn-cta loc-cta-btn loc-cta-secondary" contact={telegram} prefillMessage={dict.contact.prefill_message} source={`location_page_${district}`}>
            <TelegramIcon size={18} /> {lp.book_telegram}
          </ContactLink>
        </div>
        {lp.see_all_bikes_note && <p className="loc-see-all-note">{lp.see_all_bikes_note}</p>}
        <Link className="btn-cta loc-cta-btn loc-cta-outline" href={`/${locale}/bikes`}>{lp.see_all_bikes}</Link>
      </div>

      <h2 className="display section-h2">{fill(lp.delivery_title, name)}</h2>
      {page.delivery_html && <div className="article-body" dangerouslySetInnerHTML={{ __html: page.delivery_html }} />}
      {page.delivery_disclaimer && <p className="loc-disclaimer">{page.delivery_disclaimer}</p>}

      {page.getting_around_html && (
        <>
          <h2 className="display section-h2">{fill(lp.getting_around_title, name)}</h2>
          <div className="article-body" dangerouslySetInnerHTML={{ __html: page.getting_around_html }} />
        </>
      )}

      {page.distances?.length > 0 && (
        <>
          <h2 className="display section-h2">{fill(lp.distances_title, name)}</h2>
          <div className="article-body loc-table-wrap">
            <table>
              <thead>
                <tr>
                  <th>{lp.col_destination}</th>
                  <th>{lp.col_distance}</th>
                  <th>{lp.col_light_traffic}</th>
                  <th>{lp.col_peak_hours}</th>
                </tr>
              </thead>
              <tbody>
                {page.distances.map((row) => (
                  <tr key={row.destination}>
                    <td>{row.destination}</td>
                    <td>{row.distance}</td>
                    <td>{row.light}</td>
                    <td>{row.peak}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <p className="lede">{fill(lp.distances_note, name)}</p>
        </>
      )}

      <h2 className="display section-h2">{fill(lp.which_bike_title, name)}</h2>
      {page.which_bike_html && <div className="article-body" dangerouslySetInnerHTML={{ __html: page.which_bike_html }} />}

      {page.route_html && (
        <>
          <h2 className="display section-h2">{fill(lp.route_title, name)}</h2>
          <p className="loc-todo">{page.route_html}</p>
        </>
      )}

      {page.popular_locations?.length > 0 && (
        <>
          <h2 className="display section-h2">{fill(lp.popular_locations_title, name)}</h2>
          <ul className="loc-places">
            {page.popular_locations.map((place) => (
              <li key={place.name}>
                <a href={place.href} target="_blank" rel="noopener noreferrer">{place.name}</a>
              </li>
            ))}
          </ul>
        </>
      )}

      <h2 className="display section-h2">{fill(lp.faq_title, name)}</h2>
      <FaqAccordion items={faqItems} />

      <div className="cta-final loc-cta-final">
        <div className="cta-in">
          <h2>{lp.cta_title}</h2>
          <p>{page.cta_text}</p>
          <div className="loc-hero-ctas loc-cta-final-btns">
            <ContactLink className="btn-cta loc-cta-btn" contact={whatsapp} prefillMessage={dict.contact.prefill_message} source={`location_page_${district}_bottom`}>
              <WhatsAppIcon size={18} /> {lp.book_whatsapp}
            </ContactLink>
            <ContactLink className="btn-cta loc-cta-btn loc-cta-secondary" contact={telegram} prefillMessage={dict.contact.prefill_message} source={`location_page_${district}_bottom`}>
              <TelegramIcon size={18} /> {lp.book_telegram}
            </ContactLink>
            <Link className="btn-cta loc-cta-btn loc-cta-outline" href={`/${locale}/bikes`}>{lp.browse_all_bikes}</Link>
          </div>
        </div>
      </div>
    </div>
  );
}
