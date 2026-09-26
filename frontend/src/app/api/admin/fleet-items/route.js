import { NextResponse } from 'next/server';
import { backendAdminFetch } from '../../../../lib/backendAdminFetch.js';

// GET /api/admin/fleet-items?product_id=&status= — форвардит query как есть,
// backendAdminFetch переписывает только /api→/api/v1 префикс (regex ^\/api,
// хвост со строкой запроса не трогает).
export async function GET(request) {
  const { search } = new URL(request.url);
  try {
    const res = await backendAdminFetch(`/api/fleet-items${search}`);
    const data = await res.text();
    return new NextResponse(data, { status: res.status, headers: { 'Content-Type': 'application/json' } });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}
