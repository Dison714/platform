'use client';
import { useState } from 'react';
import { formatIdr } from '../../lib/api.js';

const PAYMENT_METHOD_CODES = ['cash', 'bank_transfer', 'other'];

// Форма заявки. Клиент шлёт ВЫБОР (продукт, даты, страховка, допы,
// location_link) + контакты — НЕ итоговую сумму. Бэкенд пересчитывает цену,
// делает снимок и сам пингует менеджеров в Telegram (фронт это не трогает).
export default function BookingForm({ slug, locale, start, end, locationLink, deliveryTime, selection, quote, dict, onCancel }) {
  const t = dict.booking;
  const [name, setName] = useState('');
  const [whatsapp, setWhatsapp] = useState('');
  const [telegram, setTelegram] = useState('');
  const [paymentMethods, setPaymentMethods] = useState({});
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
    const paymentPreference = PAYMENT_METHOD_CODES.filter((code) => paymentMethods[code]);
    return {
      product: slug,
      locale, // язык заявки → язык уведомления менеджеру
      start_date: start,
      end_date: end,
      customer,
      ...(selection.insurance ? { insurance: selection.insurance } : {}),
      ...(selection.equipment ? { equipment: selection.equipment } : {}),
      ...(locationLink ? { location_link: locationLink } : {}),
      ...(deliveryTime ? { delivery_time: deliveryTime } : {}),
      ...(paymentPreference.length ? { payment_preference: paymentPreference } : {}),
      ...(comment.trim() ? { comment: comment.trim() } : {}),
    };
  }

  async function submit(e) {
    e.preventDefault();
    if (!name.trim()) { setStatus('error'); setErrMsg(t.name_required); return; }
    const hasContact = [whatsapp, telegram].some((v) => v.trim() !== '');
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
      // Конверсионный сигнал — только после успешного ответа API (не на
      // raw submit, это уже ловит Enhanced Measurement, включая неудачные
      // попытки), чтобы считать реально дошедшие заявки.
      if (typeof window.gtag === 'function') {
        window.gtag('event', 'booking_form_submit', {
          locale,
          product: slug,
          start_date: start,
          end_date: end,
        });
      }
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
      </div>

      <div className="field">
        <span>{t.payment_method}</span>
        {PAYMENT_METHOD_CODES.map((code) => (
          <label className="check" key={code}>
            <input
              type="checkbox"
              checked={!!paymentMethods[code]}
              onChange={(e) => setPaymentMethods((m) => ({ ...m, [code]: e.target.checked }))}
            />
            {t[`payment_${code}`]}
          </label>
        ))}
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
