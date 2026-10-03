'use client';

import { useEffect, useMemo, useRef, useState, useCallback } from 'react';
import { DELIVERY_TIME_OPTIONS } from '../../../lib/timeSlots.js';
import { formatIdr } from '../../../lib/api.js';

const TASKS_API = '/api/admin/driver-tasks';
const TASK_TYPES_API = '/api/admin/task-types';
const DRIVERS_API = '/api/admin/drivers';
const BOOKINGS_API = '/api/admin/bookings';
const FLEET_ITEMS_API = '/api/admin/fleet-items';
const EQUIPMENT_API = '/api/admin/equipment-options';

// task_status enum (001_foundation.sql).
const TASK_STATUSES = ['pending', 'acknowledged', 'in_progress', 'completed', 'cancelled'];

const emptyForm = {
  type_code: '', booking_id: '', scheduled_date: '', scheduled_time: '',
  assigned_driver_slot: '', assigned_driver_slot_2: '', comment: '',
  location_text: '', customer_contact: '', fleet_item_id: '',
  pakai_mode: 'none', pakai_fleet_item_id: '', pakai_text: '',
  // Ветка "без брони + клиентский тип" (needs_customer): задача создаётся вместе
  // с новой бронью (create-manual → байк → подтверждение → водитель).
  customer_name: '', end_date: '',
};

const EMPTY_INSURANCE = { theft: false, damageOn: false, coverage: 1500000, age: 30, hasLicense: true, experienced: true };

function daysBetween(start, end) {
  return Math.round((new Date(end).getTime() - new Date(start).getTime()) / 86_400_000);
}

// Одно поле "Контакт клиента" → поле customers: @name → telegram_username,
// строка с "@" и "." → email, иначе WhatsApp (основной канал; в карточке
// водителю превращается в кликабельную wa.me-ссылку).
function customerFromContact(fullName, contact) {
  const c = contact.trim();
  const customer = { full_name: fullName.trim() };
  if (c.startsWith('@')) customer.telegram_username = c.slice(1);
  else if (c.includes('@') && c.includes('.')) customer.email = c;
  else customer.whatsapp = c;
  return customer;
}

async function postJson(url, body) {
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body ?? {}),
  });
  const json = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(json.message || `Ошибка ${res.status}`);
  return json.data;
}

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

