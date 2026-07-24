import Link from 'next/link';

// Чипы категорий из GET /api/categories. Активная — из ?category=.
// Server-friendly: каждый чип — обычная ссылка (SSR, без JS).
// catNames — карта code→локализованное имя (dict.cat); fallback на имя из API.
// group (Блок A) — если задан, сужает видимые чипы до категорий этой группы
// (Скутеры/Мотоциклы) и сохраняет ?group= в ссылках чипов, чтобы верхний
// таб оставался подсвечен при выборе конкретной модели внутри группы.
export default function CategoryFilter({ locale, categories, active, allLabel, catNames = {}, group = null }) {
  const base = `/${locale}/bikes`;
  const visible = group ? categories.filter((c) => group.codes.includes(c.code)) : categories;
  const allHref = group ? `${base}?group=${group.key}` : base;
  return (
    <nav className="filter" aria-label="Categories">
      <Link href={allHref} className={`chip ${!active ? 'on' : ''}`}>{allLabel}</Link>
      {visible.map((c) => (
        <Link
          key={c.code}
          href={`${base}?category=${c.code}${group ? `&group=${group.key}` : ''}`}
          className={`chip ${active === c.code ? 'on' : ''}`}
        >
          {catNames[c.code] ?? c.name}
        </Link>
      ))}
    </nav>
  );
}
