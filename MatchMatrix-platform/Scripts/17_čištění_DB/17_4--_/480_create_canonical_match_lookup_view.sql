-- 480_create_canonical_match_lookup_view.sql
-- Cíl:
-- vytvořit lookup view pro matches přes canonical team IDs

DROP VIEW IF EXISTS public.v_canonical_match_lookup;

CREATE VIEW public.v_canonical_match_lookup AS
SELECT
    m.id AS match_id,
    m.league_id,
    l.name AS league_name,
    l.country AS league_country,
    l.ext_source AS league_source,
    l.ext_league_id,
    m.kickoff,

    m.home_team_id,
    th.name AS home_team_name,
    COALESCE(rh.canonical_team_id, m.home_team_id) AS canonical_home_team_id,

    m.away_team_id,
    ta.name AS away_team_name,
    COALESCE(ra.canonical_team_id, m.away_team_id) AS canonical_away_team_id

FROM public.matches m
LEFT JOIN public.leagues l
       ON l.id = m.league_id
LEFT JOIN public.teams th
       ON th.id = m.home_team_id
LEFT JOIN public.teams ta
       ON ta.id = m.away_team_id

LEFT JOIN public.v_canonical_team_resolve rh
       ON rh.provider = COALESCE(th.ext_source, 'canonical')
      AND rh.provider_team_id = m.home_team_id

LEFT JOIN public.v_canonical_team_resolve ra
       ON ra.provider = COALESCE(ta.ext_source, 'canonical')
      AND ra.provider_team_id = m.away_team_id;

-- kontrola 1: počet řádků
SELECT COUNT(*) AS match_rows
FROM public.v_canonical_match_lookup;

-- kontrola 2: preview
SELECT
    match_id,
    league_name,
    kickoff,
    home_team_id,
    home_team_name,
    canonical_home_team_id,
    away_team_id,
    away_team_name,
    canonical_away_team_id
FROM public.v_canonical_match_lookup
ORDER BY kickoff DESC
LIMIT 20;