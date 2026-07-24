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
export default function ProductVideo({ src }) {
  const [hidden, setHidden] = useState(false);
  const videoRef = useRef(null);

  useEffect(() => {
    if (videoRef.current) videoRef.current.src = src;
  }, [src]);

  if (hidden) return null;
  return (
    <div className="product-video">
      <video ref={videoRef} controls preload="metadata" onError={() => setHidden(true)} />
    </div>
  );
}
