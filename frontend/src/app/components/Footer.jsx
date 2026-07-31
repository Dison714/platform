// Футер: контакты бренда (статичные данные, не из API).
import Link from 'next/link';

export default function Footer({ dict, locale }) {
  const year = new Date().getFullYear();
  return (
    <footer className="ftr">
      <div className="container ftr-in">
        <div>
          <h3 className="display">{dict.brand.name}</h3>
          <p>{dict.brand.tagline}</p>
          <p><span className="i" aria-hidden="true">⏱</span>{dict.footer.hours}</p>
          <p className="ftr-note">{dict.footer.hours_note}</p>
          <p><span className="i" aria-hidden="true">📍</span>{dict.footer.address}</p>
        </div>
        <div>
          <h3 className="display">{dict.footer.get_in_touch}</h3>
          <a href="https://wa.me/6282146433303"><span className="i" aria-hidden="true">✆</span>WhatsApp +62 821 464 333 03</a>
          <a href="https://t.me/Bali_rent_main"><span className="i" aria-hidden="true">✈</span>Telegram @Bali_rent_main</a>
          <a href="https://instagram.com/bali_rents"><span className="i" aria-hidden="true">◎</span>Instagram @bali_rents</a>
          <a href="mailto:rentbalibike@gmail.com"><span className="i" aria-hidden="true">✉</span>rentbalibike@gmail.com</a>
        </div>
      </div>
      <div className="ftr-bottom">
        <div className="container">
          © {year} {dict.brand.name}. {dict.footer.rights} · <Link href={`/${locale}/terms`} className="ftr-terms-link">{dict.footer.terms}</Link>
        </div>
      </div>
    </footer>
  );
}
