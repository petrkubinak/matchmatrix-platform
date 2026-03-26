-- 037_promote_bk_fixtures_target_117.sql
-- Cíl:
-- posunout funkční BK fixtures target 117 / 2023-2024 na první místo
-- a odsunout prázdný target 40_2024.

UPDATE ops.ingest_planner
SET
    priority = 5000,
    updated_at = now()
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'fixtures'
  AND run_group = 'BK_TOP'
  AND provider_league_id = '40';

UPDATE ops.ingest_planner
SET
    status = 'pending',
    attempts = 0,
    priority = 1010,
    updated_at = now()
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'fixtures'
  AND run_group = 'BK_TOP'
  AND provider_league_id = '117'
  AND season = '2023-2024';

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
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'fixtures'
  AND run_group = 'BK_TOP'
ORDER BY priority, id
LIMIT 15;