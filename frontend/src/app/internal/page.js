import { redirect } from 'next/navigation';

export const metadata = { robots: { index: false, follow: false } };

// /internal без раздела — раздел по умолчанию.
export default function InternalIndex() {
  redirect('/internal/pricing');
}
