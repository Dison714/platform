/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Фото продуктов придут из CDN позже (сейчас source_url пустые → placeholder).
  // Когда появится CDN-хост, добавить его сюда в images.remotePatterns.
  images: { remotePatterns: [] },
};

export default nextConfig;
