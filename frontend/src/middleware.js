import { NextResponse } from 'next/server';
import { enabledLocales, DEFAULT_LOCALE } from './i18n/config.js';

// /internal/* (админка) и /api/admin/* (её BFF) — не локализуются, закрыты
// Basic Auth. Первая админка в проекте (Блок 2, сезонный мультипликатор) —
// пароль в env INTERNAL_ADMIN_PASSWORD, один общий, без ролей. Временная
// защита на период разработки; см. PROJECT_STATUS.md.
function checkBasicAuth(request) {
  const header = request.headers.get('authorization');
  const expected = process.env.INTERNAL_ADMIN_PASSWORD;
  if (!expected) return false; // не сконфигурирован пароль — доступ закрыт по умолчанию
  if (!header?.startsWith('Basic ')) return false;
  try {
    const decoded = atob(header.slice('Basic '.length));
    const idx = decoded.indexOf(':');
    const password = idx === -1 ? decoded : decoded.slice(idx + 1);
    return password === expected;
  } catch {
    return false;
  }
}

function unauthorized() {
  return new NextResponse('Authentication required', {
    status: 401,
    headers: { 'WWW-Authenticate': 'Basic realm="MDB internal"' },
  });
}

// Любой путь без активного языкового префикса → редирект на /<default>/...
// Структура готова к 7 языкам; сейчас активен только en.
export function middleware(request) {
  const { pathname } = request.nextUrl;

  let response;
  if (pathname.startsWith('/internal') || pathname.startsWith('/api/admin')) {
    response = checkBasicAuth(request) ? NextResponse.next() : unauthorized();
  } else {
    const hasLocale = enabledLocales().some(
      (l) => pathname === `/${l}` || pathname.startsWith(`/${l}/`)
    );
    if (hasLocale) {
      response = NextResponse.next();
    } else {
      const url = request.nextUrl.clone();
      url.pathname = `/${DEFAULT_LOCALE}${pathname === '/' ? '' : pathname}`;
      response = NextResponse.redirect(url);
    }
  }

  // Анонимная cookie для Блока 5 (виджет доступных байков на главной) — ставится
  // один раз при первом визите, живёт год. Не привязана к клиенту (нет
  // аккаунтов у посетителей сайта), нужна только чтобы один и тот же браузер
  // видел стабильную пару карточек в течение 30-минутного окна ротации.
  if (!request.cookies.get('mdb_cid')) {
    response.cookies.set('mdb_cid', crypto.randomUUID(), {
      maxAge: 60 * 60 * 24 * 365,
      path: '/',
      sameSite: 'lax',
    });
  }

  return response;
}

export const config = {
  // Не трогаем остальные API-роуты (BFF-прокси /api/quote, /api/bookings —
  // без локализации, без Basic Auth), _next и статику (в т.ч. фото байков
  // /bikes/*.webp, видео /bikes/*/video.mp4, manifest.webmanifest) — только
  // страницы + /internal + /api/admin. Без исключения расширений/спецфайлов
  // middleware редиректил бы их на /<locale>/... — так уже было с .webp и
  // sitemap.xml/robots.txt, и по той же причине не грузилось video.mp4 (Блок 3).
  matcher: ['/((?!api/(?!admin)|_next|favicon.ico|sitemap.xml|robots.txt|manifest.webmanifest|.*\\.(?:svg|png|ico|webp|jpg|jpeg|gif|avif|mp4)).*)'],
};
