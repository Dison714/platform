'use client';

import { useEffect, useMemo, useState, useCallback } from 'react';
import { DELIVERY_TIME_OPTIONS } from '../../../lib/timeSlots.js';
import { formatIdr } from '../../../lib/api.js';

const BOOKINGS_API = '/api/admin/bookings';
const DRIVERS_API = '/api/admin/drivers';
const RENTALS_API = '/api/admin/rentals';
const PRODUCTS_API = '/api/admin/bookings-products';
const EQUIPMENT_API = '/api/admin/equipment-options';

// booking_status enum (001_foundation.sql) — порядок этого среза (CRM v1.1,
// согласован с Дмитрием, НЕ порядок объявления enum):
// created → fleet_item_assigned → confirmed → driver_assigned →
// awaiting_payment → paid → fulfilled. ai_processing в этом срезе не
// используется вообще.
const STATUS_OPTIONS = [
  'created', 'fleet_item_assigned', 'confirmed', 'driver_assigned',
  'awaiting_payment', 'paid', 'fulfilled', 'cancelled', 'expired',
];

function money(idr) {
  return Number(idr).toLocaleString('en-US');
}

function contactsText(row) {
  const parts = [];
  if (row.telegram_username) parts.push(`@${row.telegram_username}`);
  if (row.whatsapp) parts.push(`WA ${row.whatsapp}`);
  if (row.phone) parts.push(row.phone);
  return parts.join(' · ') || '—';
}

// Один шаг вперёд по цепочке (см. STATUS_OPTIONS) — ровно одна кнопка/форма
// на статус, ничего не пропустить через UI (бэкенд и так это гарантирует
// проверкой текущего статуса, см. bookingLifecycle.js).
const EMPTY_ASSIGNABLE = { exact: [], same_family: [], replacement_group: [], replacement_group_name: null };

// Раздел 2 (2026-09-27) — симметричный откат на каждом нетерминальном шаге
// кроме 'created' (там некуда откатывать). confirmText — доп. window.confirm
// для unfulfill (реально удаляет rentals-запись, не просто меняет статус).
function BackButton({ onClick, busy, confirmText }) {
  return (
    <button
      disabled={busy}
      onClick={() => {
        if (confirmText && !window.confirm(confirmText)) return;
        onClick();
      }}
      style={{ fontSize: 12, color: '#888', background: 'none', border: '1px solid #ddd', borderRadius: 4, padding: '2px 8px', cursor: 'pointer' }}
    >
      ← Назад
    </button>
  );
}

