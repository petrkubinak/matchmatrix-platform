-- extract_video_urls_from_raw_html_v1.sql
-- První bezpečný VIDEO URL extractor:
-- NBA: hledá /watch/embed/{id}
-- NHL: hledá Brightcove/entityId UUID z video-js bloku
-- Aktualizuje staging i public podle URL článku.

WITH extracted AS (
    SELECT
        id,
        source_name,
        url,

        CASE
            -- NBA embed URL
            WHEN source_name = 'NBA'
             AND raw_html ~ 'https://www\.nba\.com/watch/embed/[0-9]+'
            THEN substring(raw_html from 'https://www\.nba\.com/watch/embed/[0-9]+')

            -- NBA fallback podle data-nba-id
            WHEN source_name = 'NBA'
             AND raw_html ~ 'data-nba-id="[0-9]+"'
            THEN 'https://www.nba.com/watch/embed/' ||
                 substring(raw_html from 'data-nba-id="([0-9]+)"')

            -- NHL Brightcove / video-js entityId UUID
            WHEN source_name = 'NHL'
             AND raw_html ~ 'entityId":"[a-f0-9-]{36}"'
            THEN 'https://players.brightcove.net/6415718365001/default_default/index.html?videoId=' ||
                 substring(raw_html from 'entityId":"([a-f0-9-]{36})"')

            ELSE NULL
        END AS extracted_video_url

    FROM staging.stg_media_articles
    WHERE is_video = true
)
UPDATE staging.stg_media_articles s
SET
    video_url = e.extracted_video_url,
    updated_at = now()
FROM extracted e
WHERE s.id = e.id
  AND e.extracted_video_url IS NOT NULL
  AND s.video_url IS NULL;


-- Propagace do public.articles podle URL
UPDATE public.articles a
SET
    video_url = s.video_url,
    updated_at = now()
FROM staging.stg_media_articles s
WHERE a.url = s.url
  AND s.video_url IS NOT NULL
  AND a.video_url IS NULL;


-- Kontrola
SELECT
    source_name,
    COUNT(*) FILTER (WHERE is_video = true) AS video_rows,
    COUNT(*) FILTER (WHERE is_video = true AND video_url IS NOT NULL) AS with_video_url
FROM staging.stg_media_articles
GROUP BY source_name
ORDER BY source_name;


-- Kontrola výsledku pro webový VIDEO feed
SELECT
    article_id,
    title,
    source_name,
    url,
    video_url
FROM public.v_video_feed_v2
ORDER BY display_published_at DESC NULLS LAST
LIMIT 20;