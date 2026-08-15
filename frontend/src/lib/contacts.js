// Контакты бренда — реальные константы из брифа (не «факты под уточнение»).
export const CONTACTS = [
  { key: 'whatsapp', label: 'WhatsApp', value: '+62 821 464 333 03', href: 'https://wa.me/6282146433303' },
  { key: 'telegram', label: 'Telegram', value: '@Bali_rent_main', href: 'https://t.me/Bali_rent_main' },
  { key: 'instagram', label: 'Instagram', value: '@bali_rents', href: 'https://instagram.com/bali_rents' },
  { key: 'email', label: 'Email', value: 'rentbalibike@gmail.com', href: 'mailto:rentbalibike@gmail.com' },
];
// Префилл сообщения для WhatsApp/Telegram (wa.me и t.me оба поддерживают
// ?text=) — клиенту не нужно печатать с нуля, нам маркер источника лида
// (сайт vs другие каналы), не завязано на конкретный товар/страницу.
export function withPrefill(href, message) {
  if (!message) return href;
  const sep = href.includes('?') ? '&' : '?';
  return `${href}${sep}text=${encodeURIComponent(message)}`;
}

// Чат-каналы — единственные CONTACTS-ссылки с префиллом И с явным
// GA4-трекингом клика (Instagram/email — просто ссылки). Общий Set вместо
// двух копий в Footer.jsx/about/page.js.
export const CHAT_KEYS = new Set(['whatsapp', 'telegram']);

// Явный конверсионный сигнал вместо Enhanced Measurement generic "click":
// свой event name на канал (whatsapp_click/telegram_click), не путается с
// автосбором в отчётах GA4. source различает точку конверсии (footer,
// floating_button, contacts_page, success_screen) для анализа воронки.
export function trackChatClick(key, href, source) {
  if (typeof window.gtag === 'function') {
    window.gtag('event', `${key}_click`, { link_url: href, ...(source ? { source } : {}) });
  }
}
export const ADDRESS = 'Gg. 1 Kerobokan Kelod, Kuta Utara, Badung, Bali';
export const HOURS = '08:00–19:00';
// Сноска к часам работы — не часть openingHours JSON-LD (organization.js
// использует только HOURS), чисто для отображения на About/Footer.
export const HOURS_NOTE = '24/7 by planned request';
