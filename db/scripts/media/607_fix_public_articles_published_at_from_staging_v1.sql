-- fix_public_articles_published_at_from_staging_v1.sql
-- Doplní public.articles.published_at ze staging.stg_media_articles.created_at.
-- Bezpečné: aktualizuje jen články, kde public.published_at je NULL.

UPDATE public.articles a
SET
    published_at = s.created_at,
    updated_at = now()
FROM staging.stg_media_articles s
WHERE a.url = s.url
  AND a.published_at IS NULL
  AND s.created_at IS NOT NULL;


-- Kontrola výsledku
SELECT
    COUNT(*) AS total_articles,
    COUNT(*) FILTER (WHERE published_at IS NOT NULL) AS with_published_at,
    MIN(published_at) AS min_published_at,
    MAX(published_at) AS max_published_at
FROM public.articles;