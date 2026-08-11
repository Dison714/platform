'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { DEFAULT_LOCALE, isEnabledLocale } from '../../i18n/config.js';

// Рендерится ВНУТРИ [locale]/layout.js (тот же <html>/<body>, Header/Footer)
// — не отдельный root-узел, иначе HierarchyRequestError (Задача 7: до этого
// файла notFound() из blog/[slug]/page.js падал на дефолтный Next-фоллбек,
// который ломал DOM при отсутствии root app/layout.js). not-found.js не
// получает params от Next.js, поэтому локаль читаем из pathname — тот же
// приём, что и в Header.jsx. dir=rtl не дублируем — уже стоит на <html> из
// layout.js (params.locale там валиден, раз мы вообще внутри него).
const COPY = {
  en: { title: 'Page not found', message: "Sorry, we couldn't find this page.", back: 'Back to Blog' },
  ru: { title: 'Страница не найдена', message: 'К сожалению, мы не смогли найти эту страницу.', back: 'Вернуться в блог' },
  de: { title: 'Seite nicht gefunden', message: 'Diese Seite konnte leider nicht gefunden werden.', back: 'Zurück zum Blog' },
  fr: { title: 'Page introuvable', message: "Désolé, nous n'avons pas trouvé cette page.", back: 'Retour au blog' },
  es: { title: 'Página no encontrada', message: 'Lo sentimos, no pudimos encontrar esta página.', back: 'Volver al blog' },
  it: { title: 'Pagina non trovata', message: 'Siamo spiacenti, non abbiamo trovato questa pagina.', back: 'Torna al blog' },
  ja: { title: 'ページが見つかりません', message: '申し訳ございません、このページは見つかりませんでした。', back: 'ブログに戻る' },
  ar: { title: 'الصفحة غير موجودة', message: 'عذرًا، لم نتمكن من العثور على هذه الصفحة.', back: 'العودة إلى المدونة' },
};

export default function LocaleNotFound() {
  const pathname = usePathname() || `/${DEFAULT_LOCALE}`;
  const seg = pathname.split('/')[1];
  const locale = isEnabledLocale(seg) ? seg : DEFAULT_LOCALE;
  const copy = COPY[locale] ?? COPY[DEFAULT_LOCALE];

  return (
    <div className="container page">
      <h1 className="display page-h1">{copy.title}</h1>
      <p className="lede">{copy.message}</p>
      <p><Link href={`/${locale}/blog`}>{copy.back}</Link></p>
    </div>
  );
}