function ActionCell({ booking, drivers, onAction, busy }) {
  const [assignable, setAssignable] = useState(EMPTY_ASSIGNABLE);
  const [loadingFleet, setLoadingFleet] = useState(false);
  const [selectedFleetItem, setSelectedFleetItem] = useState('');
  const [replacementReason, setReplacementReason] = useState('');
  const [selectedDriver, setSelectedDriver] = useState('');
  const [startDate, setStartDate] = useState(booking.start_date);
  const [endDate, setEndDate] = useState(booking.end_date);
  const [followupLocation, setFollowupLocation] = useState('');
  const [followupTime, setFollowupTime] = useState('');
  const [showCancel, setShowCancel] = useState(false);
  const [cancelReason, setCancelReason] = useState('');

  useEffect(() => {
    if (booking.status !== 'created') return;
    let cancelled = false;
    setLoadingFleet(true);
    fetch(`${BOOKINGS_API}/${booking.id}/assignable-fleet-items`, { cache: 'no-store' })
      .then((r) => r.json())
      .then((json) => {
        if (cancelled) return;
        setAssignable(json.data ?? EMPTY_ASSIGNABLE);
      })
      .catch(() => {})
      .finally(() => { if (!cancelled) setLoadingFleet(false); });
    return () => { cancelled = true; };
  }, [booking.status, booking.id]);

  // Раздел 4 (2026-09-27) — "Отменить" доступна на любом нетерминальном
  // статусе (созданной ещё не выданной брони), независимо от того, что
  // показывает mainContent ниже.
  const cancellable = !['fulfilled', 'cancelled', 'expired'].includes(booking.status);
  let mainContent;

  // Автосворачивание на первую непустую ступень (дизайн 2026-09-27,
  // CLAUDE.md §3.1): точное совпадение → другой цвет той же Family → та же
  // replacement_groups. Пустые ступени вообще не показываются оператору.
  if (booking.status === 'created') {
    const tier = assignable.exact.length ? 'exact'
      : assignable.same_family.length ? 'same_family'
      : assignable.replacement_group.length ? 'replacement_group'
      : null;
    const items = tier === 'exact' ? assignable.exact
      : tier === 'same_family' ? assignable.same_family
      : tier === 'replacement_group' ? assignable.replacement_group
      : [];
    const tierLabel = tier === 'exact' ? `Точное совпадение — ${items.length} свободно`
      : tier === 'same_family' ? `Другой цвет, та же модель — ${items.length} свободно`
      : tier === 'replacement_group' ? `Замена по группе: ${assignable.replacement_group_name ?? '—'} — ${items.length} свободно`
      : null;
    const isReplacement = tier === 'same_family' || tier === 'replacement_group';
    const reasonOk = !isReplacement || replacementReason.trim();

    mainContent = (
      <div style={{ display: 'flex', gap: 6, alignItems: 'center', flexWrap: 'wrap' }}>
        {tierLabel && <span style={{ fontSize: 11, color: '#666' }}>{tierLabel}</span>}
        <select value={selectedFleetItem} disabled={loadingFleet || busy || !tier}
          onChange={(e) => setSelectedFleetItem(e.target.value)}>
          <option value="">{loadingFleet ? 'загрузка…' : items.length ? '— байк —' : 'нет свободных'}</option>
          {items.map((f) => (
            <option key={f.id} value={f.id}>
              №{f.internal_number} {f.brand} {f.model_name} {f.color_name} ({f.license_plate})
            </option>
          ))}
        </select>
        {isReplacement && selectedFleetItem && (
          <input type="text" placeholder="Причина замены" value={replacementReason} disabled={busy}
            style={{ minWidth: 200 }}
            onChange={(e) => setReplacementReason(e.target.value)} />
        )}
        <button disabled={!selectedFleetItem || !reasonOk || busy}
          onClick={() => onAction(booking.id, 'assign-fleet-item', {
            fleet_item_id: selectedFleetItem,
            replacement_reason: isReplacement ? replacementReason.trim() : null,
          })}>
          Назначить байк
        </button>
      </div>
    );
  } else if (booking.status === 'fleet_item_assigned') {
    mainContent = (
      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <button disabled={busy} onClick={() => onAction(booking.id, 'confirm', {})}>Подтвердить</button>
        <BackButton busy={busy} onClick={() => onAction(booking.id, 'unassign-fleet-item', {})} />
      </div>
    );
  } else if (booking.status === 'confirmed') {
    const activeDrivers = drivers.filter((d) => d.is_active);
    mainContent = (
      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <select value={selectedDriver} disabled={busy} onChange={(e) => setSelectedDriver(e.target.value)}>
          <option value="">— водитель —</option>
          {activeDrivers.map((d) => (
            <option key={d.driver_slot} value={d.driver_slot}>{d.name}</option>
          ))}
        </select>
        <button disabled={!selectedDriver || busy}
          onClick={() => onAction(booking.id, 'assign-driver', { driver_slot: Number(selectedDriver) })}>
          Назначить водителя
        </button>
        <BackButton busy={busy} onClick={() => onAction(booking.id, 'unconfirm', {})} />
      </div>
    );
  } else if (booking.status === 'driver_assigned') {
    if (booking.has_pengiriman_task) {
      mainContent = (
        <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
          <span style={{ color: '#0a0', fontSize: 12 }}>✓ задача водителю создана</span>
          <button disabled={busy} onClick={() => onAction(booking.id, 'mark-awaiting-payment', {})}>Отметить: ожидает оплаты</button>
          <BackButton busy={busy} onClick={() => onAction(booking.id, 'unassign-driver', {})} />
        </div>
      );
    } else {
      // Автосоздание задачи 'pengiriman' (bookingLifecycle.assignDriver(),
      // CRM v1.1 Раздел 1) не сработало сразу — не хватало данных. Показываем
      // инпуты именно под недостающие поля, не сваливаем всё в одну форму.
      const missing = [];
      if (!booking.has_customer_contact) missing.push('контакт клиента');
      if (!booking.location_link) missing.push('локация');
      if (!booking.delivery_time) missing.push('время доставки');
      const ready = booking.has_customer_contact
        && (booking.location_link || followupLocation.trim())
        && (booking.delivery_time || followupTime);
      mainContent = (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          <div style={{ fontSize: 11, color: '#a60' }}>Не хватает для задачи водителю: {missing.join(', ')}</div>
          <div style={{ display: 'flex', gap: 6, alignItems: 'center', flexWrap: 'wrap' }}>
            {!booking.location_link && (
              <input type="text" placeholder="Локация" value={followupLocation} disabled={busy}
                style={{ minWidth: 160 }}
                onChange={(e) => setFollowupLocation(e.target.value)} />
            )}
            {!booking.delivery_time && (
              <input type="time" value={followupTime} disabled={busy}
                onChange={(e) => setFollowupTime(e.target.value)} />
            )}
            <button disabled={busy || !ready}
              onClick={() => {
                const body = {};
                if (!booking.location_link) body.location_link = followupLocation.trim();
                if (!booking.delivery_time) body.delivery_time = followupTime;
                onAction(booking.id, 'driver-task-followup', body);
              }}>
              Создать и отправить задачу
            </button>
          </div>
          <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
            <button disabled={busy}
              onClick={() => onAction(booking.id, 'mark-awaiting-payment', {})}>
              Отметить: ожидает оплаты
            </button>
            <BackButton busy={busy} onClick={() => onAction(booking.id, 'unassign-driver', {})} />
          </div>
        </div>
      );
    }
  } else if (booking.status === 'awaiting_payment') {
    mainContent = (
      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <button disabled={busy} onClick={() => onAction(booking.id, 'mark-paid', {})}>Отметить: оплачено</button>
        <BackButton busy={busy} onClick={() => onAction(booking.id, 'unmark-awaiting-payment', {})} />
      </div>
    );
  } else if (booking.status === 'paid') {
    mainContent = (
      <div style={{ display: 'flex', gap: 6, alignItems: 'center', flexWrap: 'wrap' }}>
        <input type="date" value={startDate} disabled={busy} style={{ width: 132 }}
          onChange={(e) => setStartDate(e.target.value)} />
        <input type="date" value={endDate} disabled={busy} style={{ width: 132 }}
          onChange={(e) => setEndDate(e.target.value)} />
        <button disabled={busy}
          onClick={() => onAction(booking.id, 'fulfill', { start_date: startDate, end_date: endDate })}>
          Завершить (Fulfilled)
        </button>
        <BackButton busy={busy} onClick={() => onAction(booking.id, 'unmark-paid', {})} />
      </div>
    );
  } else if (booking.status === 'fulfilled') {
    // fulfilled — терминальный шаг в обычном потоке, но откат нужен на случай
    // ошибочного клика (реальной выдачи байка не было): unfulfillBooking()
    // полностью удаляет rentals/events, байк возвращается в 'reserved'
    // (CRM v1.1 Раздел 2, дизайн подтверждён Дмитрием 2026-09-27).
    mainContent = (
      <BackButton busy={busy}
        confirmText="Откатить Fulfilled? Запись в rentals будет удалена целиком — используйте только если реальной выдачи байка не было."
        onClick={() => onAction(booking.id, 'unfulfill', {})} />
    );
  } else {
    mainContent = <span style={{ color: '#888' }}>—</span>;
  }

  // Раздел 4 — "Отменить" не заменяет mainContent, а идёт вторым рядом:
  // диспетчер должен суметь отменить бронь на любом шаге, не теряя
  // возможность продолжить обычную цепочку, если передумает.
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      {mainContent}
      {cancellable && (
        showCancel ? (
          <div style={{ display: 'flex', gap: 6, alignItems: 'center', flexWrap: 'wrap' }}>
            <input type="text" placeholder="Причина отмены" value={cancelReason} disabled={busy}
              style={{ minWidth: 160 }}
              onChange={(e) => setCancelReason(e.target.value)} />
            <button disabled={busy || !cancelReason.trim()}
              onClick={() => onAction(booking.id, 'cancel', { reason: cancelReason.trim() })}
              style={{ color: '#c00' }}>
              Подтвердить отмену
            </button>
            <button disabled={busy} onClick={() => setShowCancel(false)}>Не отменять</button>
          </div>
        ) : (
          <button disabled={busy} style={{ width: 'fit-content', color: '#c00', fontSize: 12, background: 'none', border: '1px solid #fcc', borderRadius: 4, padding: '2px 8px', cursor: 'pointer' }}
            onClick={() => setShowCancel(true)}>
            Отменить заявку
          </button>
        )
      )}
    </div>
  );
}

