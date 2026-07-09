// Резолв одной строки family_specs в отображаемые label+value. Общая логика
// для UI-рендера specs на странице продукта И для additionalProperty в
// Product JSON-LD — не дублировать. spec.value language-neutral (число или
// код), label/unit — из i18n по spec.key.
export function resolveSpec(spec, dict) {
  if (!spec || spec.value == null || spec.value === '') return null;
  const meta = dict.spec?.[spec.key];
  const label = meta?.label ?? spec.key;
  // transmission — код (cvt/manual/automatic) → локализованное слово;
  // остальные — значение + единица (если есть в i18n).
  const value = spec.key === 'transmission'
    ? (meta?.[spec.value] ?? spec.value)
    : (meta?.unit ? `${spec.value} ${meta.unit}` : spec.value);
  return { key: spec.key, label, value };
}

// Все specs продукта → отфильтрованный массив {key,label,value}, готовый и
// для UI, и для JSON-LD.
export function resolveSpecs(specs, dict) {
  return (specs ?? []).map((s) => resolveSpec(s, dict)).filter(Boolean);
}
