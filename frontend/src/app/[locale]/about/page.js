import { notFound } from 'next/navigation';
import { isEnabledLocale } from '../../../i18n/config.js';
import { getDictionary } from '../../../i18n/getDictionary.js';
import { CONTACTS, ADDRESS, HOURS, HOURS_NOTE } from '../../../lib/contacts.js';
import { ogTwitter, hreflangAlternates } from '../../../lib/seo.js';

export async function generateMetadata({ params }) {
  const dict = await getDictionary(params.locale);
  const title = `${dict.about.title} — ${dict.brand.name}`;
  const description = dict.about.p1;
  const url = `/${params.locale}/about`;
  return {
    title,
    description,
    alternates: { canonical: url, languages: hreflangAlternates('/about') },
    ...ogTwitter({ title, description, url }),
  };
}

export default async function AboutPage({ params }) {
  const { locale } = params;
  if (!isEnabledLocale(locale)) notFound();
  const dict = await getDictionary(locale);
  const a = dict.about;

  return (
    <div className="container page">
      <h1 className="display page-h1">{a.title}</h1>
      <p className="lede">{a.p1}</p>
      <p className="lede">{a.p2}</p>

      <h2 className="display section-h2">{a.offer_title}</h2>
      <ul className="ticks">
        {a.offer.map((item, i) => <li key={i}>{item}</li>)}
      </ul>

      <h2 className="display section-h2" id="contact">{a.contact_title}</h2>
      <div className="contact-card">
        {CONTACTS.map((c) => (
          <a className="contact-row" key={c.key} href={c.href}>
            <span className="contact-label">{c.label}</span>
            <span className="contact-value">{c.value}</span>
          </a>
        ))}
        <div className="contact-row static">
          <span className="contact-label">Address</span>
          <span className="contact-value">{ADDRESS}</span>
        </div>
        <div className="contact-row static">
          <span className="contact-label">Hours</span>
          <span className="contact-value">{HOURS}</span>
        </div>
      </div>
      <p className="hint">{HOURS_NOTE}</p>
    </div>
  );
}
