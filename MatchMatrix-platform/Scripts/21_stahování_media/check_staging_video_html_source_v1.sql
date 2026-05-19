-- check_staging_video_html_source_v1.sql

SELECT
    COUNT(*) AS staging_rows,
    COUNT(*) FILTER (WHERE is_video = true) AS staging_video_rows,
    COUNT(*) FILTER (WHERE raw_html IS NOT NULL AND length(raw_html) > 100) AS with_raw_html,
    COUNT(*) FILTER (WHERE is_video = true AND raw_html IS NOT NULL AND length(raw_html) > 100) AS video_with_raw_html,
    COUNT(*) FILTER (WHERE video_url IS NOT NULL) AS with_video_url,
    COUNT(*) FILTER (WHERE duration_seconds IS NOT NULL) AS with_duration
FROM staging.stg_media_articles;


SELECT
    id,
    source_name,
    title,
    url,
    is_video,
    thumbnail_url,
    video_url,
    duration_seconds,
    length(raw_html) AS raw_html_len,
    length(raw_text) AS raw_text_len
FROM staging.stg_media_articles
WHERE is_video = true
ORDER BY updated_at DESC
LIMIT 50;