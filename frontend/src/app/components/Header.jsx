'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useEffect, useState } from 'react';
import { LOCALES, enabledLocales } from '../../i18n/config.js';
import { DISTRICTS } from '../../lib/districts.js';
import LanguageDropdown from './LanguageDropdown.jsx';
import DistrictsDropdown from './DistrictsDropdown.jsx';

// /blog/[slug] — единственный раздел с per-locale slug (article_translations.slug,
// в отличие от единого products.slug у /bikes) — просто менять сегмент локали
// в пути (как для остального сайта) там даёт 404/краш (Задача 7). На странице
// статьи резолвим slug для целевого языка через article_id (бэкенд:
// /api/blog/posts/:slug/translations).
// [a-zA-Z-]+ (не жёстко [a-z]{2}) — с zh-Hans локаль перестала быть ровно
// двумя строчными буквами (2026-09-07, hi/zh-Hans).
const BLOG_ARTICLE_RE = /^\/[a-zA-Z-]+\/blog\/([^/]+)$/;

// Шапка: логотип + меню + переключатель языка. На телефоне меню — гамбургер.
export default function Header({ locale, dict }) {
  const [open, setOpen] = useState(false);
  const [districtsOpen, setDistrictsOpen] = useState(false);
  const pathname = usePathname() || `/${locale}`;
  const base = `/${locale}`;

  const articleSlug = pathname.match(BLOG_ARTICLE_RE)?.[1] ?? null;
  const [articleTranslations, setArticleTranslations] = useState(null);

  useEffect(() => {
    if (!articleSlug) {
      setArticleTranslations(null);
      return;
    }
    let cancelled = false;
    setArticleTranslations(null);
    fetch(`/api/blog/posts/${encodeURIComponent(articleSlug)}/translations?lang=${encodeURIComponent(locale)}`)
      .then((res) => (res.ok ? res.json() : { data: [] }))
      .then(({ data }) => { if (!cancelled) setArticleTranslations(data ?? []); })
      .catch(() => { if (!cancelled) setArticleTranslations([]); });
    return () => { cancelled = true; };
  }, [articleSlug, locale]);

  // Переключение языка: на странице статьи блога — резолв slug'а под целевой
  // язык (см. BLOG_ARTICLE_RE выше); пока перевод не подгружен или его нет —
  // fallback на /{target}/blog, а не угадывание чужого slug'а. На остальных
  // страницах — просто меняем первый сегмент пути, оставаясь на той же странице
  // (slug там единый для всех локалей).
  const switchLocaleHref = (target) => {
    if (articleSlug) {
      if (!articleTranslations) return `/${target}/blog`;
      const match = articleTranslations.find((t) => t.language_code === target);
      return match ? `/${target}/blog/${match.slug}` : `/${target}/blog`;
    }
    const parts = pathname.split('/');
    parts[1] = target; // [0]='' , [1]=локаль
    return parts.join('/') || `/${target}`;
  };
  const langs = LOCALES.filter((l) => enabledLocales().includes(l.code));
  // "Bali Routes & Guides" — временно на /blog (см. ЗАДАЧА п.2), заменить на
  // /blog/routes, когда появится эта категория блога.
  const guidesHref = `${base}/blog`;
  const linksBefore = [
    { href: `${base}`, label: dict.nav.home },
    { href: `${base}/bikes`, label: dict.nav.bikes },
    { href: `${base}/blog`, label: dict.nav.blog },
  ];
  const linksAfter = [
    { href: `${base}/about`, label: dict.nav.about },
    { href: `${base}/faq`, label: dict.nav.faq },
    { href: `${base}/about#contact`, label: dict.nav.contact },
  ];

  return (
    <header className="hdr">
      <div className="container hdr-in">
        <Link href={`${base}/bikes`} className="display logo" aria-label={dict.brand.name}>
          BIKE BALI <b>RENT</b>
        </Link>
        <span className="hdr-tagline">{dict.brand.tagline}</span>

        <nav className="nav-desktop" aria-label="Main">
          {linksBefore.map((l) => (
            <Link key={l.href} href={l.href}>{l.label}</Link>
          ))}
          <DistrictsDropdown locale={locale} label={dict.nav.districts} guidesLabel={dict.nav.districts_guides} guidesHref={guidesHref} />
          {linksAfter.map((l) => (
            <Link key={l.href} href={l.href}>{l.label}</Link>
          ))}
        </nav>

        <div className="hdr-right">
          {/* Языковой переключатель — единый компактный дропдаун на всех ширинах
              (см. globals.css): фиксированная ширина (текущий код + шеврон), не
              растёт с числом языков — раньше на десктопе был плоский список
              EN·RU·DE·... (см. git-историю), упирался в nav-desktop при длинных
              лейблах (ES/DE/FR/IT) и рос с каждым новым языком. */}
          <Link href={`${base}/bikes`} className="hdr-cta">
            <span className="hdr-cta-text">{dict.home.cta_btn}</span>
          </Link>
          <LanguageDropdown locale={locale} langs={langs} hrefFor={switchLocaleHref} />
          <button
            className="burger"
            aria-label="Menu"
            aria-expanded={open}
            onClick={() => setOpen((v) => !v)}
          >
            {open ? '×' : '☰'}
          </button>
        </div>
      </div>

      <nav className={`nav-mobile ${open ? 'open' : ''}`} aria-label="Mobile">
        {linksBefore.map((l) => (
          <Link key={l.href} href={l.href} onClick={() => setOpen(false)}>{l.label}</Link>
        ))}
        {/* Мобильный "Bali Districts" — не попап (тому негде открыться поверх
            fixed-панели меню), а инлайн-раскрытие подсписка, тот же паттерн
            toggle, что у бургера самой шапки. */}
        <button
          type="button"
          className="nav-mobile-districts-toggle"
          aria-expanded={districtsOpen}
          onClick={() => setDistrictsOpen((v) => !v)}
        >
          {dict.nav.districts}
          <svg className={`lang-chevron${districtsOpen ? ' up' : ''}`} width="10" height="10" viewBox="0 0 10 10" aria-hidden="true">
            <path d="M1.5 3.5 5 7l3.5-3.5" stroke="currentColor" strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </button>
        {districtsOpen && (
          <div className="nav-mobile-districts-list">
            {DISTRICTS.map((d) => (
              <Link key={d.slug} href={`${base}/scooter-rental-${d.slug}`} onClick={() => setOpen(false)}>{d.name}</Link>
            ))}
            <Link href={guidesHref} onClick={() => setOpen(false)}>{dict.nav.districts_guides}</Link>
          </div>
        )}
        {linksAfter.map((l) => (
          <Link key={l.href} href={l.href} onClick={() => setOpen(false)}>{l.label}</Link>
        ))}
      </nav>
    </header>
  );
}
