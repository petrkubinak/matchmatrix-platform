-- =====================================================================
-- MatchMatrix
-- Check references for manual seed team_id = 1
-- Soubor:
-- C:\MatchMatrix-platform\db\migrations\20260326_08_check_team_1_references.sql
-- Spouštět v DBeaveru
-- =====================================================================

SELECT 'TEAM_1' AS section, t.*
FROM public.teams t
WHERE t.id = 1;

SELECT 'TEAM_1_PROVIDER_MAP' AS section, pm.*
FROM public.team_provider_map pm
WHERE pm.team_id = 1
ORDER BY pm.provider;

SELECT 'TEAM_1_ALIASES' AS section, a.*
FROM public.team_aliases a
WHERE a.team_id = 1
ORDER BY a.alias;

SELECT 'TEAM_1_LEAGUE_TEAMS' AS section, lt.*
FROM public.league_teams lt
WHERE lt.team_id = 1
ORDER BY lt.league_id, lt.season;

SELECT 'TEAM_1_MATCH_USAGE' AS section, x.team_id, COUNT(*) AS matches_used
FROM (
    SELECT home_team_id AS team_id FROM public.matches
    UNION ALL
    SELECT away_team_id AS team_id FROM public.matches
) x
WHERE x.team_id = 1
GROUP BY x.team_id;

SELECT 'TEAM_1_TEAM_ALIAS_REFCOUNT' AS section, COUNT(*) AS cnt
FROM public.team_aliases
WHERE team_id = 1;

SELECT 'TEAM_1_PROVIDER_REFCOUNT' AS section, COUNT(*) AS cnt
FROM public.team_provider_map
WHERE team_id = 1;

SELECT 'TEAM_1_LEAGUE_TEAMS_REFCOUNT' AS section, COUNT(*) AS cnt
FROM public.league_teams
WHERE team_id = 1;

SELECT 'TEAM_1_MATCH_REFCOUNT' AS section, COUNT(*) AS cnt
FROM public.matches
WHERE home_team_id = 1 OR away_team_id = 1;