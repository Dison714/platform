// Ссылка на обзор модели (Bike Models) в блоке family_content_translations.
// Аудит индексации 2026-10-03: на статьи Bike Models вели ссылки только из
// индекса блога, у старых статей — из сотен карточек байков (через ссылки
// внутри этого же HTML-блока). Решение Дмитрия (03.10.2026): добавить в блок
// каждой семьи, у которой есть опубликованный обзор, одну ссылку на него.
//
// Одна ссылка на страницу, в начале блока (после вводного абзаца). Текст
// ссылки — переведённый заголовок статьи на языке страницы, slug — per-locale
// (article_translations.slug), оба берутся из БД, а не пишутся руками.
//
// Идемпотентно: прежний <p class="review-link"> заменяется, не дублируется.
// Используется и отдельным apply_review_links.mjs (правка уже залитых данных),
// и apply_family_content.mjs (чтобы повторный прогон не откатил ссылки).

export const REVIEW_LEAD = {
  en: 'Read our full review:',
  ru: 'Читайте наш полный обзор:',
  de: 'Lesen Sie unseren ausführlichen Test:',
  fr: 'Lisez notre test complet :',
  es: 'Lee nuestra reseña completa:',
  it: 'Leggi la nostra recensione completa:',
  ja: '詳しいレビューはこちら：',
  ar: 'اقرأ مراجعتنا الكاملة:',
  ko: '전체 리뷰 읽어보기:',
  hi: 'हमारी पूरी समीक्षा पढ़ें:',
  'zh-Hans': '阅读我们的完整评测：',
};

const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const OLD = /<p class="review-link">[\s\S]*?<\/p>\s*/;

export function injectReviewLink(html, lang, href, title) {
  const lead = REVIEW_LEAD[lang];
  if (!lead) throw new Error(`no REVIEW_LEAD for language ${lang}`);
  const base = html.replace(OLD, '');
  const para = `<p class="review-link"><strong>${esc(lead)}</strong> <a href="${esc(href)}">${esc(title)}</a></p>\n`;
  const i = base.indexOf('</p>');
  if (i === -1) return para + base;
  const end = i + '</p>'.length;
  return `${base.slice(0, end)}\n${para}${base.slice(end).replace(/^\s*/, '')}`;
}

// Опубликованный обзор Bike Models, привязанный к семье (articles.related_product_family_id).
export async function reviewLinkFor(pool, familyId, lang) {
  const { rows } = await pool.query(
    `SELECT t.slug, t.title
       FROM articles a
       JOIN article_categories c ON c.id = a.category_id
       JOIN article_translations t ON t.article_id = a.id AND t.language_code = $2
      WHERE a.related_product_family_id = $1 AND a.status = 'published' AND c.slug = 'bike-models'
      ORDER BY a.display_order, a.slug LIMIT 1`,
    [familyId, lang]
  );
  return rows[0] ? { href: `/${lang}/blog/${rows[0].slug}`, title: rows[0].title } : null;
}

export async function withReviewLink(pool, familyId, lang, html) {
  const link = await reviewLinkFor(pool, familyId, lang);
  return link ? injectReviewLink(html, lang, link.href, link.title) : html;
}
