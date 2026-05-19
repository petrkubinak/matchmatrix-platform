-- create_v_video_feed_by_team_v1.sql
--
-- CO TO DĚLÁ:
-- Vytvoří video feed podle týmů.
-- Propojí:
-- public.v_video_feed_v2
-- public.article_team_map
-- public.teams
--
-- KAM TO VEDE:
-- Vznikne view:
-- public.v_video_feed_by_team
--
-- K ČEMU TO BUDE:
-- Každý tým bude mít vlastní video/highlights feed.
--
-- VYUŽITÍ NA WEBU/APLIKACI:
-- Team page:
-- /team/{id}/videos
-- /team/{id}/highlights
--
-- Homepage:
-- týmové video bloky
-- doporučená videa podle oblíbeného týmu

DROP VIEW IF EXISTS public.v_video_feed_by_team;

CREATE VIEW public.v_video_feed_by_team AS
SELECT
    atm.team_id,
    t.name AS team_name,

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
JOIN public.article_team_map atm
    ON atm.article_id = vf.article_id
JOIN public.teams t
    ON t.id = atm.team_id

ORDER BY
    atm.team_id,
    CASE
        WHEN vf.video_content_type = 'REAL_VIDEO' THEN 1
        ELSE 2
    END,
    vf.feed_score DESC,
    vf.display_published_at DESC NULLS LAST;