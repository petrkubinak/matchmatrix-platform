-- 831_check_latest_uefa_articles.sql
-- Inspect UEFA articles captured by generic scraper

SELECT
    a.id,
    cs.name,
    a.title,
    a.url,
    a.created_at
FROM public.articles a
JOIN public.content_sources cs
  ON cs.id = a.content_source_id
WHERE cs.name = 'UEFA'
ORDER BY a.id DESC
LIMIT 20;