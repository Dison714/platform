import Link from 'next/link';
import { cookies } from 'next/headers';
import { notFound } from 'next/navigation';
import { isEnabledLocale } from '../../i18n/config.js';
import { getDictionary } from '../../i18n/getDictionary.js';
import { apiGet, formatIdr } from '../../lib/api.js';
import { pickAvailablePair } from '../../lib/availableBikes.js';
import { resolvePhotoUrl } from '../../lib/photos.js';
import { ogTwitter, hreflangAlternates } from '../../lib/seo.js';
import BikeCard from '../components/BikeCard.jsx';

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

  // Витрина популярных моделей (Блок E) — фиксированный список slug'ов,
  // подобранный вручную для показа РАЗНООБРАЗИЯ парка (эконом-скутер →
  // макси-скутер → турист-эндуро → круизер → спорт → нейкед-классика),
  // а не выдуманного "популярности" — реальных данных о частоте бронирований
  // пока нет (CRM/бронирования — v1.1+). Отдельно от виджета доступности
  // (Блок 5) — та секция про "что свободно сейчас", эта — про ассортимент.
  const POPULAR_SLUGS = [
    'honda-adv-total-black',
    'yamaha-xmax-black-partner',
    'suzuki-vstrom250-black-crashbar',
    'keeway-road-falcon-250-black',
    'honda-cbr250rr-white-blue',
    'tvs-ronin225-total-black',
  ];
  let popularModels = [];
  try {
    const all = (await apiGet('/api/products')).data ?? [];
    const bySlug = new Map(all.map((p) => [p.slug, p]));
    popularModels = POPULAR_SLUGS.map((s) => bySlug.get(s)).filter(Boolean);
  } catch {
    popularModels = [];
  }

  let availableBikes = [];
  try {
    const available = (await apiGet('/api/products?available=true')).data ?? [];
    const cookieId = cookies().get('mdb_cid')?.value ?? null;
    availableBikes = pickAvailablePair(available, cookieId);
  } catch {
    availableBikes = []; // виджет просто не рендерится, если API недоступен
  }
  const faqTop = (dict.faq.items ?? []).slice(0, 3);
  const bikesHref = `/${locale}/bikes`;

  return (
    <div className="home">
      <section className="hero">
        <div className="container hero-in">
          <div className="hero-text">
            <h1 className="display hero-title">{h.hero_title}</h1>
            <p className="hero-sub">{h.hero_sub}</p>
            <Link href={bikesHref} className="btn-cta">{h.hero_cta} →</Link>
          </div>
          {availableBikes.length > 0 && (
            <div className="hero-bikes">
              <span className="hero-bikes-label">{h.available_now}</span>
              <div className="hero-bikes-grid">
                {availableBikes.map((p) => (
                  <Link href={`/${locale}/bikes/${p.slug}`} className="hero-bike-card" key={p.id}>
                    <div className="hero-bike-photo">
                      {p.hero ? (
                        <img src={resolvePhotoUrl(p.hero, 'thumb')} alt={p.name} loading="lazy" width="400" height="300" />
                      ) : (
                        <span aria-hidden="true">🏍</span>
                      )}
                    </div>
                    <div className="hero-bike-name">{p.name}</div>
                    {p.price_preview && <div className="hero-bike-price">{formatIdr(p.price_preview.price_idr)}</div>}
                  </Link>
                ))}
              </div>
            </div>
          )}
        </div>
      </section>

      <section className="trust-strip">
        <div className="container trust-strip-in">
          {h.trust.map((t, i) => (
            <div className="trust-item" key={i}>
              <span aria-hidden="true">{t.icon}</span>
              <span>{t.text}</span>
            </div>
          ))}
        </div>
      </section>

      <section className="container block">
        <h2 className="display block-title">{h.steps_title}</h2>
        <div className="steps-grid">
          {h.steps.map((s, i) => (
            <div className="step-card" key={i}>
              <span className="why-num display" aria-hidden="true">{i + 1}</span>
              <h3>{s.title}</h3>
              <p>{s.text}</p>
            </div>
          ))}
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

      {popularModels.length > 0 && (
        <section className="container block">
          <h2 className="display block-title">{h.popular_title}</h2>
          <p className="block-sub">{h.popular_sub}</p>
          <div className="grid">
            {popularModels.map((p) => (
              <BikeCard key={p.id} locale={locale} product={p} dict={dict} />
            ))}
          </div>
        </section>
      )}

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
