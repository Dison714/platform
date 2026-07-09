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
  // /bikes/*.webp, manifest.webmanifest) — только страницы. Без исключения
  // расширений/спецфайлов middleware редиректил бы их на /<locale>/... —
  // так уже было с .webp и sitemap.xml/robots.txt, теперь то же с manifest.
  matcher: ['/((?!api|_next|favicon.ico|sitemap.xml|robots.txt|manifest.webmanifest|.*\\.(?:svg|png|ico|webp|jpg|jpeg|gif|avif)).*)'],
};
