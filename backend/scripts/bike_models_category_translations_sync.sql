-- bike-models category name/description translations (was en-only, no other
-- locale ever had it because the category had zero published articles before
-- this session). Publishing 15 articles into it surfaced the gap live (raw
-- "bike-models" slug shown in breadcrumb/tabs on ru/ja/etc). Same style as
-- the other categories (short 2-3 word name, one-sentence description).
BEGIN;

UPDATE article_category_translations
SET description = 'In-depth reviews of every bike and scooter model in our fleet.'
WHERE language_code = 'en' AND category_id = (SELECT id FROM article_categories WHERE slug = 'bike-models');

INSERT INTO article_category_translations (category_id, language_code, name, slug, description)
SELECT ac.id, v.language_code, v.name, 'bike-models', v.description
FROM article_categories ac,
  (VALUES
    ('ru', 'Гид по моделям байков', 'Подробные обзоры каждой модели байка и скутера в нашем парке.'),
    ('de', 'Modellguide', 'Ausführliche Testberichte zu jedem Motorrad- und Rollermodell in unserer Flotte.'),
    ('fr', 'Guide des modèles', 'Avis détaillés sur chaque modèle de moto et de scooter de notre flotte.'),
    ('es', 'Guía de modelos', 'Reseñas detalladas de cada modelo de moto y scooter de nuestra flota.'),
    ('it', 'Guida ai modelli', 'Recensioni dettagliate di ogni modello di moto e scooter della nostra flotta.'),
    ('ja', 'モデルガイド', '当店の全バイク・スクーターモデルの詳しいレビュー。'),
    ('ko', '모델 가이드', '저희 보유 오토바이 및 스쿠터 전 모델에 대한 상세 리뷰입니다.'),
    ('ar', 'دليل الموديلات', 'مراجعات مفصلة لكل طراز دراجة نارية وسكوتر في أسطولنا.'),
    ('hi', 'मॉडल गाइड', 'हमारे बेड़े में मौजूद हर बाइक और स्कूटर मॉडल की विस्तृत समीक्षा।'),
    ('zh-Hans', '车型指南', '我们车队中每款摩托车和踏板车车型的详细评测。')
  ) AS v(language_code, name, description)
WHERE ac.slug = 'bike-models'
ON CONFLICT (category_id, language_code) DO UPDATE SET
  name = EXCLUDED.name, description = EXCLUDED.description;

COMMIT;
