-- =====================================================================
-- MatchMatrix
-- Arsenal audit only
-- Soubor:
-- C:\MatchMatrix-platform\db\migrations\20260326_04_arsenal_audit_only.sql
-- Spouštět v DBeaveru
-- Jen audit, bez změn dat
-- =====================================================================

-- Kandidáti:
-- 1      Arsenal
-- 11910  Arsenal / api_football / 42
-- 13102  Arsenal / api_football / 9419
-- 26871  Arsenal / api_sport / 9419

-- ============================================================
-- 1) ZÁKLADNÍ TEAMS
-- ============================================================

SELECT 'ARSENAL_TEAMS' AS section, t.*
FROM public.teams t
WHERE t.id IN (1, 11910, 13102, 26871)
ORDER BY t.id;

-- ============================================================
-- 2) PROVIDER MAP
-- ============================================================

SELECT 'ARSENAL_PROVIDER_MAP' AS section, pm.*
FROM public.team_provider_map pm
WHERE pm.team_id IN (1, 11910, 13102, 26871)
ORDER BY pm.team_id, pm.provider;

-- ============================================================
-- 3) ALIASES
-- ============================================================

SELECT 'ARSENAL_ALIASES' AS section, a.*
FROM public.team_aliases a
WHERE a.team_id IN (1, 11910, 13102, 26871)
ORDER BY a.team_id, a.alias;

-- ============================================================
-- 4) LEAGUE_TEAMS
-- ============================================================

SELECT 'ARSENAL_LEAGUE_TEAMS' AS section, lt.*
FROM public.league_teams lt
WHERE lt.team_id IN (1, 11910, 13102, 26871)
ORDER BY lt.team_id, lt.league_id, lt.season;

-- ============================================================
-- 5) MATCH USAGE
-- ============================================================

SELECT 'ARSENAL_MATCH_USAGE' AS section, x.team_id, COUNT(*) AS matches_used
FROM (
    SELECT home_team_id AS team_id FROM public.matches
    UNION ALL
    SELECT away_team_id AS team_id FROM public.matches
) x
WHERE x.team_id IN (1, 11910, 13102, 26871)
GROUP BY x.team_id
ORDER BY x.team_id;

-- ============================================================
-- 6) MATCH SPLIT PODLE ZDROJE
-- ============================================================

SELECT
    'ARSENAL_MATCH_SPLIT' AS section,
    CASE
        WHEN m.home_team_id = 1 OR m.away_team_id = 1 THEN 1
        WHEN m.home_team_id = 11910 OR m.away_team_id = 11910 THEN 11910
        WHEN m.home_team_id = 13102 OR m.away_team_id = 13102 THEN 13102
        WHEN m.home_team_id = 26871 OR m.away_team_id = 26871 THEN 26871
    END AS arsenal_team_id,
    COALESCE(m.ext_source, '(null)') AS ext_source,
    COUNT(*) AS matches_cnt,
    MIN(m.kickoff) AS min_kickoff,
    MAX(m.kickoff) AS max_kickoff
FROM public.matches m
WHERE m.home_team_id IN (1, 11910, 13102, 26871)
   OR m.away_team_id IN (1, 11910, 13102, 26871)
GROUP BY 2, 3
ORDER BY 2, 3;

-- ============================================================
-- 7) DETAIL MATCHŮ PRO RUČNÍ KONTROLU
-- ============================================================

SELECT
    'ARSENAL_MATCH_DETAIL' AS section,
    m.id,
    m.ext_source,
    m.ext_match_id,
    m.kickoff,
    m.home_team_id,
    ht.name AS home_team_name,
    m.away_team_id,
    at.name AS away_team_name,
    m.league_id,
    l.name AS league_name,
    m.season
FROM public.matches m
LEFT JOIN public.teams ht ON ht.id = m.home_team_id
LEFT JOIN public.teams at ON at.id = m.away_team_id
LEFT JOIN public.leagues l ON l.id = m.league_id
WHERE m.home_team_id IN (1, 11910, 13102, 26871)
   OR m.away_team_id IN (1, 11910, 13102, 26871)
ORDER BY m.kickoff DESC NULLS LAST
LIMIT 200;

-- ============================================================
-- 8) KONTROLA KOLIZE PROVIDERŮ PŘI BUDOUCÍM MERGI NA 11910
-- ============================================================

SELECT
    'ARSENAL_PROVIDER_CONFLICT_TO_11910' AS section,
    old_pm.team_id AS old_team_id,
    old_pm.provider,
    old_pm.provider_team_id AS old_provider_team_id,
    new_pm.team_id AS target_team_id,
    new_pm.provider_team_id AS target_provider_team_id
FROM public.team_provider_map old_pm
JOIN public.team_provider_map new_pm
  ON new_pm.team_id = 11910
 AND new_pm.provider = old_pm.provider
WHERE old_pm.team_id IN (1, 13102, 26871)
ORDER BY old_pm.team_id, old_pm.provider;