-- 906_check_bk_team_errors.sql

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
    status,
    attempts DESC,
    updated_at DESC;