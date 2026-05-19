-- 805_media_staging_status_check.sql
-- MEDIA staging stav

SELECT
    parse_status,
    COUNT(*) AS rows_count
FROM staging.stg_media_articles
GROUP BY parse_status
ORDER BY parse_status;

SELECT
    id,
    provider,
    source_name,
    source_type,
    title,
    url,
    parse_status,
    parse_message,
    created_at
FROM staging.stg_media_articles
ORDER BY id DESC
LIMIT 20;