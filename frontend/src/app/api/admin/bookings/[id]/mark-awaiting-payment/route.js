import { NextResponse } from 'next/server';
import { backendAdminFetch } from '../../../../../../lib/backendAdminFetch.js';

export async function POST(request, { params }) {
  try {
    const res = await backendAdminFetch(`/api/bookings/${params.id}/mark-awaiting-payment`, { method: 'POST' });
    const data = await res.text();
    return new NextResponse(data, { status: res.status, headers: { 'Content-Type': 'application/json' } });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}
