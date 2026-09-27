// 09:00–22:00, шаг 30 минут, 27 значений — окно, в которое доставка идёт
// штатно (без согласования с менеджером). Раньше/позже — по запросу.
// Источник — Calculator.jsx (калькулятор на сайте); вынесено сюда (Раздел 3,
// 2026-09-27), чтобы тот же набор переиспользовал /internal/driver-tasks
// (форма создания задачи), без второй копии массива.
export const DELIVERY_TIME_OPTIONS = Array.from({ length: 27 }, (_, i) => {
  const totalMinutes = 9 * 60 + i * 30;
  const h = String(Math.floor(totalMinutes / 60)).padStart(2, '0');
  const m = String(totalMinutes % 60).padStart(2, '0');
  return `${h}:${m}`;
});
