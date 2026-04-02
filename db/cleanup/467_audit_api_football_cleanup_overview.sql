-- 467_audit_api_football_cleanup_overview.sql
-- Audit před cleanupem api_football větve
-- Spustit v DBeaveru po blocích nebo celé.

-- =========================================================
-- 1) Přehled lig podle ext_source
-- =========================================================
SELECT
    COALESCE(ext_source, '(null)') AS ext_source,
    COUNT(*) AS leagues_count
FROM public.leagues
GROUP BY COALESCE(ext_source, '(null)')
ORDER BY leagues_count DESC, ext_source;


-- =========================================================
-- 2) Podezřelé duplicitní ligy podle názvu
--    (stejný/similar název, více provider větví)
-- =========================================================
SELECT
    lower(trim(name)) AS league_key,
    COUNT(*) AS cnt,
    STRING_AGG(
        CONCAT(
            'id=', id,
            ' | name=', name,
            ' | country=', COALESCE(country, '?'),
            ' | ext_source=', COALESCE(ext_source, '?'),
            ' | ext_league_id=', COALESCE(ext_league_id::text, '?')
        ),
        E'\n' ORDER BY ext_source, id
    ) AS leagues_detail
FROM public.leagues
WHERE name IS NOT NULL
GROUP BY lower(trim(name))
HAVING COUNT(*) > 1
ORDER BY cnt DESC, league_key;


-- =========================================================
-- 3) Přímé porovnání football_data vs api_football lig
--    podle stejného názvu
-- =========================================================
SELECT
    fd.id  AS fd_league_id,
    fd.name AS fd_name,
    fd.country AS fd_country,
    fd.ext_league_id AS fd_ext_league_id,
    api.id AS api_league_id,
    api.name AS api_name,
    api.country AS api_country,
    api.ext_league_id AS api_ext_league_id
FROM public.leagues fd
JOIN public.leagues api
  ON lower(trim(fd.name)) = lower(trim(api.name))
 AND COALESCE(lower(trim(fd.country)), '') = COALESCE(lower(trim(api.country)), '')
WHERE fd.ext_source IN ('football_data', 'football_data_uk')
  AND api.ext_source = 'api_football'
ORDER BY fd.name, fd.country, fd.id, api.id;


-- =========================================================
-- 4) Kolik matches je navázáno na ligy z api_football
-- =========================================================
SELECT
    l.id AS league_id,
    l.name,
    l.country,
    l.ext_source,
    l.ext_league_id,
    COUNT(m.id) AS matches_count
FROM public.leagues l
LEFT JOIN public.matches m
       ON m.league_id = l.id
WHERE l.ext_source = 'api_football'
GROUP BY
    l.id, l.name, l.country, l.ext_source, l.ext_league_id
ORDER BY matches_count DESC, l.name, l.id;


-- =========================================================
-- 5) Kolik matches je navázáno na ligy z football_data
-- =========================================================
SELECT
    l.id AS league_id,
    l.name,
    l.country,
    l.ext_source,
    l.ext_league_id,
    COUNT(m.id) AS matches_count
FROM public.leagues l
LEFT JOIN public.matches m
       ON m.league_id = l.id
WHERE l.ext_source IN ('football_data', 'football_data_uk')
GROUP BY
    l.id, l.name, l.country, l.ext_source, l.ext_league_id
ORDER BY matches_count DESC, l.name, l.id;


-- =========================================================
-- 6) Týmy s ext_source = api_football
-- =========================================================
SELECT
    COUNT(*) AS api_football_teams
FROM public.teams
WHERE ext_source = 'api_football';


-- =========================================================
-- 7) Týmy s ext_source = football_data / football_data_uk
-- =========================================================
SELECT
    ext_source,
    COUNT(*) AS teams_count
FROM public.teams
WHERE ext_source IN ('football_data', 'football_data_uk')
GROUP BY ext_source
ORDER BY ext_source;


-- =========================================================
-- 8) Kolik matches používá home/away team z api_football větve
-- =========================================================
SELECT
    COUNT(*) AS matches_with_api_football_home_or_away_team
FROM public.matches m
LEFT JOIN public.teams th ON th.id = m.home_team_id
LEFT JOIN public.teams ta ON ta.id = m.away_team_id
WHERE th.ext_source = 'api_football'
   OR ta.ext_source = 'api_football';


-- =========================================================
-- 9) Přehled provider map pro api_football
-- =========================================================
SELECT
    provider,
    COUNT(*) AS rows_count
FROM public.team_provider_map
WHERE provider = 'api_football'
GROUP BY provider;


-- =========================================================
-- 10) Přehled provider map pro football_data
-- =========================================================
SELECT
    provider,
    COUNT(*) AS rows_count
FROM public.team_provider_map
WHERE provider IN ('football_data', 'football_data_uk')
GROUP BY provider
ORDER BY provider;


-- =========================================================
-- 11) Kandidáti: ligy api_football, které mají stejné jméno
--     jako football_data liga
-- =========================================================
SELECT
    api.id AS api_league_id,
    api.name,
    api.country,
    api.ext_league_id AS api_ext_league_id,
    COUNT(m.id) AS api_matches_count,
    fd.id AS fd_league_id,
    fd.ext_source AS fd_source,
    fd.ext_league_id AS fd_ext_league_id
FROM public.leagues api
JOIN public.leagues fd
  ON lower(trim(api.name)) = lower(trim(fd.name))
 AND COALESCE(lower(trim(api.country)), '') = COALESCE(lower(trim(fd.country)), '')
LEFT JOIN public.matches m
       ON m.league_id = api.id
WHERE api.ext_source = 'api_football'
  AND fd.ext_source IN ('football_data', 'football_data_uk')
GROUP BY
    api.id, api.name, api.country, api.ext_league_id,
    fd.id, fd.ext_source, fd.ext_league_id
ORDER BY api_matches_count DESC, api.name, api.id;


-- =========================================================
-- 12) Rychlý souhrn pro rozhodnutí
-- =========================================================
SELECT 'api_football_leagues' AS metric, COUNT(*)::bigint AS value
FROM public.leagues
WHERE ext_source = 'api_football'

UNION ALL

SELECT 'api_football_matches', COUNT(*)::bigint
FROM public.matches m
JOIN public.leagues l ON l.id = m.league_id
WHERE l.ext_source = 'api_football'

UNION ALL

SELECT 'api_football_teams', COUNT(*)::bigint
FROM public.teams
WHERE ext_source = 'api_football'

UNION ALL

SELECT 'team_provider_map_api_football', COUNT(*)::bigint
FROM public.team_provider_map
WHERE provider = 'api_football';