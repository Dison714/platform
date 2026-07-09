import { SITE_URL } from './site.js';
import { CONTACTS, HOURS } from './contacts.js';

// LocalBusiness JSON-LD (не Organization): у бизнеса есть операционная база
// с известными координатами (см. geo ниже) и публичный адрес, уже
// показанный на сайте (About/Footer) — это не просто юрлицо без локации.
//
// Источники фактов (не выдумано):
// - name/telephone/sameAs/email/address/openingHours — src/lib/contacts.js
//   (то же, что уже публикуется на About/Footer).
// - legalName — Knowledge Base MDB, §22 «Реквизиты компании» (Drive).
// - geo — system_config.delivery_base_coords (та же точка, от которой
//   считается доставка по прямой; см. миграция 013 backend), НЕ угадано.
//
// TODO(business): открытые вопросы — см. финальный отчёт по чанку SEO
// (Kerobokan vs юр.адрес в Sanur; часы 7 дней/нед без исключений; WhatsApp
// как telephone).
const wa = CONTACTS.find((c) => c.key === 'whatsapp');
const instagram = CONTACTS.find((c) => c.key === 'instagram');
const telegram = CONTACTS.find((c) => c.key === 'telegram');
const email = CONTACTS.find((c) => c.key === 'email');

export const organizationJsonLd = {
  '@context': 'https://schema.org',
  '@type': 'LocalBusiness',
  name: 'Bike Bali Rent',
  legalName: 'PT Modern Development Bali',
  url: SITE_URL,
  ...(wa ? { telephone: `+${wa.href.split('/').pop()}` } : {}),
  ...(email ? { email: email.value } : {}),
  sameAs: [instagram?.href, telegram?.href].filter(Boolean),
  address: {
    '@type': 'PostalAddress',
    streetAddress: 'Gg. 1 Kerobokan Kelod',
    addressLocality: 'Kuta Utara',
    addressRegion: 'Bali',
    addressCountry: 'ID',
  },
  geo: {
    '@type': 'GeoCoordinates',
    latitude: -8.672194,
    longitude: 115.1755,
  },
  openingHours: `Mo-Su ${HOURS.replace('–', '-')}`,
};
