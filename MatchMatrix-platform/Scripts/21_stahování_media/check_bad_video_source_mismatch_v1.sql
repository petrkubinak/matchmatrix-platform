-- check_bad_video_source_mismatch_v1.sql
-- CO TO DĚLÁ:
-- Hledá články, kde source_name/source provider nesedí s URL článku.
-- Například source_name = NBA, ale URL vede na nhl.com.
--
-- KAM TO VEDE:
-- Výsledek zatím nic nemaže ani neupravuje.
-- Jen ukáže podezřelé řádky v public.articles a staging.stg_media_articles.
--
-- K ČEMU TO BUDE:
-- Vyčistíme video feed od falešných položek a zabráníme špatnému zobrazení na webu.
--
-- VYUŽITÍ NA WEBU/APLIKACI:
-- Homepage / video feed nebude ukazovat NHL chybu jako NBA video.
-- Feed bude důvěryhodnější a čistší.

SELECT
    'public.articles' AS layer,
    a.id,
    cs.name AS source_name,
    a.title,
    a.url,
    a.is_video,
    a.video_url,
    a.article_quality_score,
    a.article_quality_reason
FROM public.articles a
LEFT JOIN public.content_sources cs
    ON cs.id = a.content_source_id
WHERE (
       lower(cs.name) = 'nba'
       AND lower(a.url) LIKE '%nhl.com%'
)
OR (
       lower(cs.name) = 'nhl'
       AND lower(a.url) LIKE '%nba.com%'
)

UNION ALL

SELECT
    'staging.stg_media_articles' AS layer,
    s.id,
    s.source_name,
    s.title,
    s.url,
    s.is_video,
    s.video_url,
    s.article_quality_score,
    s.article_quality_reason
FROM staging.stg_media_articles s
WHERE (
       lower(s.source_name) = 'nba'
       AND lower(s.url) LIKE '%nhl.com%'
)
OR (
       lower(s.source_name) = 'nhl'
       AND lower(s.url) LIKE '%nba.com%'
)
ORDER BY layer, id;