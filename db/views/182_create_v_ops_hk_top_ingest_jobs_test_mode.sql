-- =========================================================
-- 182_create_v_ops_hk_top_ingest_jobs_test_mode.sql
-- MATCHMATRIX - HK TOP ingest jobs - TEST MODE
-- =========================================================

CREATE OR REPLACE VIEW ops.v_ops_hk_top_ingest_jobs_test_mode AS
SELECT *
FROM ops.v_ops_hk_top_ingest_jobs
WHERE entity IN ('leagues', 'teams', 'fixtures')
ORDER BY
    provider,
    priority,
    canonical_league_id,
    season;

-- kontrola
SELECT
    provider,
    sport_code,
    entity,
    run_group,
    COUNT(*) AS job_count
FROM ops.v_ops_hk_top_ingest_jobs_test_mode
GROUP BY
    provider,
    sport_code,
    entity,
    run_group
ORDER BY
    provider,
    sport_code,
    entity,
    run_group;