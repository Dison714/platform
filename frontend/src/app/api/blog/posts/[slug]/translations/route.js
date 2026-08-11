import { NextResponse } from 'next/server';

// BFF-прокси: Header.jsx (клиентский компонент) не может звать backend
// напрямую (API_BASE_URL — серверный env, CORS) — тот же паттерн, что и
// /api/quote.
const BASE = process.env.API_BASE_URL || 'http://localhost:3000';

export async function GET(request, { params }) {
  const { slug } = params;
  const lang = request.nextUrl.searchParams.get('lang') || 'en';
  try {
    const res = await fetch(
      `${BASE}/api/blog/posts/${encodeURIComponent(slug)}/translations?lang=${encodeURIComponent(lang)}`,
      { cache: 'no-store' }
    );
    const data = await res.text();
    return new NextResponse(data, {
      status: res.status,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}
