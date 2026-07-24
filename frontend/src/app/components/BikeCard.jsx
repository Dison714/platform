import Link from 'next/link';
import { formatIdr } from '../../lib/api.js';
import { resolvePhotoUrl } from '../../lib/photos.js';

// Карточка продукта. Hero-фото в thumb (400w); если фото нет — placeholder
// (need_photos → «Photo coming soon», иначе аккуратная иконка, не битая картинка).
// Метки: archived_color → «Rare colour» (деликатно); print_name → имя серии.
// partner_bike в UI НЕ показываем (флаг только для внутренней аналитики).
export default function BikeCard({ locale, product, dict }) {
  const { slug, name, category, hero, price_preview, archived_color, print_name, need_photos } = product;
  const thumb = resolvePhotoUrl(hero, 'thumb');

  return (
    <Link href={`/${locale}/bikes/${slug}`} className="card">
      <div className="card-img">
        {thumb ? (
          <img src={thumb} alt={name} loading="lazy" width="400" height="300" />
        ) : need_photos ? (
          <span className="photo-soon">{dict.placeholder?.photo_soon}</span>
        ) : (
          <span aria-hidden="true" style={{ fontSize: 34 }}>🏍</span>
        )}
        {archived_color ? <span className="badge-rare">{dict.badge?.rare_colour}</span> : null}
      </div>
      <div className="card-body">
        {category?.name ? <span className="pill">{category.name}</span> : null}
        <div className="card-name">{name}</div>
        {print_name ? <div className="badge-print">{dict.badge?.print}{print_name}</div> : null}
        {price_preview ? (
          <>
            <div className="card-from">{dict.catalog.from_month}</div>
            <div className="display card-price">{formatIdr(price_preview.price_idr)}</div>
          </>
        ) : null}
      </div>
    </Link>
  );
}
