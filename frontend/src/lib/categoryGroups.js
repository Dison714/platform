// Блок A (визуальный чанк) — верхний уровень фильтра каталога: "Все" /
// "Скутеры" / "Мотоциклы". Группировка НЕ в БД (vehicle_categories —
// плоский список, "чисто UI-фильтр", CLAUDE.md §3.1) — фиксированная
// таксономия типа кузова, не бизнес-правило, меняющееся через админку,
// поэтому просто здесь, во frontend.
// Yamaha Xmax 250 (макси-скутер) — в "Скутеры", не отдельная группа.
export const CATEGORY_GROUPS = {
  scooter: ['honda_adv160', 'honda_pcx160', 'honda_vario160', 'yamaha_nmax155', 'yamaha_xmax250'],
  motorcycle: ['touring', 'naked_classic', 'sport', 'cruiser', 'neo_retro_roadster'],
};

export function groupOfCategory(code) {
  if (!code) return null;
  for (const [group, codes] of Object.entries(CATEGORY_GROUPS)) {
    if (codes.includes(code)) return group;
  }
  return null;
}

export function categoriesInGroup(group) {
  return CATEGORY_GROUPS[group] ?? null;
}

// Каждая категория в "Скутеры" — ровно одна модель (та самая разбивка
// scooter_filter_split, миграция 028) — в отличие от "Мотоциклы", где одна
// категория = несколько разных моделей. Так что ?category=<scooter code> —
// однозначный по модели URL (кандидат на self-referencing canonical/hub-
// страницу, см. bikes/page.js), а ?category=<motorcycle code> — нет, там
// однозначность даёт только отдельная ось ?model= (ModelFilter).
export const SINGLE_MODEL_CATEGORIES = CATEGORY_GROUPS.scooter;
