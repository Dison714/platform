'use client';
import Link from 'next/link';
import { useEffect, useRef, useState } from 'react';
import { DISTRICTS } from '../../lib/districts.js';

// Десктопный дропдаун "Bali Districts" в nav-desktop — по образцу
// LanguageDropdown.jsx (клик-тоггл, закрытие по клику вовне/Escape).
// guidesLabel/guidesHref — последний пункт списка ("Bali Routes & Guides"),
// временно ведёт на /{locale}/blog (см. Header.jsx).
export default function DistrictsDropdown({ locale, label, guidesLabel, guidesHref }) {
  const [open, setOpen] = useState(false);
  const rootRef = useRef(null);

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
    <div className="districts-dd" ref={rootRef}>
      <button
        type="button"
        className="districts-trigger"
        aria-haspopup="true"
        aria-expanded={open}
        onClick={() => setOpen((v) => !v)}
      >
        {label}
        <svg className={`lang-chevron${open ? ' up' : ''}`} width="10" height="10" viewBox="0 0 10 10" aria-hidden="true">
          <path d="M1.5 3.5 5 7l3.5-3.5" stroke="currentColor" strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </button>
      {open && (
        <ul className="districts-menu" role="menu">
          {DISTRICTS.map((d) => (
            <li key={d.slug} role="none">
              <Link role="menuitem" href={`/${locale}/scooter-rental-${d.slug}`} onClick={() => setOpen(false)}>{d.name}</Link>
            </li>
          ))}
          <li className="districts-menu-sep" role="none">
            <Link role="menuitem" href={guidesHref} onClick={() => setOpen(false)}>{guidesLabel}</Link>
          </li>
        </ul>
      )}
    </div>
  );
}
