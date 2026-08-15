'use client';
// Плавающая кнопка контактов — persistent, монтируется один раз в
// [locale]/layout.js, видна на всех страницах. Переиспользует ContactLink
// (href/prefill/GA4-трекинг), source="floating_button" отличает клики отсюда
// от футера/страницы контактов в отчётах GA4.
import { CONTACTS } from '../../lib/contacts.js';
import ContactLink from './ContactLink.jsx';
import { WhatsAppIcon, TelegramIcon } from './icons/BrandIcons.jsx';

const ICONS = { whatsapp: WhatsAppIcon, telegram: TelegramIcon };
const FLOATING_KEYS = ['whatsapp', 'telegram'];

export default function FloatingContactButton({ dict }) {
  const contacts = CONTACTS.filter((c) => FLOATING_KEYS.includes(c.key));

  return (
    <div className="fcb">
      <span className="fcb-invite">{dict.contact.floating_invite}</span>
      <div className="fcb-btns">
        {contacts.map((c) => {
          const Icon = ICONS[c.key];
          return (
            <ContactLink
              key={c.key}
              contact={c}
              prefillMessage={dict.contact.prefill_message}
              className={`fcb-btn fcb-${c.key}`}
              source="floating_button"
            >
              <Icon size={30} />
              <span className="sr-only">{c.label}</span>
            </ContactLink>
          );
        })}
      </div>
    </div>
  );
}
