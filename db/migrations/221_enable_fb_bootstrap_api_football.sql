-- 221_enable_fb_bootstrap_api_football.sql
-- Zapnutí FB bootstrap targetů pouze pro api_football

BEGIN;

UPDATE ops.ingest_targets
SET
    enabled = TRUE,
    updated_at = NOW(),
    notes = COALESCE(notes, '') || ' | ENABLED_BOOTSTRAP_V1_FIX'
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND run_group = 'FB_BOOTSTRAP_V1'
  AND enabled = FALSE;

COMMIT;

SELECT
    provider,
    sport_code,
    run_group,
    enabled,
    COUNT(*) AS targets
FROM ops.ingest_targets
WHERE sport_code = 'FB'
  AND run_group = 'FB_BOOTSTRAP_V1'
GROUP BY provider, sport_code, run_group, enabled
ORDER BY provider, enabled;