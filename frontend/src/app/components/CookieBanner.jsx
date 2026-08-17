'use client';
// Consent Mode v2 — MVP-баннер. Нет реальной гео-детекции, поэтому locale
// страницы используется как приближение EEA/UK (de/fr/es/it, см. layout.js
// про gtag('consent','default', ...) — остальные регионы уже granted по
// умолчанию, баннер им не нужен). Сохранённый выбор в localStorage
// переигрывает default при каждом визите, баннер повторно не показывается.
import { useEffect, useState } from 'react';

const STORAGE_KEY = 'mdb_consent';
const CONSENT_LOCALES = ['de', 'fr', 'es', 'it'];

function applyConsent(choice) {
  if (typeof window.gtag !== 'function') return;
  const value = choice === 'accept' ? 'granted' : 'denied';
  window.gtag('consent', 'update', {
    ad_storage: value,
    ad_user_data: value,
    ad_personalization: value,
    analytics_storage: value,
  });
}

export default function CookieBanner({ locale, dict }) {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    let stored = null;
    try {
      stored = localStorage.getItem(STORAGE_KEY);
    } catch {
      // localStorage недоступен (приватный режим и т.п.) — считаем выбор
      // отсутствующим, баннер может показаться снова, это не критично.
    }
    if (stored === 'accept' || stored === 'decline') {
      applyConsent(stored);
      return;
    }
    if (CONSENT_LOCALES.includes(locale)) setVisible(true);
  }, [locale]);

  function choose(choice) {
    applyConsent(choice);
    try {
      localStorage.setItem(STORAGE_KEY, choice);
    } catch {
      // см. комментарий выше — если сохранить не вышло, просто закрываем.
    }
    setVisible(false);
  }

  if (!visible) return null;

  return (
    <div className="cookie-banner" role="dialog" aria-live="polite">
      <p className="cookie-banner-text">{dict.cookie_banner.message}</p>
      <div className="cookie-banner-actions">
        <button type="button" className="cookie-banner-btn cookie-banner-decline" onClick={() => choose('decline')}>
          {dict.cookie_banner.decline}
        </button>
        <button type="button" className="cookie-banner-btn cookie-banner-accept" onClick={() => choose('accept')}>
          {dict.cookie_banner.accept}
        </button>
      </div>
    </div>
  );
}
