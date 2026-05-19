-- create_v_media_trending_players_v1.sql
-- Trending hráči podle počtu článků + quality score.

CREATE OR REPLACE VIEW public.v_media_trending_players_v1 AS
SELECT
    p.id AS player_id,
    p.name AS player_name,
    p.team_id,

    COUNT(*) AS article_count,

    ROUND(AVG(
        COALESCE(a.article_quality_score, 0)
    ), 2) AS avg_quality_score,

    ROUND(SUM(
        COALESCE(a.article_quality_score, 0)
    ), 2) AS total_quality_score,

    MAX(a.published_at) AS latest_article_at

FROM public.article_player_map apm

JOIN public.players p
    ON p.id = apm.player_id

JOIN public.articles a
    ON a.id = apm.article_id

WHERE COALESCE(a.article_quality_score, 0) >= 70

GROUP BY
    p.id,
    p.name,
    p.team_id

ORDER BY
    article_count DESC,
    total_quality_score DESC,
    latest_article_at DESC;