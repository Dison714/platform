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

// Без crypto.randomUUID() — не гарантирован во всех self-hosted Edge Runtime
// сборках (упавший middleware в проде выглядит как "no available server" на
// Traefik, а не как обычная страница ошибки). Не криптографический контекст
// (анонимный id только для стабильности ротации виджета), Math.random() достаточно.
function randomId() {
  return `${Date.now().toString(36)}-${Math.random().toString(36).slice(2)}`;
}

// Разбор Accept-Language в список {tag, q}, отсортированный по убыванию
// приоритета браузера. Некорректный/отсутствующий q считаем как 1.
function parseAcceptLanguage(header) {
  if (!header) return [];
  return header
    .split(',')
    .map((part) => {
      const [rawTag, rawQ] = part.trim().split(';q=');
      const tag = rawTag?.trim().toLowerCase();
      const q = rawQ ? parseFloat(rawQ) : 1;
      return tag ? { tag, q: Number.isFinite(q) ? q : 1 } : null;
    })
    .filter(Boolean)
    .sort((a, b) => b.q - a.q);
}

// Первый тег из Accept-Language, чей primary subtag (до дефиса, напр. "de"
// из "de-DE") входит в enabled — это и есть автодетект языка для голого
// домена. matched===null → покажем DEFAULT_LOCALE как раньше; browserPrimary
// возвращается отдельно, чтобы залогировать сам факт "к нам приходил язык,
// которого нет" даже когда redirect уходит на дефолт.
function detectLocale(header, enabled) {
  const parsed = parseAcceptLanguage(header);
  for (const { tag } of parsed) {
    const primary = tag.split('-')[0];
    if (enabled.includes(primary)) return { matched: primary, browserPrimary: primary };
  }
  return { matched: null, browserPrimary: parsed[0]?.tag.split('-')[0] ?? null };
}

// Fire-and-forget сигнал в web_events (backend/src/services/webEvents.js) —
// сырой материал для будущего решения "добавлять ли язык N" (CLAUDE.md §5).
// Не await'ится в вызывающем коде: waitUntil держит процесс, если платформа
// его даёт, но редирект не должен ждать сеть в любом случае — ошибки/недо-
// ступность backend проглатываются здесь же.
function logUnsupportedLocale(event, browserPrimary, header, pathname) {
  const base = process.env.API_BASE_URL || 'http://localhost:3000';
  const promise = fetch(`${base}/api/web-events`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      event_code: 'locale_autodetect_unmatched',
      metadata: { browser_lang: browserPrimary, accept_language: header, path: pathname },
    }),
  }).catch(() => {});
  if (typeof event?.waitUntil === 'function') event.waitUntil(promise);
}

// Любой путь без активного языкового префикса → редирект на язык браузера
// (Accept-Language), если он входит в 8 поддерживаемых; иначе на
// DEFAULT_LOCALE. Раньше редиректило на DEFAULT_LOCALE безусловно — дефолт
// нередко подсовывался немецко-/франко-/etc.-язычным пользователям, зашедшим
// на голый домен без явного /de и т.п. (актуально для части Google Ads
// объявлений, где Final URL — голый домен).
export function middleware(request, event) {
  const { pathname } = request.nextUrl;

  let response;
  if (pathname.startsWith('/internal') || pathname.startsWith('/api/admin')) {
    response = checkBasicAuth(request) ? NextResponse.next() : unauthorized();
  } else {
    const enabled = enabledLocales();
    const hasLocale = enabled.some(
      (l) => pathname === `/${l}` || pathname.startsWith(`/${l}/`)
    );
    if (hasLocale) {
      response = NextResponse.next();
    } else {
      const url = request.nextUrl.clone();
      const acceptLanguage = request.headers.get('accept-language');
      const { matched, browserPrimary } = detectLocale(acceptLanguage, enabled);
      url.pathname = `/${matched || DEFAULT_LOCALE}${pathname === '/' ? '' : pathname}`;
      response = NextResponse.redirect(url);
      if (!matched && browserPrimary) {
        logUnsupportedLocale(event, browserPrimary, acceptLanguage, pathname);
      }
    }
  }

  // Анонимная cookie для Блока 5 (виджет доступных байков на главной) — ставится
  // один раз при первом визите, живёт год. Не привязана к клиенту (нет
  // аккаунтов у посетителей сайта), нужна только чтобы один и тот же браузер
  // видел стабильную пару карточек в течение 30-минутного окна ротации.
  // try/catch — эта cookie не критична: если что-то пойдёт не так, сайт должен
  // продолжать работать (виджет просто получит нестабильную пару), а не падать.
  try {
    if (!request.cookies.get('mdb_cid')) {
      response.cookies.set('mdb_cid', randomId(), {
        maxAge: 60 * 60 * 24 * 365,
        path: '/',
        sameSite: 'lax',
      });
    }
  } catch {
    // не блокируем ответ из-за второстепенной cookie
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
