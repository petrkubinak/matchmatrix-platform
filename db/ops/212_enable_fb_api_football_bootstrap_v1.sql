-- 212_enable_fb_api_football_bootstrap_v1.sql
-- Bezpečné povolení jen bootstrap targetů pro FB + api_football
-- Ostatní providery a sporty zatím necháme být.

BEGIN;

UPDATE ops.ingest_targets
SET
    enabled = TRUE,
    updated_at = NOW(),
    notes = COALESCE(notes, '') || ' | ENABLED_FB_API_FOOTBALL_BOOTSTRAP_V1'
WHERE sport_code = 'FB'
  AND provider = 'api_football'
  AND run_group = 'FB_BOOTSTRAP_V1'
  AND enabled = FALSE;

COMMIT;

-- kontrola
SELECT
    sport_code,
    provider,
    run_group,
    enabled,
    COUNT(*) AS targets
FROM ops.ingest_targets
WHERE sport_code = 'FB'
  AND provider = 'api_football'
GROUP BY sport_code, provider, run_group, enabled
ORDER BY run_group, enabled;