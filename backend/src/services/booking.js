import { pool } from '../db/pool.js';
import { getCompanyId, getConfig } from './config.js';
import { getActiveRuleSetId } from './ruleSet.js';
import { buildQuote } from './quote.js';
import { notifyDict } from './notifyDict.js';

const CONTACT_FIELDS = ['phone', 'whatsapp', 'telegram_username', 'telegram_id', 'email'];
const SUPPORTED_LOCALES = ['en', 'ru'];

function badReq(message) {
    const e = new Error(message);
    e.status = 400;
    return e;
}

function parseDateOnly(s) {
    if (typeof s !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(s)) return null;
    const d = new Date(`${s}T00:00:00Z`);
    return Number.isNaN(d.getTime()) ? null : d;
}

// rental_days = end − start (целые дни). Клиент выбирает даты в календаре:
// «с 10 по 22» = 12 дней (подтверждено Дмитрием).
function daysBetween(start, end) {
    return Math.round((end.getTime() - start.getTime()) / 86_400_000);
}

// Деньги для людей — в формате тысяч (CLAUDE.md §4: 1000к = 1 000 000 IDR).
// kk → "1 100к" (для строк разбивки); валюту "IDR" дописываем у итога/депозита.
function kk(idr) {
    return `${Math.round(Number(idr) / 1000).toLocaleString('ru-RU')}к`;
}

