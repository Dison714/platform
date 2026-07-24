export const metadata = { robots: { index: false, follow: false }, title: 'Insurance admin — internal' };
export const dynamic = 'force-dynamic';

import InsuranceAdminClient from './InsuranceAdminClient.jsx';

export default function InsuranceAdminPage() {
  return <InsuranceAdminClient />;
}
