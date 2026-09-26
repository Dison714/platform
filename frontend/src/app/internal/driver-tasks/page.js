export const metadata = { robots: { index: false, follow: false }, title: 'Driver tasks admin — internal' };
export const dynamic = 'force-dynamic';

import DriverTasksAdminClient from './DriverTasksAdminClient.jsx';

export default function DriverTasksAdminPage() {
  return <DriverTasksAdminClient />;
}
