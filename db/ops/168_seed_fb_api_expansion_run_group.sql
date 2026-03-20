ROLLBACK;
BEGIN;

-- =========================================================
-- 168_seed_fb_api_expansion_run_group.sql
-- První malý subset api_football targetů přesuneme do FB_API_EXPANSION
-- mimo FOOTBALL_MAINTENANCE_TOP
-- =========================================================

UPDATE ops.ingest_targets
SET run_group = 'FB_API_EXPANSION'
WHERE sport_code = 'FB'
  AND provider = 'api_football'
  AND run_group = 'FOOTBALL_MAINTENANCE'
  AND id IN (
      SELECT id
      FROM ops.ingest_targets
      WHERE sport_code = 'FB'
        AND provider = 'api_football'
        AND run_group = 'FOOTBALL_MAINTENANCE'
      ORDER BY id
      LIMIT 20
  );

COMMIT;

-- kontrola
SELECT
    run_group,
    provider,
    COUNT(*) AS cnt
FROM ops.ingest_targets
WHERE sport_code = 'FB'
  AND provider = 'api_football'
GROUP BY run_group, provider
ORDER BY run_group, provider;