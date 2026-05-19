-- check_articles_video_columns_v1.sql

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'articles'
  AND (
       column_name LIKE '%video%'
    OR column_name LIKE '%duration%'
    OR column_name LIKE '%thumbnail%'
    OR column_name LIKE '%html%'
  )
ORDER BY ordinal_position;


SELECT
    id,
    title,
    url,
    thumbnail_url,
    video_url,
    is_video,
    raw_html_path
FROM public.articles
WHERE is_video = true
ORDER BY published_at DESC NULLS LAST
LIMIT 50;