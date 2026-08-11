'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

// Общая навигация Configuration First-панели (п.12 ТЗ) — единообразная
// связка между разделами вместо 5 разрозненных страниц. Табы, не сайдбар:
// проще для 5 пунктов, не нужен отдельный layout-контейнер с фиксированной
// шириной колонки.
const SECTIONS = [
  { href: '/internal/pricing', label: 'Сезонные цены' },
  { href: '/internal/insurance', label: 'Страховка' },
  { href: '/internal/delivery', label: 'Доставка' },
  { href: '/internal/deposit', label: 'Депозит' },
  { href: '/internal/replacement-groups', label: 'Replacement Groups' },
  { href: '/internal/blog', label: 'Blog' },
];

export default function InternalNav() {
  const pathname = usePathname();
  return (
    <nav
      style={{
        display: 'flex',
        gap: 4,
        borderBottom: '1px solid #ddd',
        padding: '0 20px',
        fontFamily: 'system-ui, sans-serif',
        overflowX: 'auto',
      }}
    >
      {SECTIONS.map((s) => {
        const active = pathname === s.href;
        return (
          <Link
            key={s.href}
            href={s.href}
            style={{
              padding: '14px 16px',
              textDecoration: 'none',
              whiteSpace: 'nowrap',
              color: active ? '#1a2b6d' : '#666',
              borderBottom: active ? '2px solid #1a2b6d' : '2px solid transparent',
              fontWeight: active ? 600 : 400,
              fontSize: 14,
            }}
          >
            {s.label}
          </Link>
        );
      })}
    </nav>
  );
}
