import { NextResponse } from 'next/server';

// BFF-прокси: клиентский калькулятор постит на свой origin (/api/quote),
// а мы пересылаем на backend. Так нет CORS, а адрес backend остаётся
// серверным (env API_BASE_URL). Сервер — единственный источник цен.
const BASE = process.env.API_BASE_URL || 'http://localhost:3000';

export async function POST(request) {
  const body = await request.text();
  try {
    const res = await fetch(`${BASE}/api/quote`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body,
      cache: 'no-store',
    });
    const data = await res.text();
    // Пробрасываем статус как есть (400/404/501 → клиент покажет сообщение).
    return new NextResponse(data, {
      status: res.status,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}
