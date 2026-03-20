CREATE OR REPLACE VIEW public.v_fd_matches_today AS
SELECT
    m.id AS match_id,
    l.id AS league_id,
    l.name AS league_name,
    s.code AS sport_code,
    m.season,
    m.kickoff AS kickoff_at_utc,
    m.kickoff::timestamptz AS kickoff_at_local,
    m.status,
    ht.id AS home_team_id,
    ht.name AS home_team_name,
    at.id AS away_team_id,
    at.name AS away_team_name,
    c.iso2 AS country_code,
    ht.logo_url AS home_team_logo_url,
    at.logo_url AS away_team_logo_url
FROM public.matches m
JOIN public.leagues l
    ON l.id = m.league_id
LEFT JOIN public.countries c
    ON c.id = l.country_id
JOIN public.teams ht
    ON ht.id = m.home_team_id
JOIN public.teams at
    ON at.id = m.away_team_id
JOIN public.sports s
    ON s.id = m.sport_id
WHERE DATE(m.kickoff) = CURRENT_DATE;


CREATE OR REPLACE VIEW public.v_fd_matches_tomorrow AS
SELECT
    m.id AS match_id,
    l.id AS league_id,
    l.name AS league_name,
    s.code AS sport_code,
    m.season,
    m.kickoff AS kickoff_at_utc,
    m.kickoff::timestamptz AS kickoff_at_local,
    m.status,
    ht.id AS home_team_id,
    ht.name AS home_team_name,
    at.id AS away_team_id,
    at.name AS away_team_name,
    c.iso2 AS country_code,
    ht.logo_url AS home_team_logo_url,
    at.logo_url AS away_team_logo_url
FROM public.matches m
JOIN public.leagues l
    ON l.id = m.league_id
LEFT JOIN public.countries c
    ON c.id = l.country_id
JOIN public.teams ht
    ON ht.id = m.home_team_id
JOIN public.teams at
    ON at.id = m.away_team_id
JOIN public.sports s
    ON s.id = m.sport_id
WHERE DATE(m.kickoff) = CURRENT_DATE + 1;


CREATE OR REPLACE VIEW public.v_fd_matches_week AS
SELECT
    m.id AS match_id,
    l.id AS league_id,
    l.name AS league_name,
    s.code AS sport_code,
    m.season,
    m.kickoff AS kickoff_at_utc,
    m.kickoff::timestamptz AS kickoff_at_local,
    m.status,
    ht.id AS home_team_id,
    ht.name AS home_team_name,
    at.id AS away_team_id,
    at.name AS away_team_name,
    c.iso2 AS country_code,
    ht.logo_url AS home_team_logo_url,
    at.logo_url AS away_team_logo_url
FROM public.matches m
JOIN public.leagues l
    ON l.id = m.league_id
LEFT JOIN public.countries c
    ON c.id = l.country_id
JOIN public.teams ht
    ON ht.id = m.home_team_id
JOIN public.teams at
    ON at.id = m.away_team_id
JOIN public.sports s
    ON s.id = m.sport_id
WHERE DATE(m.kickoff) BETWEEN CURRENT_DATE AND CURRENT_DATE + 6;