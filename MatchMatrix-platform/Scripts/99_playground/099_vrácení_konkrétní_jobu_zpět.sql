--vrácení konkrétní jobu zpět
UPDATE ops.ingest_planner
SET
    status = 'pending',
    updated_at = NOW(),
    next_run = NOW()
WHERE id = 475;

--kontrola
SELECT id, provider_league_id, season, run_group, status, attempts, next_run
FROM ops.ingest_planner
WHERE id = 475;

