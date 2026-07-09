import './globals.css';
import { SITE_URL } from '../lib/site.js';

// metadataBase — основа для абсолютных canonical/og:url на всех страницах.
export const metadata = {
  metadataBase: new URL(SITE_URL),
};

// Root layout — сквозной: <html>/<body> отрисовывает [locale]/layout.js, где
// доступен params.locale. Так lang резолвится из сегмента на билде (без headers()),
// а static rendering страниц сохраняется.
export default function RootLayout({ children }) {
  return children;
}
