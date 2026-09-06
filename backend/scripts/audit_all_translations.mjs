// Единая точка входа для аудита переводов — прогоняет ВСЕ три таблицы
// разом (CLAUDE.md §3.8): product_translations, vehicle_category_translations,
// family_content_translations. Не заменяет отдельные audit_*.mjs (у каждого
// свои флаги — --fallback/--fields/--ratio для product, и т.д.), а
// оборачивает их с настройками по умолчанию, чтобы "прогнал аудит переводов"
// по умолчанию значило "все три", а не одну — см. инцидент 2026-09-06,
// откуда и появился этот чек-лист.
//
// Usage: node scripts/audit_all_translations.mjs

import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const scripts = [
  { label: 'product_translations (title + description)', file: 'audit_translations.mjs', args: ['--fields', 'title,description'] },
  { label: 'vehicle_category_translations (фильтры каталога)', file: 'audit_category_translations.mjs', args: [] },
  { label: 'family_content_translations (Key Benefits/Expert Tips/FAQ)', file: 'audit_family_content.mjs', args: [] },
];

let totalFindings = 0;
for (const { label, file, args } of scripts) {
  console.log(`\n${'='.repeat(70)}\n${label}\n${'='.repeat(70)}`);
  const result = spawnSync('node', [path.join(__dirname, file), ...args], { encoding: 'utf8' });
  process.stdout.write(result.stdout);
  if (result.stderr) process.stderr.write(result.stderr);
  const match = result.stdout.match(/Findings: (\d+)/);
  if (match) totalFindings += parseInt(match[1], 10);
}

console.log(`\n${'='.repeat(70)}`);
console.log(`TOTAL findings across all 3 translation tables: ${totalFindings}`);
console.log('='.repeat(70));
process.exit(totalFindings > 0 ? 1 : 0);
