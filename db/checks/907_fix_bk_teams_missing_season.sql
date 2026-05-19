-- 907_fix_bk_teams_missing_season.sql
-- BK teams joby potřebují sezónu. Doplníme výchozí sezonu 2024.

UPDATE ops.ingest_planner
SET
    season = '2024',
    status = 'pending',
    attempts = 0,
    last_attempt = NULL,
    next_run = NULL,
    updated_at = now()
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'teams'
  AND run_group = 'BK_TOP'
  AND (
        season IS NULL
        OR btrim(season) = ''
      );

SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    status,
    attempts,
    last_attempt,
    next_run,
    updated_at
FROM ops.ingest_planner
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'teams'
ORDER BY
    provider_league_id::text,
    season;