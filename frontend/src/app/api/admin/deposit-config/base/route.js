import { NextResponse } from 'next/server';
import { backendAdminFetch } from '../../../../../lib/backendAdminFetch.js';

export async function PUT(request) {
  const body = await request.text();
  try {
    const res = await backendAdminFetch('/api/deposit-config/base', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body,
    });
    const data = await res.text();
    return new NextResponse(data, { status: res.status, headers: { 'Content-Type': 'application/json' } });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}
