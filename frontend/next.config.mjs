// Legacy WordPress catalog URLs (/product/bikes-scooters/<category>/<slug>/,
// pre-redesign structure) still get clicks in GSC (baseline 12.09) but 404
// on the current site — no route handles /product/* at all. Mapped from a
// GSC export (Pages report, /product/ filter, 41 URLs) against the current
// products table by Dmitry 2026-09-14. Where the old slug matches exactly
// one current product (by model + color), redirect straight to that product;
// where it's ambiguous (several current color variants could match, e.g.
// "yamaha-nmax-pink" → 3 current pink Nmax products) or the color no longer
// exists in the catalog, redirect to the model's catalog filter instead of
// guessing a specific color (Wayback Machine was rate-limited from this
// environment at the time — could sharpen the 2 highest-click ambiguous
// ones, yamaha-nmax-pink and honda-pcx-cbs-pink, later if useful).
// /product/sell/energiser/energiser-black/ (1 impression, 0 clicks) is not
// a bike page (different path shape, not in bikes-scooters) — intentionally
// excluded, left as 404.
const legacyProductRedirects = [
  // Exact slug matches
  ['yamaha-nmax-red', '/en/bikes/yamaha-nmax-red'],
  ['morbidelli-c252v-black', '/en/bikes/morbidelli-c252v-black'],
  ['yamaha-xmax-green', '/en/bikes/yamaha-xmax-green'],
  ['honda-cb150x-brown', '/en/bikes/honda-cb150x-brown'],
  ['honda-cb150x-green', '/en/bikes/honda-cb150x-green'],
  // Single current candidate for the model (only one product in that family/color)
  ['kawasaki-d-tracker-250-2011', '/en/bikes/kawasaki-dtracker250-black'],
  ['yamaha-byson-150-2012', '/en/bikes/yamaha-byson150-black'],
  ['yamaha-xsr-155-custom', '/en/bikes/yamaha-xsr-custom-black'],
  ['yamaha-xsr-155-total-black-copy', '/en/bikes/yamaha-xsr-total-black'],
  ['yamaha-mt-25-red-box', '/en/bikes/yamaha-mt25-black-red-box'],
  ['honda-adv-abs-2023-black', '/en/bikes/honda-adv-total-black'],
  ['honda-adv-abs-chameleon-green-purple', '/en/bikes/honda-adv-chameleon-abs'],
  ['honda-adv-abs-chameleon', '/en/bikes/honda-adv-chameleon-abs'],
  ['honda-adv-cbs-white-2', '/en/bikes/honda-adv-white'],
  ['yamaha-nmax-keyless-purple', '/en/bikes/yamaha-nmax-purple'],
  ['yamaha-nmax-neo-white', '/en/bikes/yamaha-nmax-neo-s-white-partner'],
  ['yamaha-xmax-tech-chameleon', '/en/bikes/yamaha-xmax-chameleon'],
  ['honda-cbr-250-abs-sp-qs', '/en/bikes/honda-cbr250rr-white-blue'],
  ['kawasaki-zx25r-se', '/en/bikes/kawasaki-zx25r-blue'],
  ['kawasaki-frankenstein-300', '/en/bikes/custom-frankenstein-white'],
  // Ambiguous (multiple current color variants, or color discontinued) —
  // catalog filter for the model, not a guessed color
  ['yamaha-nmax-pink', '/en/bikes?category=yamaha_nmax155'],
  ['honda-pcx-cbs-pink', '/en/bikes?category=honda_pcx160'],
  ['honda-adv-abs-blue', '/en/bikes?category=honda_adv160'],
  ['honda-pcx-cbs-custom', '/en/bikes?category=honda_pcx160'],
  ['yamaha-nmax-sky', '/en/bikes?category=yamaha_nmax155'],
  ['yamaha-scorpio-225-2006', '/en/bikes?category=naked_classic'],
  ['yamaha-xsr-155-black', '/en/bikes?category=naked_classic'],
  ['yamaha-mt-25-black', '/en/bikes?category=sport'],
  ['yamaha-mt-25-red', '/en/bikes?category=sport'],
  ['yamaha-mt-250-black', '/en/bikes?category=sport'],
  ['honda-pcx-abs-pink', '/en/bikes?category=honda_pcx160'],
  ['yamaha-nmax-keyless-green', '/en/bikes?category=yamaha_nmax155'],
  ['yamaha-nmax-neo-gray', '/en/bikes?category=yamaha_nmax155'],
  ['yamaha-xmax-tech-green-2', '/en/bikes?category=yamaha_xmax250'],
  ['yamaha-xmax-tech-green', '/en/bikes?category=yamaha_xmax250'],
  ['kawasaki-versys-x-250-total-black', '/en/bikes?category=touring'],
  ['kawasaki-versys-x-250', '/en/bikes?category=touring'],
  ['suzuki-v-strom-250-abs-black', '/en/bikes?category=touring'],
  ['suzuki-v-strom-250', '/en/bikes?category=touring'],
].map(([slug, destination]) => ({
  source: `/product/bikes-scooters/:category/${slug}`,
  destination,
  permanent: true,
}));

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Минимальный self-contained билд для контейнерного деплоя (Coolify).
  // Не обязателен для Nixpacks, но безвреден и упрощает будущий переход на Dockerfile.
  output: 'standalone',
  // Фото продуктов придут из CDN позже (сейчас source_url пустые → placeholder).
  // Когда появится CDN-хост, добавить его сюда в images.remotePatterns.
  images: { remotePatterns: [] },
  // geoip-lite (задача 4, cookie-consent по IP) грузит свою .dat-базу через
  // fs + __dirname при импорте — webpack-бандлинг ломает эти пути (route
  // молча 404-ился без geoip-lite в external, ни одной ошибки в логе).
  // serverComponentsExternalPackages оставляет пакет как обычный require()
  // из node_modules и (важно для output:'standalone') заставляет трассировщик
  // файлов скопировать его node_modules целиком, а не только статически
  // найденные импорты — иначе .dat-база не попадёт в standalone-билд.
  experimental: {
    serverComponentsExternalPackages: ['geoip-lite'],
  },
  // kawasaki-zx25r-biru → kawasaki-zx25r-blue (slug rename, задача 4b,
  // сессия 2026-09-07): "biru" — индонезийское "синий", утекло на сидинге.
  // Один regex-source покрывает все locale-префиксы разом.
  async redirects() {
    return [
      {
        source: '/:locale(en|ru|de|fr|es|it|ja|ar)/bikes/kawasaki-zx25r-biru',
        destination: '/:locale/bikes/kawasaki-zx25r-blue',
        permanent: true,
      },
      ...legacyProductRedirects,
    ];
  },
};

export default nextConfig;
