'use client';
// Общий рендер ссылки из CONTACTS для Footer.jsx и about/page.js — оба
// сервер-компоненты, а клику по чат-каналам (wa.me/t.me) нужен client
// boundary для onClick-трекинга, поэтому вынесено сюда.
import { withPrefill, trackChatClick, CHAT_KEYS } from '../../lib/contacts.js';

export default function ContactLink({ contact, prefillMessage, className, children }) {
  const trackable = CHAT_KEYS.has(contact.key);
  const href = trackable ? withPrefill(contact.href, prefillMessage) : contact.href;

  // target="_blank" на чат-ссылках намеренно: не уводит со страницы —
  // событие успевает уйти в GA4 до навигации (на текущей вкладке браузер
  // мог оборвать отправку при переходе на wa.me/t.me).
  return (
    <a
      className={className}
      href={href}
      {...(trackable ? { target: '_blank', rel: 'noopener noreferrer' } : {})}
      onClick={trackable ? () => trackChatClick(contact.key, href) : undefined}
    >
      {children}
    </a>
  );
}
