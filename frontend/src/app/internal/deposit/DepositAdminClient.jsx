'use client';

import { useEffect, useState, useCallback } from 'react';

const API = '/api/admin/deposit-config';
const RULES_API = '/api/admin/deposit-rules';

const emptyForm = { family_id: '', max_rental_days: '', deposit_idr: '', priority: '0', note: '' };

export default function DepositAdminClient() {
  const [baseIdr, setBaseIdr] = useState(0);
  const [baseDraft, setBaseDraft] = useState('');
  const [rules, setRules] = useState([]);
  const [families, setFamilies] = useState([]);
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
      setBaseIdr(json.data.base_idr);
      setBaseDraft(String(json.data.base_idr));
      setRules(json.data.rules ?? []);
      setFamilies(json.data.families ?? []);
      setError('');
    } catch (e) {
      setError(`Не удалось загрузить: ${e.message}`);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  async function saveBase() {
    const amount = Number(baseDraft);
    if (!Number.isFinite(amount) || amount < 0) { setError('Базовая сумма должна быть неотрицательным числом'); return; }
    setBusy(true);
    try {
      const res = await fetch(`${API}/base`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ deposit_idr: amount }),
      });
      if (!res.ok) {
        const json = await res.json().catch(() => ({}));
        setError(json.message || `Ошибка ${res.status}`);
        return;
      }
      await load();
    } finally {
      setBusy(false);
    }
  }

  function startEdit(row) {
    setEditingId(row.id);
    setForm({
      family_id: row.family_id,
      max_rental_days: row.max_rental_days == null ? '' : String(row.max_rental_days),
      deposit_idr: String(row.deposit_idr),
      priority: String(row.priority),
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
    if (!confirm('Удалить исключение?')) return;
    setBusy(true);
    try {
      await fetch(`${RULES_API}/${id}`, { method: 'DELETE' });
      await load();
      if (editingId === id) cancelEdit();
    } finally {
      setBusy(false);
    }
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');

    if (!form.family_id) { setError('Выберите модель'); return; }
    const maxDays = form.max_rental_days.trim() === '' ? null : Number(form.max_rental_days);
    if (maxDays !== null && (!Number.isInteger(maxDays) || maxDays < 1)) { setError('Максимум дней — целое число ≥ 1, либо пусто (любой срок)'); return; }
    const deposit = Number(form.deposit_idr);
    if (!Number.isFinite(deposit) || deposit < 0) { setError('Сумма депозита должна быть неотрицательным числом'); return; }
    const priority = Number(form.priority);
    if (!Number.isInteger(priority)) { setError('Приоритет — целое число'); return; }

    setBusy(true);
    try {
      const body = JSON.stringify({
        family_id: form.family_id,
        max_rental_days: maxDays,
        deposit_idr: deposit,
        priority,
        note: form.note,
      });
      const res = await fetch(editingId ? `${RULES_API}/${editingId}` : RULES_API, {
        method: editingId ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body,
      });
      if (!res.ok) {
        const json = await res.json().catch(() => ({}));
        setError(json.message || `Ошибка ${res.status}`);
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
      <h1 style={{ fontSize: 22 }}>Депозит</h1>
      <p style={{ color: '#666', fontSize: 14 }}>
        Базовая сумма действует, если ни одно исключение по модели не подошло.
        Из исключений для модели+срока аренды выбирается то, у которого выше
        приоритет (при равенстве — любое подходящее).
      </p>

      <h2 style={{ fontSize: 18, marginTop: 24 }}>Базовая сумма</h2>
      <div style={{ display: 'flex', gap: 8, alignItems: 'center', maxWidth: 360 }}>
        <input
          type="number" min="0" value={baseDraft}
          onChange={(e) => setBaseDraft(e.target.value)}
          style={{ flex: 1 }}
        />
        <button onClick={saveBase} disabled={busy || loading}>Сохранить</button>
      </div>
      {!loading && <p style={{ color: '#888', fontSize: 12 }}>Сейчас: {Number(baseIdr).toLocaleString('en-US')} IDR</p>}

      <h2 style={{ fontSize: 18, marginTop: 32 }}>Исключения по модели</h2>
      <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 8, fontSize: 14 }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #ddd', textAlign: 'left' }}>
            <th style={{ padding: 8 }}>Модель</th>
            <th style={{ padding: 8 }}>Макс. дней</th>
            <th style={{ padding: 8 }}>Депозит (IDR)</th>
            <th style={{ padding: 8 }}>Приоритет</th>
            <th style={{ padding: 8 }}>Заметка</th>
            <th style={{ padding: 8 }} />
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan={6} style={{ padding: 8 }}>Загрузка…</td></tr>
          ) : rules.length === 0 ? (
            <tr><td colSpan={6} style={{ padding: 8, color: '#888' }}>Исключений нет</td></tr>
          ) : rules.map((r) => (
            <tr key={r.id} style={{ borderBottom: '1px solid #eee' }}>
              <td style={{ padding: 8 }}>{r.brand} {r.model_name}</td>
              <td style={{ padding: 8 }}>{r.max_rental_days ?? 'любой'}</td>
              <td style={{ padding: 8 }}>{Number(r.deposit_idr).toLocaleString('en-US')}</td>
              <td style={{ padding: 8 }}>{r.priority}</td>
              <td style={{ padding: 8 }}>{r.note ?? '—'}</td>
              <td style={{ padding: 8, whiteSpace: 'nowrap' }}>
                <button onClick={() => startEdit(r)} disabled={busy} style={{ marginRight: 8 }}>изменить</button>
                <button onClick={() => handleDelete(r.id)} disabled={busy}>удалить</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <h2 style={{ fontSize: 18, marginTop: 32 }}>{editingId ? 'Изменить исключение' : 'Новое исключение'}</h2>
      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 10, maxWidth: 360 }}>
        <label>
          Модель
          <select value={form.family_id} required
            onChange={(e) => setForm((f) => ({ ...f, family_id: e.target.value }))}
            style={{ display: 'block', width: '100%' }}>
            <option value="">— выберите —</option>
            {families.map((f) => (
              <option key={f.id} value={f.id}>{f.brand} {f.model_name}</option>
            ))}
          </select>
        </label>
        <label>
          Макс. дней аренды (правило применяется, если срок ≤ этого) — пусто = любой срок
          <input type="number" min="1" value={form.max_rental_days}
            onChange={(e) => setForm((f) => ({ ...f, max_rental_days: e.target.value }))}
            style={{ display: 'block', width: '100%' }} />
        </label>
        <label>
          Депозит (IDR)
          <input type="number" step="1" min="0" value={form.deposit_idr} required
            onChange={(e) => setForm((f) => ({ ...f, deposit_idr: e.target.value }))}
            style={{ display: 'block', width: '100%' }} />
        </label>
        <label>
          Приоритет (выше = специфичнее, выбирается первым)
          <input type="number" step="1" value={form.priority}
            onChange={(e) => setForm((f) => ({ ...f, priority: e.target.value }))}
            style={{ display: 'block', width: '100%' }} />
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
