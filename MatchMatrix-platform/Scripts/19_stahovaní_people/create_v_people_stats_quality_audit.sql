DROP VIEW IF EXISTS public.v_people_stats_quality_audit;

CREATE VIEW public.v_people_stats_quality_audit AS

SELECT
    s.code AS sport_code,
    s.name AS sport_name,

    l.id AS league_id,
    l.name AS league_name,

    pss.season,

    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE pss.team_id IS NOT NULL) AS rows_with_team,

    COUNT(*) FILTER (WHERE pss.appearances IS NOT NULL) AS rows_with_appearances,

    COUNT(*) FILTER (WHERE pss.rating IS NOT NULL) AS rows_with_rating,

    COUNT(*) FILTER (WHERE pss.goals IS NOT NULL) AS rows_with_goals,

    ROUND(
        COUNT(*) FILTER (WHERE pss.appearances IS NOT NULL)::NUMERIC
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS appearances_coverage_pct,

    ROUND(
        COUNT(*) FILTER (WHERE pss.rating IS NOT NULL)::NUMERIC
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS rating_coverage_pct,

    ROUND(
        COUNT(*) FILTER (WHERE pss.team_id IS NOT NULL)::NUMERIC
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS team_mapping_coverage_pct

FROM public.player_season_statistics pss

LEFT JOIN public.leagues l
    ON l.id = pss.league_id

LEFT JOIN public.sports s
    ON s.id = pss.sport_id

GROUP BY
    s.code,
    s.name,
    l.id,
    l.name,
    pss.season;