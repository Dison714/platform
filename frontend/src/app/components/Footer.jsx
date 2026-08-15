// Футер: контакты бренда (статичные данные, не из API).
import Link from 'next/link';
import { CONTACTS } from '../../lib/contacts.js';
import ContactLink from './ContactLink.jsx';
import { BRAND_ICONS } from './icons/BrandIcons.jsx';

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
          <div className="ftr-contacts">
            {CONTACTS.map((c) => {
              const Icon = BRAND_ICONS[c.key];
              return (
                <ContactLink key={c.key} contact={c} prefillMessage={dict.contact.prefill_message} className="ftr-contact" source="footer">
                  <Icon size={32} />
                  <span className="ftr-contact-text">
                    <span className="ftr-contact-label">{c.label}</span>
                    <span className="ftr-contact-value">{c.value}</span>
                  </span>
                </ContactLink>
              );
            })}
          </div>
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
