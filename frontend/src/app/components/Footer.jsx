// Футер: контакты бренда (статичные данные, не из API).
import Link from 'next/link';
import { CONTACTS } from '../../lib/contacts.js';
import ContactLink from './ContactLink.jsx';

const ICONS = { whatsapp: '✆', telegram: '✈', instagram: '◎', email: '✉' };

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
            <ContactLink key={c.key} contact={c} prefillMessage={dict.contact.prefill_message}>
              <span className="i" aria-hidden="true">{ICONS[c.key]}</span>{c.key === 'email' ? c.value : `${c.label} ${c.value}`}
            </ContactLink>
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
