export const metadata = { robots: { index: false, follow: false }, title: 'Bookings admin — internal' };
export const dynamic = 'force-dynamic';

import BookingsAdminClient from './BookingsAdminClient.jsx';

export default function BookingsAdminPage() {
  return <BookingsAdminClient />;
}
