import { DEFAULT_LOCALE } from './config.js';

// Словари грузятся динамически по языку. Активны en + ru; при незаполненном
// словаре — fallback на en (как на бэкенде с переводами).
const dictionaries = {
  en: () => import('./dictionaries/en.json').then((m) => m.default),
  ru: () => import('./dictionaries/ru.json').then((m) => m.default),
};

export async function getDictionary(locale) {
  const load = dictionaries[locale] ?? dictionaries[DEFAULT_LOCALE];
  return load();
}
