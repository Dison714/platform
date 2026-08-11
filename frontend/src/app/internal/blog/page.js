export const metadata = { robots: { index: false, follow: false }, title: 'Blog admin — internal' };
export const dynamic = 'force-dynamic';

import BlogAdminClient from './BlogAdminClient.jsx';

export default function BlogAdminPage() {
  return <BlogAdminClient />;
}
