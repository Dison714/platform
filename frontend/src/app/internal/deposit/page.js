export const metadata = { robots: { index: false, follow: false }, title: 'Deposit admin — internal' };
export const dynamic = 'force-dynamic';

import DepositAdminClient from './DepositAdminClient.jsx';

export default function DepositAdminPage() {
  return <DepositAdminClient />;
}
