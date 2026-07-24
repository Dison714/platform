'use client';

import { useEffect, useState, useCallback } from 'react';

const API = '/api/admin/insurance-plans';

const KIND_LABEL = { theft: 'Theft', damage: 'Damage' };
const DRIVER_LABEL = { experienced: 'Опытный', inexperienced: 'Неопытный' };

export default function InsuranceAdminClient() {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [editingId, setEditingId] = useState(null);
  const [draft, setDraft] = useState('');
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
    setDraft(String(row.monthly_idr));
    setError('');
  }

  function cancelEdit() {
    setEditingId(null);
    setDraft('');
  }

  async function saveEdit(id) {
    const monthly = Number(draft);
    if (!Number.isFinite(monthly) || monthly < 0) { setError('Сумма должна быть неотрицательным числом'); return; }
    setBusy(true);
    try {
      const res = await fetch(`${API}/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ monthly_idr: monthly }),
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
      <h1 style={{ fontSize: 22 }}>Страховка — тарифы</h1>
      <p style={{ color: '#666', fontSize: 14 }}>
        Theft: единый тариф в месяц. Damage: по категории водителя × сумме покрытия.
        Здесь редактируется только сумма — набор строк фиксирован логикой калькулятора.
      </p>

      <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 20, fontSize: 14 }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #ddd', textAlign: 'left' }}>
            <th style={{ padding: 8 }}>Вид</th>
            <th style={{ padding: 8 }}>Водитель</th>
            <th style={{ padding: 8 }}>Покрытие</th>
            <th style={{ padding: 8 }}>Только Бали</th>
            <th style={{ padding: 8 }}>В месяц (IDR)</th>
            <th style={{ padding: 8 }} />
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan={6} style={{ padding: 8 }}>Загрузка…</td></tr>
          ) : rows.map((r) => (
            <tr key={r.id} style={{ borderBottom: '1px solid #eee' }}>
              <td style={{ padding: 8 }}>{KIND_LABEL[r.kind] ?? r.kind}</td>
              <td style={{ padding: 8 }}>{r.driver_exp ? (DRIVER_LABEL[r.driver_exp] ?? r.driver_exp) : '—'}</td>
              <td style={{ padding: 8 }}>{r.coverage_idr ? Number(r.coverage_idr).toLocaleString('en-US') : '—'}</td>
              <td style={{ padding: 8 }}>{r.bali_only ? 'да' : 'нет'}</td>
              <td style={{ padding: 8 }}>
                {editingId === r.id ? (
                  <input
                    type="number"
                    value={draft}
                    onChange={(e) => setDraft(e.target.value)}
                    style={{ width: 120 }}
                  />
                ) : (
                  Number(r.monthly_idr).toLocaleString('en-US')
                )}
              </td>
              <td style={{ padding: 8, whiteSpace: 'nowrap' }}>
                {editingId === r.id ? (
                  <>
                    <button onClick={() => saveEdit(r.id)} disabled={busy} style={{ marginRight: 8 }}>сохранить</button>
                    <button onClick={cancelEdit} disabled={busy}>отмена</button>
                  </>
                ) : (
                  <button onClick={() => startEdit(r)} disabled={busy}>изменить</button>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {error && <div style={{ color: '#c00', fontSize: 13, marginTop: 12 }}>{error}</div>}
    </div>
  );
}
