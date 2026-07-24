'use client';

import { useEffect, useState, useCallback } from 'react';

const API = '/api/admin/delivery-fee-rules';

const emptyForm = { min_days: '', max_days: '', fee_idr: '', manager_approval: false, note: '' };

export default function DeliveryAdminClient() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetch(API, { cache: 'no-store' });
      const json = await res.json();
      if (!res.ok) throw new Error(json.message || `HTTP ${res.status}`);
      setRows(json.data ?? []);
      setError('');
    } catch (e) {
      setError(`Не удалось загрузить список: ${e.message}`);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  function startEdit(row) {
    setEditingId(row.id);
    setForm({
      min_days: String(row.min_days),
      max_days: row.max_days == null ? '' : String(row.max_days),
      fee_idr: String(row.fee_idr),
      manager_approval: row.manager_approval,
      note: row.note ?? '',
    });
    setError('');
  }

  function cancelEdit() {
    setEditingId(null);
    setForm(emptyForm);
    setError('');
  }

  async function handleDelete(id) {
    if (!confirm('Удалить тир?')) return;
    setBusy(true);
    try {
      await fetch(`${API}/${id}`, { method: 'DELETE' });
      await load();
      if (editingId === id) cancelEdit();
    } finally {
      setBusy(false);
    }
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');

    const min = Number(form.min_days);
    if (!Number.isInteger(min) || min < 1) { setError('«От» должно быть целым числом от 1'); return; }
    const max = form.max_days.trim() === '' ? null : Number(form.max_days);
    if (max !== null && (!Number.isInteger(max) || max < min)) { setError('«До» должно быть целым числом ≥ «От», либо пусто (без верхней границы)'); return; }
    const fee = Number(form.fee_idr);
    if (!Number.isFinite(fee) || fee < 0) { setError('Стоимость должна быть неотрицательным числом'); return; }

    setBusy(true);
    try {
      const body = JSON.stringify({
        min_days: min,
        max_days: max,
        fee_idr: fee,
        manager_approval: form.manager_approval,
        note: form.note,
      });
      const res = await fetch(editingId ? `${API}/${editingId}` : API, {
        method: editingId ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body,
      });
      if (!res.ok) {
        const json = await res.json().catch(() => ({}));
        if (res.status === 409) {
          setError('Сервер отклонил: диапазон пересекается с существующим тиром (проверено в БД).');
        } else {
          setError(json.message || `Ошибка ${res.status}`);
        }
        return;
      }
      await load();
      cancelEdit();
    } finally {
      setBusy(false);
    }
  }

  return (
    <div style={{ maxWidth: 760, margin: '40px auto', padding: '0 20px', fontFamily: 'system-ui, sans-serif' }}>
      <h1 style={{ fontSize: 22 }}>Доставка — тарифы по сроку аренды</h1>
      <p style={{ color: '#666', fontSize: 14 }}>
        Стоимость доставки зависит от СРОКА аренды, не от расстояния. «До» можно
        оставить пустым — тир без верхней границы (последний тир обычно такой).
      </p>

      <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 20, fontSize: 14 }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #ddd', textAlign: 'left' }}>
            <th style={{ padding: 8 }}>От (дней)</th>
            <th style={{ padding: 8 }}>До (дней)</th>
            <th style={{ padding: 8 }}>Стоимость (IDR)</th>
            <th style={{ padding: 8 }}>Approval менеджера</th>
            <th style={{ padding: 8 }}>Заметка</th>
            <th style={{ padding: 8 }} />
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan={6} style={{ padding: 8 }}>Загрузка…</td></tr>
          ) : rows.length === 0 ? (
            <tr><td colSpan={6} style={{ padding: 8, color: '#888' }}>Тиров нет</td></tr>
          ) : rows.map((r) => (
            <tr key={r.id} style={{ borderBottom: '1px solid #eee' }}>
              <td style={{ padding: 8 }}>{r.min_days}</td>
              <td style={{ padding: 8 }}>{r.max_days ?? '∞'}</td>
              <td style={{ padding: 8 }}>{Number(r.fee_idr).toLocaleString('en-US')}</td>
              <td style={{ padding: 8 }}>{r.manager_approval ? 'да' : 'нет'}</td>
              <td style={{ padding: 8 }}>{r.note ?? '—'}</td>
              <td style={{ padding: 8, whiteSpace: 'nowrap' }}>
                <button onClick={() => startEdit(r)} disabled={busy} style={{ marginRight: 8 }}>изменить</button>
                <button onClick={() => handleDelete(r.id)} disabled={busy}>удалить</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <h2 style={{ fontSize: 18, marginTop: 32 }}>{editingId ? 'Изменить тир' : 'Новый тир'}</h2>
      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 10, maxWidth: 360 }}>
        <label>
          От (дней)
          <input type="number" min="1" value={form.min_days} required
            onChange={(e) => setForm((f) => ({ ...f, min_days: e.target.value }))}
            style={{ display: 'block', width: '100%' }} />
        </label>
        <label>
          До (дней) — пусто = без верхней границы
          <input type="number" min="1" value={form.max_days}
            onChange={(e) => setForm((f) => ({ ...f, max_days: e.target.value }))}
            style={{ display: 'block', width: '100%' }} />
        </label>
        <label>
          Стоимость (IDR)
          <input type="number" step="1" min="0" value={form.fee_idr} required
            onChange={(e) => setForm((f) => ({ ...f, fee_idr: e.target.value }))}
            style={{ display: 'block', width: '100%' }} />
        </label>
        <label>
          <input type="checkbox" checked={form.manager_approval}
            onChange={(e) => setForm((f) => ({ ...f, manager_approval: e.target.checked }))} />
          {' '}Требует approval менеджера (удалённые районы)
        </label>
        <label>
          Заметка (необязательно)
          <input type="text" value={form.note}
            onChange={(e) => setForm((f) => ({ ...f, note: e.target.value }))}
            style={{ display: 'block', width: '100%' }} />
        </label>

        {error && <div style={{ color: '#c00', fontSize: 13 }}>{error}</div>}

        <div style={{ display: 'flex', gap: 8 }}>
          <button type="submit" disabled={busy}>{editingId ? 'Сохранить' : 'Добавить'}</button>
          {editingId && <button type="button" onClick={cancelEdit} disabled={busy}>Отмена</button>}
        </div>
      </form>
    </div>
  );
}
