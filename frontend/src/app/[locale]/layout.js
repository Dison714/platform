import '../globals.css';
import Script from 'next/script';
import { Teko, Poppins, Noto_Sans_Arabic } from 'next/font/google';
import { notFound } from 'next/navigation';
import { isEnabledLocale, enabledLocales } from '../../i18n/config.js';
import { getDictionary } from '../../i18n/getDictionary.js';
import Header from '../components/Header.jsx';
import Footer from '../components/Footer.jsx';
import { organizationJsonLd } from '../../lib/organization.js';
import { IS_PRODUCTION, SITE_URL } from '../../lib/site.js';

// Google Ads conversion tag — перенесено со старого WordPress-сайта
// (там стоял как GT-KDB22DZQ через Site Kit). Пока без привязки к
// конкретному conversion action — Дмитрий перелинкует в кабинете Google
// Ads после проверки, что тег вообще стреляет на платформе. Не гейтим
// IS_PRODUCTION намеренно: нужно поймать событие на sslip.io-стейджинге
// до DNS-катовера.
const GOOGLE_ADS_ID = 'AW-17065885486';

// Шрифты бренда: Teko — дисплейные заголовки, Poppins — текст/UI (self-hosted).
// Ни один не покрывает арабскую графику — для ar подменяем --font-poppins
// на Noto Sans Arabic (заголовки на ar остаются без display-шрифта Teko,
// латиница/кириллица в Teko всё равно не читается арабским пользователем).
const teko = Teko({ subsets: ['latin'], weight: ['500', '600'], variable: '--font-teko', display: 'swap' });
const poppins = Poppins({ subsets: ['latin'], weight: ['400', '500'], variable: '--font-poppins', display: 'swap' });
const notoArabic = Noto_Sans_Arabic({ subsets: ['arabic'], weight: ['400', '500'], variable: '--font-poppins', display: 'swap' });

export function generateStaticParams() {
  return enabledLocales().map((locale) => ({ locale }));
}

// До финального DNS cutover (SITE_ENV != production) — глобальный noindex на
// каждой странице сайта (сливается с page-level metadata; ни одна страница
// пока сама не задаёт robots, так что конфликтов нет). Вместе с robots.js
// (Disallow: /) и пустым sitemap.js закрывает стейджинг/IP/дефолтный
// Coolify-поддомен от индексации.
export async function generateMetadata() {
  // metadataBase — основа для абсолютных canonical/og:url (раньше жил в
  // корневом app/layout.js; тот убран — html/body теперь только здесь и в
  // app/internal/layout.js, см. комментарий ниже про multiple root layouts).
  return {
    metadataBase: new URL(SITE_URL),
    ...(IS_PRODUCTION ? {} : { robots: { index: false, follow: false } }),
  };
}

// <html>/<body> живут здесь (а не в едином root layout — его нет, см. Next.js
// "multiple root layouts": [locale]/layout.js и internal/layout.js — два
// независимых корня, каждый сам объявляет <html>/<body>), чтобы lang
// резолвился из params.locale на билде — статический рендер сохраняется,
// без headers().
export default async function LocaleLayout({ children, params }) {
  const { locale } = params;
  if (!isEnabledLocale(locale)) notFound();
  const dict = await getDictionary(locale);
  const isRtl = locale === 'ar';
  const bodyFont = isRtl ? notoArabic : poppins;

  return (
    <html lang={locale} dir={isRtl ? 'rtl' : 'ltr'} className={`${teko.variable} ${bodyFont.variable}`}>
      <body>
        {/* LocalBusiness — глобально на каждой странице, не только на homepage. */}
        <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(organizationJsonLd) }} />
        <Script src={`https://www.googletagmanager.com/gtag/js?id=${GOOGLE_ADS_ID}`} strategy="afterInteractive" />
        <Script id="google-ads-gtag" strategy="afterInteractive">
          {`
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', '${GOOGLE_ADS_ID}');
          `}
        </Script>
        <div className="layout-root">
          <Header locale={locale} dict={dict} />
          <main style={{ flex: 1 }}>{children}</main>
          <Footer dict={dict} locale={locale} />
        </div>
      </body>
    </html>
  );
}
