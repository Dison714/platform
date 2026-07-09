import { absoluteUrl } from '../lib/site.js';

// Нативный App Router manifest (→ /manifest.webmanifest). Иконки — 192/512
// (минимум PWA-спеки), из того же исходника, что icon.png/apple-icon.png
// (frontend/assets/brand/bbr-logo-source.svg — реальный бренд-лого, не сток).
// theme_color/background_color — существующая брендовая палитра (globals.css:
// --navy #1c2c6e / --bg #ffffff), новый цвет не придуман.
export default function manifest() {
  return {
    name: 'Bike Bali Rent',
    short_name: 'BBR',
    start_url: absoluteUrl('/'),
    display: 'standalone',
    background_color: '#ffffff',
    theme_color: '#1c2c6e',
    icons: [
      { src: '/icon-192.png', sizes: '192x192', type: 'image/png' },
      { src: '/icon-512.png', sizes: '512x512', type: 'image/png' },
    ],
  };
}
