-- create_v_video_feed_by_player_v1.sql
--
-- CO TO DĚLÁ:
-- Vytvoří video/highlights feed podle hráčů.
--
-- Propojí:
-- public.v_video_feed_v2
-- public.article_player_map
-- public.players
--
-- KAM TO VEDE:
-- public.v_video_feed_by_player
--
-- K ČEMU TO BUDE:
-- Každý hráč bude mít vlastní highlights/video feed.
--
-- VYUŽITÍ NA WEBU/APLIKACI:
--
-- Player page:
-- /player/{id}/videos
--
-- Homepage:
-- Trending player highlights
--
-- Mobilní aplikace:
-- "Best moments"
-- "Top playoff highlights"
--
-- Budoucnost:
-- AI reels
-- player hype feed
-- highlights podle oblíbených hráčů

DROP VIEW IF EXISTS public.v_video_feed_by_player;

CREATE VIEW public.v_video_feed_by_player AS
SELECT
    apm.player_id,
    p.name AS player_name,

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

JOIN public.article_player_map apm
    ON apm.article_id = vf.article_id

JOIN public.players p
    ON p.id = apm.player_id

ORDER BY
    apm.player_id,
    CASE
        WHEN vf.video_content_type = 'REAL_VIDEO' THEN 1
        ELSE 2
    END,
    vf.feed_score DESC,
    vf.display_published_at DESC NULLS LAST;