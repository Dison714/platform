-- =====================================================================
-- MDB PLATFORM — DATABASE SCHEMA  (Opus build)
-- 23_family_specs_seed.sql
-- Seed family_specs from open manufacturer/aggregator data (July 2026).
-- Values are language-neutral (number as text, or code for transmission).
-- Fields genuinely not found in open sources are OMITTED (not fabricated).
-- Variant assumptions (Vario 160, XSR155, Versys-X 250) flagged in review.
-- sort_order: engine_cc 1, power 2, top_speed 3, transmission 4,
--   fuel_consumption 5, fuel_tank 6, seat_height 7, curb_weight 8, seats 9.
-- =====================================================================

INSERT INTO family_specs (family_id, spec_key, spec_value, source, sort_order)
SELECT pf.id, v.spec_key, v.spec_value, v.source, v.sort_order
FROM product_families pf
JOIN (VALUES
    -- Honda ADV160
    ('honda_adv','engine_cc','156.9','ultimatespecs.com',1),
    ('honda_adv','power','15.8','ultimatespecs.com',2),
    ('honda_adv','transmission','cvt','honda.co.id',4),
    ('honda_adv','fuel_tank','8.1','powersports.honda.com',6),
    ('honda_adv','seat_height','780','powersports.honda.com',7),
    ('honda_adv','seats','2','honda.co.id',9),
    -- Honda PCX160
    ('honda_pcx','engine_cc','156.9','ultimatespecs.com',1),
    ('honda_pcx','power','15.8','bikedekho.com',2),
    ('honda_pcx','transmission','cvt','honda.co.id',4),
    ('honda_pcx','fuel_tank','8.1','bikedekho.com',6),
    ('honda_pcx','seat_height','764','bikedekho.com',7),
    ('honda_pcx','curb_weight','132','bikedekho.com',8),
    ('honda_pcx','seats','2','honda.co.id',9),
    -- Honda Vario 160 (variant assumed)
    ('honda_vario','engine_cc','156.9','oto.com',1),
    ('honda_vario','power','15.4','oto.com',2),
    ('honda_vario','transmission','cvt','oto.com',4),
    ('honda_vario','fuel_consumption','2.1','91wheels.com',5),
    ('honda_vario','fuel_tank','5.5','oto.com',6),
    ('honda_vario','seat_height','778','91wheels.com',7),
    ('honda_vario','curb_weight','115','91wheels.com',8),
    ('honda_vario','seats','2','oto.com',9),
    -- Honda CB150X
    ('honda_cb150x','engine_cc','149.16','ultimatespecs.com',1),
    ('honda_cb150x','power','16.6','oto.com',2),
    ('honda_cb150x','transmission','manual','oto.com',4),
    ('honda_cb150x','fuel_consumption','2.5','oto.com',5),
    ('honda_cb150x','fuel_tank','12','oto.com',6),
    ('honda_cb150x','seat_height','817','oto.com',7),
    ('honda_cb150x','curb_weight','139','oto.com',8),
    ('honda_cb150x','seats','2','oto.com',9),
    -- Honda CBR250RR
    ('honda_cbr250rr','engine_cc','249.7','en.wikipedia.org',1),
    ('honda_cbr250rr','power','40.2','en.wikipedia.org',2),
    ('honda_cbr250rr','transmission','manual','en.wikipedia.org',4),
    ('honda_cbr250rr','fuel_tank','14.5','en.wikipedia.org',6),
    ('honda_cbr250rr','seat_height','790','en.wikipedia.org',7),
    ('honda_cbr250rr','curb_weight','168','en.wikipedia.org',8),
    ('honda_cbr250rr','seats','2','en.wikipedia.org',9),
    -- Suzuki V-Strom 250 (DL250)
    ('suzuki_vstrom250','engine_cc','248','en.wikipedia.org',1),
    ('suzuki_vstrom250','power','25','en.wikipedia.org',2),
    ('suzuki_vstrom250','top_speed','140','en.wikipedia.org',3),
    ('suzuki_vstrom250','transmission','manual','en.wikipedia.org',4),
    ('suzuki_vstrom250','fuel_consumption','2.7','motorcyclespecs.co.za',5),
    ('suzuki_vstrom250','fuel_tank','17.3','en.wikipedia.org',6),
    ('suzuki_vstrom250','seat_height','800','en.wikipedia.org',7),
    ('suzuki_vstrom250','curb_weight','188','en.wikipedia.org',8),
    ('suzuki_vstrom250','seats','2','en.wikipedia.org',9),
    -- Morbidelli C252V (official site)
    ('morbidelli_c252v','engine_cc','249','morbidelli.com',1),
    ('morbidelli_c252v','power','25','morbidelli.com',2),
    ('morbidelli_c252v','transmission','manual','morbidelli.com',4),
    ('morbidelli_c252v','fuel_tank','15.5','morbidelli.com',6),
    ('morbidelli_c252v','seat_height','690','morbidelli.com',7),
    ('morbidelli_c252v','curb_weight','200','morbidelli.com',8),
    ('morbidelli_c252v','seats','2','morbidelli.com',9),
    -- Yamaha Nmax 155 (power omitted: sources conflict)
    ('yamaha_nmax','engine_cc','155','ultimatespecs.com',1),
    ('yamaha_nmax','transmission','cvt','yamaha-motor.co.id',4),
    ('yamaha_nmax','fuel_tank','7.1','ultimatespecs.com',6),
    ('yamaha_nmax','seat_height','765','ultimatespecs.com',7),
    ('yamaha_nmax','curb_weight','127','ultimatespecs.com',8),
    ('yamaha_nmax','seats','2','yamaha-motor.co.id',9),
    -- Yamaha XMAX 250 (current gen)
    ('yamaha_xmax','engine_cc','250','yamahamotorsports.com',1),
    ('yamaha_xmax','power','22.5','zigwheels.my',2),
    ('yamaha_xmax','transmission','cvt','yamahamotorsports.com',4),
    ('yamaha_xmax','fuel_tank','13','yamahamotorsports.com',6),
    ('yamaha_xmax','seat_height','795','yamahamotorsports.com',7),
    ('yamaha_xmax','seats','2','yamahamotorsports.com',9),
    -- Yamaha XSR155 (variant assumed)
    ('yamaha_xsr','engine_cc','155','oto.com',1),
    ('yamaha_xsr','power','18.4','oto.com',2),
    ('yamaha_xsr','transmission','manual','oto.com',4),
    ('yamaha_xsr','fuel_tank','10','oto.com',6),
    ('yamaha_xsr','seat_height','810','oto.com',7),
    ('yamaha_xsr','curb_weight','134','bikedekho.com',8),
    ('yamaha_xsr','seats','2','oto.com',9),
    -- Yamaha MT-25
    ('yamaha_mt25','engine_cc','249','ultimatespecs.com',1),
    ('yamaha_mt25','power','35.5','ultimatespecs.com',2),
    ('yamaha_mt25','top_speed','179','ultimatespecs.com',3),
    ('yamaha_mt25','transmission','manual','yamaha-motor.co.id',4),
    ('yamaha_mt25','fuel_tank','14','ultimatespecs.com',6),
    ('yamaha_mt25','seat_height','780','zigwheels.my',7),
    ('yamaha_mt25','seats','2','yamaha-motor.co.id',9),
    -- Kawasaki Versys-X 250 (variant assumed)
    ('kawasaki_versys','engine_cc','249','en.wikipedia.org',1),
    ('kawasaki_versys','power','33.5','oto.com',2),
    ('kawasaki_versys','transmission','manual','en.wikipedia.org',4),
    ('kawasaki_versys','fuel_tank','17','en.wikipedia.org',6),
    ('kawasaki_versys','seat_height','815','en.wikipedia.org',7),
    ('kawasaki_versys','curb_weight','173','oto.com',8),
    ('kawasaki_versys','seats','2','en.wikipedia.org',9),
    -- Kawasaki Ninja ZX-25R
    ('kawasaki_zx25r','engine_cc','249.8','en.wikipedia.org',1),
    ('kawasaki_zx25r','power','46','en.wikipedia.org',2),
    ('kawasaki_zx25r','top_speed','190','en.wikipedia.org',3),
    ('kawasaki_zx25r','transmission','manual','en.wikipedia.org',4),
    ('kawasaki_zx25r','fuel_tank','15','en.wikipedia.org',6),
    ('kawasaki_zx25r','seat_height','785','en.wikipedia.org',7),
    ('kawasaki_zx25r','curb_weight','184','en.wikipedia.org',8),
    ('kawasaki_zx25r','seats','2','en.wikipedia.org',9),
    -- TVS Ronin 225
    ('tvs_ronin225','engine_cc','225.9','tvsmotor.com',1),
    ('tvs_ronin225','power','20.1','tvsmotor.com',2),
    ('tvs_ronin225','transmission','manual','tvsmotor.com',4),
    ('tvs_ronin225','fuel_tank','14','91wheels.com',6),
    ('tvs_ronin225','seat_height','795','91wheels.com',7),
    ('tvs_ronin225','curb_weight','159','91wheels.com',8),
    ('tvs_ronin225','seats','2','tvsmotor.com',9)
) AS v(family_code, spec_key, spec_value, source, sort_order)
  ON v.family_code = pf.code;
