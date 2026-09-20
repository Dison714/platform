'use client';

import { useEffect, useRef, useState } from 'react';

// Блок 3: видео карточки товара — без признака в схеме, рендерим только
// если файл физически существует (проверка браузером при загрузке, не
// сервером — иначе лишний HEAD-запрос на каждый SSR-рендер страницы).
// Нет видео → onError скрывает блок целиком, ничего не меняется для
// остальных products.
//
// src ставится через useEffect, а не сразу в JSX: если отдать его в SSR-разметку,
// браузер начинает грузить video ещё во время парсинга HTML, до гидратации —
// на 404 error-событие успевает произойти раньше, чем React повесит обработчик,
// и onError молча теряется (проверено: ошибка на видео реально была, но
// компонент не скрывался). Простановка src после mount гарантирует, что
// слушатель уже активен к началу загрузки.
export default function ProductVideo({ src, poster, className }) {
  const [hidden, setHidden] = useState(false);
  const [inView, setInView] = useState(false);
  const containerRef = useRef(null);
  const videoRef = useRef(null);

  // Найдено PSI 2026-09-19: со статьёй из 12 клипов подряд браузер ставит
  // ВСЕ 12 постеров (и, судя по network-логу PSI, начинает диапазонные
  // запросы к самим .mp4 при preload="metadata") в очередь сразу при
  // разборе HTML — они конкурируют за полосу с featured-фото статьи
  // (LCP-элементом) на throttled-мобильной сети, хотя сами находятся ниже
  // сгиба. IntersectionObserver откладывает и poster, и src до реального
  // приближения к вьюпорту — на карточках товара (обычно в первом экране)
  // это сработает почти сразу, разницы не будет.
  useEffect(() => {
    if (!containerRef.current || typeof IntersectionObserver === 'undefined') {
      setInView(true);
      return;
    }
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0]?.isIntersecting) {
          setInView(true);
          observer.disconnect();
        }
      },
      { rootMargin: '300px' }
    );
    observer.observe(containerRef.current);
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    if (inView && videoRef.current) videoRef.current.src = src;
  }, [inView, src]);

  if (hidden) return null;
  // <span>, not <div>: when this renders inside article Markdown content
  // (ArticleMedia in blog/[slug]/page.js), remark-gfm wraps a lone image
  // node in a <p> — a <div> there is invalid (flow content inside a
  // phrasing-content-only parent), so the browser's HTML parser silently
  // closes the <p> early, restructuring the parsed DOM out from under
  // React's hydration and throwing #418/#423 on every one of the 12 Versys
  // clips (found live, 2026-09-20: src/poster stuck empty forever — React
  // gives up hydrating a mismatched subtree, so the mount effect that sets
  // them never runs). <span> is phrasing content, valid in both this
  // context and the plain product-page usage; `display: block` in
  // globals.css keeps the same box behavior a <div> had.
  return (
    <span ref={containerRef} className={className ? `product-video ${className}` : 'product-video'}>
      <video
        ref={videoRef}
        controls
        preload="none"
        poster={inView ? poster : undefined}
        playsInline
        onError={() => setHidden(true)}
      />
    </span>
  );
}
