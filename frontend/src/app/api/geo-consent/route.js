import { NextResponse } from 'next/server';
import geoip from 'geoip-lite';
import { EEA_UK_CH_COUNTRIES } from '../../../lib/eeaCountries.js';

// Задача 4 (Webvisor, 2026-09-01): баннер решал по locale страницы (de/fr/es/it),
// не по стране визитёра — немецкоязычный турист физически на Бали видел баннер,
// хотя по IP не должен. CF-IPCountry не вариант: Cloudflare-прокси для домена
// сейчас DNS only (см. CLAUDE.md, IPv6-разбирательство), заголовок физически не
// доходит до приложения. Вместо этого — geoip-lite: офлайн MMDB-база в самом
// пакете, без внешних вызовов, смотрит на реальный IP клиента (который и так
// доходит напрямую до Traefik, раз Cloudflare-прокси выключен).
//
// Fail-closed по явному требованию задачи: IP не определился/не распознан —
// requiresConsent: false (баннер НЕ показываем всем подряд на всякий случай,
// это про UX/конверсию, не про сокрытие него — дефолт gtag('consent','default')
// в layout.js для НЕ-EEA стран и так 'granted').
//
// IPv6 сейчас не актуален: AAAA-запись домена снята (CLAUDE.md, сессия
// 2026-08-16) до починки IPv6-маршрута на стороне Contabo — весь трафик идёт
// по IPv4, а geoip-lite's IPv6-покрытие в lite-базе слабое. Если/когда AAAA
// вернут, стоит перепроверить долю IPv6-визитов с lookup=null.
export const dynamic = 'force-dynamic';

function clientIp(request) {
  const xff = request.headers.get('x-forwarded-for');
  if (xff) {
    const first = xff.split(',')[0]?.trim();
    if (first) return first;
  }
  return request.headers.get('x-real-ip') || null;
}

export async function GET(request) {
  const ip = clientIp(request);
  const country = ip ? geoip.lookup(ip)?.country : null;
  const requiresConsent = country ? EEA_UK_CH_COUNTRIES.includes(country) : false;

  return NextResponse.json(
    { requiresConsent, country: country || null },
    { headers: { 'Cache-Control': 'no-store' } }
  );
}
