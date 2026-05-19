-- check_media_video_layer_inventory_v1.sql
-- Audit VIDEO/HIGHLIGHTS layer připravenosti.

-- 1) Video/media related tables
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND (
       table_name LIKE '%video%'
    OR table_name LIKE '%highlight%'
    OR table_name LIKE '%clip%'
  )
ORDER BY table_type, table_name;


-- 2) Video/media related views
SELECT
    table_name AS view_name
FROM information_schema.views
WHERE table_schema = 'public'
  AND (
       table_name LIKE '%video%'
    OR table_name LIKE '%highlight%'
    OR table_name LIKE '%clip%'
  )
ORDER BY table_name;


-- 3) Existing columns in public.articles related to videos
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'articles'
  AND (
       column_name LIKE '%video%'
    OR column_name LIKE '%thumbnail%'
    OR column_name LIKE '%duration%'
    OR column_name LIKE '%media%'
  )
ORDER BY ordinal_position;


-- 4) Current video article coverage
SELECT
    COUNT(*) AS total_articles,
    COUNT(*) FILTER (WHERE is_video = true) AS video_articles,
    COUNT(*) FILTER (WHERE video_url IS NOT NULL) AS with_video_url,
    COUNT(*) FILTER (WHERE thumbnail_url IS NOT NULL) AS with_thumbnail,
    COUNT(*) FILTER (WHERE duration_seconds IS NOT NULL) AS with_duration
FROM public.articles;