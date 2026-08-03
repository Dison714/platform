'use client';

import { useEffect, useRef } from 'react';

// Блок F: «показать оригинал» — исходный скриншот переписки в WhatsApp.
//
// Зачем вообще: текст карточки — наш перевод английского оригинала, то есть
// слово компании. Скриншот с таймстемпами и галочками — то, что это слово
// подтверждает. Поэтому картинка не декоративная и убирать её нельзя.
//
// Почему картинка не в разметке карточки, а только в диалоге: 7 скриншотов на
// главной — это ~290 КБ поверх LCP ради блока, до которого ещё надо
// доскроллить. <dialog> рендерит содержимое сразу, но src проставляется по
// первому открытию — до клика запроса нет вообще.
//
// Нативный <dialog>.showModal() взят вместо самописного оверлея намеренно:
// фокус-трап, инертность фона, закрытие по Esc и роль dialog — уже в браузере,
// без зависимостей и без ручного aria.
export default function ReviewScreenshot({ src, label, openLabel, closeLabel, originalNote }) {
  const dialogRef = useRef(null);
  const imgRef = useRef(null);

  // Клик по подложке (не по картинке) закрывает — привычное поведение лайтбокса.
  // У <dialog> клик по ::backdrop приходит на сам элемент, поэтому сверяем target.
  useEffect(() => {
    const dlg = dialogRef.current;
    if (!dlg) return;
    const onClick = (e) => { if (e.target === dlg) dlg.close(); };
    dlg.addEventListener('click', onClick);
    return () => dlg.removeEventListener('click', onClick);
  }, []);

  const open = () => {
    if (imgRef.current && !imgRef.current.src) imgRef.current.src = src;
    dialogRef.current?.showModal();
  };

  return (
    <>
      <button type="button" className="review-original-btn" onClick={open}>
        {/* WhatsApp-глиф: источник отзыва виден до открытия, без слова «WhatsApp» в 8 переводах */}
        <svg className="review-original-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
          <path
            fill="currentColor"
            d="M12.04 2C6.58 2 2.13 6.45 2.13 11.91c0 1.75.46 3.45 1.32 4.95L2 22l5.25-1.38a9.9 9.9 0 0 0 4.79 1.22h.01c5.46 0 9.91-4.45 9.91-9.91 0-2.65-1.03-5.14-2.9-7.01A9.82 9.82 0 0 0 12.04 2Zm0 18.15h-.01a8.2 8.2 0 0 1-4.19-1.15l-.3-.18-3.12.82.83-3.04-.2-.31a8.16 8.16 0 0 1-1.26-4.38c0-4.54 3.7-8.24 8.25-8.24a8.2 8.2 0 0 1 8.24 8.25c0 4.54-3.7 8.23-8.24 8.23Zm4.52-6.16c-.25-.12-1.47-.72-1.69-.81-.23-.08-.39-.12-.56.13-.16.24-.64.8-.78.97-.15.16-.29.18-.53.06-.25-.13-1.05-.39-1.99-1.23-.74-.66-1.23-1.47-1.38-1.72-.14-.25-.01-.38.11-.5.11-.11.25-.29.37-.44.13-.15.17-.25.25-.41.08-.17.04-.31-.02-.44-.06-.12-.56-1.34-.76-1.84-.2-.48-.41-.42-.56-.43h-.48c-.16 0-.43.06-.65.31-.22.25-.85.83-.85 2.03s.87 2.35.99 2.51c.12.17 1.71 2.62 4.15 3.67.58.25 1.03.4 1.39.51.58.19 1.11.16 1.53.1.47-.07 1.47-.6 1.67-1.18.21-.58.21-1.07.15-1.18-.06-.11-.22-.17-.47-.29Z"
          />
        </svg>
        {openLabel}
      </button>

      <dialog ref={dialogRef} className="review-dialog" aria-label={label}>
        <div className="review-dialog-inner">
          <form method="dialog">
            <button type="submit" className="review-dialog-close" aria-label={closeLabel}>×</button>
          </form>
          <img ref={imgRef} alt={label} className="review-dialog-img" />
          <p className="review-dialog-note">{originalNote}</p>
        </div>
      </dialog>
    </>
  );
}
