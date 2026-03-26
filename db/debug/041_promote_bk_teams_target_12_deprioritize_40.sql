-- 041_promote_bk_teams_target_12_deprioritize_40.sql
-- Cíl:
-- odsunout problematický BK teams target 40
-- a posunout ověřený target 12 / 2024 nahoru.

UPDATE ops.ingest_planner
SET
    priority = 5000,
    updated_at = now()
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'teams'
  AND run_group = 'BK_TOP'
  AND provider_league_id = '40';

UPDATE ops.ingest_planner
SET
    status = 'pending',
    attempts = 0,
    priority = 1000,
    updated_at = now()
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'teams'
  AND run_group = 'BK_TOP'
  AND provider_league_id = '12'
  AND season = '2024';

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