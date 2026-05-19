-- =========================================================
-- 183_create_v_ops_hk_top_test_execution_order.sql
-- MATCHMATRIX - HK TOP TEST execution order
-- =========================================================

CREATE OR REPLACE VIEW ops.v_ops_hk_top_test_execution_order AS
SELECT
    provider,
    sport_code,
    entity,
    run_group,
    canonical_league_id,
    provider_league_id,
    season,
    priority,
    CASE entity
        WHEN 'leagues'  THEN 1
        WHEN 'teams'    THEN 2
        WHEN 'fixtures' THEN 3
        WHEN 'odds'     THEN 4
        WHEN 'players'  THEN 5
        WHEN 'coaches'  THEN 6
        ELSE 99
    END AS entity_order
FROM ops.v_ops_hk_top_ingest_jobs_test_mode
ORDER BY
    provider,
    CASE entity
        WHEN 'leagues'  THEN 1
        WHEN 'teams'    THEN 2
        WHEN 'fixtures' THEN 3
        WHEN 'odds'     THEN 4
        WHEN 'players'  THEN 5
        WHEN 'coaches'  THEN 6
        ELSE 99
    END,
    canonical_league_id,
    season;

-- kontrola
SELECT
    provider,
    sport_code,
    entity,
    entity_order,
    COUNT(*) AS job_count
FROM ops.v_ops_hk_top_test_execution_order
GROUP BY
    provider,
    sport_code,
    entity,
    entity_order
ORDER BY
    entity_order,
    entity;