// Раздел 5А (2026-09-27) — ручное создание заявки диспетчером. Переиспользует
// createBooking() целиком через POST /bookings/create-manual (validation,
// buildQuote() по продукту/датам/оборудованию/страховке, findOrCreateCustomer,
// уведомления менеджеру/водителям) — цена НЕ вводится руками.
//
// Доработка (2026-10-03): страховка один в один с Calculator.jsx, live-превью
// цены через публичный /api/quote (тот же debounce 400мс), и продолжение
// оформления в этом же экране — после создания под формой появляется панель
// с тем же <ActionCell>, что и в таблице (байк → подтверждение → водитель).
function daysBetween(start, end) {
  return Math.round((new Date(end).getTime() - new Date(start).getTime()) / 86_400_000);
}

const EMPTY_CREATE_FORM = {
  full_name: '', phone: '', whatsapp: '', telegram_username: '',
  product_id: '', start_date: '', end_date: '',
  location_link: '', delivery_time: '',
};

function QuotePreview({ status, result, rentalDays }) {
  const b = result?.breakdown;
  return (
    <div style={{ borderTop: '1px solid #eee', paddingTop: 10 }}>
      {status === 'error' && (
        <div style={{ color: '#a60', fontSize: 13 }}>
          Не удалось рассчитать цену (бэкенд пересчитает при создании)
        </div>
      )}
      {!result && status === 'loading' && <div style={{ color: '#888', fontSize: 13 }}>Считаем…</div>}
      {result && b && (
        <div style={{ opacity: status === 'loading' ? 0.5 : 1 }}>
          <div style={{ fontSize: 22, fontWeight: 600 }}>{formatIdr(result.total_payable_idr)}</div>
          <div style={{ fontSize: 11, color: '#666', marginTop: 4, lineHeight: 1.5 }}>
            <div>Аренда · {rentalDays}д — {formatIdr(b.base_rental.price_idr)}</div>
            <div>Доставка — {b.delivery.free ? 'бесплатно' : formatIdr(b.delivery.fee_idr)}</div>
            {b.insurance?.theft && (
              <div>Страховка от угона · {b.insurance.theft.months} мес — {formatIdr(b.insurance.theft.total_idr)}</div>
            )}
            {b.insurance?.damage && (
              <div>Страховка от повреждений · {formatIdr(b.insurance.damage.coverage_idr)} — {formatIdr(b.insurance.damage.total_idr)}</div>
            )}
            {b.equipment?.items?.map((it) => (
              <div key={it.code}>{it.name}{it.quantity > 1 ? ` ×${it.quantity}` : ''} — {formatIdr(it.total_idr)}</div>
            ))}
            <div>Депозит (возвращаемый, не в сумме) — {formatIdr(result.deposit.amount_idr)}</div>
          </div>
        </div>
      )}
    </div>
  );
}

