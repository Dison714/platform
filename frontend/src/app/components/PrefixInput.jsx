'use client';
// Инпут с "залипающим" префиксом (+/@, см. BookingForm.jsx) и серой
// подсказкой-примером сразу после него — исчезает, как только клиент
// допечатал что-то своё. Скрытый span-зеркало меряет реальную ширину
// префикса в текущем шрифте, чтобы подсказка не наезжала на текст и не
// зависела от моноширинности шрифта (Poppins — пропорциональный).
import { useEffect, useRef, useState } from 'react';

export default function PrefixInput({ value, onChange, onFocus, prefix, example, type = 'text', inputMode }) {
  const mirrorRef = useRef(null);
  const [offset, setOffset] = useState(0);

  useEffect(() => {
    if (mirrorRef.current) setOffset(mirrorRef.current.getBoundingClientRect().width);
  }, []);

  const showGhost = value === prefix;

  return (
    <span className="prefix-input">
      <span ref={mirrorRef} className="prefix-input-mirror" aria-hidden="true">{prefix}</span>
      {showGhost && (
        <span className="prefix-input-ghost" style={{ left: offset }} aria-hidden="true">{example}</span>
      )}
      <input type={type} inputMode={inputMode} value={value} onChange={onChange} onFocus={onFocus} />
    </span>
  );
}
