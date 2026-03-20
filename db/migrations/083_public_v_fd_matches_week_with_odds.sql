CREATE OR REPLACE VIEW public.v_fd_matches_week_with_odds AS
SELECT
    bo.match_id,

    l.id AS league_id,
    l.name AS league_name,
    c.iso2 AS country_code,

    ht.name AS home_team_name,
    at.name AS away_team_name,

    ht.logo_url AS home_team_logo_url,
    at.logo_url AS away_team_logo_url,

    m.kickoff::timestamptz AS kickoff_at_local,
    m.status,

    bo.odds_1,
    bo.odds_x,
    bo.odds_2

FROM public.v_matches_with_odds_week bo

JOIN public.matches m
    ON m.id = bo.match_id

JOIN public.leagues l
    ON l.id = m.league_id

LEFT JOIN public.countries c
    ON c.id = l.country_id

JOIN public.teams ht
    ON ht.id = m.home_team_id

JOIN public.teams at
    ON at.id = m.away_team_id

ORDER BY m.kickoff ASC;