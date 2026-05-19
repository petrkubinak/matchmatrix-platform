CREATE VIEW public.v_player_trending_feed AS

SELECT
    pt.player_id,

    p.name AS player_name,

    p.photo_url,

    p.position,

    p.team_id,

    t.name AS team_name,

    t.logo_url AS team_logo,

    pt.article_count,

    pt.trending_score,

    pt.last_article_at,

    pt.updated_at

FROM public.player_trending pt

JOIN public.players p
    ON p.id = pt.player_id

LEFT JOIN public.teams t
    ON t.id = p.team_id

ORDER BY
    pt.trending_score DESC;