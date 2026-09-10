// 9 SEO-районных страниц (/scooter-rental-<slug>) — общий источник правды
// для Header.jsx (дропдаун "Bali Districts") и [locationSlug]/page.js
// (отображаемое имя района). slug — не всегда однословный (nusa-dua), поэтому
// простой capitalize() первой буквы (как было для одного canggu) больше не
// годится — нужна явная карта slug → имя.
//
// namesByLocale — только для языков, где топоним разумно транслитерировать в
// другую письменность (кириллица/CJK/арабица/деванагари), чтобы {district} в
// переведённых заголовках/FAQ/CTA не подставлял сырой латинский "Canggu"
// посреди русского/японского и т.п. предложения (баг, найденный на живой
// /ru/ странице 2026-09-10 — заголовки блоков и "in Canggu"/"around Uluwatu"
// внутри переведённого текста оставались на английском). Для языков на
// латинице (de/fr/es/it) топоним не меняется — обычная практика для
// индонезийских топонимов без устоявшегося экзонима, namesByLocale не нужен.
export const DISTRICTS = [
  { slug: 'canggu', name: 'Canggu', namesByLocale: { ru: 'Чангу' } },
  { slug: 'seminyak', name: 'Seminyak', namesByLocale: { ru: 'Семиньяк' } },
  { slug: 'ubud', name: 'Ubud', namesByLocale: { ru: 'Убуд' } },
  { slug: 'uluwatu', name: 'Uluwatu', namesByLocale: { ru: 'Улувату' } },
  { slug: 'jimbaran', name: 'Jimbaran', namesByLocale: { ru: 'Джимбаран' } },
  { slug: 'sanur', name: 'Sanur', namesByLocale: { ru: 'Санур' } },
  { slug: 'kuta', name: 'Kuta', namesByLocale: { ru: 'Кута' } },
  { slug: 'nusa-dua', name: 'Nusa Dua', namesByLocale: { ru: 'Нуса-Дуа' } },
  { slug: 'denpasar', name: 'Denpasar', namesByLocale: { ru: 'Денпасар' } },
];

export function districtName(slug, locale) {
  const d = DISTRICTS.find((d) => d.slug === slug);
  if (!d) return slug;
  return d.namesByLocale?.[locale] ?? d.name;
}
