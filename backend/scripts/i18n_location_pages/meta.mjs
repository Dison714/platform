// Общие для всех языков метаданные района: предлог для FAQ/CTA-шаблонов
// ("in Canggu" vs "around Uluwatu") и англ. имя района (для языков, где
// топоним не склоняется/не меняется — большинство).
export const DISTRICT_META = {
  canggu: { name: 'Canggu', prep: 'in' },
  seminyak: { name: 'Seminyak', prep: 'in' },
  ubud: { name: 'Ubud', prep: 'in' },
  uluwatu: { name: 'Uluwatu', prep: 'around' },
  jimbaran: { name: 'Jimbaran', prep: 'in' },
  sanur: { name: 'Sanur', prep: 'in' },
  kuta: { name: 'Kuta', prep: 'in' },
  'nusa-dua': { name: 'Nusa Dua', prep: 'in' },
  denpasar: { name: 'Denpasar', prep: 'in' },
  // name/prep unused by generation (see apply_location_i18n.mjs comment —
  // real per-language name/prep live in each district's own d.name/d.prep);
  // airport's ctaBody reads fine with "at the airport", but the same
  // prep breaks the templated IDP question ("ride at the airport?" is
  // nonsense) — see d.faqIdpQOverride in each language file.
  airport: { name: 'the airport', prep: 'at' },
};
