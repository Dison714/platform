'use client';

import { useEffect } from 'react';
import { usePathname, useSearchParams } from 'next/navigation';

// Ручной page_view/hit на монтировании И на каждой смене пути — поэтому в
// layout.js GA4 сконфигурирован с send_page_view:false, а Метрика — с
// defer:true в init: без этого автоматические первые хиты обоих счётчиков
// задвоились бы с этим компонентом. usePathname() в App Router с
// [locale]-сегментом уже включает префикс локали (например /ru/bikes).
export default function RouteTracker({ yandexId }) {
  const pathname = usePathname();
  const searchParams = useSearchParams();

  useEffect(() => {
    const query = searchParams.toString();
    const url = query ? `${pathname}?${query}` : pathname;

    if (typeof window.gtag === 'function') {
      window.gtag('event', 'page_view', { page_path: url });
    }
    if (typeof window.ym === 'function') {
      window.ym(yandexId, 'hit', url);
    }
  }, [pathname, searchParams, yandexId]);

  return null;
}
