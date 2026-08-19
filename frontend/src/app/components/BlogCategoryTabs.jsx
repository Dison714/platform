'use client';

// Same-page переход к секции по клику (вариант 1 макета) — обычный <a
// href="#slug"> тут не скроллит сам: в этом App Router клик по
// внутристраничному хэшу меняет location.hash, но не двигает scroll
// (проверено вживую, в т.ч. через native element.click(), не только
// синтетический клик тестового окружения — не артефакт автоматизации).
export default function BlogCategoryTabs({ categories }) {
  function handleClick(e, slug) {
    e.preventDefault();
    const el = document.getElementById(slug);
    if (!el) return;
    const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    el.scrollIntoView({ behavior: reduceMotion ? 'auto' : 'smooth' });
    history.replaceState(null, '', `#${slug}`);
  }

  return (
    <nav className="blog-tabs">
      {categories.map((category) => (
        <a
          key={category.slug}
          href={`#${category.slug}`}
          className="blog-tab"
          onClick={(e) => handleClick(e, category.slug)}
        >
          {category.name} <span className="blog-tab-count">· {category.total}</span>
        </a>
      ))}
    </nav>
  );
}
