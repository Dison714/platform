import { DEFAULT_LOCALE } from './config.js';

// Словари грузятся динамически по языку. de/fr/es/it/ja/ar пока копия en.json
// (заглушка — реальный перевод следующим чанком); при незаполненном
// словаре — fallback на en (как на бэкенде с переводами).
const dictionaries = {
  en: () => import('./dictionaries/en.json').then((m) => m.default),
  ru: () => import('./dictionaries/ru.json').then((m) => m.default),
  de: () => import('./dictionaries/de.json').then((m) => m.default),
  fr: () => import('./dictionaries/fr.json').then((m) => m.default),
  es: () => import('./dictionaries/es.json').then((m) => m.default),
  it: () => import('./dictionaries/it.json').then((m) => m.default),
  ja: () => import('./dictionaries/ja.json').then((m) => m.default),
  ar: () => import('./dictionaries/ar.json').then((m) => m.default),
};

export async function getDictionary(locale) {
  const load = dictionaries[locale] ?? dictionaries[DEFAULT_LOCALE];
  return load();
}
