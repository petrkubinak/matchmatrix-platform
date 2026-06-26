ROLLBACK;
BEGIN;

-- =========================================================
-- 160_enable_fb_eu_targets.sql
-- Zapnutí FB_EU targetů pro football_data
-- =========================================================

UPDATE ops.ingest_targets
SET enabled = TRUE
WHERE sport_code = 'FB'
  AND run_group = 'FB_EU'
  AND provider = 'football_data';

COMMIT;

-- kontrola
SELECT
    provider,
    sport_code,
    run_group,
    enabled,
    COUNT(*) AS cnt
FROM ops.ingest_targets
WHERE sport_code = 'FB'
  AND run_group = 'FB_EU'
GROUP BY provider, sport_code, run_group, enabled
ORDER BY provider, enabled;