import { NextResponse } from 'next/server';
import { backendAdminFetch } from '../../../../lib/backendAdminFetch.js';

// GET /api/admin/equipment-options — тот же публичный список, что видит
// Calculator.jsx на сайте (GET /api/equipment, is_customer_addon=true),
// переиспользуется в /internal/bookings ("Создать заявку", Раздел 5А) и
// /internal/driver-tasks (мульти-select оборудования, Раздел 5D).
// Публичный эндпоинт не требует X-Internal-Admin-Token, но идём через
// тот же backendAdminFetch (единая точка префикса /api → /api/v1).
export async function GET(request) {
  const { search } = new URL(request.url);
  try {
    const res = await backendAdminFetch(`/api/equipment${search}`);
    const data = await res.text();
    return new NextResponse(data, { status: res.status, headers: { 'Content-Type': 'application/json' } });
  } catch {
    return NextResponse.json({ error: 'upstream_unreachable' }, { status: 502 });
  }
}
