-- 217_cleanup_fb_odds_errors_free_mode.sql
-- Free režim: uklidit staré odds error joby po vypnutí odds

BEGIN;

UPDATE ops.ingest_planner
SET
    status = 'skipped',
    updated_at = NOW()
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'odds'
  AND status = 'error';

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    status,
    COUNT(*) AS jobs
FROM ops.ingest_planner
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'odds'
GROUP BY provider, sport_code, entity, status
ORDER BY status;