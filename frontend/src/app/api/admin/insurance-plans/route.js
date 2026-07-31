import { NextResponse } from 'next/server';
import { backendAdminFetch } from '../../../../lib/backendAdminFetch.js';

// BFF-прокси для /internal/insurance. Basic Auth уже проверен middleware'ом
// на уровне /api/admin/*.
export async function GET() {
  try {
    const res = await backendAdminFetch('/api/insurance-plans');
    const data = await res.text();
    return new NextResponse(data, { status: res.status, headers: { 'Content-Type': 'application/json' } });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}
