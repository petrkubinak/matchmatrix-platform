ROLLBACK;
BEGIN;

-- =========================================================
-- 166_rename_fb_eu_to_fb_fd_core.sql
-- Převod run_group FB_EU → FB_FD_CORE
-- =========================================================

UPDATE ops.ingest_targets
SET run_group = 'FB_FD_CORE'
WHERE run_group = 'FB_EU'
  AND sport_code = 'FB';

COMMIT;

-- kontrola
SELECT
    run_group,
    provider,
    COUNT(*) AS cnt
FROM ops.ingest_targets
WHERE sport_code = 'FB'
GROUP BY run_group, provider
ORDER BY run_group, provider;