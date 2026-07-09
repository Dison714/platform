import { NextResponse } from 'next/server';

// BFF-прокси для приёма заявки: клиент постит на свой origin (/api/bookings),
// пересылаем на backend (нет CORS, адрес backend — серверный env).
// Бэкенд сам пересчитывает цену и сам шлёт Telegram менеджерам — фронт не дублирует.
const BASE = process.env.API_BASE_URL || 'http://localhost:3000';

export async function POST(request) {
  const body = await request.text();
  try {
    const res = await fetch(`${BASE}/api/bookings`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body,
      cache: 'no-store',
    });
    const data = await res.text();
    return new NextResponse(data, {
      status: res.status,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}
