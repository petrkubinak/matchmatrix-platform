-- 823_cleanup_bad_nba_article_urls.sql
-- Cleanup bad NBA article URLs that were saved with nhl.com domain

BEGIN;

DELETE FROM public.article_media_team_alias_map
WHERE article_id IN (
    SELECT a.id
    FROM public.articles a
    JOIN public.content_sources cs
      ON cs.id = a.content_source_id
    WHERE cs.name = 'NBA'
      AND cs.source_type = 'official_site'
      AND a.url ILIKE 'https://www.nhl.com/%'
);

DELETE FROM public.articles
WHERE id IN (
    SELECT a.id
    FROM public.articles a
    JOIN public.content_sources cs
      ON cs.id = a.content_source_id
    WHERE cs.name = 'NBA'
      AND cs.source_type = 'official_site'
      AND a.url ILIKE 'https://www.nhl.com/%'
);

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

COMMIT;