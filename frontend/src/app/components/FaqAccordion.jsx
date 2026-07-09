'use client';
import { useState } from 'react';

// Лёгкий клиентский аккордеон. Контент уже в SSR-разметке (раскрыт для
// SEO/без-JS), JS только сворачивает/разворачивает.
export default function FaqAccordion({ items }) {
  const [open, setOpen] = useState(0);
  return (
    <div className="faq-list">
      {items.map((it, i) => {
        const isOpen = open === i;
        return (
          <div className={`faq-item ${isOpen ? 'open' : ''}`} key={i}>
            <button
              type="button"
              className="faq-q"
              aria-expanded={isOpen}
              onClick={() => setOpen(isOpen ? -1 : i)}
            >
              <span>{it.q}</span>
              <span className="faq-mark" aria-hidden="true">{isOpen ? '−' : '+'}</span>
            </button>
            <div className="faq-a" hidden={!isOpen}>{it.a}</div>
          </div>
        );
      })}
    </div>
  );
}
