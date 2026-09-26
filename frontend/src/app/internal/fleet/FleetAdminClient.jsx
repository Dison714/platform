'use client';

import { useEffect, useState, useCallback } from 'react';

const API = '/api/admin/fleet-items';

// fleet_status enum (001_foundation.sql).
const STATUSES = ['available', 'prepared', 'reserved', 'rented', 'maintenance', 'repair', 'retired'];

export default function FleetAdminClient() {
  const [items, setItems] = useState([]);
  const [statusFilter, setStatusFilter] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [busyId, setBusyId] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const qs = statusFilter ? `?status=${encodeURIComponent(statusFilter)}` : '';
      const res = await fetch(`${API}${qs}`, { cache: 'no-store' });
      const json = await res.json();
      if (!res.ok) throw new Error(json.message || `HTTP ${res.status}`);
      setItems(json.data ?? []);
      setError('');
    } catch (e) {
      setError(`Не удалось загрузить: ${e.message}`);
    } finally {
      setLoading(false);
    }
  }, [statusFilter]);

  useEffect(() => { load(); }, [load]);

  async function handleStatusChange(id, status) {
    setBusyId(id);
    setError('');
    try {
      const res = await fetch(`${API}/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status }),
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
    <div style={{ maxWidth: 1000, margin: '40px auto', padding: '0 20px', fontFamily: 'system-ui, sans-serif' }}>
      <h1 style={{ fontSize: 22 }}>Флот</h1>
      <p style={{ color: '#666', fontSize: 14 }}>
        Статус — единственное, что правится здесь (склад/финансы — отдельный
        срез). Байк уходит в <code>reserved</code> автоматически при
        назначении на бронь (/internal/bookings) и в <code>rented</code> — при
        фактической передаче; если бронь так и не состоялась, вернуть в
        <code> available</code> нужно вручную здесь.
      </p>

      <div style={{ margin: '16px 0' }}>
        <label>
          Фильтр по статусу:{' '}
          <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
            <option value="">все</option>
            {STATUSES.map((s) => <option key={s} value={s}>{s}</option>)}
          </select>
        </label>
      </div>

      {error && <div style={{ color: '#c00', fontSize: 13, marginBottom: 12 }}>{error}</div>}

      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 14 }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #ddd', textAlign: 'left' }}>
            <th style={{ padding: 8 }}>№</th>
            <th style={{ padding: 8 }}>Байк</th>
            <th style={{ padding: 8 }}>Госномер</th>
            <th style={{ padding: 8 }}>Статус</th>
            <th style={{ padding: 8 }}>Пробег, км</th>
            <th style={{ padding: 8 }}>Арендован до</th>
            <th style={{ padding: 8 }}>Заметки</th>
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan={7} style={{ padding: 8 }}>Загрузка…</td></tr>
          ) : items.length === 0 ? (
            <tr><td colSpan={7} style={{ padding: 8, color: '#888' }}>Ничего не найдено</td></tr>
          ) : items.map((it) => (
            <tr key={it.id} style={{ borderBottom: '1px solid #eee' }}>
              <td style={{ padding: 8 }}>{it.internal_number}</td>
              <td style={{ padding: 8 }}>{it.brand} {it.product_name}</td>
              <td style={{ padding: 8 }}>{it.license_plate}</td>
              <td style={{ padding: 8 }}>
                <select
                  value={it.status}
                  disabled={busyId === it.id}
                  onChange={(e) => handleStatusChange(it.id, e.target.value)}
                >
                  {STATUSES.map((s) => <option key={s} value={s}>{s}</option>)}
                </select>
              </td>
              <td style={{ padding: 8 }}>{it.current_odo_km}</td>
              <td style={{ padding: 8 }}>{it.rent_until_date ?? '—'}</td>
              <td style={{ padding: 8, color: '#666' }}>{it.notes ?? ''}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
