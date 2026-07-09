import { Teko, Poppins } from 'next/font/google';
import { notFound } from 'next/navigation';
import { isEnabledLocale, enabledLocales } from '../../i18n/config.js';
import { getDictionary } from '../../i18n/getDictionary.js';
import Header from '../components/Header.jsx';
import Footer from '../components/Footer.jsx';
import { organizationJsonLd } from '../../lib/organization.js';

// Шрифты бренда: Teko — дисплейные заголовки, Poppins — текст/UI (self-hosted).
const teko = Teko({ subsets: ['latin'], weight: ['500', '600'], variable: '--font-teko', display: 'swap' });
const poppins = Poppins({ subsets: ['latin'], weight: ['400', '500'], variable: '--font-poppins', display: 'swap' });

export function generateStaticParams() {
  return enabledLocales().map((locale) => ({ locale }));
}

// <html>/<body> живут здесь (а не в root layout), чтобы lang резолвился из
// params.locale на билде — статический рендер сохраняется, без headers().
export default async function LocaleLayout({ children, params }) {
  const { locale } = params;
  if (!isEnabledLocale(locale)) notFound();
  const dict = await getDictionary(locale);

  return (
    <html lang={locale} className={`${teko.variable} ${poppins.variable}`}>
      <body>
        {/* LocalBusiness — глобально на каждой странице, не только на homepage. */}
        <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(organizationJsonLd) }} />
        <div className="layout-root">
          <Header locale={locale} dict={dict} />
          <main style={{ flex: 1 }}>{children}</main>
          <Footer dict={dict} />
        </div>
      </body>
    </html>
  );
}
