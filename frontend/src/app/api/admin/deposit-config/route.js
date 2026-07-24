import { NextResponse } from 'next/server';

const BASE = process.env.API_BASE_URL || 'http://localhost:3000';

export async function GET() {
  try {
    const res = await fetch(`${BASE}/api/deposit-config`, { cache: 'no-store' });
    const data = await res.text();
    return new NextResponse(data, { status: res.status, headers: { 'Content-Type': 'application/json' } });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}
