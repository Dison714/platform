import Link from 'next/link';
import { notFound } from 'next/navigation';
import { isEnabledLocale } from '../../i18n/config.js';
import { getDictionary } from '../../i18n/getDictionary.js';
import { apiGet } from '../../lib/api.js';
import { ogTwitter, hreflangAlternates } from '../../lib/seo.js';

// Главная — SSR-контент (для SEO). Категории тянем из API, остальное — словари.
export const dynamic = 'force-dynamic';

export async function generateMetadata({ params }) {
  const dict = await getDictionary(params.locale);
  const title = `${dict.brand.name} — ${dict.brand.tagline}`;
  const description = dict.home.hero_sub;
  const url = `/${params.locale}`;
  return {
    title,
    description,
    alternates: { canonical: url, languages: hreflangAlternates('') },
    ...ogTwitter({ title, description, url }),
  };
}

export default async function HomePage({ params }) {
  const { locale } = params;
  if (!isEnabledLocale(locale)) notFound();
  const dict = await getDictionary(locale);
  const h = dict.home;

  let categories = [];
  try {
    categories = (await apiGet('/api/categories')).data ?? [];
  } catch {
    categories = []; // главная не падает, если API недоступен — просто без плиток
  }
  const faqTop = (dict.faq.items ?? []).slice(0, 3);
  const bikesHref = `/${locale}/bikes`;

  return (
    <div className="home">
      <section className="hero">
        <div className="container hero-in">
          <h1 className="display hero-title">{h.hero_title}</h1>
          <p className="hero-sub">{h.hero_sub}</p>
          <Link href={bikesHref} className="btn-cta">{h.hero_cta} →</Link>
        </div>
      </section>

      <section className="container block">
        <h2 className="display block-title">{h.why_title}</h2>
        <div className="why-grid">
          {h.why.map((w, i) => (
            <div className="why-card" key={i}>
              <span className="why-num display" aria-hidden="true">{i + 1}</span>
              <h3>{w.title}</h3>
              <p>{w.text}</p>
            </div>
          ))}
        </div>
      </section>

      {categories.length > 0 && (
        <section className="container block">
          <h2 className="display block-title">{h.categories_title}</h2>
          <p className="block-sub">{h.categories_sub}</p>
          <div className="cat-grid">
            {categories.map((c) => (
              <Link key={c.code} href={`${bikesHref}?category=${c.code}`} className="cat-tile">
                <span className="cat-name">{dict.cat?.[c.code] ?? c.name}</span>
                <span className="cat-count">{c.product_count}</span>
              </Link>
            ))}
          </div>
        </section>
      )}

      <section className="container block">
        <h2 className="display block-title">{h.faq_title}</h2>
        <div className="faq-mini">
          {faqTop.map((f, i) => (
            <div className="faq-mini-item" key={i}>
              <h3>{f.q}</h3>
              <p>{f.a}</p>
            </div>
          ))}
        </div>
        <Link href={`/${locale}/faq`} className="link-more">{h.faq_all} →</Link>
      </section>

      <section className="cta-final">
        <div className="container cta-in">
          <h2 className="display">{h.cta_title}</h2>
          <p>{h.cta_sub}</p>
          <Link href={bikesHref} className="btn-cta">{h.cta_btn} →</Link>
        </div>
      </section>
    </div>
  );
}
