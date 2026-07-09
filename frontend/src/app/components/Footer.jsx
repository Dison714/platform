// Футер: контакты бренда (статичные данные, не из API).
export default function Footer({ dict }) {
  const year = new Date().getFullYear();
  return (
    <footer className="ftr">
      <div className="container ftr-in">
        <div>
          <h3 className="display">{dict.brand.name}</h3>
          <p>{dict.brand.tagline}</p>
          <p><span className="i" aria-hidden="true">⏱</span>{dict.footer.hours}</p>
          <p><span className="i" aria-hidden="true">📍</span>{dict.footer.address}</p>
        </div>
        <div>
          <h3 className="display">{dict.footer.get_in_touch}</h3>
          <a href="https://wa.me/6282146433303"><span className="i" aria-hidden="true">✆</span>WhatsApp +62 821 464 333 03</a>
          <a href="https://t.me/rents_manager"><span className="i" aria-hidden="true">✈</span>Telegram @rents_manager</a>
          <a href="https://instagram.com/bali_rents"><span className="i" aria-hidden="true">◎</span>Instagram @bali_rents</a>
          <a href="mailto:support@bikebalirent.com"><span className="i" aria-hidden="true">✉</span>support@bikebalirent.com</a>
        </div>
      </div>
      <div className="ftr-bottom">
        <div className="container">© {year} {dict.brand.name}. {dict.footer.rights}</div>
      </div>
    </footer>
  );
}
