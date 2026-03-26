-- 033_deprioritize_empty_hk_fixtures_targets.sql
-- Cíl:
-- nechat league 59 nahoře a odsunout známé prázdné HK fixtures targety.

UPDATE ops.ingest_planner
SET
    priority = 5000,
    updated_at = now()
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'fixtures'
  AND run_group = 'HK_TOP'
  AND provider_league_id IN ('6', '101', '110', '146', '224', '236');

UPDATE ops.ingest_planner
SET
    priority = 1010,
    status = 'pending',
    attempts = 0,
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
LIMIT 20;