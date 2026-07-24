import '../globals.css';
import { SITE_URL } from '../../lib/site.js';
import InternalNav from './InternalNav.jsx';

// /internal/* — второй независимый root layout (Next.js "multiple root
// layouts"), сиблинг [locale]/layout.js. Не локализуется, не в нав/sitemap —
// свой <html>/<body>, не наследует из [locale]. Общий app/layout.js убран
// (Next.js не поддерживает частичное наследование html между root'ами).
// Configuration First (п.12 ТЗ) — общая навигация между разделами, единая
// для всей панели; Basic Auth на весь /internal/* уже стоит в middleware.js.
export const metadata = {
  metadataBase: new URL(SITE_URL),
  robots: { index: false, follow: false },
};

export default function InternalLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <InternalNav />
        {children}
      </body>
    </html>
  );
}
