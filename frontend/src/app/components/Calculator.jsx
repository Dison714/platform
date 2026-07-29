'use client';
import { useEffect, useMemo, useRef, useState } from 'react';
import { formatIdr } from '../../lib/api.js';
import BookingForm from './BookingForm.jsx';

// Калькулятор НИЧЕГО не считает сам: собирает ввод → POST /api/quote (через
// same-origin прокси) → рисует разбивку из ответа сервера. На изменение —
// debounce-перезапрос. Книга заявки раскрывается тут же, на той же странице,
// и переиспользует это же состояние выбора (даты/страховка/допы/локация).

function todayISO(offsetDays = 0) {
  const d = new Date();
  d.setDate(d.getDate() + offsetDays);
  return d.toISOString().slice(0, 10);
}
function daysBetween(start, end) {
  return Math.round((new Date(end).getTime() - new Date(start).getTime()) / 86_400_000);
}

export default function Calculator({ slug, locale, equipment, insuranceOptions, dict }) {
  const t = dict.calc;

  const [start, setStart] = useState(todayISO(1));
  const [end, setEnd] = useState(todayISO(8));
  const [locationLink, setLocationLink] = useState('');

  const [theft, setTheft] = useState(false);
  const [damageOn, setDamageOn] = useState(false);
  const [coverage, setCoverage] = useState(insuranceOptions.damage?.[0]?.coverage_idr ?? 1500000);
  const [age, setAge] = useState(30);
  const [hasLicense, setHasLicense] = useState(true);
  const [experienced, setExperienced] = useState(true);

  // Группировка допов по addon_group (не по кодам). Шлемы — модель «2 слота,
  // потолок 2»; остальное — обычные чекбоксы.
  const helmets = useMemo(() => equipment.filter((e) => e.addon_group === 'helmet'), [equipment]);
  const extrasList = useMemo(() => equipment.filter((e) => e.addon_group !== 'helmet'), [equipment]);
  // 2 слота, по умолчанию оба = бесплатный шлем (цена 0).
  const [helmetSlots, setHelmetSlots] = useState(() => {
    const free = equipment.find((e) => e.addon_group === 'helmet' && e.rental_price_idr === 0)?.code
      ?? equipment.find((e) => e.addon_group === 'helmet')?.code ?? null;
    return [free, free];
  });
  const [extras, setExtras] = useState({});

  const [result, setResult] = useState(null);
  const [status, setStatus] = useState('idle'); // idle | loading | error
  const [nonce, setNonce] = useState(0); // для retry
  const [showBooking, setShowBooking] = useState(false);

  const rentalDays = useMemo(() => daysBetween(start, end), [start, end]);
  const daysValid = Number.isInteger(rentalDays) && rentalDays >= 1;

  // Общая часть выбора (страховка + допы) — переиспользуется для quote и booking.
  const selection = useMemo(() => {
    // Шлемы: каждый отмеченный слот фиксируется явно, даже если выбран
    // бесплатный тип (0к) — иначе непонятно, взял клиент шлем или нет.
    // null = чекбокс слота снят → в заявку не идёт вообще.
    const helmetTally = {};
    for (const code of helmetSlots) {
      if (!code) continue;
      const h = helmets.find((x) => x.code === code);
      if (h) helmetTally[code] = (helmetTally[code] || 0) + 1;
    }
    const equip = [
      ...Object.entries(helmetTally).map(([code, n]) => ({ code, quantity: n })),
      ...extrasList.filter((e) => extras[e.code]).map((e) => ({ code: e.code, quantity: 1 })),
    ];
    let insurance;
    if (theft || damageOn) {
      insurance = {};
      if (theft) insurance.theft = true;
      if (damageOn) {
        insurance.damage = { coverage_idr: Number(coverage) };
        insurance.driver = { age: Number(age), has_license: hasLicense, experienced };
      }
    }
    return { insurance, equipment: equip.length ? equip : undefined };
  }, [helmetSlots, extras, helmets, extrasList, theft, damageOn, coverage, age, hasLicense, experienced]);

  // location_link в расчёт НЕ шлём (на цену не влияет, иначе спам shadow-стат);
  // он едет только в заявку.
  const quoteBody = useMemo(() => ({
    product: slug,
    rental_days: rentalDays,
    start_date: start, // сезонный мультипликатор — по дате начала аренды
    lang: locale, // имена оборудования в сводке — на языке клиента
    ...(selection.insurance ? { insurance: selection.insurance } : {}),
    ...(selection.equipment ? { equipment: selection.equipment } : {}),
  }), [slug, locale, rentalDays, start, selection]);

  const debounce = useRef(null);
  useEffect(() => {
    if (!daysValid) { setResult(null); return; }
    setStatus('loading');
    clearTimeout(debounce.current);
    debounce.current = setTimeout(async () => {
      try {
        const res = await fetch('/api/quote', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(quoteBody),
        });
        if (!res.ok) throw new Error('quote failed');
        setResult((await res.json()).data);
        setStatus('idle');
      } catch {
        setStatus('error');
      }
    }, 400);
    return () => clearTimeout(debounce.current);
  }, [quoteBody, daysValid, nonce]);

  const b = result?.breakdown;
  const daysLabel = (rentalDays === 1 ? t.days_one : t.days_other).replace('{n}', String(Math.max(rentalDays, 0)));

  return (
    <div className="calc">
      <h2 className="display calc-h">{t.title}</h2>
      <div className="calc-body">
        <div className="calc-inputs">
          <section className="calc-section">
            <h3>{t.period}</h3>
            <div className="calc-row">
              <label className="field"><span>{t.start}</span>
                <input type="date" value={start} min={todayISO(0)} onChange={(e) => setStart(e.target.value)} />
              </label>
              <label className="field"><span>{t.end}</span>
                <input type="date" value={end} min={start} onChange={(e) => setEnd(e.target.value)} />
              </label>
            </div>
            {daysValid ? <p className="hint">{daysLabel}</p> : <p className="hint err">{t.days_invalid}</p>}
          </section>

          <section className="calc-section">
            <h3>{t.location}</h3>
            <input type="url" inputMode="url" placeholder={t.location_ph}
              value={locationLink} onChange={(e) => setLocationLink(e.target.value)} />
            <p className="hint">{t.location_hint}</p>
          </section>

          <section className="calc-section">
            <h3>{t.insurance}</h3>
            <label className="check"><input type="checkbox" checked={theft} onChange={(e) => setTheft(e.target.checked)} /> {t.theft}</label>
            <label className="check"><input type="checkbox" checked={damageOn} onChange={(e) => setDamageOn(e.target.checked)} /> {t.damage}</label>
            {damageOn && (
              <div className="subform">
                <label className="field"><span>{t.coverage}</span>
                  <select value={coverage} onChange={(e) => setCoverage(e.target.value)}>
                    {insuranceOptions.damage.map((d) => (
                      <option key={d.coverage_idr} value={d.coverage_idr}>{formatIdr(d.coverage_idr)}</option>
                    ))}
                  </select>
                </label>
                <label className="field"><span>{t.driver_age}</span>
                  <input type="number" min="16" max="99" value={age} onChange={(e) => setAge(e.target.value)} />
                </label>
                <label className="check"><input type="checkbox" checked={hasLicense} onChange={(e) => setHasLicense(e.target.checked)} /> {t.has_license}</label>
                <label className="check"><input type="checkbox" checked={experienced} onChange={(e) => setExperienced(e.target.checked)} /> {t.experienced}</label>
              </div>
            )}
          </section>

          {helmets.length > 0 && (
            <section className="calc-section">
              <h3>{t.helmets}</h3>
              <p className="hint" style={{ marginTop: 0, marginBottom: 8 }}>{t.helmets_note}</p>
              {[0, 1].map((i) => {
                const defaultFreeCode = helmets.find((h) => h.rental_price_idr === 0)?.code ?? helmets[0]?.code ?? null;
                return (
                  <div className="field" key={i}>
                    <label className="check">
                      <input
                        type="checkbox"
                        checked={helmetSlots[i] != null}
                        onChange={(e) => setHelmetSlots((s) => {
                          const c = [...s];
                          c[i] = e.target.checked ? defaultFreeCode : null;
                          return c;
                        })}
                      />
                      {t.helmet_slot.replace('{n}', String(i + 1))}
                    </label>
                    {helmetSlots[i] != null && (
                      <select
                        value={helmetSlots[i]}
                        onChange={(e) => setHelmetSlots((s) => { const c = [...s]; c[i] = e.target.value; return c; })}
                      >
                        {helmets.map((h) => (
                          <option key={h.code} value={h.code}>
                            {h.rental_price_idr > 0 ? `${h.name} (+${formatIdr(h.rental_price_idr)})` : `${h.name} — ${t.free}`}
                          </option>
                        ))}
                      </select>
                    )}
                  </div>
                );
              })}
            </section>
          )}

          {extrasList.length > 0 && (
            <section className="calc-section">
              <h3>{t.extras}</h3>
              {extrasList.map((eq) => (
                <label className="check" key={eq.code}>
                  <input
                    type="checkbox"
                    checked={!!extras[eq.code]}
                    onChange={(e) => setExtras((x) => ({ ...x, [eq.code]: e.target.checked }))}
                  />
                  {eq.name}
                  <span className="eq-price">{eq.rental_price_idr > 0 ? formatIdr(eq.rental_price_idr) : t.free}</span>
                </label>
              ))}
            </section>
          )}
        </div>

        <div className="calc-summary">
          <div className="summary" aria-live="polite">
            <h3 className="display">{t.summary}</h3>

            {status === 'error' && !showBooking && (
              <div className="qerror">
                <p className="hint err">{t.error}</p>
                <button type="button" className="btn-link" onClick={() => setNonce((n) => n + 1)}>{t.retry}</button>
              </div>
            )}

            {!result && status === 'loading' && (
              <div className="skel" aria-hidden="true">
                <span /><span /><span /><span className="skel-total" />
              </div>
            )}

            {b && !showBooking && (
              <div className={status === 'loading' ? 'sum-rows dim' : 'sum-rows'}>
                <div className="sum-row"><span>{t.base} · {result.rental_days}d</span><span>{formatIdr(b.base_rental.price_idr)}</span></div>
                <div className="sum-row"><span>{t.delivery}</span><span>{b.delivery.free ? t.free : formatIdr(b.delivery.fee_idr)}</span></div>
                {b.insurance?.theft && (
                  <div className="sum-row"><span>{t.insurance_theft} · {t.months_note.replace('{n}', String(b.insurance.theft.months))}</span><span>{formatIdr(b.insurance.theft.total_idr)}</span></div>
                )}
                {b.insurance?.damage && (
                  <div className="sum-row"><span>{t.insurance_damage} · {formatIdr(b.insurance.damage.coverage_idr)}</span><span>{formatIdr(b.insurance.damage.total_idr)}</span></div>
                )}
                {b.equipment?.items?.map((it) => (
                  <div className="sum-row" key={it.code}><span>{it.name}{it.quantity > 1 ? ` ×${it.quantity}` : ''}</span><span>{formatIdr(it.total_idr)}</span></div>
                ))}
                <div className="sum-row sum-total"><span>{t.total}</span><span>{formatIdr(result.total_payable_idr)}</span></div>
                <div className="deposit-box">
                  <div className="sum-row"><span>{t.deposit}</span><span>{formatIdr(result.deposit.amount_idr)}</span></div>
                  <p className="hint">{t.deposit_note}</p>
                </div>
                {status === 'loading' && <p className="hint">{t.updating}</p>}
              </div>
            )}

            {!showBooking ? (
              <button type="button" className="btn-book" onClick={() => setShowBooking(true)} disabled={!result}>
                {t.book}
              </button>
            ) : (
              <BookingForm
                slug={slug}
                locale={locale}
                start={start}
                end={end}
                locationLink={locationLink || null}
                selection={selection}
                quote={result}
                dict={dict}
                onCancel={() => setShowBooking(false)}
              />
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
