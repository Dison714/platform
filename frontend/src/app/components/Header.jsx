'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useState } from 'react';
import { LOCALES, enabledLocales } from '../../i18n/config.js';

// Шапка: логотип + меню + переключатель языка. На телефоне меню — гамбургер.
export default function Header({ locale, dict }) {
  const [open, setOpen] = useState(false);
  const pathname = usePathname() || `/${locale}`;
  const base = `/${locale}`;

  // Переключение языка: меняем первый сегмент пути на другую локаль,
  // оставаясь на той же странице.
  const switchLocaleHref = (target) => {
    const parts = pathname.split('/');
    parts[1] = target; // [0]='' , [1]=локаль
    return parts.join('/') || `/${target}`;
  };
  const langs = LOCALES.filter((l) => enabledLocales().includes(l.code));
  const links = [
    { href: `${base}`, label: dict.nav.home },
    { href: `${base}/bikes`, label: dict.nav.bikes },
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
