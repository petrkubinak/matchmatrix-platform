CREATE OR REPLACE VIEW public.v_fd_matches_week_ui AS
SELECT
    m.id AS match_id,

    l.id AS league_id,
    l.name AS league_name,
    l.logo_url AS league_logo_url,
    l.is_cup AS league_is_cup,
    l.is_international AS league_is_international,
    c.iso2 AS country_code,

    m.kickoff::timestamptz AS kickoff_at_local,
    m.status,

    ht.name AS home_team_name,
    ht.logo_url AS home_team_logo_url,
    NULL::text AS home_team_country_code,

    at.name AS away_team_name,
    at.logo_url AS away_team_logo_url,
    NULL::text AS away_team_country_code

FROM public.matches m
JOIN public.leagues l
  ON l.id = m.league_id
LEFT JOIN public.countries c
  ON c.id = l.country_id
JOIN public.teams ht
  ON ht.id = m.home_team_id
JOIN public.teams at
  ON at.id = m.away_team_id
WHERE DATE(m.kickoff) BETWEEN CURRENT_DATE AND CURRENT_DATE + 6
ORDER BY m.kickoff;