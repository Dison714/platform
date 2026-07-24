// Блок 5: детерминированный выбор пары карточек для виджета "доступно
// сейчас" на главной. Без серверного состояния — hash(cookie + окно 30 мин)
// определяет пару; один браузер видит стабильную пару 30 минут, потом
// новую. ≤2 доступных → показываем все без ротации.

const WINDOW_MS = 30 * 60 * 1000;

// djb2 — простой детерминированный хэш строки в неотрицательное число.
function hashString(str) {
  let h = 5381;
  for (let i = 0; i < str.length; i++) h = ((h << 5) + h + str.charCodeAt(i)) | 0;
  return Math.abs(h);
}

// available — продукты из GET /api/products?available=true (уже отфильтрованы
// по наличию свободного fleet_item). cookieId — из mdb_cid (middleware.js);
// null на самом первом запросе до того, как cookie появится у клиента —
// тогда пара просто случайна для этого рендера (следующий заход уже стабилен).
export function pickAvailablePair(available, cookieId) {
  if (available.length <= 2) return available;
  const bucket = Math.floor(Date.now() / WINDOW_MS);
  const seed = `${cookieId ?? Math.random()}:${bucket}`;
  const start = hashString(seed) % available.length;
  return [available[start], available[(start + 1) % available.length]];
}
