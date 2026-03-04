-- mm_api_football_backfill_status.sql
-- Report: staging vs public coverage pro API-Football (fixtures -> public.matches)
-- Použití:
--   docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -f Scripts/99_reports/mm_api_football_backfill_status.sql
-- nebo v PowerShellu stream:
--   Get-Content "C:\MATCHMATRIX-PLATFORM\MatchMatrix-platform\Scripts\99_reports\mm_api_football_backfill_status.sql" -Raw |
--   docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -P pager=off

\echo
\echo ==== MATCHMATRIX REPORT: API-FOOTBALL BACKFILL STATUS ====
\echo Timestamp:
SELECT NOW() AS generated_at;

\echo
\echo [A] Global staging vs public (api_football)
SELECT
  (SELECT COUNT(*) FROM staging.api_football_fixtures)                                  AS staging_rows,
  (SELECT COUNT(DISTINCT fixture_id) FROM staging.api_football_fixtures)                AS staging_distinct_fixtures,
  (SELECT COUNT(*) FROM public.matches WHERE ext_source='api_football')                 AS public_matches_api_football,
  (SELECT COUNT(DISTINCT ext_match_id) FROM public.matches WHERE ext_source='api_football') AS public_distinct_ext_match_id;

\echo
\echo [B] Coverage per run_id (distinct fixtures + missing in public)
WITH per_run AS (
  SELECT
    f.run_id,
    COUNT(DISTINCT f.fixture_id) AS staging_distinct,
    COUNT(DISTINCT f.fixture_id) FILTER (WHERE m.ext_match_id IS NULL) AS missing_in_public_now
  FROM staging.api_football_fixtures f
  LEFT JOIN public.matches m
    ON m.ext_source='api_football'
   AND m.ext_match_id = f.fixture_id::text
  GROUP BY f.run_id
)
SELECT
  run_id,
  staging_distinct,
  missing_in_public_now,
  (staging_distinct - missing_in_public_now) AS present_in_public,
  ROUND(100.0 * (staging_distinct - missing_in_public_now) / NULLIF(staging_distinct, 0), 2) AS pct_complete
FROM per_run
ORDER BY run_id;

\echo
\echo [C] Top runs with missing > 0 (prioritization)
WITH per_run AS (
  SELECT
    f.run_id,
    COUNT(DISTINCT f.fixture_id) AS staging_distinct,
    COUNT(DISTINCT f.fixture_id) FILTER (WHERE m.ext_match_id IS NULL) AS missing_in_public_now
  FROM staging.api_football_fixtures f
  LEFT JOIN public.matches m
    ON m.ext_source='api_football'
   AND m.ext_match_id = f.fixture_id::text
  GROUP BY f.run_id
)
SELECT *
FROM per_run
WHERE missing_in_public_now > 0
ORDER BY missing_in_public_now DESC
LIMIT 20;

\echo
\echo [D] Mapping gaps (league_provider_map) for all staging
SELECT
  COUNT(DISTINCT f.league_id) FILTER (WHERE lpm.league_id IS NULL) AS missing_league_map_distinct_leagues,
  COUNT(*) FILTER (WHERE lpm.league_id IS NULL)                    AS missing_league_map_rows
FROM staging.api_football_fixtures f
LEFT JOIN public.league_provider_map lpm
  ON lpm.provider='api_football'
 AND lpm.provider_league_id=f.league_id::text;

\echo
\echo [E] Mapping gaps (team_provider_map) for all staging
SELECT
  COUNT(DISTINCT f.fixture_id) FILTER (WHERE th.team_id IS NULL OR ta.team_id IS NULL) AS fixtures_missing_team_map,
  COUNT(*) FILTER (WHERE th.team_id IS NULL) AS rows_missing_home_team_map,
  COUNT(*) FILTER (WHERE ta.team_id IS NULL) AS rows_missing_away_team_map
FROM staging.api_football_fixtures f
LEFT JOIN public.team_provider_map th
  ON th.provider='api_football'
 AND th.provider_team_id=f.home_team_id::text
LEFT JOIN public.team_provider_map ta
  ON ta.provider='api_football'
 AND ta.provider_team_id=f.away_team_id::text;

\echo
\echo [F] Last job runs (ops.job_runs) - quick health check
SELECT
  id,
  job_code,
  status,
  started_at,
  finished_at,
  LEFT(COALESCE(message,''), 120) AS message_short
FROM ops.job_runs
ORDER BY id DESC
LIMIT 15;

\echo
\echo ==== END REPORT ====
\echo