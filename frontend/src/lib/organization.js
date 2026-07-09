import { SITE_URL } from './site.js';
import { CONTACTS, HOURS } from './contacts.js';

// LocalBusiness JSON-LD (не Organization): у бизнеса есть операционная база
// и публичные часы работы, уже показанные на сайте (About/Footer) — это не
// просто юрлицо без локации. При этом бизнес принципиально не публикует
// точный адрес/координаты (delivery-first позиционирование, подтверждено
// владельцем) — вместо street-level address и geo используется только
// регион (addressRegion/addressCountry) + areaServed.
//
// Источники фактов (не выдумано):
// - name/sameAs/email/openingHours — src/lib/contacts.js (то же, что уже
//   публикуется на About/Footer).
// - legalName — Knowledge Base MDB, §22 «Реквизиты компании» (Drive).
// - contactPoint.telephone/url — номер WhatsApp из contacts.js, в явном
//   WhatsApp-контексте (url), не выдаётся за отдельную voice-линию.
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
  ...(email ? { email: email.value } : {}),
  sameAs: [instagram?.href, telegram?.href].filter(Boolean),
  ...(wa
    ? {
        contactPoint: {
          '@type': 'ContactPoint',
          contactType: 'customer service',
          telephone: `+${wa.href.split('/').pop()}`,
          url: wa.href,
          availableLanguage: ['English', 'Russian'],
        },
      }
    : {}),
  address: {
    '@type': 'PostalAddress',
    addressRegion: 'Bali',
    addressCountry: 'ID',
  },
  areaServed: { '@type': 'Place', name: 'Bali' },
  openingHours: `Mo-Su ${HOURS.replace('–', '-')}`,
};
