-- =====================================================
-- 239_reset_vb_fixtures_planner_job_4137.sql
-- Účel:
--   Vrátit planner job 4137 zpět do pending,
--   aby šel znovu zpracovat přes panel V9 po opravě provideru.
-- =====================================================

UPDATE ops.ingest_planner
SET
    status = 'pending',
    next_run = NOW(),
    updated_at = NOW()
WHERE id = 4137;

-- =====================================================
-- KONTROLA
-- =====================================================

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
WHERE id = 4137;