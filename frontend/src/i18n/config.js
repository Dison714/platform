// i18n заложен на 7 языков Phase 1, но АКТИВЕН только en. Добавить язык =
// перенести код в `enabled` + создать словарь dictionaries/<code>.json —
// без переделки роутинга/структуры.
export const LOCALES = [
  { code: 'en', label: 'English', enabled: true },
  { code: 'ru', label: 'Русский', enabled: true },
  { code: 'de', label: 'Deutsch', enabled: false },
  { code: 'fr', label: 'Français', enabled: false },
  { code: 'es', label: 'Español', enabled: false },
  { code: 'it', label: 'Italiano', enabled: false },
  { code: 'ja', label: '日本語', enabled: false },
];

export const DEFAULT_LOCALE = 'en';

export const enabledLocales = () => LOCALES.filter((l) => l.enabled).map((l) => l.code);
export const isEnabledLocale = (code) => enabledLocales().includes(code);
