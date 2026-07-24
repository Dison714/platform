// Блок F (визуальный чанк) — блок отзывов. Данные СЕЙЧАС плейсхолдерные
// (src/data/reviews.placeholder.json, явно помечено) — реальные отзывы
// добавляются вручную Claude Code в следующих сессиях по мере поступления
// от Дмитрия. Нет формы/админки — не нужна для разового добавления руками.
// Instagram/Meta API — сознательно не подключено, отложено.
export default function Reviews({ title, sub, reviews }) {
  if (!reviews?.length) return null;
  return (
    <section className="container block">
      <h2 className="display block-title">{title}</h2>
      <p className="block-sub">{sub}</p>
      <div className="reviews-grid">
        {reviews.map((r, i) => (
          <div className="review-card" key={i}>
            <div className="review-head">
              <span className="review-avatar" aria-hidden="true">{r.name.charAt(0)}</span>
              <div>
                <div className="review-name">{r.name}</div>
                <div className="review-date">{r.date}</div>
              </div>
            </div>
            {r.rating ? (
              <div className="review-rating" aria-label={`${r.rating}/5`}>
                {'★'.repeat(r.rating)}{'☆'.repeat(5 - r.rating)}
              </div>
            ) : null}
            <p className="review-text">{r.text}</p>
          </div>
        ))}
      </div>
    </section>
  );
}
