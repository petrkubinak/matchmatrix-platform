/*
================================================================================
MATCHMATRIX FB CORE REALITY CHECK V1.1
================================================================================

Co skript dělá:
- kontroluje skutečný stav football CORE vrstvy po doplnění public.teams.sport_id

Kontroluje:
- public.leagues
- public.teams
- public.matches
- provider maps
- api_football coverage
- football_data coverage
- missing mappings
- duplicate risks
- player_match_statistics coverage

Jak se využije:
- základ pro PEOPLE
- základ pro MEDIA
- základ pro ODDS
- základ pro AI layer
================================================================================
*/

-- 1. FOOTBALL LEAGUES
SELECT
    'FB_LEAGUES' AS section,
    ext_source,
    COUNT(*) AS leagues_count
FROM public.leagues
WHERE sport_id = 1
GROUP BY ext_source
ORDER BY leagues_count DESC;

-- 2. FOOTBALL TEAMS
SELECT
    'FB_TEAMS' AS section,
    ext_source,
    COUNT(*) AS teams_count
FROM public.teams
WHERE sport_id = 1
GROUP BY ext_source
ORDER BY teams_count DESC;

-- 3. FOOTBALL MATCHES
SELECT
    'FB_MATCHES' AS section,
    ext_source,
    COUNT(*) AS matches_count
FROM public.matches
WHERE sport_id = 1
GROUP BY ext_source
ORDER BY matches_count DESC;

-- 4. MATCH STATUS DISTRIBUTION
SELECT
    'FB_MATCH_STATUS' AS section,
    status,
    COUNT(*) AS total
FROM public.matches
WHERE sport_id = 1
GROUP BY status
ORDER BY total DESC;

-- 5. API_FOOTBALL MATCH COVERAGE
SELECT
    'API_FOOTBALL_MATCHES' AS section,
    COUNT(*) AS total_matches,
    COUNT(*) FILTER (WHERE status = 'FINISHED') AS finished_matches,
    COUNT(*) FILTER (WHERE status = 'SCHEDULED') AS scheduled_matches,
    MIN(kickoff) AS oldest_match,
    MAX(kickoff) AS newest_match
FROM public.matches
WHERE sport_id = 1
  AND ext_source = 'api_football';

-- 6. FOOTBALL_DATA MATCH COVERAGE
SELECT
    'FOOTBALL_DATA_MATCHES' AS section,
    COUNT(*) AS total_matches,
    COUNT(*) FILTER (WHERE status = 'FINISHED') AS finished_matches,
    COUNT(*) FILTER (WHERE status = 'SCHEDULED') AS scheduled_matches,
    MIN(kickoff) AS oldest_match,
    MAX(kickoff) AS newest_match
FROM public.matches
WHERE sport_id = 1
  AND ext_source IN ('football_data', 'football_data_uk');

-- 7. TEAM PROVIDER MAP COVERAGE FOR FB TEAMS
SELECT
    'FB_TEAM_PROVIDER_MAP' AS section,
    tpm.provider,
    COUNT(*) AS mapped_teams
FROM public.team_provider_map tpm
JOIN public.teams t
    ON t.id = tpm.team_id
WHERE t.sport_id = 1
GROUP BY tpm.provider
ORDER BY mapped_teams DESC;

-- 8. LEAGUE PROVIDER MAP COVERAGE FOR FB LEAGUES
SELECT
    'FB_LEAGUE_PROVIDER_MAP' AS section,
    lpm.provider,
    COUNT(*) AS mapped_leagues
FROM public.league_provider_map lpm
JOIN public.leagues l
    ON l.id = lpm.league_id
WHERE l.sport_id = 1
GROUP BY lpm.provider
ORDER BY mapped_leagues DESC;

-- 9. MATCHES WITHOUT TEAM MAPPING
SELECT
    'FB_MISSING_TEAM_MAPPING' AS section,
    COUNT(*) AS missing_count
FROM public.matches
WHERE sport_id = 1
  AND (
      home_team_id IS NULL
      OR away_team_id IS NULL
  );

-- 10. MATCHES WITHOUT LEAGUE
SELECT
    'FB_MISSING_LEAGUE_MAPPING' AS section,
    COUNT(*) AS missing_count
FROM public.matches
WHERE sport_id = 1
  AND league_id IS NULL;

-- 11. DUPLICATE MATCH CHECK
SELECT
    'FB_DUPLICATE_MATCHES' AS section,
    ext_source,
    ext_match_id,
    COUNT(*) AS duplicate_count
FROM public.matches
WHERE sport_id = 1
GROUP BY ext_source, ext_match_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 12. TOP FOOTBALL LEAGUES BY MATCH COUNT
SELECT
    'FB_TOP_LEAGUES_BY_MATCH_COUNT' AS section,
    l.name AS league_name,
    l.ext_source,
    COUNT(m.id) AS matches_count
FROM public.matches m
JOIN public.leagues l
    ON l.id = m.league_id
WHERE m.sport_id = 1
GROUP BY l.name, l.ext_source
ORDER BY matches_count DESC
LIMIT 30;

-- 13. PLAYER MATCH STATISTICS COVERAGE
SELECT
    'FB_PLAYER_MATCH_STATS' AS section,
    COUNT(*) AS stats_rows,
    COUNT(DISTINCT p.match_id) AS covered_matches,
    COUNT(DISTINCT p.player_id) AS covered_players
FROM public.player_match_statistics p
JOIN public.matches m
    ON m.id = p.match_id
WHERE m.sport_id = 1;

-- 14. FINISHED FB MATCHES WITHOUT PLAYER MATCH STATS
SELECT
    'FB_FINISHED_MATCHES_WITHOUT_PLAYER_STATS' AS section,
    COUNT(*) AS missing_matches
FROM public.matches m
WHERE m.sport_id = 1
  AND m.status = 'FINISHED'
  AND NOT EXISTS (
      SELECT 1
      FROM public.player_match_statistics p
      WHERE p.match_id = m.id
  );

-- 15. FB TEAMS WITHOUT SPORT_ID STILL EXPECTED?
SELECT
    'FB_PROVIDER_TEAMS_WITHOUT_SPORT_ID' AS section,
    ext_source,
    COUNT(*) AS teams_count
FROM public.teams
WHERE sport_id IS NULL
  AND ext_source IN (
      'api_football',
      'football_data',
      'football_data_uk',
      'api_football_missing_canonical'
  )
GROUP BY ext_source
ORDER BY teams_count DESC;

-- 16. FINAL FB CORE SUMMARY
SELECT
    'FB_CORE_SUMMARY' AS section,
    (
        SELECT COUNT(*)
        FROM public.leagues
        WHERE sport_id = 1
    ) AS leagues,
    (
        SELECT COUNT(*)
        FROM public.teams
        WHERE sport_id = 1
    ) AS teams,
    (
        SELECT COUNT(*)
        FROM public.matches
        WHERE sport_id = 1
    ) AS matches,
    (
        SELECT COUNT(*)
        FROM public.matches
        WHERE sport_id = 1
          AND status = 'FINISHED'
    ) AS finished_matches,
    (
        SELECT COUNT(*)
        FROM public.player_match_statistics p
        JOIN public.matches m
            ON m.id = p.match_id
        WHERE m.sport_id = 1
    ) AS player_match_stats_rows;