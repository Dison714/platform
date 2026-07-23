import '../globals.css';
import { SITE_URL } from '../../lib/site.js';

// /internal/* — второй независимый root layout (Next.js "multiple root
// layouts"), сиблинг [locale]/layout.js. Не локализуется, не в нав/sitemap —
// свой <html>/<body>, не наследует из [locale]. Общий app/layout.js убран
// (Next.js не поддерживает частичное наследование html между root'ами).
export const metadata = {
  metadataBase: new URL(SITE_URL),
  robots: { index: false, follow: false },
};

export default function InternalLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
