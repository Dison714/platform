'use client';
import { useState } from 'react';
import { formatIdr } from '../../lib/api.js';

// Форма заявки. Клиент шлёт ВЫБОР (продукт, даты, страховка, допы,
// location_link) + контакты — НЕ итоговую сумму. Бэкенд пересчитывает цену,
// делает снимок и сам пингует менеджеров в Telegram (фронт это не трогает).
export default function BookingForm({ slug, locale, start, end, locationLink, selection, quote, dict, onCancel }) {
  const t = dict.booking;
  const [name, setName] = useState('');
  const [whatsapp, setWhatsapp] = useState('');
  const [telegram, setTelegram] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [comment, setComment] = useState('');
  const [status, setStatus] = useState('idle'); // idle | sending | error
  const [errMsg, setErrMsg] = useState('');
  const [done, setDone] = useState(null); // booking_id при успехе

  const days = quote?.rental_days;
  const total = quote ? formatIdr(quote.total_payable_idr) : '';

  function buildBody() {
    const customer = { full_name: name.trim() };
    if (whatsapp.trim()) customer.whatsapp = whatsapp.trim();
    if (telegram.trim()) customer.telegram_username = telegram.trim().replace(/^@/, '');
    if (email.trim()) customer.email = email.trim();
    if (phone.trim()) customer.phone = phone.trim();
    return {
      product: slug,
      locale, // язык заявки → язык уведомления менеджеру
      start_date: start,
      end_date: end,
      customer,
      ...(selection.insurance ? { insurance: selection.insurance } : {}),
      ...(selection.equipment ? { equipment: selection.equipment } : {}),
      ...(locationLink ? { location_link: locationLink } : {}),
      ...(comment.trim() ? { comment: comment.trim() } : {}),
    };
  }

  async function submit(e) {
    e.preventDefault();
    if (!name.trim()) { setStatus('error'); setErrMsg(t.name_required); return; }
    const hasContact = [whatsapp, telegram, email, phone].some((v) => v.trim() !== '');
    if (!hasContact) { setStatus('error'); setErrMsg(t.contact_required); return; }

    setStatus('sending'); setErrMsg('');
    try {
      const res = await fetch('/api/bookings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(buildBody()),
      });
      if (!res.ok) throw new Error('booking failed');
      const json = await res.json();
      // Единый короткий номер во всех каналах (как в уведомлении менеджеру).
      setDone(json.data.booking_ref || json.data.booking_id);
    } catch {
      setStatus('error'); setErrMsg(t.error);
    }
  }

  if (done) {
    return (
      <div className="confirm" role="status">
        <div className="confirm-icon" aria-hidden="true">✓</div>
        <h3 className="display">{t.success_title}</h3>
        <p>{t.success_msg}</p>
        <p className="confirm-ref">{t.success_ref.replace('{ref}', String(done))}</p>
      </div>
    );
  }

  return (
    <form className="bform" onSubmit={submit}>
      <h3 className="display">{t.title}</h3>
      {quote && (
        <p className="bform-sum">
          {t.summary_line.replace('{name}', quote.product.name).replace('{days}', String(days)).replace('{total}', total)}
        </p>
      )}

      <label className="field"><span>{t.name}</span>
        <input type="text" value={name} placeholder={t.name_ph} onChange={(e) => setName(e.target.value)} required />
      </label>

      <p className="hint">{t.contact_hint}</p>
      <div className="bform-contacts">
        <label className="field"><span>{t.whatsapp}</span>
          <input type="tel" inputMode="tel" value={whatsapp} placeholder="+62…" onChange={(e) => setWhatsapp(e.target.value)} />
        </label>
        <label className="field"><span>{t.telegram}</span>
          <input type="text" value={telegram} placeholder="@username" onChange={(e) => setTelegram(e.target.value)} />
        </label>
        <label className="field"><span>{t.email}</span>
          <input type="email" value={email} placeholder="name@email.com" onChange={(e) => setEmail(e.target.value)} />
        </label>
        <label className="field"><span>{t.phone}</span>
          <input type="tel" inputMode="tel" value={phone} placeholder="+62…" onChange={(e) => setPhone(e.target.value)} />
        </label>
      </div>

      <label className="field"><span>{t.comment}</span>
        <textarea value={comment} rows={3} onChange={(e) => setComment(e.target.value)} />
      </label>
      <p className="hint">{t.comment_hint}</p>

      {status === 'error' && <p className="hint err">{errMsg}</p>}

      <button type="submit" className="btn-book" disabled={status === 'sending'}>
        {status === 'sending' ? t.sending : t.submit}
      </button>
      <button type="button" className="btn-link" onClick={onCancel}>{t.cancel}</button>
    </form>
  );
}
