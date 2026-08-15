import '../globals.css';
import { Suspense } from 'react';
import Script from 'next/script';
import { Teko, Poppins, Noto_Sans_Arabic } from 'next/font/google';
import { notFound } from 'next/navigation';
import { isEnabledLocale, enabledLocales } from '../../i18n/config.js';
import { getDictionary } from '../../i18n/getDictionary.js';
import Header from '../components/Header.jsx';
import Footer from '../components/Footer.jsx';
import FloatingContactButton from '../components/FloatingContactButton.jsx';
import RouteTracker from './analytics/RouteTracker.js';
import { organizationJsonLd } from '../../lib/organization.js';
import { IS_PRODUCTION, SITE_URL } from '../../lib/site.js';

// Google Ads conversion tag — перенесено со старого WordPress-сайта
// (там стоял как GT-KDB22DZQ через Site Kit). Пока без привязки к
// конкретному conversion action — Дмитрий перелинкует в кабинете Google
// Ads после проверки, что тег вообще стреляет на платформе. Не гейтим
// IS_PRODUCTION намеренно: нужно поймать событие на sslip.io-стейджинге
// до DNS-катовера.
const GOOGLE_ADS_ID = 'AW-17065885486';

// GA4-свойство, уже привязанное к тому же Google Ads аккаунту на уровне
// Google (см. PROJECT_STATUS.md, сессия 2026-07-30). gtag.js уже
// загружается один раз для GOOGLE_ADS_ID выше — здесь только ещё один
// gtag('config', ...) на тот же dataLayer, без второй загрузки библиотеки.
// send_page_view:false — Enhanced Measurement автопейджвью не используем,
// page_view шлётся вручную из RouteTracker (в т.ч. на первой загрузке).
const GA4_ID = 'G-S6RSSC9KFW';

// Яндекс.Метрика — устанавливается с нуля, официальный сниппет без
// изменения внутренней логики IIFE. defer:true в опциях init — чтобы
// автоматический первый hit не задвоился с ручным из RouteTracker.
const YANDEX_METRIKA_ID = 111448067;

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
        {/* Yandex.Metrika noscript — обычным JSX, не через next/script, в самое начало body. */}
        <noscript>
          <div>
            <img src={`https://mc.yandex.ru/watch/${YANDEX_METRIKA_ID}`} style={{ position: 'absolute', left: '-9999px' }} alt="" />
          </div>
        </noscript>
        {/* LocalBusiness — глобально на каждой странице, не только на homepage. */}
        <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(organizationJsonLd) }} />
        <Script src={`https://www.googletagmanager.com/gtag/js?id=${GOOGLE_ADS_ID}`} strategy="afterInteractive" />
        <Script id="google-ads-gtag" strategy="afterInteractive">
          {`
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', '${GOOGLE_ADS_ID}');
            gtag('config', '${GA4_ID}', { send_page_view: false });
          `}
        </Script>
        {/* Yandex.Metrika counter — официальный сниппет, IIFE не менялась. defer:true добавлен в init намеренно (см. YANDEX_METRIKA_ID выше). */}
        <Script id="yandex-metrika" strategy="afterInteractive">
          {`
            (function(m,e,t,r,i,k,a){
                m[i]=m[i]||function(){(m[i].a=m[i].a||[]).push(arguments)};
                m[i].l=1*new Date();
                for (var j = 0; j < document.scripts.length; j++) {if (document.scripts[j].src === r) { return; }}
                k=e.createElement(t),a=e.getElementsByTagName(t)[0],k.async=1,k.src=r,a.parentNode.insertBefore(k,a)
            })(window, document,'script','https://mc.yandex.ru/metrika/tag.js?id=${YANDEX_METRIKA_ID}', 'ym');
            ym(${YANDEX_METRIKA_ID}, 'init', {ssr:true, webvisor:true, clickmap:true, ecommerce:"dataLayer", referrer: document.referrer, url: location.href, accurateTrackBounce:true, trackLinks:true, defer:true});
          `}
        </Script>
        <Suspense fallback={null}>
          <RouteTracker yandexId={YANDEX_METRIKA_ID} />
        </Suspense>
        <div className="layout-root">
          <Header locale={locale} dict={dict} />
          <main style={{ flex: 1 }}>{children}</main>
          <Footer dict={dict} locale={locale} />
        </div>
        <FloatingContactButton dict={dict} />
      </body>
    </html>
  );
}
