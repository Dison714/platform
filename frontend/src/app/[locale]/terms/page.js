import { notFound } from 'next/navigation';
import { isEnabledLocale } from '../../../i18n/config.js';
import { getDictionary } from '../../../i18n/getDictionary.js';
import { hreflangAlternates } from '../../../lib/seo.js';
import { TERMS } from '../../../data/terms.js';

// Условия аренды — тот же текст, что renter подписывает на бумаге при
// получении байка (Agreement_MDB_final.docx), без формы Renter/Motorbike
// Info и строки подписи (это часть печатного экземпляра под конкретное
// бронирование, не публичная политика). Переведено на все языки сайта
// (frontend/src/data/terms.js) — но английский остаётся авторитетным
// текстом: в каждом non-en переводе есть сноска authoritative_note
// (переведена на язык страницы), объясняющая, что при расхождениях
// действует английский оригинал.
export async function generateMetadata({ params }) {
  const dict = await getDictionary(params.locale);
  const t = TERMS[params.locale] ?? TERMS.en;
  const title = `${t.title} — ${dict.brand.name}`;
  const url = `/${params.locale}/terms`;
  return {
    title,
    alternates: { canonical: url, languages: hreflangAlternates('/terms') },
  };
}

export default async function TermsPage({ params }) {
  const { locale } = params;
  if (!isEnabledLocale(locale)) notFound();
  const t = TERMS[locale] ?? TERMS.en;

  return (
    <div className="container page">
      <h1 className="display page-h1">{t.title}</h1>
      <p className="lede">{t.intro}</p>
      {t.authoritative_note ? <p className="terms-note">{t.authoritative_note}</p> : null}
      <ol className="terms-list">
        {t.conditions.map((c, i) => <li key={i}>{c}</li>)}
      </ol>
    </div>
  );
}
