'use client';

import { useEffect, useState, useCallback } from 'react';

const TASKS_API = '/api/admin/driver-tasks';
const TASK_TYPES_API = '/api/admin/task-types';
const DRIVERS_API = '/api/admin/drivers';
const BOOKINGS_API = '/api/admin/bookings';

// task_status enum (001_foundation.sql).
const TASK_STATUSES = ['pending', 'acknowledged', 'in_progress', 'completed', 'cancelled'];

const emptyForm = {
  type_code: '', booking_id: '', scheduled_date: '', scheduled_time: '',
  assigned_driver_slot: '', comment: '',
};

export default function DriverTasksAdminClient() {
  const [tasks, setTasks] = useState([]);
  const [taskTypes, setTaskTypes] = useState([]);
  const [drivers, setDrivers] = useState([]);
  const [bookings, setBookings] = useState([]);
  const [statusFilter, setStatusFilter] = useState('');
  const [typeFilter, setTypeFilter] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const [busyId, setBusyId] = useState(null);
  const [form, setForm] = useState(emptyForm);
  const [testResult, setTestResult] = useState(null);

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
      const [ttRes, dRes, bRes, bFulfilledRes] = await Promise.all([
        fetch(TASK_TYPES_API, { cache: 'no-store' }),
        fetch(DRIVERS_API, { cache: 'no-store' }),
        fetch(BOOKINGS_API, { cache: 'no-store' }),
        fetch(`${BOOKINGS_API}?status=fulfilled`, { cache: 'no-store' }),
      ]);
      setTaskTypes((await ttRes.json()).data ?? []);
      setDrivers((await dRes.json()).data ?? []);
      const active = (await bRes.json()).data ?? [];
      const fulfilled = (await bFulfilledRes.json()).data ?? [];
      setBookings([...active, ...fulfilled]);
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

  async function handleCreate(e) {
    e.preventDefault();
    setError('');
    if (!form.type_code) { setError('Выберите тип задачи'); return; }
    if (!form.scheduled_date) { setError('Укажите дату'); return; }

    setBusy(true);
    try {
      const res = await fetch(TASKS_API, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          type_code: form.type_code,
          booking_id: form.booking_id || null,
          scheduled_date: form.scheduled_date,
          scheduled_time: form.scheduled_time || null,
          assigned_driver_slot: form.assigned_driver_slot ? Number(form.assigned_driver_slot) : null,
          comment: form.comment || null,
        }),
      });
      if (!res.ok) {
        const json = await res.json().catch(() => ({}));
        setError(json.message || `Ошибка ${res.status}`);
        return;
      }
      setForm(emptyForm);
      await loadTasks();
    } finally {
      setBusy(false);
    }
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
        <label>
          Дата
          <input type="date" required value={form.scheduled_date} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ scheduled_date: e.target.value })} />
        </label>
        <label>
          Время (необязательно)
          <input type="time" value={form.scheduled_time} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ scheduled_time: e.target.value })} />
        </label>
        <label>
          Водитель (необязательно)
          <select value={form.assigned_driver_slot} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ assigned_driver_slot: e.target.value })}>
            <option value="">— не назначен —</option>
            {activeDrivers.map((d) => <option key={d.driver_slot} value={d.driver_slot}>{d.name}</option>)}
          </select>
        </label>
        <label>
          Комментарий (необязательно)
          <textarea value={form.comment} rows={2} style={{ display: 'block', width: '100%' }}
            onChange={(e) => updateForm({ comment: e.target.value })} />
        </label>
        <div>
          <button type="submit" disabled={busy}>Создать задачу</button>
        </div>
      </form>

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
              <td style={{ padding: 8 }}>{t.driver_name ?? '—'}</td>
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