function CreateBookingForm({ bookings, drivers, busyId, onAction, onCreated }) {
  const [open, setOpen] = useState(false);
  const [products, setProducts] = useState([]);
  const [equipmentOptions, setEquipmentOptions] = useState([]);
  const [insuranceOptions, setInsuranceOptions] = useState({ damage: [] });
  // Точная копия helmet-slot механики Calculator.jsx (сайт): 2 физических
  // слота на байк, каждый — чекбокс "занят/пуст" + select конкретного
  // шлема. Единственное осознанное отличие от сайта (дизайн подтверждён
  // Дмитрием 2026-09-27): по умолчанию занят только слот 1 (бесплатный
  // шлем), не оба — ручное создание не предполагает автоматически второго
  // пассажира, в отличие от калькулятора на сайте.
  const [helmetSlots, setHelmetSlots] = useState([null, null]);
  const [extras, setExtras] = useState({});
  // Страховка — те же поля и дефолты, что в Calculator.jsx.
  const [theft, setTheft] = useState(false);
  const [damageOn, setDamageOn] = useState(false);
  const [coverage, setCoverage] = useState(1500000);
  const [age, setAge] = useState(30);
  const [hasLicense, setHasLicense] = useState(true);
  const [experienced, setExperienced] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [form, setForm] = useState(EMPTY_CREATE_FORM);
  // Панель продолжения оформления (п.5 задания) — живёт независимо от
  // формы: можно закрыть форму и продолжить работать с панелью.
  const [created, setCreated] = useState(null); // { id, booking_number }

  const [quote, setQuote] = useState(null);
  const [quoteStatus, setQuoteStatus] = useState('idle'); // idle | loading | error

  const helmets = useMemo(() => equipmentOptions.filter((e) => e.addon_group === 'helmet'), [equipmentOptions]);
  const extrasList = useMemo(() => equipmentOptions.filter((e) => e.addon_group !== 'helmet'), [equipmentOptions]);

  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    (async () => {
      try {
        const [pRes, eRes] = await Promise.all([
          fetch(PRODUCTS_API, { cache: 'no-store' }),
          fetch(EQUIPMENT_API, { cache: 'no-store' }),
        ]);
        if (cancelled) return;
        setProducts((await pRes.json()).data ?? []);
        const eqData = (await eRes.json()).data ?? {};
        const eq = eqData.equipment ?? [];
        setEquipmentOptions(eq);
        const damage = eqData.insurance?.damage ?? [];
        setInsuranceOptions({ damage });
        setCoverage(damage[0]?.coverage_idr ?? 1500000);
        const freeCode = eq.find((h) => h.addon_group === 'helmet' && h.rental_price_idr === 0)?.code
          ?? eq.find((h) => h.addon_group === 'helmet')?.code ?? null;
        setHelmetSlots([freeCode, null]);
      } catch { /* справочники необязательны для показа формы */ }
    })();
    return () => { cancelled = true; };
  }, [open]);

  function update(patch) { setForm((f) => ({ ...f, ...patch })); }

  // Общая часть выбора (страховка + допы) — как `selection` в Calculator.jsx:
  // одно и то же и для live-превью, и для финального submit.
  const selection = useMemo(() => {
    const helmetTally = {};
    for (const code of helmetSlots) {
      if (!code) continue;
      const h = helmets.find((x) => x.code === code);
      if (h) helmetTally[code] = (helmetTally[code] || 0) + 1;
    }
    const equip = [
      ...Object.entries(helmetTally).map(([code, n]) => ({ code, quantity: n })),
      ...extrasList.filter((e) => extras[e.code]).map((e) => ({ code: e.code, quantity: 1 })),
    ];
    let insurance;
    if (theft || damageOn) {
      insurance = {};
      if (theft) insurance.theft = true;
      if (damageOn) {
        insurance.damage = { coverage_idr: Number(coverage) };
        insurance.driver = { age: Number(age), has_license: hasLicense, experienced };
      }
    }
    return { insurance, equipment: equip.length ? equip : undefined };
  }, [helmetSlots, extras, helmets, extrasList, theft, damageOn, coverage, age, hasLicense, experienced]);

  const rentalDays = useMemo(
    () => (form.start_date && form.end_date ? daysBetween(form.start_date, form.end_date) : NaN),
    [form.start_date, form.end_date],
  );
  const daysValid = Number.isInteger(rentalDays) && rentalDays >= 1;
  const previewReady = Boolean(form.product_id) && daysValid;

  // Live-превью: тот же debounce 400мс, что в Calculator.jsx; устаревшие
  // ответы отбрасываются флагом cancelled в cleanup.
  useEffect(() => {
    if (!open || !previewReady) { setQuote(null); setQuoteStatus('idle'); return undefined; }
    let cancelled = false;
    setQuoteStatus('loading');
    const timer = setTimeout(async () => {
      try {
        const res = await fetch('/api/quote', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            product: form.product_id,
            rental_days: rentalDays,
            start_date: form.start_date,
            ...(selection.insurance ? { insurance: selection.insurance } : {}),
            ...(selection.equipment ? { equipment: selection.equipment } : {}),
          }),
        });
        if (!res.ok) throw new Error('quote failed');
        const json = await res.json();
        if (cancelled) return;
        setQuote(json.data);
        setQuoteStatus('idle');
      } catch {
        if (!cancelled) setQuoteStatus('error');
      }
    }, 400);
    return () => { cancelled = true; clearTimeout(timer); };
  }, [open, previewReady, form.product_id, form.start_date, rentalDays, selection]);

  const hasContact = Boolean(form.phone.trim() || form.whatsapp.trim() || form.telegram_username.trim());
  const canSubmit = form.full_name.trim() && hasContact && form.product_id && form.start_date && form.end_date;

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    if (!canSubmit) { setError('Заполните клиента (имя + контакт), продукт и даты'); return; }
    setBusy(true);
    try {
      const res = await fetch('/api/admin/bookings/create-manual', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          product: form.product_id,
          start_date: form.start_date,
          end_date: form.end_date,
          customer: {
            full_name: form.full_name.trim(),
            phone: form.phone.trim() || undefined,
            whatsapp: form.whatsapp.trim() || undefined,
            telegram_username: form.telegram_username.trim() || undefined,
          },
          insurance: selection.insurance,
          equipment: selection.equipment,
          location_link: form.location_link.trim() || undefined,
          delivery_time: form.delivery_time || undefined,
        }),
      });
      const json = await res.json().catch(() => ({}));
      if (!res.ok) {
        setError(json.message || `Ошибка ${res.status}`);
        return;
      }
      // Форму НЕ закрываем (п.5): поля чистим, чтобы повторный клик не создал
      // дубль, а продолжение оформления идёт в панели под формой.
      setForm(EMPTY_CREATE_FORM);
      setExtras({});
      setTheft(false);
      setDamageOn(false);
      setHelmetSlots((s) => [s[0] ?? helmets.find((h) => h.rental_price_idr === 0)?.code ?? helmets[0]?.code ?? null, null]);
      setCreated({ id: json.data.id, booking_number: json.data.booking_number });
      await onCreated();
    } finally {
      setBusy(false);
    }
  }

  const createdBooking = created ? bookings.find((b) => b.id === created.id) : null;

  const formNode = !open ? (
    <button onClick={() => setOpen(true)} style={{ marginBottom: 12 }}>Создать заявку</button>
  ) : (
    <form onSubmit={handleSubmit} style={{ border: '1px solid #ddd', borderRadius: 6, padding: 16, marginBottom: 16, maxWidth: 480, display: 'flex', flexDirection: 'column', gap: 10 }}>
      <h3 style={{ margin: 0, fontSize: 16 }}>Новая заявка (вручную)</h3>
      {error && <div style={{ color: '#c00', fontSize: 13 }}>{error}</div>}
      <label>Клиент — имя
        <input type="text" required value={form.full_name} style={{ display: 'block', width: '100%' }}
          onChange={(e) => update({ full_name: e.target.value })} />
      </label>
      <div style={{ display: 'flex', gap: 8 }}>
        <label style={{ flex: 1 }}>Телефон
          <input type="text" value={form.phone} style={{ display: 'block', width: '100%' }}
            onChange={(e) => update({ phone: e.target.value })} />
        </label>
        <label style={{ flex: 1 }}>WhatsApp
          <input type="text" value={form.whatsapp} style={{ display: 'block', width: '100%' }}
            onChange={(e) => update({ whatsapp: e.target.value })} />
        </label>
        <label style={{ flex: 1 }}>Telegram
          <input type="text" value={form.telegram_username} style={{ display: 'block', width: '100%' }}
            onChange={(e) => update({ telegram_username: e.target.value })} />
        </label>
      </div>
      {!hasContact && <div style={{ fontSize: 11, color: '#a60' }}>Нужен хотя бы один контакт</div>}
      <label>Продукт
        <select required value={form.product_id} style={{ display: 'block', width: '100%' }}
          onChange={(e) => update({ product_id: e.target.value })}>
          <option value="">— выберите —</option>
          {products.map((p) => (
            <option key={p.id} value={p.id}>
              {p.brand} {p.model_name} {p.color_name}{p.variant ? ` (${p.variant})` : ''}
            </option>
          ))}
        </select>
      </label>
      <div style={{ display: 'flex', gap: 8 }}>
        <label style={{ flex: 1 }}>Начало
          <input type="date" required value={form.start_date} style={{ display: 'block', width: '100%' }}
            onChange={(e) => update({ start_date: e.target.value })} />
        </label>
        <label style={{ flex: 1 }}>Окончание
          <input type="date" required value={form.end_date} min={form.start_date} style={{ display: 'block', width: '100%' }}
            onChange={(e) => update({ end_date: e.target.value })} />
        </label>
      </div>
      {form.start_date && form.end_date && !daysValid && (
        <div style={{ fontSize: 11, color: '#a60' }}>Окончание должно быть позже начала (минимум 1 день)</div>
      )}
      <label>Локация (ссылка, необязательно)
        <input type="text" value={form.location_link} style={{ display: 'block', width: '100%' }}
          onChange={(e) => update({ location_link: e.target.value })} />
      </label>
      <label>Время доставки (необязательно)
        <select value={form.delivery_time} style={{ display: 'block', width: '100%' }}
          onChange={(e) => update({ delivery_time: e.target.value })}>
          <option value="">— не указано —</option>
          {DELIVERY_TIME_OPTIONS.map((time) => <option key={time} value={time}>{time}</option>)}
        </select>
      </label>
      <fieldset style={{ border: '1px solid #ddd', borderRadius: 4, padding: 10 }}>
        <legend style={{ fontSize: 13, color: '#666' }}>Страховка (необязательно)</legend>
        <label style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
          <input type="checkbox" checked={theft} onChange={(e) => setTheft(e.target.checked)} />
          От угона
        </label>
        <label style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
          <input type="checkbox" checked={damageOn} onChange={(e) => setDamageOn(e.target.checked)} />
          От повреждений
        </label>
        {damageOn && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6, paddingLeft: 20 }}>
            <label>Покрытие
              <select value={coverage} style={{ display: 'block', width: '100%' }}
                onChange={(e) => setCoverage(e.target.value)}>
                {insuranceOptions.damage.map((d) => (
                  <option key={d.coverage_idr} value={d.coverage_idr}>{formatIdr(d.coverage_idr)}</option>
                ))}
              </select>
            </label>
            <label>Возраст водителя
              <input type="number" min="16" max="99" value={age} style={{ display: 'block', width: 80 }}
                onChange={(e) => setAge(e.target.value)} />
            </label>
            <label style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <input type="checkbox" checked={hasLicense} onChange={(e) => setHasLicense(e.target.checked)} />
              Есть права
            </label>
            <label style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <input type="checkbox" checked={experienced} onChange={(e) => setExperienced(e.target.checked)} />
              Опытный водитель
            </label>
          </div>
        )}
      </fieldset>
      {helmets.length > 0 && (
        <fieldset style={{ border: '1px solid #ddd', borderRadius: 4, padding: 10 }}>
          <legend style={{ fontSize: 13, color: '#666' }}>Шлемы (2 слота на байк)</legend>
          {[0, 1].map((i) => {
            const defaultFreeCode = helmets.find((h) => h.rental_price_idr === 0)?.code ?? helmets[0]?.code ?? null;
            return (
              <div key={i} style={{ marginBottom: 6 }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <input type="checkbox" checked={helmetSlots[i] != null}
                    onChange={(e) => setHelmetSlots((s) => {
                      const next = [...s];
                      next[i] = e.target.checked ? defaultFreeCode : null;
                      return next;
                    })} />
                  Слот {i + 1}
                </label>
                {helmetSlots[i] != null && (
                  <select value={helmetSlots[i]} style={{ display: 'block', width: '100%', marginTop: 4 }}
                    onChange={(e) => setHelmetSlots((s) => { const next = [...s]; next[i] = e.target.value; return next; })}>
                    {helmets.map((h) => (
                      <option key={h.code} value={h.code}>
                        {h.rental_price_idr > 0 ? `${h.name} (+${formatIdr(h.rental_price_idr)})` : `${h.name} — бесплатно`}
                      </option>
                    ))}
                  </select>
                )}
              </div>
            );
          })}
        </fieldset>
      )}
      {extrasList.length > 0 && (
        <fieldset style={{ border: '1px solid #ddd', borderRadius: 4, padding: 10 }}>
          <legend style={{ fontSize: 13, color: '#666' }}>Другое оборудование (необязательно)</legend>
          {extrasList.map((eq) => (
            <label key={eq.code} style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
              <input type="checkbox" checked={Boolean(extras[eq.code])}
                onChange={(e) => setExtras((x) => ({ ...x, [eq.code]: e.target.checked }))} />
              {eq.name}
              <span style={{ color: '#888', fontSize: 12 }}>{eq.rental_price_idr > 0 ? formatIdr(eq.rental_price_idr) : 'бесплатно'}</span>
            </label>
          ))}
        </fieldset>
      )}
      {previewReady && <QuotePreview status={quoteStatus} result={quote} rentalDays={rentalDays} />}
      <div style={{ display: 'flex', gap: 8 }}>
        <button type="submit" disabled={busy || !canSubmit}>Создать</button>
        <button type="button" disabled={busy} onClick={() => setOpen(false)}>Закрыть форму</button>
      </div>
    </form>
  );

  return (
    <>
      {formNode}
      {created && (
        <div style={{ border: '2px solid #1a2b6d', borderRadius: 6, padding: 16, marginBottom: 16, maxWidth: 560 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 8, marginBottom: 10 }}>
            <h3 style={{ margin: 0, fontSize: 16 }}>
              Новая заявка №{created.booking_number} — продолжите оформление
            </h3>
            <button type="button" onClick={() => setCreated(null)}>Свернуть</button>
          </div>
          {createdBooking ? (
            <>
              <div style={{ fontSize: 13, color: '#555', marginBottom: 10 }}>
                {createdBooking.customer_name} · {createdBooking.brand} {createdBooking.model_name} ·{' '}
                {createdBooking.start_date} → {createdBooking.end_date} · {money(createdBooking.total_payable_idr)} · статус: {createdBooking.status}
              </div>
              <ActionCell key={createdBooking.id} booking={createdBooking} drivers={drivers}
                busy={busyId === createdBooking.id} onAction={onAction} />
            </>
          ) : (
            <div style={{ fontSize: 13, color: '#888' }}>
              Заявки нет в текущем списке (проверьте фильтр по статусу) — она доступна в таблице ниже.
            </div>
          )}
        </div>
      )}
    </>
  );
}

