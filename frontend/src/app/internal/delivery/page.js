export const metadata = { robots: { index: false, follow: false }, title: 'Delivery admin — internal' };
export const dynamic = 'force-dynamic';

import DeliveryAdminClient from './DeliveryAdminClient.jsx';

export default function DeliveryAdminPage() {
  return <DeliveryAdminClient />;
}
