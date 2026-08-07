'use client';

import { useState } from 'react';
import ReviewScreenshot from './ReviewScreenshot.jsx';
import { resolveReviewScreenshotUrl } from '../../lib/photos.js';

// Блок F — отзывы. Данные реальные (src/data/reviews.json), плейсхолдер удалён.
//
// Формат гибридный, и это осознанный выбор, а не компромисс: в карточке —
// текст, переведённый на все 8 языков (индексируется, читается немцем и
// японцем, ничего не весит), а достоверность — по кнопке «показать оригинал»,
// которая открывает скриншот переписки. Чисто скриншотный блок отвалился бы
// сразу по трём пунктам: не переводится, не индексируется и грузит ~290 КБ в
// главную. Чисто текстовый — ничем не отличается от выдуманного.
//
// Нет rating: в WhatsApp клиент звёзд не ставит, рисовать 5★ = выдумывать.
// По той же причине блок не отдаёт Schema.org Review/aggregateRating —
// разметка на собственных отзывах о себе всё равно не даёт rich-результатов
// (self-serving reviews), а фабриковать оценку ради неё тем более незачем.
//
// Свернуто/развёрнуто — через CSS-класс на <ul>, не через условный рендер:
// все карточки остаются в DOM и с выключенным JS (индексация, скринридеры),
// «свёрнуто» — просто display:none у лишних li начиная с INITIAL_VISIBLE.
const INITIAL_VISIBLE = 6;

export default function Reviews({ title, sub, reviews, locale, labels }) {
  const [expanded, setExpanded] = useState(false);
  if (!reviews?.length) return null;
  const hasMore = reviews.length > INITIAL_VISIBLE;

  return (
    <section className="container block">
      <h2 className="display block-title">{title}</h2>
      <p className="block-sub">{sub}</p>
      <ul className={`reviews-grid${hasMore && !expanded ? ' is-collapsed' : ''}`}>
        {reviews.map((r) => {
          // Текст на языке страницы, иначе оригинал — так новый отзыв можно
          // выложить сразу, а переводы дописать позже, не ломая блок.
          const text = r.text[locale] ?? r.text[r.original_locale];
          const translated = !r.text[locale] || locale !== r.original_locale;
          return (
            <li className="review-card" key={r.id}>
              <blockquote className="review-text">{text}</blockquote>
              <div className="review-foot">
                {r.name ? <span className="review-name">{r.name}</span> : null}
                <ReviewScreenshot
                  src={resolveReviewScreenshotUrl(r.screenshot)}
                  label={labels.screenshot_alt}
                  openLabel={labels.show_original}
                  closeLabel={labels.close}
                  originalNote={translated ? labels.original_note : labels.original_note_same}
                />
              </div>
            </li>
          );
        })}
      </ul>
      {hasMore ? (
        <div className="reviews-more">
          <button
            type="button"
            className="reviews-more-btn"
            aria-expanded={expanded}
            onClick={() => setExpanded((v) => !v)}
          >
            {expanded ? labels.show_less : labels.show_all.replace('{n}', String(reviews.length))}
            <svg className="reviews-more-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
              <path fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" d="M6 9l6 6 6-6" />
            </svg>
          </button>
        </div>
      ) : null}
    </section>
  );
}
