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
};

export default nextConfig;
