'use client';

import { useEffect, useState, useCallback } from 'react';

const API = '/api/admin/seasonal-multipliers';

function overlaps(a, b) {
  return a.date_from <= b.date_to && b.date_from <= a.date_to;
}

// Та же асимметричная логика, что триггер в БД (check_seasonal_multiplier_overlap):
// global конфликтует со всем; scoped — с global и со scoped той же области
// (т.е. с любым другим "current" — сейчас в системе один активный rule_set,
// так что "current" всегда означает одну и ту же область).
// Клиентская проверка — для быстрой обратной связи; сервер остаётся источником истины.
function findConflict(candidateIsGlobal, dateFrom, dateTo, existing, excludeId) {
  for (const row of existing) {
    if (row.id === excludeId) continue;
    if (!overlaps({ date_from: dateFrom, date_to: dateTo }, row)) continue;
    const rowGlobal = row.pricing_rule_set_id == null;
    if (candidateIsGlobal || rowGlobal) return row;
    return row; // оба scoped — единственный rule_set сейчас, значит та же область
  }
  return null;
}

const emptyForm = { date_from: '', date_to: '', multiplier: '1.00', scope: 'global' };

export default function PricingAdminClient() {
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
      date_from: row.date_from,
      date_to: row.date_to,
      multiplier: String(row.multiplier),
      scope: row.pricing_rule_set_id ? 'current' : 'global',
    });
    setError('');
  }

  function cancelEdit() {
    setEditingId(null);
    setForm(emptyForm);
    setError('');
  }

  async function handleDelete(id) {
    if (!confirm('Удалить период?')) return;
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

    if (!form.date_from || !form.date_to) { setError('Укажите обе даты'); return; }
    if (form.date_to < form.date_from) { setError('Дата окончания раньше даты начала'); return; }
    const mult = Number(form.multiplier);
    if (!Number.isFinite(mult) || mult <= 0) { setError('Множитель должен быть положительным числом'); return; }

    // клиентская проверка пересечений (быстрая обратная связь, не заменяет сервер)
    const conflict = findConflict(form.scope === 'global', form.date_from, form.date_to, rows, editingId);
    if (conflict) {
      setError(`Пересекается с периодом ${conflict.date_from} — ${conflict.date_to} (×${conflict.multiplier})`);
      return;
    }

    setBusy(true);
    try {
      const body = JSON.stringify({
        date_from: form.date_from,
        date_to: form.date_to,
        multiplier: mult,
        scope: form.scope,
      });
      const res = await fetch(editingId ? `${API}/${editingId}` : API, {
        method: editingId ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body,
      });
      if (!res.ok) {
        const json = await res.json().catch(() => ({}));
        if (res.status === 409) {
          setError('Сервер отклонил: период пересекается с существующим (проверено в БД).');
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
      <h1 style={{ fontSize: 22 }}>Сезонные мультипликаторы цены</h1>
      <p style={{ color: '#666', fontSize: 14 }}>
        Итоговая цена = CEIL(база × множитель / 50 000) × 50 000, всегда вверх.
        Применяется по дате НАЧАЛА аренды. «Глобальный» — для всех прайс-сетов;
        «текущий прайс-сет» — только для активного сейчас.
      </p>

      <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 20, fontSize: 14 }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #ddd', textAlign: 'left' }}>
            <th style={{ padding: 8 }}>С</th>
            <th style={{ padding: 8 }}>По</th>
            <th style={{ padding: 8 }}>Множитель</th>
            <th style={{ padding: 8 }}>Область</th>
            <th style={{ padding: 8 }} />
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan={5} style={{ padding: 8 }}>Загрузка…</td></tr>
          ) : rows.length === 0 ? (
            <tr><td colSpan={5} style={{ padding: 8, color: '#888' }}>Периодов нет — множитель везде 1.0</td></tr>
          ) : rows.map((r) => (
            <tr key={r.id} style={{ borderBottom: '1px solid #eee' }}>
              <td style={{ padding: 8 }}>{r.date_from}</td>
              <td style={{ padding: 8 }}>{r.date_to}</td>
              <td style={{ padding: 8 }}>×{r.multiplier}</td>
              <td style={{ padding: 8 }}>{r.pricing_rule_set_id ? 'текущий прайс-сет' : 'глобальный'}</td>
              <td style={{ padding: 8, whiteSpace: 'nowrap' }}>
                <button onClick={() => startEdit(r)} disabled={busy} style={{ marginRight: 8 }}>изменить</button>
                <button onClick={() => handleDelete(r.id)} disabled={busy}>удалить</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <h2 style={{ fontSize: 18, marginTop: 32 }}>{editingId ? 'Изменить период' : 'Новый период'}</h2>
      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 10, maxWidth: 360 }}>
        <label>
          Дата начала
          <input type="date" value={form.date_from} required
            onChange={(e) => setForm((f) => ({ ...f, date_from: e.target.value }))}
            style={{ display: 'block', width: '100%' }} />
        </label>
        <label>
          Дата окончания
          <input type="date" value={form.date_to} required
            onChange={(e) => setForm((f) => ({ ...f, date_to: e.target.value }))}
            style={{ display: 'block', width: '100%' }} />
        </label>
        <label>
          Множитель (напр. 1.30 = +30%)
          <input type="number" step="0.01" min="0.01" value={form.multiplier} required
            onChange={(e) => setForm((f) => ({ ...f, multiplier: e.target.value }))}
            style={{ display: 'block', width: '100%' }} />
        </label>
        <label>
          <input type="radio" name="scope" checked={form.scope === 'global'}
            onChange={() => setForm((f) => ({ ...f, scope: 'global' }))} />
          {' '}Глобальный (все прайс-сеты)
        </label>
        <label>
          <input type="radio" name="scope" checked={form.scope === 'current'}
            onChange={() => setForm((f) => ({ ...f, scope: 'current' }))} />
          {' '}Только текущий прайс-сет
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
