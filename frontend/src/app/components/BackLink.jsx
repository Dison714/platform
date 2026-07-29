'use client';

import { useRouter } from 'next/navigation';

// Назад с карточки товара — на предыдущий экран (список с сохранённым
// фильтром), а не хардкод на /bikes. Фильтр (group/category/model) уже
// целиком живёт в query-параметрах каталога (page.js), поэтому router.back()
// возвращает ровно тот URL, с которого пришли — включая ?category=/?group=/?model=.
// href остаётся настоящей ссылкой на /bikes (без query) как fallback.
//
// document.referrer НЕ годится как признак "пришли ли изнутри сайта" — у
// Next.js клиентские переходы по <Link> идут через History API (pushState),
// а не полную перезагрузку, поэтому document.referrer не обновляется между
// ними и остаётся тем, каким был на первой жёсткой загрузке вкладки
// (проверено: клик по карточке — до сих пор пустой referrer). Настоящий
// признак "есть куда возвращаться в этой вкладке" — window.history.length:
// >1 у обычной SPA-навигации внутри сайта, 1 при прямом заходе на карточку
// (шаренная ссылка, новая вкладка) — тогда используем href как обычно.
export default function BackLink({ href, label }) {
  const router = useRouter();

  function onClick(e) {
    if (window.history.length > 1) {
      e.preventDefault();
      router.back();
    }
    // иначе — обычный переход по href (некуда возвращаться в этой вкладке)
  }

  return (
    <a href={href} className="back-link" onClick={onClick}>
      ← {label}
    </a>
  );
}
