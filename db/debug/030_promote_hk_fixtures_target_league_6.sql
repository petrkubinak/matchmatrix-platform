-- 030_promote_hk_fixtures_target_league_6.sql
-- Cíl:
-- posunout funkční HK fixtures target (league 6) na první místo,
-- aby ho scheduler vzal jako další job.

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
  AND provider_league_id = '6';

-- kontrola
SELECT
    id,
    provider,
    sport_code,
    entity,
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