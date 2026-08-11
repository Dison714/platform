'use client';

import { useEffect, useState, useCallback } from 'react';

const LIST_API = '/api/admin/blog/articles';
const emptyForm = {
  title: '', slug: '', excerpt: '', content: '',
  status: 'draft', featured_image_url: '', related_product_family_id: '',
};

export default function BlogAdminClient() {
  const [articles, setArticles] = useState([]);
  const [categories, setCategories] = useState([]);
  const [families, setFamilies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);

  const [editingId, setEditingId] = useState(null);
  const [form, setForm] = useState(emptyForm);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetch(LIST_API, { cache: 'no-store' });
      const json = await res.json();
      if (!res.ok) throw new Error(json.message || `HTTP ${res.status}`);
      setArticles(json.data.articles ?? []);
      setCategories(json.data.categories ?? []);
      setFamilies(json.data.families ?? []);
      setError('');
    } catch (e) {
      setError(`Не удалось загрузить: ${e.message}`);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  async function startEdit(articleId) {
    setError('');
    setBusy(true);
    try {
      const res = await fetch(`${LIST_API}/${articleId}`, { cache: 'no-store' });
      const json = await res.json();
      if (!res.ok) throw new Error(json.message || `HTTP ${res.status}`);
      const a = json.data;
      setEditingId(articleId);
      setForm({
        title: a.title ?? '',
        slug: a.translation_slug ?? a.slug ?? '',
        excerpt: a.excerpt ?? '',
        content: a.content ?? '',
        status: a.status,
        featured_image_url: a.featured_image_url ?? '',
        related_product_family_id: a.related_product_family_id ?? '',
      });
    } catch (e) {
      setError(`Не удалось загрузить статью: ${e.message}`);
    } finally {
      setBusy(false);
    }
  }

  function cancelEdit() {
    setEditingId(null);
    setForm(emptyForm);
    setError('');
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    if (!form.title.trim()) { setError('Title обязателен'); return; }
    if (!/^[a-z0-9-]+$/.test(form.slug)) { setError('Slug — строчные буквы, цифры, дефисы'); return; }

    setBusy(true);
    try {
      const res = await fetch(`${LIST_API}/${editingId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      if (!res.ok) {
        const json = await res.json().catch(() => ({}));
        setError(res.status === 409 ? 'Такой slug уже занят в этом языке' : (json.message || `Ошибка ${res.status}`));
        return;
      }
      await load();
      cancelEdit();
    } finally {
      setBusy(false);
    }
  }

  return (
    <div style={{ maxWidth: 900, margin: '40px auto', padding: '0 20px', fontFamily: 'system-ui, sans-serif' }}>
      <h1 style={{ fontSize: 22 }}>Blog</h1>
      <p style={{ color: '#666', fontSize: 14 }}>
        Категории и статьи блога (ТЗ п.4.15, pillar+cluster). Только английский язык
        на этом этапе — контент и переводы на остальные языки будут заполняться отдельно.
      </p>

      <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 16, fontSize: 14 }}>
        <thead>
          <tr style={{ borderBottom: '2px solid #ddd', textAlign: 'left' }}>
            <th style={{ padding: 8 }}>Title</th>
            <th style={{ padding: 8 }}>Category</th>
            <th style={{ padding: 8 }}>Status</th>
            <th style={{ padding: 8 }}>Pillar</th>
            <th style={{ padding: 8 }}>Updated</th>
            <th style={{ padding: 8 }} />
          </tr>
        </thead>
        <tbody>
          {loading ? (
            <tr><td colSpan={6} style={{ padding: 8 }}>Загрузка…</td></tr>
          ) : articles.length === 0 ? (
            <tr><td colSpan={6} style={{ padding: 8, color: '#888' }}>Статей нет</td></tr>
          ) : articles.map((a) => (
            <tr key={a.id} style={{ borderBottom: '1px solid #eee' }}>
              <td style={{ padding: 8 }}>{a.title}</td>
              <td style={{ padding: 8 }}>{a.category_name}</td>
              <td style={{ padding: 8 }}>{a.status}</td>
              <td style={{ padding: 8 }}>{a.is_pillar ? 'yes' : ''}</td>
              <td style={{ padding: 8, whiteSpace: 'nowrap' }}>{new Date(a.updated_at).toISOString().slice(0, 10)}</td>
              <td style={{ padding: 8 }}>
                <button onClick={() => startEdit(a.id)} disabled={busy}>изменить</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {editingId && (
        <>
          <h3 style={{ fontSize: 16, marginTop: 32 }}>Изменить статью</h3>
          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 10, maxWidth: 640 }}>
            <label>
              Title
              <input type="text" value={form.title} required
                onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))}
                style={{ display: 'block', width: '100%' }} />
            </label>
            <label>
              Slug
              <input type="text" value={form.slug} required
                onChange={(e) => setForm((f) => ({ ...f, slug: e.target.value }))}
                style={{ display: 'block', width: '100%' }} />
            </label>
            <label>
              Excerpt
              <textarea value={form.excerpt} rows={2}
                onChange={(e) => setForm((f) => ({ ...f, excerpt: e.target.value }))}
                style={{ display: 'block', width: '100%' }} />
            </label>
            <label>
              Content
              <textarea value={form.content} rows={10}
                onChange={(e) => setForm((f) => ({ ...f, content: e.target.value }))}
                style={{ display: 'block', width: '100%', fontFamily: 'monospace' }} />
            </label>
            <label>
              Status
              <select value={form.status}
                onChange={(e) => setForm((f) => ({ ...f, status: e.target.value }))}
                style={{ display: 'block' }}>
                <option value="draft">draft</option>
                <option value="published">published</option>
              </select>
            </label>
            <label>
              Featured image URL
              <input type="text" value={form.featured_image_url}
                onChange={(e) => setForm((f) => ({ ...f, featured_image_url: e.target.value }))}
                style={{ display: 'block', width: '100%' }} />
            </label>
            <label>
              Related product family
              <select value={form.related_product_family_id}
                onChange={(e) => setForm((f) => ({ ...f, related_product_family_id: e.target.value }))}
                style={{ display: 'block' }}>
                <option value="">— none —</option>
                {families.map((f) => (
                  <option key={f.id} value={f.id}>{f.brand} {f.model_name}</option>
                ))}
              </select>
            </label>
            {error && <div style={{ color: '#c00', fontSize: 13 }}>{error}</div>}
            <div style={{ display: 'flex', gap: 8 }}>
              <button type="submit" disabled={busy}>Сохранить</button>
              <button type="button" onClick={cancelEdit} disabled={busy}>Отмена</button>
            </div>
          </form>
        </>
      )}
      {!editingId && error && <div style={{ color: '#c00', fontSize: 13, marginTop: 16 }}>{error}</div>}
    </div>
  );
}
