// Переводит короткие описания в скобках у Popular Locations (Дмитрий,
// 2026-09-10: "если это конечный небольшой набор категорий... переведи как
// словарь"). Проверено: 19 уникальных фраз в скобках на 49 точек, 2 из
// них — не категории, а полные названия акронимов (Garuda Wisnu Kencana,
// Lapangan Puputan Badung), оставлены как есть на всех языках. Остальные
// 17 — реальные короткие описания, переведены словарём. Сами названия
// заведений/топонимов (то, что снаружи скобок) НЕ трогаем ни на одном
// языке — это proper nouns, как и раньше.
import { pool } from '../src/db/pool.js';

const DICT = {
  'BBQ venue': { ru: 'барбекю-площадка', de: 'BBQ-Lokal', fr: 'lieu de barbecue', es: 'local de barbacoa', it: 'locale per barbecue', ja: 'BBQ会場', ko: 'BBQ 장소', ar: 'مكان للشواء', hi: 'BBQ स्थल', 'zh-Hans': '烧烤场所' },
  'Eastern European menu': { ru: 'восточноевропейская кухня', de: 'osteuropäische Küche', fr: "cuisine d'Europe de l'Est", es: 'cocina de Europa del Este', it: "cucina dell'Europa dell'Est", ja: '東欧料理', ko: '동유럽 요리', ar: 'قائمة طعام أوروبا الشرقية', hi: 'पूर्वी यूरोपीय व्यंजन', 'zh-Hans': '东欧菜单' },
  'Elephant Cave': { ru: 'Пещера слона', de: 'Elefantenhöhle', fr: "grotte de l'éléphant", es: 'cueva del elefante', it: "grotta dell'elefante", ja: '象の洞窟', ko: '코끼리 동굴', ar: 'كهف الفيل', hi: 'हाथी गुफा', 'zh-Hans': '象窟' },
  'Tegalalang rice-terrace swings': { ru: 'качели на рисовых террасах Тегалаланга', de: 'Schaukeln an den Reisterrassen von Tegalalang', fr: 'balançoires des rizières en terrasses de Tegalalang', es: 'columpios en las terrazas de arroz de Tegalalang', it: 'altalene sulle terrazze di riso di Tegalalang', ja: 'テガラランの棚田のブランコ', ko: '테갈랄랑 계단식 논 그네', ar: 'أراجيح مدرجات الأرز في تيغالالانغ', hi: 'तेगल्लालंग धान की सीढ़ियों के झूले', 'zh-Hans': '德格拉朗梯田秋千' },
  'Uluwatu temple road': { ru: 'дорога к храму Улувату', de: 'Straße zum Uluwatu-Tempel', fr: "route du temple d'Uluwatu", es: 'carretera al templo de Uluwatu', it: 'strada per il tempio di Uluwatu', ja: 'ウルワツ寺院への道', ko: '울루와투 사원 가는 길', ar: 'طريق معبد أولوواتو', hi: 'उलुवातु मंदिर की सड़क', 'zh-Hans': '乌鲁瓦图神庙道路' },
  bar: { ru: 'бар', de: 'Bar', fr: 'bar', es: 'bar', it: 'bar', ja: 'バー', ko: '바', ar: 'بار', hi: 'बार', 'zh-Hans': '酒吧' },
  beachfront: { ru: 'у пляжа', de: 'Strandlage', fr: 'en bord de plage', es: 'frente a la playa', it: 'sul lungomare', ja: 'ビーチフロント', ko: '해변가', ar: 'على الشاطئ', hi: 'बीचफ़्रंट', 'zh-Hans': '海滨' },
  breakfast: { ru: 'завтрак', de: 'Frühstück', fr: 'petit-déjeuner', es: 'desayuno', it: 'colazione', ja: '朝食', ko: '아침 식사', ar: 'إفطار', hi: 'नाश्ता', 'zh-Hans': '早餐' },
  'breakfast, rice-field view': { ru: 'завтрак, вид на рисовые поля', de: 'Frühstück, Blick auf die Reisfelder', fr: 'petit-déjeuner, vue sur les rizières', es: 'desayuno, vistas a los arrozales', it: 'colazione, vista sulle risaie', ja: '朝食、棚田の眺め', ko: '아침 식사, 논 전망', ar: 'إفطار، إطلالة على حقول الأرز', hi: 'नाश्ता, धान के खेतों का नज़ारा', 'zh-Hans': '早餐，稻田景观' },
  'ceramics workshops': { ru: 'мастер-классы по керамике', de: 'Keramik-Workshops', fr: 'ateliers de céramique', es: 'talleres de cerámica', it: 'laboratori di ceramica', ja: '陶芸ワークショップ', ko: '도자기 워크숍', ar: 'ورش عمل السيراميك', hi: 'सिरेमिक वर्कशॉप', 'zh-Hans': '陶艺工作坊' },
  coffee: { ru: 'кофе', de: 'Kaffee', fr: 'café', es: 'café', it: 'caffè', ja: 'コーヒー', ko: '커피', ar: 'قهوة', hi: 'कॉफ़ी', 'zh-Hans': '咖啡' },
  'coworking/events': { ru: 'коворкинг/мероприятия', de: 'Coworking/Events', fr: 'coworking/événements', es: 'coworking/eventos', it: 'coworking/eventi', ja: 'コワーキング／イベント', ko: '코워킹/이벤트', ar: 'العمل المشترك/الفعاليات', hi: 'कोवर्किंग/इवेंट्स', 'zh-Hans': '联合办公／活动' },
  'night market': { ru: 'ночной рынок', de: 'Nachtmarkt', fr: 'marché nocturne', es: 'mercado nocturno', it: 'mercato notturno', ja: 'ナイトマーケット', ko: '야시장', ar: 'سوق ليلي', hi: 'नाइट मार्केट', 'zh-Hans': '夜市' },
  'rooftop restaurant/bar': { ru: 'ресторан-бар на крыше', de: 'Rooftop-Restaurant/Bar', fr: 'restaurant/bar sur le toit', es: 'restaurante/bar en la azotea', it: 'ristorante/bar sul tetto', ja: '屋上レストラン・バー', ko: '루프탑 레스토랑/바', ar: 'مطعم/بار على السطح', hi: 'रूफ़टॉप रेस्तराँ/बार', 'zh-Hans': '屋顶餐厅／酒吧' },
  'sports pub, Petitenget': { ru: 'спорт-паб, Петитенгет', de: 'Sportkneipe, Petitenget', fr: 'pub sportif, Petitenget', es: 'pub deportivo, Petitenget', it: 'pub sportivo, Petitenget', ja: 'スポーツパブ、プティテンゲット', ko: '스포츠 펍, 프티텡겟', ar: 'حانة رياضية، بيتيتينغيت', hi: 'स्पोर्ट्स पब, पेटीटेंगेट', 'zh-Hans': '体育酒吧，Petitenget' },
  'to Nusa Penida': { ru: 'на Нуса-Пениду', de: 'nach Nusa Penida', fr: 'vers Nusa Penida', es: 'a Nusa Penida', it: 'verso Nusa Penida', ja: 'ヌサペニダ行き', ko: '누사페니다행', ar: 'إلى نوسا بينيدا', hi: 'नुसा पेनिडा के लिए', 'zh-Hans': '前往努沙贝妲' },
  'valley view': { ru: 'вид на долину', de: 'Talblick', fr: 'vue sur la vallée', es: 'vistas al valle', it: 'vista sulla valle', ja: '渓谷の眺め', ko: '계곡 전망', ar: 'إطلالة على الوادي', hi: 'घाटी का नज़ारा', 'zh-Hans': '山谷景观' },
};

const LANGS = ['ru', 'de', 'fr', 'es', 'it', 'ja', 'ko', 'ar', 'hi', 'zh-Hans'];

const { rows } = await pool.query(
    `SELECT lpt.location_page_id, lpt.language_code, lpt.popular_locations
     FROM location_page_translations lpt
     WHERE lpt.language_code = ANY($1)`,
    [LANGS]
);

let changed = 0;
for (const row of rows) {
    const locs = row.popular_locations;
    if (!locs) continue;
    const newLocs = locs.map((loc) => {
        let name = loc.name;
        for (const [en, translations] of Object.entries(DICT)) {
            const needle = `(${en})`;
            if (name.includes(needle)) {
                name = name.replace(needle, `(${translations[row.language_code]})`);
            }
        }
        return { ...loc, name };
    });
    await pool.query(
        `UPDATE location_page_translations SET popular_locations = $1
         WHERE location_page_id = $2 AND language_code = $3`,
        [JSON.stringify(newLocs), row.location_page_id, row.language_code]
    );
    changed++;
}
console.log(`Updated popular_locations descriptors on ${changed} rows.`);
await pool.end();
