'use client';

import { useState } from 'react';
import Lightbox from 'yet-another-react-lightbox';
import Counter from 'yet-another-react-lightbox/plugins/counter';
import 'yet-another-react-lightbox/styles.css';
import 'yet-another-react-lightbox/plugins/counter.css';
import { resolvePhotoUrl } from '../../lib/photos.js';

// Блок 4: клик по hero/миниатюре открывает fullscreen-просмотр (swipe на
// тач, стрелки/Esc на десктопе, клик вне — всё из коробки yet-another-react-lightbox).
// Видео (Блок 3) сюда не входит осознанно — у него свой fullscreen в нативных
// контролах, отдельная лента.
export default function ProductGallery({ hero, gallery, productName, showPlaceholder, placeholderText }) {
  const [index, setIndex] = useState(-1); // -1 = закрыт

  if (showPlaceholder) {
    return (
      <div className="gallery-main">
        <div className="gallery-ph">
          <span aria-hidden="true" style={{ fontSize: 56 }}>🏍</span>
          <span className="hint">{placeholderText}</span>
        </div>
      </div>
    );
  }

  const photos = [hero, ...gallery];
  // hero-размер (1200w) — крупнейший доступный, используем для всех слайдов лайтбокса.
  const slides = photos.map((ph) => ({ src: resolvePhotoUrl(ph, 'hero') }));

  return (
    <>
      <div className="gallery-main">
        <img
          src={resolvePhotoUrl(hero, 'hero')}
          alt={productName}
          loading="eager"
          width="1200"
          height="900"
          onClick={() => setIndex(0)}
          className="zoomable"
        />
      </div>
      {gallery.length ? (
        <div className="gallery-thumbs">
          {gallery.map((ph, i) => (
            <div className="thumb" key={ph.sort_order} onClick={() => setIndex(i + 1)}>
              <img src={resolvePhotoUrl(ph, 'gallery')} alt="" loading="lazy" width="800" height="600" className="zoomable" />
            </div>
          ))}
        </div>
      ) : null}
      <Lightbox
        open={index >= 0}
        close={() => setIndex(-1)}
        index={index}
        slides={slides}
        plugins={[Counter]}
        controller={{ closeOnBackdropClick: true }}
      />
    </>
  );
}
