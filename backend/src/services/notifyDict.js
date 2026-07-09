// Серверный словарь уведомлений менеджеру. Уведомление собирается ЦЕЛИКОМ на
// языке заявки (booking.locale) — без fallback на язык менеджера, без дублей.
// Названия оборудования приходят уже локализованными (equipment_type_translations).
export const NOTIFY = {
  en: {
    lang_name: 'English',
    new_booking: 'New booking',
    lang_label: 'Language',
    days: 'days',
    mo: 'mo',
    calc: 'Breakdown',
    rental: 'Rental',
    delivery: 'Delivery',
    free: 'free',
    theft: 'Insurance: theft',
    bali_only: 'Bali only',
    damage: 'Insurance: damage',
    coverage: 'cover',
    exp: { experienced: 'experienced', inexperienced: 'inexperienced' },
    no_equipment: 'Equipment: —',
    to_pay: 'To pay',
    deposit: 'Deposit (refundable)',
    location_map: 'Location on map',
    location: 'Location',
  },
  ru: {
    lang_name: 'Русский',
    new_booking: 'Новая заявка',
    lang_label: 'Язык',
    days: 'дн.',
    mo: 'мес.',
    calc: 'Расчёт',
    rental: 'Аренда',
    delivery: 'Доставка',
    free: 'бесплатно',
    theft: 'Страховка: угон',
    bali_only: 'только Бали',
    damage: 'Страховка: повреждения',
    coverage: 'покрытие',
    exp: { experienced: 'опытный', inexperienced: 'неопытный' },
    no_equipment: 'Оборудование: —',
    to_pay: 'К оплате',
    deposit: 'Депозит (возврат)',
    location_map: 'Локация на карте',
    location: 'Локация',
  },
};

export function notifyDict(locale) {
  return NOTIFY[locale] ?? NOTIFY.en;
}
