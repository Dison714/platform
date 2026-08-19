import Link from 'next/link';
import { breadcrumbJsonLd } from '../../lib/seo.js';

// Общий breadcrumb для bikes/[slug] и blog/[slug] (изначально жил только в
// bikes/[slug]/page.js — вынесен сюда при добавлении на blog, чтобы не
// дублировать разметку/JSON-LD между двумя страницами). trail: [{ name,
// path }], последний элемент — текущая страница, не кликабелен. Разделитель
// "/" не переворачивается в RTL вручную — .breadcrumb это flex-контейнер,
// порядок и направление читаются из dir="rtl" на <html> автоматически.
export default function Breadcrumb({ trail }) {
  const breadcrumbLd = breadcrumbJsonLd(trail);
  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbLd) }} />
      <nav className="breadcrumb" aria-label="Breadcrumb">
        {trail.map((step, i) =>
          i === trail.length - 1 ? (
            <span key={step.path} className="breadcrumb-current">{step.name}</span>
          ) : (
            <span key={step.path} className="breadcrumb-step">
              <Link href={step.path}>{step.name}</Link>
              <span className="breadcrumb-sep">/</span>
            </span>
          )
        )}
      </nav>
    </>
  );
}
