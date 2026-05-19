-- 832_cleanup_uefa_landing_page_article.sql
-- Remove UEFA landing page saved as article

DELETE FROM public.articles a
USING public.content_sources cs
WHERE a.content_source_id = cs.id
  AND cs.name = 'UEFA'
  AND cs.source_type = 'official_site'
  AND a.url = 'https://www.uefa.com/news-media/news/';

-- kontrola
SELECT
    cs.name,
    cs.source_type,
    COUNT(*) AS articles_count
FROM public.articles a
JOIN public.content_sources cs
  ON cs.id = a.content_source_id
GROUP BY cs.name, cs.source_type
ORDER BY cs.name, cs.source_type;