// Builds photos_manifest.json from raw Drive folder listings (scripts/_drive_dump/*.json)
// and the Step 2B folder→product mapping (embedded below). Metadata only — no bytes.
//
// Each dump file is a verbatim MCP search_files response ({ files: [ {id,title,mimeType,parentId,...} ] }).
// Run:  node scripts/build_manifest.js
// Reports: folders with 0 images, mapped folders absent from dumps, and unknown parentIds.

import { writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const decodeEntities = (s) => s
  .replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>')
  .replace(/&#39;/g, "'").replace(/&quot;/g, '"');

// List a PUBLIC Drive folder's children via the keyless embeddedfolderview HTML
// (returns id="entry-FILEID" + flip-entry-title">NAME, in order). Metadata only.
async function listFolder(folderId) {
  const url = `https://drive.google.com/embeddedfolderview?id=${folderId}#list`;
  const res = await fetch(url, { redirect: 'follow' });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const html = await res.text();
  const out = [];
  for (const chunk of html.split('class="flip-entry"').slice(1)) {
    const id = chunk.match(/id="entry-([^"]+)"/)?.[1];
    const title = chunk.match(/flip-entry-title">([^<]+)</)?.[1];
    if (id && title) out.push({ id, title: decodeEntities(title) });
  }
  return out;
}

// folderId → { slug, title }   (Step 2B decisions; merged products share a slug)
const FOLDER_MAP = {
  // — active + equipment + archived (root) —
  '1YvUL9HmJvMlE7eL_MrbX8JJ6WGnyK8UH': { slug: 'honda-adv-total-black', title: '1.ADV ABS black' },
  '1JLMcsHgDLUufZriZMtTUXl_4XAVWFzaM': { slug: 'honda-adv-total-black-box', title: '1.ADV ABS black box' },
  '1nopMjd9turnVBAyiYEwx0sfbohRdPiZ7': { slug: 'honda-pcx-orange', title: '2.PCX CBS orange' },
  '1C6Mtr2UU9Cya2nu5qcvyU3p8Yhst3pTl': { slug: 'honda-pcx-orange-box', title: '2.PCX CBS orange+box' },
  '1EU6Fb_QZyExeXMLNYzmaYQL4sMKgKdli': { slug: 'honda-pcx-red', title: '2.PCX CBS red' },
  '1_-thlwEmQaksafHJYvnqt1Ee0U7eYx-h': { slug: 'honda-pcx-red', title: '21.PCX ABS Red' },
  '1Ga1iD82f1T83MIEi7pTmk9VWjF3WbIPc': { slug: 'honda-adv-cream', title: '3.ADV CBS Cream' },
  '1bZQVOkG9HMybQ1BzrEmMVlk9e8z2HSdw': { slug: 'honda-adv-white', title: '3.ADV CBS white' },
  '1P-Dq578_FaJh-UGXfbh-kCywiK9sFRNU': { slug: 'honda-adv-white', title: '4.ADV ABS white' },
  '14UF7O11UsGMMeCPOgioTUbIdmYBT0nRF': { slug: 'honda-adv-white', title: '28.ADV ABS White' },
  '1uFMioUV7W5BlFJUfZgiVLRpywNd_Qlyo': { slug: 'honda-adv-white', title: '34.ADV CBS White' },
  '1TN80pEpjqk21VRnonuR4EekWW5TG1y2R': { slug: 'honda-adv-white', title: '34.ADV CBS White+box' },
  '1Nm-1JfH775Xsn6b3OZCIRPz_apOQWkLs': { slug: 'honda-adv-turquoise', title: '4.ADV ABS Turquoise' },
  '1ln8HmNoT9SpbIJpgWC8f07p4qWDaOBNi': { slug: 'honda-adv-turquoise-box', title: '4.ADV ABS Turquoise+box' },
  '1MX1KAgPYKTvUkZ4V98UnPskwLc7CPwWm': { slug: 'honda-adv-turquoise-bracket', title: '4.ADV ABS Turquoise+bracket' },
  '15QhVRZVQFP7fQx9CJ8b5n3jqqHSTX8RL': { slug: 'honda-pcx-purple-cbs', title: '5.PCX CBS Purple' },
  '1zpFewuXPcjWndYdz_ulyPbcc4K0UQ8fL': { slug: 'honda-pcx-purple-cbs', title: '43.PCX CBS Purple' },
  '1SvAFXhcH-O7-p56JXkk15XBPPZ2jUsEV': { slug: 'honda-pcx-pink-blue-cbs', title: '6.PCX CBS Pink' },
  '1blJbn0X_VanZxJBtM0XyyHXRY38YMQUr': { slug: 'honda-pcx-pink-blue-cbs', title: '7.РСХ CBS Pink' },
  '1aXMEQLSvN6M6OimVnhvQYwN_BN2twvPg': { slug: 'honda-pcx-pink-blue-cbs', title: '30.PCX CBS Pink' },
  '1cznWAGhG00ktCUpDnqeP10TQ5UqKUA4z': { slug: 'honda-pcx-pink-blue-cbs', title: '46.PCX CBS Pink' },
  '18aFq1gQgBUs2bIb64lU9LEMFwwNmN3_w': { slug: 'suzuki-vstrom250-black', title: '8.Suzuki Vstrom 250 Black' },
  '1F86esaIVId9cJzHeArIHLEGLdwwzfmXA': { slug: 'suzuki-vstrom250-black-crashbar', title: '11.Suzuki Vstrom 250 Black+crashbar' },
  '1CJVSEjJaEH36CF1fYqJ7efb7hjLkGOLK': { slug: 'honda-adv-turquoise-road-sync', title: '9.ADV Road Sync Turquoise' },
  '1IK9f9GG5GeKAHho-7Nv1qiNzg-Z4VCGg': { slug: 'morbidelli-c252v-black', title: '10.Morbidelli C252V black' },
  '1S1YkwVN035yhlo2zP4qVSKE9cdKkbAJ9': { slug: 'yamaha-nmax-pink-purple', title: '12.Nmax Neo turbo' },
  '1twzFXmviFaOCgA06ZWXG9oT54sVwtu7P': { slug: 'yamaha-nmax-pink-purple', title: '12.Nmax Neo turbo Pink' },
  '1xDEgoOuU2gAo4ztu-Cry85BL-32GmuCr': { slug: 'yamaha-xmax-green', title: '13.Xmax Green' },
  '1EK0jDSSMgD9zyf0HNMBRtutuWL-MV2zE': { slug: 'yamaha-xmax-green-blue-wheels', title: '13. Xmax Green Blue Wheels' },
  '1I6RPZuloHutIpQGTG2W_UNQmt7zvcJlM': { slug: 'yamaha-xmax-grey', title: '14.Xmax Tech Custom Grey' },
  '1bSiyiJUw504-83LsePSevQKIIwytlFJ1': { slug: 'yamaha-xmax-chameleon', title: '15.Xmax Tech Chameleon' },
  '1KgX-TjP-wnErPVuaGCAxcV3fDHVLufv3': { slug: 'yamaha-nmax-black', title: '16.Nmax Keyless Black' },
  '1lTDWinkA61DZYDmVWU5pHW3UAa58o5RV': { slug: 'yamaha-nmax-pink-blue', title: '16.Nmax Keyless Pink' },
  '1ne8cFzV6ic1bIhU-c_xYjaxgw4qfcUZd': { slug: 'yamaha-nmax-pink-blue', title: '17.Nmax Key Pink' },
  '1xqcZb4-f33bgabteg27kPhKqnhJ0eCqT': { slug: 'yamaha-nmax-purple', title: '17.Nmax Key Purple' },
  '14h4-gk10416netmPCXawlU8S12DUg5Ky': { slug: 'yamaha-nmax-green', title: '18.Nmax Key Green' },
  '1W4aueha1NADbZoiY2078RW0XbbN0GdRq': { slug: 'yamaha-nmax-blue', title: '18.Nmax Key Blue' },
  '1hON09lobQH_E7ZgExg_ZxeWhKQnOOh0B': { slug: 'yamaha-nmax-purple', title: '19.Nmax Key Purple' },
  '1nff7s4j_wtP8UwU4tOCV6_0WpBGbfgZU': { slug: 'yamaha-nmax-red', title: '19.Nmax Key Red' },
  '1ImNc0ECC8NM3l3u-Tfm5wC5dnRmV0cxX': { slug: 'yamaha-nmax-chameleon', title: '20.Nmax Keyless Chameleon Blue-purple' },
  '1xwWy27du-7eAUe4gm6byjzsuaZNvL4Zv': { slug: 'yamaha-nmax-dark-green', title: '20.Nmax Keyless Dark Green' },
  '1COOXp_DqrZgNC5U5I5Mjz-riO63rrYUc': { slug: 'yamaha-nmax-chameleon-sky-pink', title: '20.Nmax Keyless Stiker Sky Pink' },
  '1Lb3HDDupo-IUffLIPO3SyvR7o-KZ7OtO': { slug: 'honda-pcx-purple-abs', title: '21.PCX ABS Purple' },
  '1T9G_V0Gu-2JELeBnoV5lm2vhKYqwZV6z': { slug: 'yamaha-xsr-total-black', title: '22.Yamaha XSR Total Black' },
  '1P77STjJdJc9J6M5g1kGcn6khQ1P5L6xS': { slug: 'yamaha-xsr-black', title: '23.Yamaha XSR Custom Black' },
  '1rI_cXajkUVmB2Y4ir9nyiBBq-0nfrskv': { slug: 'yamaha-xsr-black', title: '26.Yamaha XSR Black' },
  '1tq-_uTfJooLTo-zShTCy-jAljNi-Km4x': { slug: 'yamaha-xsr-black-box', title: '23.Yamaha XSR Custom Black+box' },
  '1UwmR05JpGA630CVGBWWYJiYqqGuc1ELY': { slug: 'yamaha-xsr-black-bracket', title: '23.Yamaha XSR Custom Black+bracket' },
  '1sILcfEVCZKNga0PN9G7Obnjztdq2et8p': { slug: 'yamaha-nmax-green', title: '24.Nmax Keyless Green' },
  '14jM-5q2WJHE3GVdkHX2bIR3Ih9e08Jbj': { slug: 'yamaha-nmax-green-box', title: '24.Nmax Keyless Green+box' },
  '1Msgx15UlKairPSS92VIoZvEQHZ-5zlnw': { slug: 'honda-pcx-yellow-green', title: '25.PCX ABS Yellow Green Toxic' },
  '1Eq7SdkMOsFOHgz4ZfvflylTCdkps-anm': { slug: 'honda-pcx-pink-blue-abs', title: '25.PCX ABS Dari Pink' },
  '1q8PzgwRVUWJvN7WWKUHB2dIuTs0jzQw2': { slug: 'honda-adv-chameleon-abs', title: '28.ADV ABS Chameleon' },
  '1jXvdJNsmZLbvYSuAvKNADb0n4LUh_oCS': { slug: 'honda-adv-chameleon-cbs', title: '29.ADV CBS Chameleon' },
  '1iepNf1Lxdma0ZiwManGUMyGBiEGmSNye': { slug: 'yamaha-mt25-black-red', title: '31.Yamaha MT25 Black+Red' },
  '1poHSvt3GrGktuyKu6xkxT_PQHDVOEi9d': { slug: 'yamaha-mt25-black-red-box', title: '31.Yamaha MT25 Black+Red+box' },
  '1DjCtF9VH6fcugV7J81abjiHsOUumSZXE': { slug: 'kawasaki-versys-black', title: '32.Kawasaki Versys Black' },
  '1IegrusQBKm1PwvjTbCDDVfYkcAMrdUM2': { slug: 'kawasaki-versys-black', title: '49.Kawasari Versys Black' },
  '1ApWu5VVh5PSZur_Ivd3hJY1u8xpy9hIm': { slug: 'kawasaki-versys-black-no-boxes', title: '32.Kawasaki Versys Black-no boxes' },
  '19mvjwhMCC_m07gRgKCYUGGmxmlmNDe0I': { slug: 'kawasaki-versys-black-no-boxes', title: '49.Kawasari Versys Black-no boxes' },
  '1iF99v5hpikjnQ1gI8N10IY1OZwf2rdEX': { slug: 'honda-cb150x-black', title: '33.Honda CB150X Black' },
  '13sHbcIyr59BHDkFSiSJZfw-NSfa_Nwo2': { slug: 'honda-cb150x-brown', title: '33.Honda CB150X Brown' },
  '1cW7lcVUit2Kr1nv_8lzKoOzDPeM-kouF': { slug: 'honda-adv-pink-purple-abs', title: '54.ADV ABS Pink' },
  '1b_iDNotU6fJcJwPEkxaIr-cM-KJ2CIln': { slug: 'yamaha-nmax-pink-blue', title: '35.Nmax Keyless Pink' },
  '1EMZRi40kFjh558y0zKkxM7UGxoJ2QDE5': { slug: 'yamaha-nmax-pink-blue-blue-sky', title: '35.Nmax Keyless Blue Sky' },
  '1QTaQ6_J6NTl5DCg1leg8Kew7Iyh9-Ckx': { slug: 'yamaha-nmax-pink-blue', title: '36.Nmax Key Pink' },
  '1u_cadKiyZnXIyUN1ymyBUiQjjRV7Hzph': { slug: 'honda-pcx-green', title: '37.PCX CBS Green' },
  '1ys1f59o2AN6JWdKbAUYFmmD3Ui9RJkGI': { slug: 'yamaha-mt25-chameleon', title: '38.Yamaha МТ25 Chameleon' },
  '1fkcoXqTS0LstmkJqJB_07w2C6A4li-MK': { slug: 'honda-cb150x-total-black', title: '40.Honda CB150X Black' },
  '1VFbjJLlFc69DilN4-Py_sX6upCn3KUdn': { slug: 'honda-cb150x-green', title: '40.Honda CB150X Green' },
  '1U-rQJTGq2_0wG8lhkPWcpWEhK_nwPqOA': { slug: 'yamaha-nmax-light-green', title: '41.Nmax Key Green' },
  '1yND7iECmIzk45xScYkwOfP8zU1Beuutt': { slug: 'kawasaki-zx25r-biru', title: '42.Kawasaki ZX25R Blue' },
  '1tk85rAMLLKdGhoAwj1jfiOy7BCebEBxZ': { slug: 'honda-pcx-silver', title: '43.PCX CBS Silver' },
  '1LWeZ9RtLckpKmuXQvmKXaN6nrMNYxS0Z': { slug: 'honda-pcx-pink-blue-abs', title: '44.PCX ABS Pink' },
  '1QgP2FfFmo2NQEvAuDo3OTDXNWDs41J6Z': { slug: 'honda-pcx-pink-blue-abs', title: '47.PCX ABS Pink' },
  '1Hg4TA5qBewYerdFeAK4TsgOHbtFDxlBl': { slug: 'honda-pcx-pink-blue-abs', title: '48.PCX ABS Pink' },
  '1vhuLC9FSG998__Qi1rFD_Hi6QeUxdhtc': { slug: 'suzuki-vstrom250-total-black', title: '45.Suzuki Vstrom 250 Black' },
  '1veHP-OdnFs1s1TPxvNZN24O0u6FKP6ya': { slug: 'suzuki-vstrom250-total-black-all-boxes', title: '45.Suzuki Vstrom 250 Black +all boxes' },
  '14KqYvmekefF-RLUoNtzobzxTGpP0-KOO': { slug: 'honda-pcx-pink-blue-cbs-anime', title: '46.PCX CBS Stiker Anime' },
  '1gQKv6gLeNq0yTmWyla8NlPG-VcIBmtut': { slug: 'honda-pcx-black-abs-sticker-custom', title: '47.PCX ABS Black Sticker LV' },
  '1FZn-VIESORml_VAQwc7XFrI9p_67zZhw': { slug: 'honda-cbr250rr-white-blue', title: '50.Honda CBR250RR SP QS' },
  '1oub2txc7uf1t8JlVmFq8kp7RI8CZIt53': { slug: 'yamaha-mt25-black', title: '51.Yamaha МТ25 Black' },
  '1sHy34Onp0d31DsO0c-f-zwJP7m0kaja4': { slug: 'yamaha-mt25-black-box', title: '51.Yamaha МТ25 Black+box' },
  '1V5HASGLSV6F61Z2OD3LwdndYckqGfKsI': { slug: 'yamaha-xmax-green-blue', title: '52.Xmax Green Blue' },
  '1TDKBqmbUwnKAAUfF5KVaSMBniPWNpT6M': { slug: 'yamaha-xmax-silver', title: '52.Xmax Silver' },
  '1VdCBFbZsFgKhetf7J_JiTP-qqJH7ielW': { slug: 'tvs-ronin225-total-black', title: '55. TVS Ronin 225 ABS Black' },
  '1Wa_3_H7n-tSinWXKmQj1zjytjknkF8SA': { slug: 'tvs-ronin225-total-black', title: '56. TVS Ronin 225 ABS Black' },
  // — partner (Викины) —
  '1jE6cfmALOq6sIm4V4BueJrBikmRXNDZJ': { slug: 'yamaha-xmax-dark-green-partner', title: 'Викины/Xmax dark Green' },
  '1THy0GRFhpz_uqnS85bnFi4euaBRgKuB-': { slug: 'yamaha-xmax-red-partner', title: 'Викины/Xmax Red' },
  '14m6myDTPMvpuv_YTfqzD7KZijDtMhb3t': { slug: 'yamaha-xmax-black-partner', title: 'Викины/Xmax Black' },
  '1NCbzzWzkyE07cGWQnf3N40h_uBhcC0cJ': { slug: 'yamaha-xmax-cartoon-partner', title: 'Викины/X-max Cartoon' },
  '1N8eF_0D3Q8moNa8_j5eD68TPNvFt-Vtd': { slug: 'yamaha-xmax-grey-partner', title: 'Викины/Xmax Grey' },
  '1qFzwnsO-r2Irqinc8tsyC53WQBycxosU': { slug: 'yamaha-nmax-neo-blue-partner', title: 'Викины/Nmax Neo blue' },
  '1ibnansc7NHqZpvkX6TOWwRDmB7GCIZfc': { slug: 'yamaha-nmax-neo-s-black-partner', title: 'Викины/Nmax Neo S Black' },
  '1VfXYk28isM93C4-nKxXWF5PC_MuuAkjb': { slug: 'yamaha-nmax-neo-s-white-partner', title: 'Викины/Nmax Neo S white' },
};

const IMG_EXT = new Set(['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif']);
function isImage(f) {
  if (f.title === '.DS_Store') return false;
  if (typeof f.mimeType === 'string' && f.mimeType.startsWith('image/')) return true;
  const ext = (f.title.split('.').pop() || '').toLowerCase();
  return IMG_EXT.has(ext);
}

async function main() {
  const ids = Object.keys(FOLDER_MAP);
  const products = {};
  const emptyFolders = [], errorFolders = [];
  let imgCount = 0, fileCount = 0;

  for (const id of ids) {
    const m = FOLDER_MAP[id];
    let entries;
    try { entries = await listFolder(id); }
    catch (e) { errorFolders.push(`${m.title} (${e.message})`); continue; }
    fileCount += entries.length;
    const imgs = entries.filter(isImage);
    if (!imgs.length) emptyFolders.push(m.title);
    for (const f of imgs) {
      const ext = (f.title.split('.').pop() || '').toLowerCase();
      (products[m.slug] ||= []).push({ folder: m.title, fileId: f.id, name: f.title, mime: `image/${ext}` });
    }
    imgCount += imgs.length;
  }
  for (const slug of Object.keys(products)) {
    products[slug].sort((a, b) => a.folder.localeCompare(b.folder) ||
      a.name.localeCompare(b.name, undefined, { numeric: true, sensitivity: 'base' }));
  }

  await writeFile(path.join(__dirname, 'photos_manifest.json'),
    JSON.stringify({ generatedAt: new Date().toISOString(), products }, null, 2));

  console.log(`folders: ${ids.length} | files seen: ${fileCount} | images: ${imgCount} | products: ${Object.keys(products).length}`);
  console.log(`empty folders (${emptyFolders.length}): ${emptyFolders.join(' | ') || 'none'}`);
  console.log(`fetch errors (${errorFolders.length}): ${errorFolders.join(' | ') || 'none'}`);
}
main();
