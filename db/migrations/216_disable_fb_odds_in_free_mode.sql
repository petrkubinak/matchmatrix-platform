-- 212_disable_fb_odds_in_free_mode.sql
-- Free režim: odds dočasně vypnout, ale strukturu ponechat připravenou

BEGIN;

UPDATE ops.ingest_targets
SET
    enabled = FALSE,
    updated_at = NOW(),
    notes = COALESCE(notes, '') || ' | DISABLED_IN_FREE_MODE_ODDS'
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND COALESCE(run_group, '') <> ''
  AND EXISTS (
      SELECT 1
      FROM ops.ingest_entity_plan p
      WHERE p.provider = ops.ingest_targets.provider
        AND p.sport_code = ops.ingest_targets.sport_code
        AND p.entity = 'odds'
  );

UPDATE ops.ingest_planner
SET
    status = 'skipped',
    updated_at = NOW()
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'odds'
  AND status IN ('pending', 'ready');

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