// Экранирование для Telegram parse_mode=HTML.
function esc(s) {
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

// Кликабельные контакты клиента: менеджер тапнул — открылся чат/звонок.
// WhatsApp → wa.me/<только цифры>; Telegram username → t.me/<user>;
// телефон → tel:; email → mailto:. Если только telegram_id без username —
// надёжной deep-link нет, показываем текстом.
function buildContactsHtml(c) {
    const parts = [];
    if (c.telegram_username) {
        const u = String(c.telegram_username).replace(/^@/, '');
        parts.push(`<a href="https://t.me/${encodeURIComponent(u)}">@${esc(u)}</a>`);
    } else if (c.telegram_id != null && String(c.telegram_id).trim() !== '') {
        parts.push(`TG id ${esc(c.telegram_id)}`);
    }
    if (c.whatsapp) {
        const digits = String(c.whatsapp).replace(/\D/g, '');
        parts.push(`<a href="https://wa.me/${digits}">WhatsApp ${esc(c.whatsapp)}</a>`);
    }
    if (c.phone) {
        const tel = String(c.phone).replace(/[^\d+]/g, '');
        parts.push(`<a href="tel:${tel}">${esc(c.phone)}</a>`);
    }
    if (c.email) {
        parts.push(`<a href="mailto:${esc(c.email)}">${esc(c.email)}</a>`);
    }
    return parts.join(' · ') || '—';
}

// Строка доставки из снимка: тариф по сроку или «бесплатно».
function deliveryLine(d, t) {
    if (d.free) return `${t.delivery} — ${t.free}`;
    const tier = d.tier ? ` (${d.tier.min_days}–${d.tier.max_days ?? '∞'} ${t.days})` : '';
    return `${t.delivery}${tier} — ${kk(d.fee_idr)}`;
}

// Заявка водителю (база знаний диспетчера): деньги — просто тысячи без
// разделителей/суффикса ("4400"), как в шаблоне Дмитрия — не путать с kk().
function ddk(idr) {
    return String(Math.round(Number(idr) / 1000));
}

function formatDDMMYYYY(isoDate) {
    const [y, m, d] = String(isoDate).split('-');
    return `${d}.${m}.${y}`;
}

// Все шлемы в группе helmet сводятся к физическому типу для комплектации —
// биллинг (обычный/новый, платный/бесплатный) водителю не важен, важно
// открытый (HF) или закрытый (FF) (база знаний диспетчера §4.2).
const HELMET_HF_CODES = new Set(['helmet_biasa', 'helmet_kyt_hf', 'helmet_kyt_hf_new']);
const HELMET_FF_CODES = new Set(['helmet_kyt_ff', 'helmet_kyt_ff_new']);

// Peralatan (комплектация в заявке водителю). Правила (уточнены с Дмитрием,
// не покрыты базой знаний диспетчера п.4.2 целиком):
//  - lap, dudukan hp — всегда, независимо от чекбоксов клиента на сайте;
//  - jas hujan — количество = числу выбранных шлемов, только если клиент
//    отметил дождевик (по числу шлемов, а не фиксированная 1 шт — так
//    подтвердил Дмитрий, это переопределяет дефолт подготовки байка "1 шт"
//    из базы знаний, специфично для этой заявки);
//  - karpet — всегда при выбранном SHAD-боксе (shad_box);
//  - safety set — всегда и только для категории 'touring' (Vstrom/Versys).
function computePeralatan(equipmentItems, categoryCode) {
    let helmetCount = 0;
    let hasRaincoat = false;
    let hasShadBox = false;
    const helmetTokens = [];
    for (const it of equipmentItems ?? []) {
        if (HELMET_HF_CODES.has(it.code)) {
            for (let i = 0; i < it.quantity; i++) helmetTokens.push('HF');
            helmetCount += it.quantity;
        } else if (HELMET_FF_CODES.has(it.code)) {
            for (let i = 0; i < it.quantity; i++) helmetTokens.push('FF');
            helmetCount += it.quantity;
        } else if (it.code === 'raincoat') {
            hasRaincoat = true;
        } else if (it.code === 'shad_box') {
            hasShadBox = true;
        }
    }
    const list = [...helmetTokens];
    if (hasRaincoat && helmetCount > 0) list.push(`${helmetCount} jas hujan`);
    list.push('dudukan hp', 'lap');
    if (hasShadBox) list.push('karpet');
    if (categoryCode === 'touring') list.push('safety set');
    return list;
}

// Заявка для водителей (вторая карточка, всегда на индонезийском — CLAUDE.md
// §4: "все задачи водителям на индонезийском"). Sopir/Pakai/номер юнита в
// Motor — сознательно пустые плейсхолдеры (нет справочника свободных
// байков/водителей в админке — будущий чанк). Memesan/время НЕ парсим из
// комментария клиента — диспетчер читает и проставляет вручную.
export function buildDriverText({ seq, startDate, customer, link, comment, productName, categoryCode, quote }) {
    const eq = quote.breakdown.equipment;
    const peralatan = computePeralatan(eq?.items, categoryCode);
    const total = Number(quote.total_payable_idr) + Number(quote.deposit.amount_idr);

    const lines = [
        `${seq}.`,
        `Sopir: —`,
        `Memesan: pengiriman ${formatDDMMYYYY(startDate)}, jam — lihat Komentar`,
        `Pakai: —`,
        `Location: ${link ? esc(link) : '—'}`,
        `Client hubungan: ${buildContactsHtml(customer)}`,
        `Motor: ${esc(productName)} — unit: —`,
        `Harga: ${ddk(quote.total_payable_idr)}`,
        `Deposit: ${ddk(quote.deposit.amount_idr)}`,
        `Total: ${ddk(total)}`,
        `Peralatan: ${peralatan.length ? peralatan.join(', ') : '—'}`,
        `Komentar: ${comment ? esc(comment) : '—'}`,
    ];
    return lines.join('\n');
}

// Текст уведомления менеджеру — ЦЕЛИКОМ на языке заявки (locale). Подписи из
// серверного словаря NOTIFY[locale]; названия оборудования уже локализованы в
// снимке (computeEquipment(lang)). ВСЕ суммы — из quote_snapshot, без пересчёта.
export function buildManagerText({ locale, ref, productName, startDate, endDate, rentalDays, customer, quote, link, comment }) {
    const t = notifyDict(locale);
    const b = quote.breakdown;
    const ins = b.insurance;
    const eq = b.equipment;

    const calc = [`• ${t.rental} · ${rentalDays} ${t.days} — ${kk(b.base_rental.price_idr)}`];
    calc.push(`• ${deliveryLine(b.delivery, t)}`);
    if (ins?.theft) {
        calc.push(`• ${t.theft} · ${ins.theft.months} ${t.mo}${ins.theft.bali_only ? ` · ${t.bali_only}` : ''} — ${kk(ins.theft.total_idr)}`);
    }
    if (ins?.damage) {
        const cat = t.exp[ins.damage.driver_category] ?? ins.damage.driver_category;
        calc.push(`• ${t.damage} · ${t.coverage} ${kk(ins.damage.coverage_idr)} · ${cat} · ${ins.damage.months} ${t.mo} — ${kk(ins.damage.total_idr)}`);
    }
    if (eq?.items?.length) {
        for (const it of eq.items) calc.push(`• ${esc(it.name)} × ${it.quantity} — ${kk(it.total_idr)}`);
    } else {
        calc.push(`• ${t.no_equipment}`);
    }

    const lines = [
        `🆕 <b>${t.new_booking}</b> · №<code>${esc(ref)}</code>`,
        `🌐 ${t.lang_label}: ${t.lang_name}`,
        '',
        `🏍 <b>${esc(productName)}</b>`,
        `📅 ${esc(startDate)} → ${esc(endDate)} · ${rentalDays} ${t.days}`,
        `👤 ${esc(customer.full_name)}`,
        `☎️ ${buildContactsHtml(customer)}`,
        link ? `📍 <a href="${esc(link)}">${t.location_map}</a>` : `📍 ${t.location}: —`,
        '',
        `<b>${t.calc}</b>`,
        ...calc,
        '———————',
        `💰 <b>${t.to_pay}: ${kk(quote.total_payable_idr)} IDR</b>`,
        `🔐 ${t.deposit}: ${kk(quote.deposit.amount_idr)} IDR`,
        ...(comment ? ['', `💬 <b>${t.comment}</b>: ${esc(comment)}`] : []),
    ];
    return lines.join('\n');
}

// Ищем существующего клиента по предоставленным идентификаторам (только
// непустые, по приоритету). telegram_username НЕ используем для матчинга
// (не уникален). Иначе создаём нового.
async function findOrCreateCustomer(client, companyId, c) {
    const checks = [];
    if (c.telegram_id != null && String(c.telegram_id).trim() !== '') checks.push(['telegram_id', Number(c.telegram_id)]);
    if (c.email) checks.push(['email', String(c.email).trim()]);
    if (c.phone) checks.push(['phone', String(c.phone).trim()]);
    if (c.whatsapp) checks.push(['whatsapp', String(c.whatsapp).trim()]);

    for (const [col, val] of checks) {
        const { rows } = await client.query(
            `SELECT id FROM customers WHERE company_id = $1 AND ${col} = $2 LIMIT 1`,
            [companyId, val]
        );
        if (rows.length) return rows[0].id;
    }

    const { rows } = await client.query(
        `INSERT INTO customers (company_id, full_name, phone, whatsapp, telegram_username, telegram_id, email)
         VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING id`,
        [
            companyId, c.full_name.trim(),
            c.phone ?? null, c.whatsapp ?? null, c.telegram_username ?? null,
            c.telegram_id != null && String(c.telegram_id).trim() !== '' ? Number(c.telegram_id) : null,
            c.email ?? null,
        ]
    );
    return rows[0].id;
}

export async function createBooking(input) {
    const { product, start_date, end_date, customer, insurance, equipment, location_link, comment } = input ?? {};
    // Язык заявки: уведомление менеджеру и снимок имён — на нём. Неизвестный → en.
    const locale = SUPPORTED_LOCALES.includes(input?.locale) ? input.locale : 'en';

    // --- валидация (понятные 400) ---
    if (!product) throw badReq('product is required');
    const start = parseDateOnly(start_date);
    const end = parseDateOnly(end_date);
    if (!start) throw badReq('start_date must be a valid date (YYYY-MM-DD)');
    if (!end) throw badReq('end_date must be a valid date (YYYY-MM-DD)');
    const rentalDays = daysBetween(start, end);
    if (rentalDays < 1) throw badReq('end_date must be after start_date');
    const today = new Date();
    today.setUTCHours(0, 0, 0, 0);
    if (start.getTime() < today.getTime()) throw badReq('start_date must not be in the past');
    if (!customer || typeof customer.full_name !== 'string' || !customer.full_name.trim()) {
        throw badReq('customer.full_name is required');
    }
    const hasContact = CONTACT_FIELDS.some((f) => customer[f] != null && String(customer[f]).trim() !== '');
    if (!hasContact) {
        throw badReq('at least one customer contact is required (phone / whatsapp / telegram_username / telegram_id / email)');
    }

    // --- цену считает сервер заново (фронту не доверяем). lang → имена
    //     оборудования в снимке на языке заявки. Бросит 404, если продукт не найден. ---
    const quote = await buildQuote({ product, rentalDays, insurance, equipment, lang: locale, startDate: start_date });

    const companyId = await getCompanyId();
    const ruleSetId = await getActiveRuleSetId();
    const link = typeof location_link === 'string' && location_link.trim() ? location_link.trim() : null;
    const commentText = typeof comment === 'string' && comment.trim() ? comment.trim() : null;

    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        const customerId = await findOrCreateCustomer(client, companyId, customer);

        const { rows: bRows } = await client.query(
            `INSERT INTO bookings (
                company_id, source, status, customer_id, product_id, rule_set_id,
                start_date, end_date, rental_days,
                base_price_idr, delivery_fee_idr, total_payable_idr, quote_snapshot, location_link, locale, comment
             ) VALUES ($1,'website','created',$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
             RETURNING id, status, created_at, booking_number`,
            [
                companyId, customerId, quote.product.id, ruleSetId,
                start_date, end_date, rentalDays,
                quote.breakdown.base_rental.price_idr,
                quote.breakdown.delivery.fee_idr,
                quote.total_payable_idr,
                quote, link, locale, commentText,
            ]
        );
        const booking = bRows[0];

        await client.query(
            `INSERT INTO booking_status_history (booking_id, from_status, to_status, note)
             VALUES ($1, NULL, 'created', 'Website lead via POST /api/bookings')`,
            [booking.id]
        );

        // Долговечные записи уведомлений (queued) — ПО ОДНОЙ НА КАЖДЫЙ chat_id.
        // Эскалация уходит во все аккаунты из конфига; у каждого свой статус
        // (одному ушло, другому нет — видно отдельно). Отправка — после ответа
        // клиенту (fire-and-forget). БД — источник правды.
        const chatIds = (await getConfig(companyId, 'manager_telegram_chat_ids')) || [];
        // ref — короткий человекочитаемый номер заявки (серийный booking_number,
        // миграция 018) в формате BR-00001. Менеджер называет его клиенту вслух.
        const ref = `BR-${String(booking.booking_number).padStart(5, '0')}`;
        const text = buildManagerText({
            locale, ref, productName: quote.product.name,
            startDate: start_date, endDate: end_date, rentalDays, customer, quote, link,
            comment: commentText,
        });
        const notificationIds = [];
        for (const chatId of chatIds) {
            const { rows: nRows } = await client.query(
                `INSERT INTO notifications (company_id, channel, status, template_code, payload, booking_id)
                 VALUES ($1,'telegram','queued','booking_created',$2,$3) RETURNING id`,
                [companyId, { chat_id: chatId, text, parse_mode: 'HTML' }, booking.id]
            );
            notificationIds.push(nRows[0].id);
        }

        // Заявка водителям (Фаза D) — та же эскалация (Дмитрий подтвердил: тот
        // же chat_id, что и у менеджера). category_id — для правила "safety set
        // только для touring" в Peralatan.
        const { rows: catRows } = await client.query(
            `SELECT vc.code
             FROM products p
             JOIN product_families pf ON pf.id = p.family_id
             JOIN vehicle_categories vc ON vc.id = pf.category_id
             WHERE p.id = $1`,
            [quote.product.id]
        );
        const categoryCode = catRows[0]?.code ?? null;

        // Сквозной номер карточки за календарный день — атомарный UPSERT в этой
        // же транзакции (миграция 042).
        const { rows: seqRows } = await client.query(
            `INSERT INTO driver_notification_daily_seq (company_id, seq_date, last_seq)
             VALUES ($1, CURRENT_DATE, 1)
             ON CONFLICT (company_id, seq_date)
             DO UPDATE SET last_seq = driver_notification_daily_seq.last_seq + 1
             RETURNING last_seq`,
            [companyId]
        );
        const dailySeq = seqRows[0].last_seq;

        const driverText = buildDriverText({
            seq: dailySeq, startDate: start_date, customer, link, comment: commentText,
            productName: quote.product.name, categoryCode, quote,
        });
        for (const chatId of chatIds) {
            const { rows: dRows } = await client.query(
                `INSERT INTO notifications (company_id, channel, status, template_code, payload, booking_id)
                 VALUES ($1,'telegram','queued','driver_card',$2,$3) RETURNING id`,
                [companyId, { chat_id: chatId, text: driverText, parse_mode: 'HTML' }, booking.id]
            );
            notificationIds.push(dRows[0].id);
        }

        await client.query('COMMIT');
        // ref (BR-00001) — единый короткий номер для всех каналов (уведомление
        // менеджеру и подтверждение клиенту).
        return { booking, ref, quote, link, notificationIds, managerText: text };
    } catch (e) {
        await client.query('ROLLBACK');
        throw e;
    } finally {
        client.release();
    }
}
