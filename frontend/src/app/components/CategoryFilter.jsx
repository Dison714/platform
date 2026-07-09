import Link from 'next/link';

// Чипы категорий из GET /api/categories. Активная — из ?category=.
// Server-friendly: каждый чип — обычная ссылка (SSR, без JS).
// catNames — карта code→локализованное имя (dict.cat); fallback на имя из API.
export default function CategoryFilter({ locale, categories, active, allLabel, catNames = {} }) {
  const base = `/${locale}/bikes`;
  return (
    <nav className="filter" aria-label="Categories">
      <Link href={base} className={`chip ${!active ? 'on' : ''}`}>{allLabel}</Link>
      {categories.map((c) => (
        <Link
          key={c.code}
          href={`${base}?category=${c.code}`}
          className={`chip ${active === c.code ? 'on' : ''}`}
        >
          {catNames[c.code] ?? c.name}
        </Link>
      ))}
    </nav>
  );
}
