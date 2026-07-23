// Первая админка в проекте (Блок 2, сезонный мультипликатор цены) —
// прецедент на будущее. Не в навигации, не в sitemap, noindex/nofollow
// (metadata ниже), доступ закрыт Basic Auth в middleware.js.
export const metadata = {
  robots: { index: false, follow: false },
  title: 'Pricing admin — internal',
};

export const dynamic = 'force-dynamic';

import PricingAdminClient from './PricingAdminClient.jsx';

export default function PricingAdminPage() {
  return <PricingAdminClient />;
}
