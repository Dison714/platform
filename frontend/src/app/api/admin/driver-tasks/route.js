import { NextResponse } from 'next/server';
import { backendAdminFetch } from '../../../../lib/backendAdminFetch.js';

// GET /api/admin/driver-tasks?status=&type_code=&scheduled_date= — форвардит
// query как есть.
export async function GET(request) {
  const { search } = new URL(request.url);
  try {
    const res = await backendAdminFetch(`/api/driver-tasks${search}`);
    const data = await res.text();
    return new NextResponse(data, { status: res.status, headers: { 'Content-Type': 'application/json' } });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}

export async function POST(request) {
  const body = await request.text();
  try {
    const res = await backendAdminFetch('/api/driver-tasks', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body,
    });
    const data = await res.text();
    return new NextResponse(data, { status: res.status, headers: { 'Content-Type': 'application/json' } });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}
