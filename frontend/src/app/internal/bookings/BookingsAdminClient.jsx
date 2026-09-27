'use client';

import { useEffect, useState, useCallback } from 'react';

const BOOKINGS_API = '/api/admin/bookings';
const DRIVERS_API = '/api/admin/drivers';
const RENTALS_API = '/api/admin/rentals';

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
    const tierLabel = tier === 'exact' ? 'Точное совпадение'
      : tier === 'same_family' ? 'Другой цвет, та же модель'
      : tier === 'replacement_group' ? `Замена по группе: ${assignable.replacement_group_name ?? '—'}`
      : null;
    const isReplacement = tier === 'same_family' || tier === 'replacement_group';
    const reasonOk = !isReplacement || replacementReason.trim();

    return (
      <div style={{ display: 'flex', gap: 6, alignItems: 'center', flexWrap: 'wrap' }}>
        {tierLabel && <span style={{ fontSize: 11, color: '#666' }}>{tierLabel}:</span>}
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
  }

  if (booking.status === 'fleet_item_assigned') {
    return (
      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <button disabled={busy} onClick={() => onAction(booking.id, 'confirm', {})}>Подтвердить</button>
        <BackButton busy={busy} onClick={() => onAction(booking.id, 'unassign-fleet-item', {})} />
      </div>
    );
  }

  if (booking.status === 'confirmed') {
    const activeDrivers = drivers.filter((d) => d.is_active);
    return (
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
  }

  if (booking.status === 'driver_assigned') {
    if (booking.has_pengiriman_task) {
      return (
        <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
          <span style={{ color: '#0a0', fontSize: 12 }}>✓ задача водителю создана</span>
          <button disabled={busy} onClick={() => onAction(booking.id, 'mark-awaiting-payment', {})}>Отметить: ожидает оплаты</button>
          <BackButton busy={busy} onClick={() => onAction(booking.id, 'unassign-driver', {})} />
        </div>
      );
    }
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
    return (
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

  if (booking.status === 'awaiting_payment') {
    return (
      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <button disabled={busy} onClick={() => onAction(booking.id, 'mark-paid', {})}>Отметить: оплачено</button>
        <BackButton busy={busy} onClick={() => onAction(booking.id, 'unmark-awaiting-payment', {})} />
      </div>
    );
  }

  if (booking.status === 'paid') {
    return (
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
  }

  // fulfilled — терминальный шаг в обычном потоке, но откат нужен на случай
  // ошибочного клика (реальной выдачи байка не было): unfulfillBooking()
  // полностью удаляет rentals/events, байк возвращается в 'reserved'
  // (CRM v1.1 Раздел 2, дизайн подтверждён Дмитрием 2026-09-27).
  if (booking.status === 'fulfilled') {
    return (
      <BackButton busy={busy}
        confirmText="Откатить Fulfilled? Запись в rentals будет удалена целиком — используйте только если реальной выдачи байка не было."
        onClick={() => onAction(booking.id, 'unfulfill', {})} />
    );
  }

  return <span style={{ color: '#888' }}>—</span>;
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
