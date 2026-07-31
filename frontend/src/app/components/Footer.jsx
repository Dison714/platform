// Футер: контакты бренда (статичные данные, не из API).
import Link from 'next/link';
import { CONTACTS, withPrefill } from '../../lib/contacts.js';

const ICONS = { whatsapp: '✆', telegram: '✈', instagram: '◎', email: '✉' };
const PREFILL_KEYS = new Set(['whatsapp', 'telegram']); // маркер источника лида — только чаты, не Instagram/email

export default function Footer({ dict, locale }) {
  const year = new Date().getFullYear();
  return (
    <footer className="ftr">
      <div className="container ftr-in">
        <div>
          <h3 className="display">{dict.brand.name}</h3>
          <p>{dict.brand.tagline}</p>
          <p><span className="i" aria-hidden="true">⏱</span>{dict.footer.hours}</p>
          <p className="ftr-note">{dict.footer.hours_note}</p>
          <p><span className="i" aria-hidden="true">📍</span>{dict.footer.address}</p>
        </div>
        <div>
          <h3 className="display">{dict.footer.get_in_touch}</h3>
          {CONTACTS.map((c) => (
            <a
              key={c.key}
              href={PREFILL_KEYS.has(c.key) ? withPrefill(c.href, dict.contact.prefill_message) : c.href}
            >
              <span className="i" aria-hidden="true">{ICONS[c.key]}</span>{c.key === 'email' ? c.value : `${c.label} ${c.value}`}
            </a>
          ))}
        </div>
      </div>
      <div className="ftr-bottom">
        <div className="container">
          © {year} {dict.brand.name}. {dict.footer.rights} · <Link href={`/${locale}/terms`} className="ftr-terms-link">{dict.footer.terms}</Link>
        </div>
      </div>
    </footer>
  );
}