export default function DriverTasksAdminClient() {
  const [tasks, setTasks] = useState([]);
  const [taskTypes, setTaskTypes] = useState([]);
  const [drivers, setDrivers] = useState([]);
  const [bookings, setBookings] = useState([]);
  const [fleetItems, setFleetItems] = useState([]);
  const [equipmentOptions, setEquipmentOptions] = useState([]);
  const [selectedEquipment, setSelectedEquipment] = useState({});
  const [statusFilter, setStatusFilter] = useState('');
  const [typeFilter, setTypeFilter] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const [busyId, setBusyId] = useState(null);
  const [form, setForm] = useState(emptyForm);
  const [testResult, setTestResult] = useState(null);
  const [insuranceOptions, setInsuranceOptions] = useState({ damage: [] });
  const [insurance, setInsurance] = useState(EMPTY_INSURANCE);
  const [quote, setQuote] = useState(null);
  const [quoteStatus, setQuoteStatus] = useState('idle'); // idle | loading | error
  // Цепочка "бронь → байк → подтверждение → водитель → задача" (ветка клиентского
  // типа без брони). Бронь создаётся первым шагом и остаётся, даже если один из
  // следующих шагов упал, — chainRef хранит всё нужное для повтора оставшихся.
  const chainRef = useRef(null);
  const [chainError, setChainError] = useState(null); // { bookingNumber, message }
  const [notice, setNotice] = useState('');

  // Справочники (типы задач/водители/брони) — загружаются один раз, не
  // зависят от фильтров списка задач ниже.
  //
  // Бронь для пикера — два запроса: дефолтный (активные, не
  // fulfilled/cancelled/expired) + отдельно fulfilled. Большинство реальных
  // задач раздела А (menjemput, tukar_motor, ambil_uang и т.п.) происходят
  // УЖЕ ПОСЛЕ того, как бронь стала fulfilled (это и есть момент начала
  // аренды, см. /internal/bookings) — без явного добавления fulfilled сюда
  // такая бронь пропадала бы из пикера сразу после первой же доставки.
  // GET /bookings поддерживает только один status за раз, отсюда два запроса.
  const loadRefs = useCallback(async () => {
    try {
      const [ttRes, dRes, bRes, bFulfilledRes, fiRes, eqRes] = await Promise.all([
        fetch(TASK_TYPES_API, { cache: 'no-store' }),
        fetch(DRIVERS_API, { cache: 'no-store' }),
        fetch(BOOKINGS_API, { cache: 'no-store' }),
        fetch(`${BOOKINGS_API}?status=fulfilled`, { cache: 'no-store' }),
        fetch(FLEET_ITEMS_API, { cache: 'no-store' }),
        fetch(EQUIPMENT_API, { cache: 'no-store' }),
      ]);
      setTaskTypes((await ttRes.json()).data ?? []);
      setDrivers((await dRes.json()).data ?? []);
      const active = (await bRes.json()).data ?? [];
      const fulfilled = (await bFulfilledRes.json()).data ?? [];
      setBookings([...active, ...fulfilled]);
      setFleetItems((await fiRes.json()).data ?? []);
      const eqData = (await eqRes.json()).data ?? {};
      setEquipmentOptions(eqData.equipment ?? []);
      const damage = eqData.insurance?.damage ?? [];
      setInsuranceOptions({ damage });
      setInsurance((i) => (damage.some((d) => d.coverage_idr === Number(i.coverage)) ? i : { ...i, coverage: damage[0]?.coverage_idr ?? 1500000 }));
    } catch (e) {
      setError(`Не удалось загрузить справочники: ${e.message}`);
    }
  }, []);

  const loadTasks = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (statusFilter) params.set('status', statusFilter);
      if (typeFilter) params.set('type_code', typeFilter);
      const qs = params.toString() ? `?${params}` : '';
      const res = await fetch(`${TASKS_API}${qs}`, { cache: 'no-store' });
      const json = await res.json();
      if (!res.ok) throw new Error(json.message || `HTTP ${res.status}`);
      setTasks(json.data ?? []);
      setError('');
    } catch (e) {
      setError(`Не удалось загрузить: ${e.message}`);
    } finally {
      setLoading(false);
    }
  }, [statusFilter, typeFilter]);

  useEffect(() => { loadRefs(); }, [loadRefs]);
  useEffect(() => { loadTasks(); }, [loadTasks]);

  // Ветка "без брони + клиентский тип": needs_customer приходит из task-types.
  const selectedType = taskTypes.find((t) => t.code === form.type_code);
  const clientBranch = !form.booking_id && Boolean(selectedType?.needs_customer);
  // В этой ветке байк занимается под НОВУЮ бронь — только свободные (фильтр на
  // уже загруженных fleetItems). Pakai и остальные ветки видят весь парк.
  const bikeOptions = clientBranch ? fleetItems.filter((f) => f.status === 'available') : fleetItems;
  const branchFleetItem = clientBranch ? fleetItems.find((f) => f.id === form.fleet_item_id) : null;
  const branchProductId = branchFleetItem?.product_id ?? '';

  // Оборудование (общий список формы) + страховка — одно и то же для
  // live-превью и для create-manual.
  const equipmentList = useMemo(
    () => Object.entries(selectedEquipment).filter(([, qty]) => qty > 0).map(([code, quantity]) => ({ code, quantity })),
    [selectedEquipment],
  );
  const insuranceBody = useMemo(() => {
    if (!insurance.theft && !insurance.damageOn) return undefined;
    const out = {};
    if (insurance.theft) out.theft = true;
    if (insurance.damageOn) {
      out.damage = { coverage_idr: Number(insurance.coverage) };
      out.driver = { age: Number(insurance.age), has_license: insurance.hasLicense, experienced: insurance.experienced };
    }
    return out;
  }, [insurance]);

  const rentalDays = form.scheduled_date && form.end_date ? daysBetween(form.scheduled_date, form.end_date) : NaN;
  const daysValid = Number.isInteger(rentalDays) && rentalDays >= 1;
  const previewReady = clientBranch && Boolean(branchProductId) && daysValid;

  // Live-превью: публичный /api/quote, debounce 400мс (как Calculator.jsx);
  // устаревшие ответы отбрасываются флагом cancelled.
  useEffect(() => {
    if (!previewReady) { setQuote(null); setQuoteStatus('idle'); return undefined; }
    let cancelled = false;
    setQuoteStatus('loading');
    const timer = setTimeout(async () => {
      try {
        const res = await fetch('/api/quote', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            product: branchProductId,
            rental_days: rentalDays,
            start_date: form.scheduled_date,
            ...(insuranceBody ? { insurance: insuranceBody } : {}),
            ...(equipmentList.length ? { equipment: equipmentList } : {}),
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
  }, [previewReady, branchProductId, form.scheduled_date, rentalDays, insuranceBody, equipmentList]);

  function updateForm(patch) {
    setForm((f) => ({ ...f, ...patch }));
  }

  // При выборе брони — если слот водителя ещё не выбран вручную, подставляем
  // тот, что уже назначен на бронь (bookings.assigned_driver_slot,
  // /internal/bookings, шаг confirmed→driver_assigned). Просто дефолт формы,
  // не серверная логика — правится вручную, если для этой задачи нужен
  // другой водитель.
  function handleBookingChange(bookingId) {
    const booking = bookings.find((b) => b.id === bookingId);
    setForm((f) => ({
      ...f,
      booking_id: bookingId,
      assigned_driver_slot: f.assigned_driver_slot || (booking?.assigned_driver_slot ? String(booking.assigned_driver_slot) : ''),
    }));
  }

  // Тело POST /driver-tasks — общее для обычной ветки и для шага (f) цепочки
  // (там добавляется booking_id новой брони).
  function buildTaskBody(extra = {}) {
    return {
      type_code: form.type_code,
      booking_id: form.booking_id || null,
      scheduled_date: form.scheduled_date,
      scheduled_time: form.scheduled_time || null,
      assigned_driver_slot: form.assigned_driver_slot ? Number(form.assigned_driver_slot) : null,
      assigned_driver_slot_2: form.assigned_driver_slot_2 ? Number(form.assigned_driver_slot_2) : null,
      comment: form.comment || null,
      location_text: form.location_text || null,
      customer_contact: form.customer_contact || null,
      fleet_item_id: form.fleet_item_id || null,
      pakai_fleet_item_id: form.pakai_mode === 'fleet' ? (form.pakai_fleet_item_id || null) : null,
      pakai_text: form.pakai_mode === 'text' ? (form.pakai_text.trim() || null) : null,
      equipment: equipmentList.length ? equipmentList : undefined,
      ...extra,
    };
  }

  function resetAfterSuccess() {
    chainRef.current = null;
    setChainError(null);
    setForm(emptyForm);
    setSelectedEquipment({});
    setInsurance((i) => ({ ...EMPTY_INSURANCE, coverage: insuranceOptions.damage[0]?.coverage_idr ?? i.coverage }));
  }

  // Оставшиеся шаги цепочки. Точка входа определяется по РЕАЛЬНОМУ статусу брони
  // (а не по номеру упавшего шага) — повтор безопасен, даже если запрос прошёл
  // на сервере, а ответ потерялся.
  async function runChain() {
    const ctx = chainRef.current;
    setChainError(null);
    setNotice('');
    try {
      const lr = await fetch(BOOKINGS_API, { cache: 'no-store' });
      const row = ((await lr.json()).data ?? []).find((b) => b.id === ctx.bookingId);
      if (!row) throw new Error('бронь не найдена среди активных — откройте /internal/bookings');
      let status = row.status;
      let autoTask = row.has_pengiriman_task;
      const base = `${BOOKINGS_API}/${ctx.bookingId}`;

      ctx.step = 'байк';
      if (status === 'created') {
        await postJson(`${base}/assign-fleet-item`, { fleet_item_id: ctx.fleetItemId });
        status = 'fleet_item_assigned';
      }
      ctx.step = 'подтверждение';
      if (status === 'fleet_item_assigned') {
        await postJson(`${base}/confirm`);
        status = 'confirmed';
      }
      ctx.step = 'водитель';
      if (status === 'confirmed') {
        const d = await postJson(`${base}/assign-driver`, { driver_slot: ctx.driverSlot });
        status = 'driver_assigned';
        autoTask = Boolean(d.driver_task?.created);
        if (!autoTask && ctx.typeCode === 'pengiriman') {
          throw new Error(`водитель назначен, но задача pengiriman не создана — не хватает: ${(d.driver_task?.missing_fields ?? []).join(', ') || '—'}. Дозаполните на /internal/bookings`);
        }
      }
      ctx.step = 'задача';
      if (ctx.typeCode === 'pengiriman') {
        // Задачу создал и отправил assign-driver (Раздел 1) — второй POST дал бы дубль.
        if (!autoTask) throw new Error('задача pengiriman не найдена после назначения водителя');
      } else if (!ctx.taskCreated) {
        await postJson(TASKS_API, { ...ctx.taskBody, booking_id: ctx.bookingId });
        ctx.taskCreated = true;
      }
      setNotice(`Бронь №${ctx.bookingNumber} создана и оформлена${ctx.typeCode === 'pengiriman' ? ', задача pengiriman создана и отправлена автоматически' : ', задача создана'}.`);
      resetAfterSuccess();
      await Promise.all([loadTasks(), loadRefs()]);
    } catch (e) {
      setChainError({ bookingNumber: ctx.bookingNumber, step: ctx.step, message: e.message });
      await Promise.all([loadTasks(), loadRefs()]);
    }
  }

  async function handleCreateClientChain() {
    if (!form.customer_name.trim()) { setError('Укажите имя клиента'); return; }
    if (!form.customer_contact.trim()) { setError('Укажите контакт клиента'); return; }
    if (!form.end_date) { setError('Укажите дату окончания аренды'); return; }
    if (!daysValid) { setError('Дата окончания должна быть позже даты начала (минимум 1 день)'); return; }
    if (!branchFleetItem || branchFleetItem.status !== 'available') { setError('Выберите свободный байк'); return; }
    if (!form.assigned_driver_slot) { setError('Выберите водителя'); return; }
    if (form.type_code === 'pengiriman' && (!form.location_text.trim() || !form.scheduled_time)) {
      setError('Для pengiriman нужны локация и время — без них автозадача не создастся');
      return;
    }
    const isPengiriman = form.type_code === 'pengiriman';
    const created = await postJson('/api/admin/bookings/create-manual', {
      product: branchFleetItem.product_id,
      start_date: form.scheduled_date,
      end_date: form.end_date,
      customer: customerFromContact(form.customer_name, form.customer_contact),
      insurance: insuranceBody,
      equipment: equipmentList.length ? equipmentList : undefined,
      location_link: form.location_text.trim() || undefined,
      // delivery_time на брони есть только у pengiriman: с ним assignDriver()
      // сам создаёт и шлёт pengiriman-задачу — для menjemput и т.п. это был бы
      // лишний дубль, поэтому там время остаётся только в самой задаче.
      delivery_time: isPengiriman ? (form.scheduled_time || undefined) : undefined,
    });
    chainRef.current = {
      bookingId: created.id,
      bookingNumber: created.booking_number,
      fleetItemId: form.fleet_item_id,
      driverSlot: Number(form.assigned_driver_slot),
      typeCode: form.type_code,
      taskBody: buildTaskBody(),
      taskCreated: false,
      step: 'бронь',
    };
    await runChain();
  }

  async function handleCreate(e) {
    e.preventDefault();
    setError('');
    setNotice('');
    if (!form.type_code) { setError('Выберите тип задачи'); return; }
    if (!form.scheduled_date) { setError('Укажите дату'); return; }

    setBusy(true);
    try {
      if (clientBranch) {
        try {
          await handleCreateClientChain();
        } catch (err) {
          // Сюда попадает только провал самого create-manual (брони ещё нет) —
          // ошибки следующих шагов ловит runChain и показывает в рамке цепочки.
          setError(`Не удалось создать бронь: ${err.message}`);
        }
        return;
      }
      const res = await fetch(TASKS_API, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(buildTaskBody()),
      });
      if (!res.ok) {
        const json = await res.json().catch(() => ({}));
        setError(json.message || `Ошибка ${res.status}`);
        return;
      }
      setForm(emptyForm);
      setSelectedEquipment({});
      await loadTasks();
    } finally {
      setBusy(false);
    }
  }

  async function handleRetryChain() {
    setBusy(true);
    setError('');
    try { await runChain(); } finally { setBusy(false); }
  }

  async function handleSendTest(id) {
    setBusyId(id);
    setError('');
    setTestResult(null);
    try {
      const res = await fetch(`${TASKS_API}/${id}/send-test`, { method: 'POST' });
      const json = await res.json().catch(() => ({}));
      if (!res.ok) {
        setError(json.message || `Ошибка ${res.status}`);
        return;
      }
      setTestResult(json.data);
    } finally {
      setBusyId(null);
    }
  }

  const sendAllowedTypes = taskTypes.filter((t) => t.send_allowed);
  const otherTypes = taskTypes.filter((t) => !t.send_allowed);
  const activeDrivers = drivers.filter((d) => d.is_active);

  return (
    <div style={{ maxWidth: 1200, margin: '40px auto', padding: '0 20px', fontFamily: 'system-ui, sans-serif' }}>
      <h1 style={{ fontSize: 22 }}>Задачи водителям</h1>
      <p style={{ color: '#666', fontSize: 14 }}>
        Кнопка "Отправить тест" шлёт черновой текст в тот же Telegram-канал,
        что и заявки менеджеру (<code>manager_telegram_chat_ids</code>) — НЕ в
        реальный водительский чат (бота туда ещё нет). Доступна только для
        клиентской логистики раздела А; для остальных типов задач —
        неактивна.
      </p>

      {error && <div style={{ color: '#c00', fontSize: 13, marginBottom: 12 }}>{error}</div>}

      <h2 style={{ fontSize: 18, marginTop: 24 }}>Новая задача</h2>
      <form onSubmit={handleCreate} style={{ display: 'flex', flexDirection: 'column', gap: 10, maxWidth: 440 }}>
        <label>
          Тип задачи
          <select value={form.type_code} required style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ type_code: e.target.value })}>
            <option value="">— выберите —</option>
            <optgroup label="Раздел А (можно отправить тест)">
              {sendAllowedTypes.map((t) => <option key={t.code} value={t.code}>{t.name_id} / {t.name_ru}</option>)}
            </optgroup>
            <optgroup label="Остальные типы (без отправки)">
              {otherTypes.map((t) => <option key={t.code} value={t.code}>{t.name_id} / {t.name_ru}</option>)}
            </optgroup>
          </select>
        </label>
        <label>
          Бронь (необязательно — подтягивает байк/контакты/Peralatan)
          <select value={form.booking_id} style={{ display: 'block', width: '100%' }}
            onChange={(e) => handleBookingChange(e.target.value)}>
            <option value="">— без брони —</option>
            {bookings.map((b) => (
              <option key={b.id} value={b.id}>
                №{b.booking_number} — {b.customer_name} — {b.brand} {b.model_name}
              </option>
            ))}
          </select>
        </label>
        {clientBranch && (
          <>
            <div style={{ fontSize: 12, color: '#445', background: '#f3f5ff', borderRadius: 4, padding: 8 }}>
              Клиентская задача без брони: вместе с ней создастся новая бронь
              (байк → подтверждение → водитель). Для pengiriman задачу создаёт и
              отправляет само назначение водителя.
            </div>
            <label>
              Клиент — имя
              <input type="text" required value={form.customer_name} style={{ display: 'block', width: '100%' }}
                onChange={(e) => updateForm({ customer_name: e.target.value })} />
            </label>
          </>
        )}
        <label>
          Локация{clientBranch && form.type_code === 'pengiriman' ? ' (обязательно для pengiriman)' : ''}
          <input type="text" value={form.location_text} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ location_text: e.target.value })} />
        </label>
        <label>
          Контакт клиента{clientBranch ? ' (WhatsApp/телефон, @telegram или email)' : ''}
          <input type="text" required={clientBranch} value={form.customer_contact} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ customer_contact: e.target.value })} />
        </label>
        <label>
          Байк {clientBranch ? '(обязательно, только свободные)' : '(необязательно)'}
          <select value={form.fleet_item_id} required={clientBranch} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ fleet_item_id: e.target.value })}>
            <option value="">— не выбран —</option>
            {bikeOptions.map((fi) => (
              <option key={fi.id} value={fi.id}>
                №{fi.internal_number} {fi.brand} {fi.model_name} {fi.license_plate}
              </option>
            ))}
          </select>
        </label>
        <label>
          {clientBranch ? 'Дата начала аренды (обычно = дата доставки)' : 'Дата'}
          <input type="date" required value={form.scheduled_date} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ scheduled_date: e.target.value })} />
        </label>
        {clientBranch && (
          <label>
            Дата окончания аренды
            <input type="date" required value={form.end_date} min={form.scheduled_date} style={{ display: 'block', width: '100%' }}
              onChange={(e) => updateForm({ end_date: e.target.value })} />
          </label>
        )}
        {clientBranch && form.scheduled_date && form.end_date && !daysValid && (
          <div style={{ fontSize: 11, color: '#a60' }}>Окончание должно быть позже начала (минимум 1 день)</div>
        )}
        <label>
          Время (необязательно)
          <select value={form.scheduled_time} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ scheduled_time: e.target.value })}>
            <option value="">— не указано —</option>
            {DELIVERY_TIME_OPTIONS.map((time) => <option key={time} value={time}>{time}</option>)}
          </select>
        </label>
        <label>
          Водитель {clientBranch ? '(обязательно)' : '(необязательно)'}
          <select value={form.assigned_driver_slot} required={clientBranch} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ assigned_driver_slot: e.target.value })}>
            <option value="">— не назначен —</option>
            {activeDrivers.map((d) => <option key={d.driver_slot} value={d.driver_slot}>{d.name}</option>)}
          </select>
        </label>
        <label>
          Второй водитель (необязательно — сценарий "два байка на задачу")
          <select value={form.assigned_driver_slot_2} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ assigned_driver_slot_2: e.target.value })}>
            <option value="">— не назначен —</option>
            {activeDrivers.map((d) => <option key={d.driver_slot} value={d.driver_slot}>{d.name}</option>)}
          </select>
        </label>
        <label>
          Pakai (байк, на котором водитель едет и возвращается)
          <select value={form.pakai_mode} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ pakai_mode: e.target.value, pakai_fleet_item_id: '', pakai_text: '' })}>
            <option value="none">— не используется —</option>
            <option value="fleet">Выбрать байк из парка</option>
            <option value="text">Указать текстом</option>
          </select>
        </label>
        {form.pakai_mode === 'fleet' && (
          <label>
            Pakai — байк
            <select value={form.pakai_fleet_item_id} style={{ display: 'block', width: '100%' }}
              onChange={(e) => updateForm({ pakai_fleet_item_id: e.target.value })}>
              <option value="">— не выбран —</option>
              {fleetItems.map((fi) => (
                <option key={fi.id} value={fi.id}>
                  №{fi.internal_number} {fi.brand} {fi.model_name} {fi.license_plate}
                </option>
              ))}
            </select>
          </label>
        )}
        {form.pakai_mode === 'text' && (
          <label>
            Pakai — текстом
            <input type="text" value={form.pakai_text} style={{ display: 'block', width: '100%' }}
              onChange={(e) => updateForm({ pakai_text: e.target.value })} />
          </label>
        )}
        <fieldset style={{ border: '1px solid #ddd', borderRadius: 4, padding: 10 }}>
          <legend style={{ fontSize: 13, color: '#666' }}>Оборудование (необязательно — формирует Peralatan)</legend>
          {equipmentOptions.length === 0 ? (
            <div style={{ fontSize: 13, color: '#888' }}>загрузка…</div>
          ) : equipmentOptions.map((eq) => (
            <div key={eq.code} style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
              <label style={{ display: 'flex', alignItems: 'center', gap: 6, flex: 1 }}>
                <input type="checkbox" checked={Boolean(selectedEquipment[eq.code])}
                  onChange={(e) => setSelectedEquipment((s) => {
                    const next = { ...s };
                    if (e.target.checked) next[eq.code] = next[eq.code] || 1;
                    else delete next[eq.code];
                    return next;
                  })} />
                {eq.name}
              </label>
              {Boolean(selectedEquipment[eq.code]) && (
                <input type="number" min={1} max={9} value={selectedEquipment[eq.code]} style={{ width: 48 }}
                  onChange={(e) => setSelectedEquipment((s) => ({ ...s, [eq.code]: Math.max(1, Number(e.target.value) || 1) }))} />
              )}
            </div>
          ))}
        </fieldset>
        {clientBranch && (
          <fieldset style={{ border: '1px solid #ddd', borderRadius: 4, padding: 10 }}>
            <legend style={{ fontSize: 13, color: '#666' }}>Страховка (необязательно)</legend>
            <label style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
              <input type="checkbox" checked={insurance.theft}
                onChange={(e) => setInsurance((i) => ({ ...i, theft: e.target.checked }))} />
              От угона
            </label>
            <label style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
              <input type="checkbox" checked={insurance.damageOn}
                onChange={(e) => setInsurance((i) => ({ ...i, damageOn: e.target.checked }))} />
              От повреждений
            </label>
            {insurance.damageOn && (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 6, paddingLeft: 20 }}>
                <label>Покрытие
                  <select value={insurance.coverage} style={{ display: 'block', width: '100%' }}
                    onChange={(e) => setInsurance((i) => ({ ...i, coverage: e.target.value }))}>
                    {insuranceOptions.damage.map((d) => (
                      <option key={d.coverage_idr} value={d.coverage_idr}>{formatIdr(d.coverage_idr)}</option>
                    ))}
                  </select>
                </label>
                <label>Возраст водителя
                  <input type="number" min="16" max="99" value={insurance.age} style={{ display: 'block', width: 80 }}
                    onChange={(e) => setInsurance((i) => ({ ...i, age: e.target.value }))} />
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <input type="checkbox" checked={insurance.hasLicense}
                    onChange={(e) => setInsurance((i) => ({ ...i, hasLicense: e.target.checked }))} />
                  Есть права
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <input type="checkbox" checked={insurance.experienced}
                    onChange={(e) => setInsurance((i) => ({ ...i, experienced: e.target.checked }))} />
                  Опытный водитель
                </label>
              </div>
            )}
          </fieldset>
        )}
        <label>
          Комментарий (необязательно)
          <textarea value={form.comment} rows={2} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ comment: e.target.value })} />
        </label>
        {previewReady && <QuotePreview status={quoteStatus} result={quote} rentalDays={rentalDays} />}
        {chainError && (
          <div style={{ border: '1px solid #c00', borderRadius: 4, padding: 10, fontSize: 13 }}>
            <div style={{ color: '#c00', fontWeight: 600 }}>
              Бронь №{chainError.bookingNumber} уже создана — шаг «{chainError.step}» не прошёл
            </div>
            <div style={{ margin: '4px 0 8px' }}>{chainError.message}</div>
            <div style={{ display: 'flex', gap: 8 }}>
              <button type="button" disabled={busy} onClick={handleRetryChain}>Повторить оставшиеся шаги</button>
              <button type="button" disabled={busy} onClick={() => { chainRef.current = null; setChainError(null); }}>
                Оставить как есть
              </button>
            </div>
          </div>
        )}
        <div>
          <button type="submit" disabled={busy || Boolean(chainError)}>Создать задачу</button>
        </div>
      </form>
      {notice && <div style={{ color: '#0a0', fontSize: 13, marginTop: 8 }}>{notice}</div>}

      {testResult && (
        <div style={{ marginTop: 24, padding: 12, border: '1px solid #ddd', borderRadius: 4, background: '#fafafa' }}>
          <div style={{ fontWeight: 600, marginBottom: 6 }}>Отправленный текст:</div>
          <pre style={{ whiteSpace: 'pre-wrap', fontFamily: 'inherit', fontSize: 13 }}>{testResult.text}</pre>
          <div style={{ marginTop: 8, fontSize: 13 }}>
            {testResult.results.map((r) => (
              <div key={r.chat_id} style={{ color: r.status === 'sent' ? '#0a0' : '#c00' }}>
                chat {r.chat_id}: {r.status}{r.error ? ` — ${r.error}` : ''}
              </div>
            ))}
          </div>
        </div>
      )}

      <h2 style={{ fontSize: 18, marginTop: 32 }}>Список задач</h2>
      <div style={{ display: 'flex', gap: 16, margin: '12px 0', flexWrap: 'wrap' }}>
        <label>
          Статус:{' '}
          <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
            <option value="">все</option>
            {TASK_STATUSES.map((s) => <option key={s} value={s}>{s}</option>)}
          </select>
        </label>
        <label>
          Тип:{' '}
          <select value={typeFilter} onChange={(e) => setTypeFilter(e.target.value)}>
            <option value="">все</option>
            {taskTypes.map((t) => <option key={t.code} value={t.code}>{t.name_id}</option>)}
          </select>
        </label>
      </div>

      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 14 }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #ddd', textAlign: 'left' }}>
            <th style={{ padding: 8 }}>№</th>
            <th style={{ padding: 8 }}>Тип</th>
            <th style={{ padding: 8 }}>Дата/время</th>
            <th style={{ padding: 8 }}>Бронь</th>
            <th style={{ padding: 8 }}>Водитель</th>
            <th style={{ padding: 8 }}>Байк</th>
            <th style={{ padding: 8 }}>Статус</th>
            <th style={{ padding: 8 }}>Комментарий</th>
            <th style={{ padding: 8 }} />
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan={9} style={{ padding: 8 }}>Загрузка…</td></tr>
          ) : tasks.length === 0 ? (
            <tr><td colSpan={9} style={{ padding: 8, color: '#888' }}>Задач нет</td></tr>
          ) : tasks.map((t) => (
            <tr key={t.id} style={{ borderBottom: '1px solid #eee' }}>
              <td style={{ padding: 8 }}>{t.daily_seq ?? '—'}</td>
              <td style={{ padding: 8 }}>{t.type_name_id}</td>
              <td style={{ padding: 8 }}>{t.scheduled_date}{t.scheduled_time ? ` ${String(t.scheduled_time).slice(0, 5)}` : ''}</td>
              <td style={{ padding: 8 }}>{t.booking_number ? `№${t.booking_number}` : '—'}</td>
              <td style={{ padding: 8 }}>{[t.driver_name, t.driver_name_2].filter(Boolean).join(' + ') || '—'}</td>
              <td style={{ padding: 8 }}>{t.fleet_internal_number != null ? `№${t.fleet_internal_number}` : '—'}</td>
              <td style={{ padding: 8 }}>{t.status}</td>
              <td style={{ padding: 8, color: '#666' }}>{t.comment ?? ''}</td>
              <td style={{ padding: 8 }}>
                <button disabled={!t.send_allowed || busyId === t.id}
                  title={t.send_allowed ? '' : 'Отправка доступна только для раздела А'}
                  onClick={() => handleSendTest(t.id)}>
                  Отправить тест
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
