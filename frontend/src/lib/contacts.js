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
export const ADDRESS = 'Gg. 1 Kerobokan Kelod, Kuta Utara, Badung, Bali';
export const HOURS = '08:00–19:00';
// Сноска к часам работы — не часть openingHours JSON-LD (organization.js
// использует только HOURS), чисто для отображения на About/Footer.
export const HOURS_NOTE = '24/7 by planned request';
