-- check_video_html_patterns_v1.sql
-- Hledá možné video identifikátory / embed patterny v raw_html.

SELECT
    id,
    source_name,
    title,
    url,
    is_video,
    length(raw_html) AS raw_html_len,

    CASE WHEN raw_html ILIKE '%video%' THEN true ELSE false END AS has_video_word,
    CASE WHEN raw_html ILIKE '%mp4%' THEN true ELSE false END AS has_mp4,
    CASE WHEN raw_html ILIKE '%m3u8%' THEN true ELSE false END AS has_m3u8,
    CASE WHEN raw_html ILIKE '%youtube%' THEN true ELSE false END AS has_youtube,
    CASE WHEN raw_html ILIKE '%brightcove%' THEN true ELSE false END AS has_brightcove,
    CASE WHEN raw_html ILIKE '%jwplayer%' THEN true ELSE false END AS has_jwplayer,
    CASE WHEN raw_html ILIKE '%embed%' THEN true ELSE false END AS has_embed,
    CASE WHEN raw_html ILIKE '%player%' THEN true ELSE false END AS has_player

FROM staging.stg_media_articles
WHERE is_video = true
ORDER BY updated_at DESC
LIMIT 50;