-- 042_deduplicate_bk_teams_target_12.sql
-- Cíl:
-- nechat jen jeden aktivní BK teams target pro league 12 / season 2024.

UPDATE ops.ingest_planner
SET
    status = 'done',
    attempts = 1,
    priority = 5000,
    updated_at = now()
WHERE id = 4140;

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
  AND entity = 'teams'
  AND run_group = 'BK_TOP'
ORDER BY priority, id
LIMIT 20;