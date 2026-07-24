// i18n заложен на 8 языков Phase 1 (ar добавлен 23.07.2026, RTL). Добавить
// язык = перенести код в `enabled` + создать словарь dictionaries/<code>.json —
// без переделки роутинга/структуры.
export const LOCALES = [
  { code: 'en', label: 'English', enabled: true },
  { code: 'ru', label: 'Русский', enabled: true },
  { code: 'de', label: 'Deutsch', enabled: true },
  { code: 'fr', label: 'Français', enabled: true },
  { code: 'es', label: 'Español', enabled: true },
  { code: 'it', label: 'Italiano', enabled: true },
  { code: 'ja', label: '日本語', enabled: true },
  { code: 'ar', label: 'العربية', enabled: true },
];

export const DEFAULT_LOCALE = 'en';

export const enabledLocales = () => LOCALES.filter((l) => l.enabled).map((l) => l.code);
export const isEnabledLocale = (code) => enabledLocales().includes(code);
