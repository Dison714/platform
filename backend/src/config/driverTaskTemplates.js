import { esc, formatDDMMYYYY } from '../services/booking.js';

// =====================================================================
// ЧЕРНОВИК — CRM v1.1, сессия 2026-09-26, версия 2 (после первого теста
// Коммита 3 — Дмитрий попросил привести к структуре buildDriverText()
// в services/booking.js:139-159, той же самой, что реально уходит при
// бронировании с сайта). Переиспользует её хелперы (esc, formatDDMMYYYY —
// экспортированы оттуда же), но не саму функцию: buildDriverText()
// жёстко привязана к контексту "карточка создаётся вместе с бронью"
// (жёсткий текст "pengiriman" в Memesan, Sopir/Pakai всегда пустые — на
// момент брони водитель и физический байк ещё не назначены). Здесь
// наоборот — задача создаётся ПОСЛЕ того, как бронь уже прошла
// bookingLifecycle (водитель и fleet_item, как правило, уже назначены),
// поэтому Sopir/Pakai заполняются реальными значениями.
//
// Дмитрий пришлёт финальный текст по итогам ещё нескольких раундов
// тестовых отправок (см. POST /driver-tasks/:id/send-test в
// driverTasksAdmin.js — уходит менеджеру, не в реальный водительский чат,
// бота туда ещё нет). ПРАВИТЬ ТОЛЬКО ЭТОТ ФАЙЛ — driverTasksAdmin.js
// вызывает DRIVER_TASK_TEMPLATES[type_code](ctx) и шлёт результат как
// есть, саму сборку ctx менять не нужно, чтобы поменять текст/порядок
// строк.
//
// ctx (собирается в driverTasksAdmin.js):
//   seq               — driver_tasks.daily_seq (сквозной номер за день,
//                        069_driver_tasks_daily_seq.sql; общий счётчик с
//                        карточкой из buildDriverText)
//   typeNameLower     — task_types.name_id, приведено к нижнему регистру
//                        (для строки Memesan, вместо жёсткого "pengiriman")
//   scheduledDate, scheduledTime — driver_tasks.scheduled_date/scheduled_time
//                        (time уже обрезано до HH:MM)
//   sopir             — drivers.name по assigned_driver_slot, или null
//   pakai             — ВСЕГДА null в этом срезе (ревью Дмитрия после теста
//                        v2): это байк, на котором ВОДИТЕЛЬ едет выполнять
//                        задачу и возвращается — другой смысл, чем Motor
//                        (байк, который сдаётся клиенту). Штатно пусто для
//                        одного водителя (возвращается на такси). Источника
//                        данных под это поле в схеме пока нет (ни второго
//                        слота водителя на задачу, ни "возвратного"
//                        fleet_item) — будущий срез, если появится сценарий
//                        с двумя водителями на одну задачу (второй едет на
//                        отдельном байке, оба возвращаются на нём). Поле
//                        оставлено в шаблоне уже сейчас, чтобы было куда
//                        его подключить позже без правки формата карточки.
//   location          — driver_tasks.location_text
//   clientContactHtml — готовый HTML (кликабельные ссылки, buildContactsHtml
//                        из брони) либо esc() от свободного текста, либо null
//   motorName         — "<internal_number>.<Brand> <Model> <Цвет>
//                        <license_plate>", собрано напрямую из
//                        fleet_items/products/product_families (НЕ
//                        "упрощённое" products.internal_name — снято тем же
//                        ревью), или null, если у задачи ещё нет
//                        конкретного fleet_item
//   hargaK, depositK, totalK — строки в тысячах (ddk() из booking.js), или
//                        null, если у задачи нет связанной брони с ценой
//   peralatan         — string[] или null
//   komentar          — driver_tasks.comment
// =====================================================================

function driverTaskCardText(ctx) {
    const lines = [
        `🧪 ТЕСТ · ${esc(ctx.typeNameLower)}`,
        `${ctx.seq ?? ''}.`,
        `Sopir: ${ctx.sopir ? esc(ctx.sopir) : ''}`,
        `Memesan: ${ctx.typeNameLower} ${ctx.scheduledDate ? formatDDMMYYYY(ctx.scheduledDate) : ''}, jam ${ctx.scheduledTime || ''}`,
        `Pakai: ${ctx.pakai ? esc(ctx.pakai) : ''}`,
        `Location: ${ctx.location ? esc(ctx.location) : ''}`,
        `Client hubungan: ${ctx.clientContactHtml || ''}`,
        `Motor: ${ctx.motorName ? esc(ctx.motorName) : ''}`,
        `Harga: ${ctx.hargaK ?? ''}`,
        `Deposit: ${ctx.depositK ?? ''}`,
        `Total: ${ctx.totalK ?? ''}`,
        `Peralatan: ${ctx.peralatan?.length ? ctx.peralatan.join(', ') : ''}`,
        `Komentar: ${ctx.komentar ? esc(ctx.komentar) : ''}`,
    ];
    return lines.join('\n');
}

// Раздел А задания (7 пунктов) — пункт 7 ("menjemput/bawa helm(+peralatan)
// dari/ke klien") закрыт ДВУМЯ существующими/новым кодами: bawa_helm
// (доставка клиенту) и menjemput_helm (забор без замены, добавлен
// миграцией 068) — итого 8 кодов в списке ниже на 7 пунктов задания.
export const DRIVER_TASK_TEMPLATES = {
    pengiriman: driverTaskCardText,
    menjemput: driverTaskCardText,
    tukar_motor: driverTaskCardText,
    menjemput_kunci_dan_foto_motor: driverTaskCardText,
    ambil_uang: driverTaskCardText,
    pengiriman_dan_foto_di_tempat_klien: driverTaskCardText,
    bawa_helm: driverTaskCardText,
    menjemput_helm: driverTaskCardText,
};

// Whitelist для кнопки "отправить" на экране /internal/driver-tasks —
// ТОЛЬКО эти type_codes. Остальные (весь остальной task_types) существуют
// в системе для учёта задач, но кнопка отправки для них выключена в этом
// срезе (склад/сервис/GPS и т.п. — не про клиентскую логистику раздела А).
export const SEND_ALLOWED_CODES = Object.keys(DRIVER_TASK_TEMPLATES);
