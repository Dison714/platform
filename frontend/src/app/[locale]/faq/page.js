import { notFound } from 'next/navigation';
import { isEnabledLocale } from '../../../i18n/config.js';
import { getDictionary } from '../../../i18n/getDictionary.js';
import FaqAccordion from '../../components/FaqAccordion.jsx';
import { ogTwitter } from '../../../lib/seo.js';

export async function generateMetadata({ params }) {
  const dict = await getDictionary(params.locale);
  const title = `${dict.faq.title} — ${dict.brand.name}`;
  const description = dict.faq.intro;
  const url = `/${params.locale}/faq`;
  return {
    title,
    description,
    alternates: { canonical: url },
    ...ogTwitter({ title, description, url }),
  };
}

export default async function FaqPage({ params }) {
  const { locale } = params;
  if (!isEnabledLocale(locale)) notFound();
  const dict = await getDictionary(locale);
  const items = dict.faq.items ?? [];

  // FAQPage structured data для SEO (Google rich result).
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: items.map((it) => ({
      '@type': 'Question',
      name: it.q,
      acceptedAnswer: { '@type': 'Answer', text: it.a },
    })),
  };

  return (
    <div className="container page">
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <h1 className="display page-h1">{dict.faq.title}</h1>
      <p className="lede">{dict.faq.intro}</p>
      <FaqAccordion items={items} />
    </div>
  );
}
