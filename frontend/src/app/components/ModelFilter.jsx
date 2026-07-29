import Link from 'next/link';

// Блок A, третья строка (П.20) — конкретная модель мотоцикла. Показывается
// только внутри группы "Мотоциклы" (см. bikes/page.js), под чипами категорий
// (тип кузова). Фильтрует по product_families.code (?model=), это отдельная
// ось от category — модель однозначна, категория может быть двойной
// (MT-25 — Sport + Naked/Classic, family_filter_categories), поэтому модель
// сама решает, какие products показать, независимо от активной category.
export default function ModelFilter({ locale, families, active, allLabel }) {
  const base = `/${locale}/bikes?group=motorcycle`;
  return (
    <nav className="filter filter-models" aria-label="Motorcycle models">
      <Link href={base} className={`chip chip-model ${!active ? 'on' : ''}`}>{allLabel}</Link>
      {families.map((f) => (
        <Link
          key={f.code}
          href={`${base}&model=${f.code}`}
          className={`chip chip-model ${active === f.code ? 'on' : ''}`}
        >
          {f.name}
        </Link>
      ))}
    </nav>
  );
}
