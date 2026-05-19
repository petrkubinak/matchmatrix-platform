-- rebuild_v_media_layer_coverage_v2.sql

DROP VIEW IF EXISTS public.v_media_layer_coverage;

CREATE VIEW public.v_media_layer_coverage AS
SELECT
    -- articles
    (SELECT COUNT(*) FROM public.articles) AS total_articles,

    -- quality
    (
        SELECT COUNT(*)
        FROM public.articles
        WHERE COALESCE(article_quality_score, 0) >= 70
    ) AS quality_70_plus,

    -- feed eligible
    (
        SELECT COUNT(*)
        FROM public.articles
        WHERE COALESCE(is_feed_eligible, false) = true
    ) AS feed_eligible,

    -- published_at
    (
        SELECT COUNT(*)
        FROM public.articles
        WHERE published_at IS NOT NULL
    ) AS with_published_at,

    -- league links
    (
        SELECT COUNT(DISTINCT article_id)
        FROM public.article_league_map
    ) AS league_linked_articles,

    -- team links
    (
        SELECT COUNT(DISTINCT article_id)
        FROM public.article_team_map
    ) AS team_linked_articles,

    -- player links
    (
        SELECT COUNT(DISTINCT article_id)
        FROM public.article_player_map
    ) AS player_linked_articles,

    -- match links
    (
        SELECT COUNT(DISTINCT article_id)
        FROM public.article_match_map
    ) AS match_linked_articles;