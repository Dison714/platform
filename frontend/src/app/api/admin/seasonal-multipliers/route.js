import { NextResponse } from 'next/server';
import { backendAdminFetch } from '../../../../lib/backendAdminFetch.js';

// BFF-прокси для /internal/pricing (Blок 2). Basic Auth уже проверен
// middleware'ом на уровне /api/admin/* — сюда долетают только
// аутентифицированные запросы.
export async function GET() {
  try {
    const res = await backendAdminFetch('/api/seasonal-multipliers');
    const data = await res.text();
    return new NextResponse(data, { status: res.status, headers: { 'Content-Type': 'application/json' } });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}

export async function POST(request) {
  const body = await request.text();
  try {
    const res = await backendAdminFetch('/api/seasonal-multipliers', {
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
