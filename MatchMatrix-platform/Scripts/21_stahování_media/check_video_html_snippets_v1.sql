-- check_video_html_snippets_v1.sql
-- Vytáhne malé ukázky HTML okolo video patternů.

SELECT
    id,
    source_name,
    title,
    url,

    substring(raw_html from greatest(position('youtube' in lower(raw_html)) - 200, 1) for 800) AS youtube_snippet,

    substring(raw_html from greatest(position('brightcove' in lower(raw_html)) - 200, 1) for 800) AS brightcove_snippet,

    substring(raw_html from greatest(position('mp4' in lower(raw_html)) - 200, 1) for 800) AS mp4_snippet,

    substring(raw_html from greatest(position('embed' in lower(raw_html)) - 200, 1) for 800) AS embed_snippet

FROM staging.stg_media_articles
WHERE is_video = true
ORDER BY updated_at DESC
LIMIT 20;