export const metadata = { robots: { index: false, follow: false }, title: 'Replacement groups admin — internal' };
export const dynamic = 'force-dynamic';

import ReplacementGroupsAdminClient from './ReplacementGroupsAdminClient.jsx';

export default function ReplacementGroupsAdminPage() {
  return <ReplacementGroupsAdminClient />;
}
