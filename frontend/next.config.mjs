/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Минимальный self-contained билд для контейнерного деплоя (Coolify).
  // Не обязателен для Nixpacks, но безвреден и упрощает будущий переход на Dockerfile.
  output: 'standalone',
  // Фото продуктов придут из CDN позже (сейчас source_url пустые → placeholder).
  // Когда появится CDN-хост, добавить его сюда в images.remotePatterns.
  images: { remotePatterns: [] },
};

export default nextConfig;
