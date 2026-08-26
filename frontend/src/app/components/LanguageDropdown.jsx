'use client';
import Link from 'next/link';
import { useEffect, useRef, useState } from 'react';

// Компактный языковой селектор: текущий код языка + шеврон, по тапу/клику —
// дропдаун со всеми enabled-локалями. `hrefFor(code)` считает целевой URL
// (в т.ч. spec-случай /blog/[slug] с per-locale slug — см. Header.jsx).
export default function LanguageDropdown({ locale, langs, hrefFor }) {
  const [open, setOpen] = useState(false);
  const rootRef = useRef(null);
  const current = langs.find((l) => l.code === locale) ?? langs[0];

  useEffect(() => {
    if (!open) return;
    const onDocClick = (e) => {
      if (rootRef.current && !rootRef.current.contains(e.target)) setOpen(false);
    };
    const onKey = (e) => { if (e.key === 'Escape') setOpen(false); };
    document.addEventListener('click', onDocClick);
    document.addEventListener('keydown', onKey);
    return () => {
      document.removeEventListener('click', onDocClick);
      document.removeEventListener('keydown', onKey);
    };
  }, [open]);

  return (
    <div className="lang-compact" ref={rootRef}>
      <button
        type="button"
        className="lang-trigger"
        aria-haspopup="listbox"
        aria-expanded={open}
        aria-label="Language"
        onClick={() => setOpen((v) => !v)}
      >
        <svg className="lang-globe" width="14" height="14" viewBox="0 0 16 16" aria-hidden="true">
          <circle cx="8" cy="8" r="7" fill="none" stroke="currentColor" strokeWidth="1.3" />
          <ellipse cx="8" cy="8" rx="3" ry="7" fill="none" stroke="currentColor" strokeWidth="1.3" />
          <ellipse cx="8" cy="8" rx="3" ry="7" fill="none" stroke="currentColor" strokeWidth="1.3" transform="rotate(60 8 8)" />
        </svg>
        <span>{current.code.toUpperCase()}</span>
        <svg className={`lang-chevron${open ? ' up' : ''}`} width="10" height="10" viewBox="0 0 10 10" aria-hidden="true">
          <path d="M1.5 3.5 5 7l3.5-3.5" stroke="currentColor" strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </button>
      {open && (
        <ul className="lang-menu" role="listbox">
          {langs.map((l) => (
            <li key={l.code} role="option" aria-selected={l.code === locale}>
              <Link
                href={hrefFor(l.code)}
                className={l.code === locale ? 'lang-on' : 'lang-off'}
                aria-current={l.code === locale ? 'true' : undefined}
                onClick={() => setOpen(false)}
              >
                {l.label}
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
