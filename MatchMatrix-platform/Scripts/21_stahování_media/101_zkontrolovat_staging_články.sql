SELECT
    provider,
    source_name,
    source_type,
    parse_status,
    COUNT(*) AS rows_count,
    MIN(created_at) AS first_created,
    MAX(created_at) AS last_created
FROM staging.stg_media_articles
GROUP BY
    provider,
    source_name,
    source_type,
    parse_status
ORDER BY
    source_name,
    parse_status;