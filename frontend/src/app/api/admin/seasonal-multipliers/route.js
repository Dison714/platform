import { NextResponse } from 'next/server';

// BFF-прокси для /internal/pricing (Blок 2). Basic Auth уже проверен
// middleware'ом на уровне /api/admin/* — сюда долетают только
// аутентифицированные запросы.
const BASE = process.env.API_BASE_URL || 'http://localhost:3000';

export async function GET() {
  try {
    const res = await fetch(`${BASE}/api/seasonal-multipliers`, { cache: 'no-store' });
    const data = await res.text();
    return new NextResponse(data, { status: res.status, headers: { 'Content-Type': 'application/json' } });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}

export async function POST(request) {
  const body = await request.text();
  try {
    const res = await fetch(`${BASE}/api/seasonal-multipliers`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body,
      cache: 'no-store',
    });
    const data = await res.text();
    return new NextResponse(data, { status: res.status, headers: { 'Content-Type': 'application/json' } });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}
