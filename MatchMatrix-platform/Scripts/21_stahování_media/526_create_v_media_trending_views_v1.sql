-- ====================================================================
-- TEAM TRENDING VIEW
-- ====================================================================

CREATE OR REPLACE VIEW public.v_media_trending_teams AS
SELECT
    mt.team_id,
    t.name AS team_name,
    t.logo_url,

    mt.article_count,
    mt.total_score,
    mt.weighted_score,
    mt.calculated_at

FROM public.media_trending_teams mt
JOIN public.teams t
    ON t.id = mt.team_id

ORDER BY mt.weighted_score DESC;

-- ====================================================================
-- LEAGUE TRENDING VIEW
-- ====================================================================

CREATE OR REPLACE VIEW public.v_media_trending_leagues AS
SELECT
    mt.league_id,
    l.name AS league_name,
    l.country,

    mt.article_count,
    mt.total_score,
    mt.weighted_score,
    mt.calculated_at

FROM public.media_trending_leagues mt
JOIN public.leagues l
    ON l.id = mt.league_id

ORDER BY mt.weighted_score DESC;