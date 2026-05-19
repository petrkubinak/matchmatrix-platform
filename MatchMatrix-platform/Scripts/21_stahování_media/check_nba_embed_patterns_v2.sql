-- check_nba_embed_patterns_v2.sql
--
-- CO TO DĚLÁ:
-- Hledá všechny NBA embed patterny,
-- které můžeme použít pro VIDEO extractor V2.
--
-- KAM TO VEDE:
-- Jen audit / kontrola.
-- Nic neupravuje.
--
-- K ČEMU TO BUDE:
-- Najdeme další varianty NBA embed videí,
-- aby extractor našel více video_url.
--
-- VYUŽITÍ NA WEBU/APLIKACI:
-- Více skutečných highlights videí:
-- homepage
-- team pages
-- player pages
-- playoffs feed
-- mobile highlights carousel

SELECT
    id,
    title,
    url,

    CASE
        WHEN raw_html ~ 'mkv-embed-[0-9]+'
        THEN substring(raw_html from 'mkv-embed-([0-9]+)')
    END AS mkv_embed_id,

    CASE
        WHEN raw_html ~ 'data-nba-id="[0-9]+"'
        THEN substring(raw_html from 'data-nba-id="([0-9]+)"')
    END AS data_nba_id,

    CASE
        WHEN raw_html ~ 'watch/embed/[0-9]+'
        THEN substring(raw_html from 'watch/embed/([0-9]+)')
    END AS watch_embed_id,

    CASE
        WHEN raw_html ~ 'iframe'
        THEN true
        ELSE false
    END AS has_iframe

FROM staging.stg_media_articles
WHERE source_name = 'NBA'
  AND is_video = true
ORDER BY updated_at DESC;