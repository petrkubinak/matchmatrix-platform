-- 032_promote_hk_fixtures_target_league_59.sql

UPDATE ops.ingest_planner
SET
    status = 'pending',
    attempts = 0,
    priority = 1010,
    updated_at = now()
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'fixtures'
  AND run_group = 'HK_TOP'
  AND provider_league_id = '59';

SELECT
    id,
    provider_league_id,
    season,
    status,
    attempts,
    priority,
    run_group,
    updated_at
FROM ops.ingest_planner
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'fixtures'
  AND run_group = 'HK_TOP'
ORDER BY priority, id
LIMIT 15;