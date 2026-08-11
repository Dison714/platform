'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useEffect, useState } from 'react';
import { LOCALES, enabledLocales } from '../../i18n/config.js';

// /blog/[slug] — единственный раздел с per-locale slug (article_translations.slug,
// в отличие от единого products.slug у /bikes) — просто менять сегмент локали
// в пути (как для остального сайта) там даёт 404/краш (Задача 7). На странице
// статьи резолвим slug для целевого языка через article_id (бэкенд:
// /api/blog/posts/:slug/translations).
const BLOG_ARTICLE_RE = /^\/[a-z]{2}\/blog\/([^/]+)$/;

// Шапка: логотип + меню + переключатель языка. На телефоне меню — гамбургер.
export default function Header({ locale, dict }) {
  const [open, setOpen] = useState(false);
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
  const links = [
    { href: `${base}`, label: dict.nav.home },
    { href: `${base}/bikes`, label: dict.nav.bikes },
    { href: `${base}/blog`, label: dict.nav.blog },
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
          {links.map((l) => (
            <Link key={l.href} href={l.href}>{l.label}</Link>
          ))}
        </nav>

        <div className="hdr-right">
          <span className="lang" role="group" aria-label="Language">
            {langs.map((l, i) => (
              <span key={l.code}>
                {i > 0 && <span className="lang-sep">·</span>}
                <Link
                  href={switchLocaleHref(l.code)}
                  className={l.code === locale ? 'lang-on' : 'lang-off'}
                  aria-current={l.code === locale ? 'true' : undefined}
                >
                  {l.code.toUpperCase()}
                </Link>
              </span>
            ))}
          </span>
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
        {links.map((l) => (
          <Link key={l.href} href={l.href} onClick={() => setOpen(false)}>{l.label}</Link>
        ))}
      </nav>
    </header>
  );
}
