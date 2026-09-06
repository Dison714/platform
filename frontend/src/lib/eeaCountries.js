// EU/EEA + UK + CH — регион, для которого нужен cookie-баннер (GDPR/UK GDPR/
// швейцарский nFADP). Единый источник для двух мест, которые раньше могли
// разъехаться: gtag('consent','default', {region: [...]}) в
// [locale]/layout.js (кому по умолчанию ставим denied) и /api/geo-consent
// (кому реально показываем баннер, см. Webvisor-задачу 2026-09-01 — раньше
// баннер ошибочно решал по locale страницы, не по стране визитёра).
export const EEA_UK_CH_COUNTRIES = [
  'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR',
  'HU', 'IS', 'IE', 'IT', 'LV', 'LI', 'LT', 'LU', 'MT', 'NL', 'NO', 'PL',
  'PT', 'RO', 'SK', 'SI', 'ES', 'SE', 'CH', 'GB',
];
