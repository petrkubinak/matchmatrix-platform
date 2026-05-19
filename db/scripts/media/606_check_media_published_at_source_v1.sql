-- check_media_published_at_source_v1.sql
-- Cíl:
-- zjistit, jestli published_at existuje ve staging vrstvě,
-- ale nepřeteklo do public.articles.

SELECT
    COUNT(*) AS staging_articles,
    COUNT(*) FILTER (WHERE published_at IS NOT NULL) AS staging_with_published_at,
    MIN(published_at) AS min_staging_published_at,
    MAX(published_at) AS max_staging_published_at
FROM staging.stg_media_articles;


SELECT
    source_name,
    COUNT(*) AS rows_count,
    COUNT(*) FILTER (WHERE published_at IS NOT NULL) AS with_published_at,
    MIN(published_at) AS min_published_at,
    MAX(published_at) AS max_published_at
FROM staging.stg_media_articles
GROUP BY source_name
ORDER BY rows_count DESC;


SELECT
    id,
    source_name,
    title,
    url,
    published_at,
    created_at,
    updated_at
FROM staging.stg_media_articles
ORDER BY created_at DESC
LIMIT 50;