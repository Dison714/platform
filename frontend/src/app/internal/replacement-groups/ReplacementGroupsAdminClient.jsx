'use client';

import { useEffect, useState, useCallback } from 'react';

const API = '/api/admin/replacement-groups';
const emptyGroupForm = { code: '', name: '' };

export default function ReplacementGroupsAdminClient() {
  const [groups, setGroups] = useState([]);
  const [families, setFamilies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);

  const [groupForm, setGroupForm] = useState(emptyGroupForm);
  const [editingGroupId, setEditingGroupId] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetch(API, { cache: 'no-store' });
      const json = await res.json();
      if (!res.ok) throw new Error(json.message || `HTTP ${res.status}`);
      setGroups(json.data.groups ?? []);
      setFamilies(json.data.families ?? []);
      setError('');
    } catch (e) {
      setError(`Не удалось загрузить: ${e.message}`);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  function startEditGroup(g) {
    setEditingGroupId(g.id);
    setGroupForm({ code: g.code, name: g.name });
    setError('');
  }
  function cancelEditGroup() {
    setEditingGroupId(null);
    setGroupForm(emptyGroupForm);
  }

  async function handleGroupSubmit(e) {
    e.preventDefault();
    setError('');
    if (!/^[a-z0-9_]+$/.test(groupForm.code)) { setError('Код — snake_case (строчные буквы, цифры, подчёркивания)'); return; }
    if (!groupForm.name.trim()) { setError('Название обязательно'); return; }

    setBusy(true);
    try {
      const res = await fetch(editingGroupId ? `${API}/${editingGroupId}` : API, {
        method: editingGroupId ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(groupForm),
      });
      if (!res.ok) {
        const json = await res.json().catch(() => ({}));
        setError(res.status === 409 ? 'Такой код уже занят' : (json.message || `Ошибка ${res.status}`));
        return;
      }
      await load();
      cancelEditGroup();
    } finally {
      setBusy(false);
    }
  }

  async function handleDeleteGroup(id) {
    if (!confirm('Удалить группу?')) return;
    setBusy(true);
    try {
      const res = await fetch(`${API}/${id}`, { method: 'DELETE' });
      if (!res.ok && res.status !== 204) {
        const json = await res.json().catch(() => ({}));
        setError(json.message || `Ошибка ${res.status}`);
        return;
      }
      await load();
    } finally {
      setBusy(false);
    }
  }

  async function handleFamilyGroupChange(familyId, groupIdRaw) {
    const groupId = groupIdRaw === '' ? null : groupIdRaw;
    setBusy(true);
    try {
      await fetch(`/api/admin/product-families/${familyId}/replacement-group`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ replacement_group_id: groupId }),
      });
      await load();
    } finally {
      setBusy(false);
    }
  }

  return (
    <div style={{ maxWidth: 760, margin: '40px auto', padding: '0 20px', fontFamily: 'system-ui, sans-serif' }}>
      <h1 style={{ fontSize: 22 }}>Replacement Groups</h1>
      <p style={{ color: '#666', fontSize: 14 }}>
        Функциональные классы байков для будущей Replacement Matrix (замена
        при поломке/недоступности) — независимо от фильтров каталога на сайте.
        Сама логика подбора замены ещё не закодирована, здесь только справочник.
      </p>

      <h2 style={{ fontSize: 18, marginTop: 24 }}>Группы</h2>
      <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 8, fontSize: 14 }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #ddd', textAlign: 'left' }}>
            <th style={{ padding: 8 }}>Код</th>
            <th style={{ padding: 8 }}>Название</th>
            <th style={{ padding: 8 }} />
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan={3} style={{ padding: 8 }}>Загрузка…</td></tr>
          ) : groups.length === 0 ? (
            <tr><td colSpan={3} style={{ padding: 8, color: '#888' }}>Групп нет</td></tr>
          ) : groups.map((g) => (
            <tr key={g.id} style={{ borderBottom: '1px solid #eee' }}>
              <td style={{ padding: 8 }}><code>{g.code}</code></td>
              <td style={{ padding: 8 }}>{g.name}</td>
              <td style={{ padding: 8, whiteSpace: 'nowrap' }}>
                <button onClick={() => startEditGroup(g)} disabled={busy} style={{ marginRight: 8 }}>изменить</button>
                <button onClick={() => handleDeleteGroup(g.id)} disabled={busy}>удалить</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <h3 style={{ fontSize: 16, marginTop: 24 }}>{editingGroupId ? 'Изменить группу' : 'Новая группа'}</h3>
      <form onSubmit={handleGroupSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 10, maxWidth: 360 }}>
        <label>
          Код (snake_case)
          <input type="text" value={groupForm.code} required
            onChange={(e) => setGroupForm((f) => ({ ...f, code: e.target.value }))}
            style={{ display: 'block', width: '100%' }} />
        </label>
        <label>
          Название
          <input type="text" value={groupForm.name} required
            onChange={(e) => setGroupForm((f) => ({ ...f, name: e.target.value }))}
            style={{ display: 'block', width: '100%' }} />
        </label>
        {error && <div style={{ color: '#c00', fontSize: 13 }}>{error}</div>}
        <div style={{ display: 'flex', gap: 8 }}>
          <button type="submit" disabled={busy}>{editingGroupId ? 'Сохранить' : 'Добавить'}</button>
          {editingGroupId && <button type="button" onClick={cancelEditGroup} disabled={busy}>Отмена</button>}
        </div>
      </form>

      <h2 style={{ fontSize: 18, marginTop: 32 }}>Состав — все модели</h2>
      <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 8, fontSize: 14 }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #ddd', textAlign: 'left' }}>
            <th style={{ padding: 8 }}>Модель</th>
            <th style={{ padding: 8 }}>Группа замены</th>
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan={2} style={{ padding: 8 }}>Загрузка…</td></tr>
          ) : families.map((f) => (
            <tr key={f.id} style={{ borderBottom: '1px solid #eee' }}>
              <td style={{ padding: 8 }}>{f.brand} {f.model_name}</td>
              <td style={{ padding: 8 }}>
                <select
                  value={f.replacement_group_id ?? ''}
                  disabled={busy}
                  onChange={(e) => handleFamilyGroupChange(f.id, e.target.value)}
                >
                  <option value="">— без группы —</option>
                  {groups.map((g) => (
                    <option key={g.id} value={g.id}>{g.name}</option>
                  ))}
                </select>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
