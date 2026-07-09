// Photo URL resolution. The DB stores storage_path size-agnostic (bikes/<slug>/NN);
// the render inserts the size dir and .webp. Base comes from env so the Drive→CDN
// migration is env-only (files move to R2, DB untouched).
//
// Precedence (per Step 2D): cdn_url (absolute override) → PHOTO_BASE_URL + sized path → source_url.

const PHOTO_BASE = process.env.NEXT_PUBLIC_PHOTO_BASE_URL || ''; // '' = same-origin (/bikes/...)

// size ∈ 'thumb' (400w) | 'gallery' (800w) | 'hero' (1200w)
export function resolvePhotoUrl(photo, size) {
  if (!photo) return null;
  if (photo.cdn_url) return photo.cdn_url;
  if (photo.storage_path) {
    const i = photo.storage_path.lastIndexOf('/');
    const dir = photo.storage_path.slice(0, i);   // bikes/<slug>
    const name = photo.storage_path.slice(i + 1); // NN
    return `${PHOTO_BASE}/${dir}/${size}/${name}.webp`;
  }
  return photo.source_url || null;
}

// Hero photo: explicit is_hero, else lowest sort_order, else first.
export function pickHero(photos) {
  if (!photos?.length) return null;
  return photos.find((p) => p.is_hero) ||
    [...photos].sort((a, b) => a.sort_order - b.sort_order)[0];
}

// Gallery = photos minus the hero, ordered by sort_order, capped.
export function galleryPhotos(photos, hero, max = 8) {
  if (!photos?.length) return [];
  return [...photos]
    .filter((p) => p !== hero)
    .sort((a, b) => a.sort_order - b.sort_order)
    .slice(0, max);
}
