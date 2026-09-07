import '../globals.css';
import { Suspense } from 'react';
import Script from 'next/script';
import { Teko, Poppins, Noto_Sans_Arabic, Oswald, Golos_Text, Noto_Sans_Devanagari } from 'next/font/google';
import { notFound } from 'next/navigation';
import { isEnabledLocale, enabledLocales } from '../../i18n/config.js';
import { getDictionary } from '../../i18n/getDictionary.js';
import Header from '../components/Header.jsx';
import Footer from '../components/Footer.jsx';
import FloatingContactButton from '../components/FloatingContactButton.jsx';
import CookieBanner from '../components/CookieBanner.jsx';
import RouteTracker from './analytics/RouteTracker.js';
import { organizationJsonLd } from '../../lib/organization.js';
import { IS_PRODUCTION, SITE_URL } from '../../lib/site.js';
import { EEA_UK_CH_COUNTRIES } from '../../lib/eeaCountries.js';

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
// Ни один не содержит ни одного кириллического глифа (проверено напрямую —
// cmap обоих файлов, ни Teko, ни Poppins не покрывают U+0400-04FF), поэтому
// на ru браузер молча подставлял системный шрифт для всего текста, включая
// заголовки (Webvisor 01.09.2026 — на скриншоте title карточки байка
// заметно "generic" начертание рядом с фирменным на других языках).
// Oswald/Golos Text — визуально близкие аналоги с полной поддержкой
// кириллицы: Oswald — тот же жанр узкого гротеска, что и Teko (обе восходят
// к Alternate Gothic); Golos Text — геометрический гротеск, изначально
// спроектированный как кириллический компаньон именно к Poppins (близкие
// пропорции, скруглённые терминалы). Для ar аналогичная подмена
// --font-poppins на Noto Sans Arabic уже была раньше; --font-teko на ar
// сознательно не подменяли (латиница/кириллица в Teko всё равно нечитаема
// для арабского пользователя, а замены для дисплейного шрифта не искали) —
// не трогаем это здесь, вне рамок задачи.
const teko = Teko({ subsets: ['latin'], weight: ['500', '600'], variable: '--font-teko', display: 'swap' });
const oswaldRu = Oswald({ subsets: ['latin', 'cyrillic'], weight: ['500', '600'], variable: '--font-teko', display: 'swap' });
// --font-teko-brand: сам логотип "BIKE BALI RENT" — всегда латиница, никогда
// не переводится, кириллическое покрытие ему не нужно. Без отдельной
// переменной .logo (className="display logo") наследовал бы --font-teko от
// .display и вместе с ним подмену на Oswald на ru — тот же текст, тот же
// font-size, но у Oswald объективно шире метрики контура, поэтому лого на
// ru визуально крупнее, чем на остальных языках (найдено 2026-09-08).
// Отдельная переменная, всегда = настоящий Teko, независимо от locale —
// подставляется в html className безусловно, ниже. Не переиспользовать
// --font-teko здесь: он ИСКОМО подменяется на ru (см. displayFont) для
// заголовков/переводимого текста, которым кириллица нужна.
const tekoBrand = Teko({ subsets: ['latin'], weight: ['500', '600'], variable: '--font-teko-brand', display: 'swap' });
const poppins = Poppins({ subsets: ['latin'], weight: ['400', '500'], variable: '--font-poppins', display: 'swap' });
const notoArabic = Noto_Sans_Arabic({ subsets: ['arabic'], weight: ['400', '500'], variable: '--font-poppins', display: 'swap' });
const golosRu = Golos_Text({ subsets: ['latin', 'cyrillic'], weight: ['400', '500'], variable: '--font-poppins', display: 'swap' });
// hi (2026-09-07): Poppins не покрывает деванагари (cmap не содержит
// U+0900-097F) — тот же класс проблемы, что у ru/ar, тот же паттерн подмены
// (--font-poppins на Noto Sans Devanagari). В отличие от ko/zh-Hans ниже,
// здесь подмена РЕАЛЬНО работает: Google Fonts отдаёт деванагари как один
// именованный `/* devanagari */`-блок (проверено прямым запросом CSS API
// с Chrome UA) — next/font/google может его самостоятельно захостить через
// subsets:['devanagari'], как и arabic для ar. --font-teko (заголовки)
// сознательно НЕ подменяли, тот же компромисс, что и для ar/ko.
const notoDevanagari = Noto_Sans_Devanagari({ subsets: ['devanagari'], weight: ['400', '500'], variable: '--font-poppins', display: 'swap' });

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
  const isRu = locale === 'ru';
  const isHi = locale === 'hi';
  // ko/zh-Hans НЕ подставляют next/font-объект здесь — см. комментарий у
  // .cjk-system-font в globals.css: next/font/google структурно не может
  // захостить сами глифы хангыля/иероглифов для этих Noto-семейств (ранее
  // ko тихо "работал" на подмене subsets:['latin'], которая на деле не
  // содержит ни одного глифа хангыля — баг обнаружен и исправлен 2026-09-07,
  // см. PROJECT_STATUS.md). poppins здесь покрывает латиницу/цифры в тексте
  // ("Rp 5,500,000" и т.п.), сами иероглифы идут через системный шрифт.
  const bodyFont = isRtl ? notoArabic : isRu ? golosRu : isHi ? notoDevanagari : poppins;
  const displayFont = isRu ? oswaldRu : teko;

  return (
    <html lang={locale} dir={isRtl ? 'rtl' : 'ltr'} className={`${displayFont.variable} ${bodyFont.variable} ${tekoBrand.variable}`}>
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
        {/* Consent Mode v2 — до первого gtag('js'/'config', ...) ниже, чтобы
            gtag.js применил дефолты к самому первому запросу. Порядок вызовов
            не влияет на результат (Google мёржит region-scoped default с
            общим), но оба обязаны стоять раньше config/js по документации.
            EEA/UK — deny-by-default (баннер решает, см. CookieBanner.jsx);
            остальные регионы (включая Индонезию) — grant, баннер не нужен. */}
        <Script id="google-ads-gtag" strategy="afterInteractive">
          {`
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('consent', 'default', {
              'ad_storage': 'denied',
              'ad_user_data': 'denied',
              'ad_personalization': 'denied',
              'analytics_storage': 'denied',
              'region': ${JSON.stringify(EEA_UK_CH_COUNTRIES)},
              'wait_for_update': 500
            });
            gtag('consent', 'default', {
              'ad_storage': 'granted',
              'ad_user_data': 'granted',
              'ad_personalization': 'granted',
              'analytics_storage': 'granted'
            });
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
        <CookieBanner dict={dict} />
      </body>
    </html>
  );
}
