import { notFound } from 'next/navigation';
import { isEnabledLocale } from '../../../i18n/config.js';
import { getDictionary } from '../../../i18n/getDictionary.js';
import { hreflangAlternates } from '../../../lib/seo.js';

// Условия аренды — тот же текст, что renter подписывает на бумаге при
// получении байка (Agreement_MDB_final.docx), без формы Renter/Motorbike
// Info и строки подписи (это часть печатного экземпляра под конкретное
// бронирование, не публичная политика). Намеренно НЕ переведено на все
// локали — это юридический текст компании, машинный перевод условий
// аренды рискованнее, чем один авторитетный английский текст на всех
// языках сайта (chrome страницы — nav/footer — остаётся на языке locale).
const CONDITIONS = [
  'Renter must have a valid driver’s license.',
  'The vehicle should be returned on time. In any case of prolongation of the rental period, payment should be made in advance. Otherwise, an additional fee is charged: full day price plus 20% of the daily price of the rented vehicle.',
  'The vehicle is intended to be used for driving on the road only; driving outside the road is forbidden (beach, field, off-road path, etc.). This includes, but is not limited to: unpaved jungle or mountain trails, rice field paths, riverbeds, sand dunes, and any unofficial trekking or waterfall-access tracks not classified as a public road.',
  'Full payment for the selected rental period must be made upon receipt of the vehicle. Payment is non-refundable in any case of early return, and the amount paid cannot be returned.',
  'The renter is fully responsible for the vehicle and must not lend it to a third person, nor allow it to be driven by any other person.',
  'The renter is fully responsible for their own health and safety while driving the vehicle.',
  'The renter must check the external condition of the vehicle and the presence of any damages, and take photos and videos before use. The renter is obliged to return the vehicle in the same technical condition as it was received.',
  'The renter is fully responsible for the vehicle and for any damages occurring to it during the rental period, and must pay for those damages according to the company’s price list. If the vehicle is broken or in an accident and cannot be used or rented out as a result, the renter must continue paying rent for the entire period the vehicle is unusable, until it is fixed and ready for use again.',
  'The renter must report any accident, breakdown, or damage to the company immediately through the company’s official WhatsApp/Telegram contact, including photos and/or video of the situation — and in any case within 24 hours. Reporting only verbally, to a driver, or through any other channel does not count as official notice. If the necessary information is not provided within 24 hours, the renter must pay an extra penalty of 50% of the damage cost. If any damage is caused to third parties as a result of the incident, the renter will be fully responsible for it.',
  'It is strictly forbidden to repair the vehicle independently or at any service (including official dealers) without the company’s consent. The company will not pay for repairs carried out without agreement, and will charge the renter 1,500k IDR plus the amount of damage incurred. If a tire (front or rear) is damaged due to nails or other sharp objects on the road, the renter is obligated to patch it, refill the air, and fix the problem.',
  'Safety deposit for every motorcycle — minimum 1,000k IDR. Any charges under these conditions (for damages, lost or broken items, or other fees) are first deducted from the deposit; if the deposit is insufficient to cover the amount owed, the renter must pay the remaining balance.',
  'It is not permitted to drive the vehicle outside Bali island without the company’s approval. To request approval for a trip outside Bali, the renter must send a message at least 72 hours in advance with the time of the trip, the trip plan (route), and the additional contact of the accompanying person. Original documents for travel outside Bali are issued against a deposit, the amount of which is specified by the company for each case.',
  'In case the vehicle is lost, the company will charge the renter: a) if the motorbike is less than 6 months old — 100% of the new vehicle value based on market price; b) if the motorbike is more than 6 months old — 100% of the vehicle value based on the average secondary market price.',
  'If helmets, extra items, the vehicle key, or the vehicle documents (separately from the vehicle itself) are lost or broken, the company will charge the renter a fixed fee according to the following price list, regardless of the cost of any other damage to the vehicle: standard helmet — 200k IDR; KYT half-face helmet — 500k IDR; KYT full-face helmet — 600k IDR; raincoat — 100k IDR if damaged or lost; cleaning cloth — 30k IDR if damaged or lost; helmet bag — 50k IDR if damaged or lost; KYT visor — 150k IDR for multiple new scratches or one large scratch; standard helmet visor — 50k IDR if new scratches are present; phone holder — 200k IDR; vehicle key — 1,500k IDR; vehicle documents — 2,250k IDR.',
  'The company’s operational hours are 08:00–18:00. Pickup or delivery requested outside operational hours (evenings, nights, or non-working hours) is possible, but may require an additional fee starting from 200k IDR, to be agreed and paid before the visit.',
  'The vehicle is handed over with a full fuel tank and must be returned with a full fuel tank. If returned with less fuel, the missing amount will be calculated in money and deducted from the deposit. Only Pertamax (or the fuel grade specified by the company for the relevant vehicle) should be used, at major branded fuel stations.',
  'If the vehicle’s battery is found fully discharged due to the renter’s use (e.g. lights, alarm, or accessories left on), the renter will be charged a compensation fee of 150k IDR for battery wear. If a driver visit is required to assist, an additional service fee of 150k IDR applies. The renter may instead visit the nearest workshop independently, at their own convenience.',
  'The renter may optionally purchase insurance offered by the company. Theft insurance is valid only within Bali and costs 400k IDR. Damage insurance is available in two coverage levels: 1,500k IDR coverage for 500k IDR/month (experienced renters with a valid license) or 700k IDR/month (renters without a license, under 33 years old, or with little experience); 4,500k IDR coverage for 750k IDR/month (experienced renters with a valid license) or 1,500k IDR/month (renters without a license, under 33 years old, or with little experience). Insurance does not replace or limit the renter’s responsibilities under this agreement beyond the purchased coverage amount.',
  'If the renter violates these agreement conditions, the company has the right to pick up the vehicle immediately.',
  'The company is not liable for damage, loss, injury, or death sustained by renters, their pillion riders, or other people involved in accidents. The company is not liable for failure to perform its obligations due to issues beyond its reasonable control, including but not limited to acts of God, power failure, fire, flood, epidemic disease, war, riot, and terrorism. The company is not liable for any illegal conduct or actions against the law of the Republic of Indonesia. The renter confirms they have read, understood, and agree to all clauses of this agreement.',
];

export async function generateMetadata({ params }) {
  const dict = await getDictionary(params.locale);
  const title = `${dict.footer.terms} — ${dict.brand.name}`;
  const url = `/${params.locale}/terms`;
  return {
    title,
    alternates: { canonical: url, languages: hreflangAlternates('/terms') },
  };
}

export default async function TermsPage({ params }) {
  const { locale } = params;
  if (!isEnabledLocale(locale)) notFound();
  const dict = await getDictionary(locale);

  return (
    <div className="container page">
      <h1 className="display page-h1">Rental Agreement — Terms &amp; Conditions</h1>
      <p className="lede">
        This is the same rental agreement you sign on paper when you pick up a bike from{' '}
        {dict.brand.name} (PT. Modern Development Bali). It is published here in English only —
        the signed original at handover is the authoritative version.
      </p>
      <ol className="terms-list">
        {CONDITIONS.map((c, i) => <li key={i}>{c}</li>)}
      </ol>
    </div>
  );
}
