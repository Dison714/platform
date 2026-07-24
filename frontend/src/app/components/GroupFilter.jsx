import Link from 'next/link';

// Блок A — верхний уровень фильтра каталога: Все / Скутеры / Мотоциклы.
// Server-friendly ссылки, как и CategoryFilter — активная группа
// подсвечивается, реально фильтрует товары (group резолвится в список
// категорий на сервере в page.js, см. lib/categoryGroups.js).
export default function GroupFilter({ locale, active, dict }) {
  const base = `/${locale}/bikes`;
  const groups = [
    { key: null, label: dict.catalog.all },
    { key: 'scooter', label: dict.catalog.group_scooter },
    { key: 'motorcycle', label: dict.catalog.group_motorcycle },
  ];
  return (
    <nav className="filter filter-groups" aria-label="Vehicle groups">
      {groups.map((g) => (
        <Link
          key={g.key ?? 'all'}
          href={g.key ? `${base}?group=${g.key}` : base}
          className={`chip chip-group ${active === g.key ? 'on' : ''}`}
        >
          {g.label}
        </Link>
      ))}
    </nav>
  );
}
