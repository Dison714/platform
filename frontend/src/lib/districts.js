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
//
// ja/ko/zh-Hans/ar/hi дозаполнены 2026-09-10 (сессия с гео-страницей
// Аэропорта) — до этого в карте была только ru, остальные 4 нелатинских
// языка молча показывали английское имя района в заголовках секций
// ("the Airportへの配送" вместо "空港への配送" — баг всплыл при первой же
// проверке новой airport-страницы на ja, но затрагивал все 9 существующих
// районов на ja/ko/zh-Hans/ar/hi с самого запуска гео-страниц). Значения —
// те же d.name, что уже используются в FAQ/CTA каждого языкового файла
// (backend/scripts/i18n_location_pages/*.mjs) для этих районов, не новый
// перевод.
export const DISTRICTS = [
  { slug: 'canggu', name: 'Canggu', namesByLocale: { ru: 'Чангу', ja: 'チャング', ko: '창구', 'zh-Hans': '芝安古', ar: 'تشانغو', hi: 'चांगू' } },
  { slug: 'seminyak', name: 'Seminyak', namesByLocale: { ru: 'Семиньяк', ja: 'スミニャック', ko: '스미냑', 'zh-Hans': '水明漾', ar: 'سيمينياك', hi: 'सेमिन्याक' } },
  { slug: 'ubud', name: 'Ubud', namesByLocale: { ru: 'Убуд', ja: 'ウブド', ko: '우붓', 'zh-Hans': '乌布', ar: 'أوبود', hi: 'उबुद' } },
  { slug: 'uluwatu', name: 'Uluwatu', namesByLocale: { ru: 'Улувату', ja: 'ウルワツ', ko: '울루와투', 'zh-Hans': '乌鲁瓦图', ar: 'أولوواتو', hi: 'उलुवातु' } },
  { slug: 'jimbaran', name: 'Jimbaran', namesByLocale: { ru: 'Джимбаран', ja: 'ジンバラン', ko: '짐바란', 'zh-Hans': '金巴兰', ar: 'جيمباران', hi: 'जिम्बरान' } },
  { slug: 'sanur', name: 'Sanur', namesByLocale: { ru: 'Санур', ja: 'サヌール', ko: '사누르', 'zh-Hans': '沙努尔', ar: 'سانور', hi: 'सानूर' } },
  { slug: 'kuta', name: 'Kuta', namesByLocale: { ru: 'Кута', ja: 'クタ', ko: '쿠타', 'zh-Hans': '库塔', ar: 'كوتا', hi: 'कुटा' } },
  { slug: 'nusa-dua', name: 'Nusa Dua', namesByLocale: { ru: 'Нуса-Дуа', ja: 'ヌサドゥア', ko: '누사두아', 'zh-Hans': '努沙杜瓦', ar: 'نوسا دوا', hi: 'नुसा दुआ' } },
  { slug: 'denpasar', name: 'Denpasar', namesByLocale: { ru: 'Денпасар', ja: 'デンパサール', ko: '덴파사르', 'zh-Hans': '登巴萨', ar: 'دينباسار', hi: 'डेनपासार' } },
  // ru here is nominative "Аэропорт" (nav/section-title form, matching the
  // other 9 entries' dictionary form) — NOT the .mjs files' d.name
  // ('аэропорту', prepositional, used only inside their own CTA/FAQ sentence
  // templates). Ubud has the same split: 'Убуд' here vs 'Убуде' there.
  // Unlike the other 9 (real toponyms with no established exonym, so
  // de/fr/es/it deliberately keep them in Latin per the file-level comment
  // above), "airport" is an ordinary noun with a normal translation in
  // every language — de/fr/es/it get their own namesByLocale entry too,
  // rather than falling back to the English `name`.
  { slug: 'airport', name: 'Airport', namesByLocale: { ru: 'Аэропорт', de: 'Flughafen', fr: 'Aéroport', es: 'Aeropuerto', it: 'Aeroporto', ja: '空港', ko: '공항', 'zh-Hans': '机场', ar: 'المطار', hi: 'एयरपोर्ट' } },
];

export function districtName(slug, locale) {
  const d = DISTRICTS.find((d) => d.slug === slug);
  if (!d) return slug;
  return d.namesByLocale?.[locale] ?? d.name;
}
