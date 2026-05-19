-- 822_inspect_nba_article_urls.sql
-- Inspect NBA article URLs for alias strategy

SELECT
    a.id,
    cs.name AS source_name,
    a.title,
    a.url
FROM public.articles a
JOIN public.content_sources cs
  ON cs.id = a.content_source_id
WHERE cs.name = 'NBA'
  AND cs.source_type = 'official_site'
ORDER BY a.id DESC
LIMIT 50;