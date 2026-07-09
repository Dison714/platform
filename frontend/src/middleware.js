import { NextResponse } from 'next/server';
import { enabledLocales, DEFAULT_LOCALE } from './i18n/config.js';

// Любой путь без активного языкового префикса → редирект на /<default>/...
// Структура готова к 7 языкам; сейчас активен только en.
export function middleware(request) {
  const { pathname } = request.nextUrl;
  const hasLocale = enabledLocales().some(
    (l) => pathname === `/${l}` || pathname.startsWith(`/${l}/`)
  );
  if (hasLocale) return NextResponse.next();

  const url = request.nextUrl.clone();
  url.pathname = `/${DEFAULT_LOCALE}${pathname === '/' ? '' : pathname}`;
  return NextResponse.redirect(url);
}

export const config = {
  // Не трогаем API-роуты (BFF-прокси), _next и статику (в т.ч. фото байков
  // /bikes/*.webp) — только страницы. Без исключения .webp middleware
  // редиректил бы картинки на /<locale>/... и ломал галерею.
  matcher: ['/((?!api|_next|favicon.ico|.*\\.(?:svg|png|ico|webp|jpg|jpeg|gif|avif)).*)'],
};