function BookingsTab() {
  const [bookings, setBookings] = useState([]);
  const [drivers, setDrivers] = useState([]);
  const [statusFilter, setStatusFilter] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [busyId, setBusyId] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const qs = statusFilter ? `?status=${encodeURIComponent(statusFilter)}` : '';
      const [bRes, dRes] = await Promise.all([
        fetch(`${BOOKINGS_API}${qs}`, { cache: 'no-store' }),
        fetch(DRIVERS_API, { cache: 'no-store' }),
      ]);
      const bJson = await bRes.json();
      if (!bRes.ok) throw new Error(bJson.message || `HTTP ${bRes.status}`);
      const dJson = await dRes.json();
      setBookings(bJson.data ?? []);
      setDrivers(dJson.data ?? []);
      setError('');
    } catch (e) {
      setError(`Не удалось загрузить: ${e.message}`);
    } finally {
      setLoading(false);
    }
  }, [statusFilter]);

  useEffect(() => { load(); }, [load]);

  async function handleAction(id, action, body) {
    setBusyId(id);
    setError('');
    try {
      const res = await fetch(`${BOOKINGS_API}/${id}/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      if (!res.ok) {
        const json = await res.json().catch(() => ({}));
        setError(json.message || `Ошибка ${res.status}`);
        return;
      }
      await load();
    } finally {
      setBusyId(null);
    }
  }

  return (
    <>
      <CreateBookingForm bookings={bookings} drivers={drivers} busyId={busyId} onAction={handleAction} onCreated={load} />

      <div style={{ margin: '16px 0' }}>
        <label>
          Фильтр по статусу:{' '}
          <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
            <option value="">активные (не fulfilled/cancelled/expired)</option>
            {STATUS_OPTIONS.map((s) => <option key={s} value={s}>{s}</option>)}
          </select>
        </label>
      </div>

      {error && <div style={{ color: '#c00', fontSize: 13, marginBottom: 12 }}>{error}</div>}

      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 14 }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #ddd', textAlign: 'left' }}>
            <th style={{ padding: 8 }}>№</th>
            <th style={{ padding: 8 }}>Статус</th>
            <th style={{ padding: 8 }}>Клиент</th>
            <th style={{ padding: 8 }}>Даты</th>
            <th style={{ padding: 8 }}>Продукт</th>
            <th style={{ padding: 8 }}>Байк</th>
            <th style={{ padding: 8 }}>Водитель</th>
            <th style={{ padding: 8 }}>К оплате</th>
            <th style={{ padding: 8 }}>Действие</th>
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan={9} style={{ padding: 8 }}>Загрузка…</td></tr>
          ) : bookings.length === 0 ? (
            <tr><td colSpan={9} style={{ padding: 8, color: '#888' }}>Ничего не найдено</td></tr>
          ) : bookings.map((b) => (
            <tr key={b.id} style={{ borderBottom: '1px solid #eee' }}>
              <td style={{ padding: 8 }}>{b.booking_number}</td>
              <td style={{ padding: 8 }}>{b.status}</td>
              <td style={{ padding: 8 }}>
                <div>{b.customer_name}</div>
                <div style={{ color: '#888', fontSize: 12 }}>{contactsText(b)}</div>
              </td>
              <td style={{ padding: 8 }}>{b.start_date} → {b.end_date} ({b.rental_days}д)</td>
              <td style={{ padding: 8 }}>{b.brand} {b.model_name}</td>
              <td style={{ padding: 8 }}>{b.fleet_internal_number != null ? `№${b.fleet_internal_number} ${b.fleet_license_plate}` : '—'}</td>
              <td style={{ padding: 8 }}>{b.driver_name ?? '—'}</td>
              <td style={{ padding: 8 }}>{money(b.total_payable_idr)}</td>
              <td style={{ padding: 8 }}>
                <ActionCell booking={b} drivers={drivers} busy={busyId === b.id} onAction={handleAction} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
}

function RentalsTab() {
  const [rentals, setRentals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    (async () => {
      setLoading(true);
      try {
        const res = await fetch(RENTALS_API, { cache: 'no-store' });
        const json = await res.json();
        if (!res.ok) throw new Error(json.message || `HTTP ${res.status}`);
        setRentals(json.data ?? []);
        setError('');
      } catch (e) {
        setError(`Не удалось загрузить: ${e.message}`);
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  return (
    <>
      {error && <div style={{ color: '#c00', fontSize: 13, margin: '16px 0' }}>{error}</div>}
      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 14, marginTop: 16 }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #ddd', textAlign: 'left' }}>
            <th style={{ padding: 8 }}>Бронь №</th>
            <th style={{ padding: 8 }}>Клиент</th>
            <th style={{ padding: 8 }}>Байк</th>
            <th style={{ padding: 8 }}>Даты</th>
            <th style={{ padding: 8 }}>Депозит</th>
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan={5} style={{ padding: 8 }}>Загрузка…</td></tr>
          ) : rentals.length === 0 ? (
            <tr><td colSpan={5} style={{ padding: 8, color: '#888' }}>Активных аренд нет</td></tr>
          ) : rentals.map((r) => (
            <tr key={r.id} style={{ borderBottom: '1px solid #eee' }}>
              <td style={{ padding: 8 }}>{r.booking_number}</td>
              <td style={{ padding: 8 }}>
                <div>{r.customer_name}</div>
                <div style={{ color: '#888', fontSize: 12 }}>{contactsText(r)}</div>
              </td>
              <td style={{ padding: 8 }}>{r.brand} {r.model_name} №{r.fleet_internal_number} ({r.license_plate})</td>
              <td style={{ padding: 8 }}>{r.start_date} → {r.end_date}</td>
              <td style={{ padding: 8 }}>{money(r.deposit_amount_idr)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
}

export default function BookingsAdminClient() {
  const [tab, setTab] = useState('bookings');

  return (
    <div style={{ maxWidth: 1200, margin: '40px auto', padding: '0 20px', fontFamily: 'system-ui, sans-serif' }}>
      <h1 style={{ fontSize: 22 }}>Заявки и аренды</h1>
      <p style={{ color: '#666', fontSize: 14 }}>
        Одна кнопка на статус — цепочка created → fleet_item_assigned →
        confirmed → driver_assigned → awaiting_payment → paid → fulfilled.
        Шаг "Завершить (Fulfilled)" создаёт запись в rentals и переводит байк
        в rented.
      </p>

      <div style={{ display: 'flex', gap: 4, borderBottom: '1px solid #ddd', marginTop: 16 }}>
        {[['bookings', 'Заявки'], ['rentals', 'Аренды']].map(([key, label]) => (
          <button key={key} onClick={() => setTab(key)}
            style={{
              padding: '8px 14px', border: 'none', background: 'none', cursor: 'pointer',
              borderBottom: tab === key ? '2px solid #1a2b6d' : '2px solid transparent',
              fontWeight: tab === key ? 600 : 400, color: tab === key ? '#1a2b6d' : '#666',
            }}>
            {label}
          </button>
        ))}
      </div>

      {tab === 'bookings' ? <BookingsTab /> : <RentalsTab />}
    </div>
  );
}
