-- create_v_video_feed_by_league_v1.sql
--
-- CO TO DĚLÁ:
-- Vytvoří video/highlights feed podle lig/soutěží.
--
-- Propojí:
-- public.v_video_feed_v2
-- public.article_league_map
-- public.leagues
--
-- KAM TO VEDE:
-- public.v_video_feed_by_league
--
-- K ČEMU TO BUDE:
-- Každá liga bude mít vlastní video/highlights feed.
--
-- VYUŽITÍ NA WEBU/APLIKACI:
--
-- League page:
-- /league/{id}/videos
-- /league/{id}/highlights
--
-- Homepage:
-- blok "Top videos by league"
--
-- Mobilní aplikace:
-- league video sekce
-- playoff highlights
--
-- Budoucnost:
-- video recommendation podle oblíbených lig

DROP VIEW IF EXISTS public.v_video_feed_by_league;

CREATE VIEW public.v_video_feed_by_league AS
SELECT
    alm.league_id,
    l.name AS league_name,

    vf.article_id,
    vf.sport_code,
    vf.source_name,
    vf.source_type,

    vf.title,
    vf.summary,
    vf.url,

    vf.thumbnail_url,
    vf.video_url,
    vf.video_content_type,

    vf.is_video,
    vf.content_type,

    vf.display_published_at,
    vf.feed_score,
    vf.playoff_related,
    vf.entity_count,
    vf.article_quality_reason

FROM public.v_video_feed_v2 vf

JOIN public.article_league_map alm
    ON alm.article_id = vf.article_id

JOIN public.leagues l
    ON l.id = alm.league_id

ORDER BY
    alm.league_id,
    CASE
        WHEN vf.video_content_type = 'REAL_VIDEO' THEN 1
        ELSE 2
    END,
    vf.feed_score DESC,
    vf.display_published_at DESC NULLS LAST;