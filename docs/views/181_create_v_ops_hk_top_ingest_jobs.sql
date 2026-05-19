-- =========================================================
-- 181_create_v_ops_hk_top_ingest_jobs.sql
-- MATCHMATRIX - HK TOP ingest jobs
-- =========================================================

CREATE OR REPLACE VIEW ops.v_ops_hk_top_ingest_jobs AS
SELECT
    t.provider,
    t.sport_code,
    p.entity,
    t.canonical_league_id,
    t.provider_league_id,
    t.season,
    t.run_group,
    p.priority,
    p.scope_type,
    p.requires_league,
    p.requires_season,
    p.source_endpoint,
    p.target_table,
    p.worker_script,
    p.notes
FROM ops.ingest_targets t
JOIN ops.ingest_entity_plan p
  ON p.provider = t.provider
 AND p.sport_code = t.sport_code
 AND p.enabled = true
WHERE t.sport_code = 'HK'
  AND t.run_group = 'HK_TOP'
  AND t.enabled = true
ORDER BY
    t.provider,
    p.priority,
    t.canonical_league_id,
    t.season;

-- kontrola
SELECT
    provider,
    sport_code,
    entity,
    run_group,
    COUNT(*) AS job_count
FROM ops.v_ops_hk_top_ingest_jobs
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