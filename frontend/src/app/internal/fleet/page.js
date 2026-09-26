export const metadata = { robots: { index: false, follow: false }, title: 'Fleet admin — internal' };
export const dynamic = 'force-dynamic';

import FleetAdminClient from './FleetAdminClient.jsx';

export default function FleetAdminPage() {
  return <FleetAdminClient />;
}
