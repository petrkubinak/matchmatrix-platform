-- ============================================================
-- MATCHMATRIX - VIEW PROVIDER ENTITY STATUS (FIX 2)
-- ============================================================

CREATE OR REPLACE VIEW ops.v_provider_entity_status AS
WITH planner_agg AS (
    SELECT
        provider,
        sport_code,
        entity,
        COUNT(*) FILTER (WHERE status = 'pending') AS pending_cnt,
        COUNT(*) FILTER (WHERE status = 'running') AS running_cnt,
        COUNT(*) FILTER (WHERE status = 'done')    AS done_cnt,
        COUNT(*) FILTER (WHERE status = 'error')   AS error_cnt,
        COUNT(*) FILTER (WHERE status = 'skipped') AS skipped_cnt,
        MAX(last_attempt) AS last_attempt,
        MAX(next_run)     AS next_run
    FROM ops.ingest_planner
    GROUP BY provider, sport_code, entity
),
targets_agg AS (
    SELECT
        provider,
        sport_code,
        COUNT(*) AS total_targets,
        COUNT(*) FILTER (WHERE enabled = true) AS enabled_targets
    FROM ops.ingest_targets
    GROUP BY provider, sport_code
)
SELECT
    c.provider,
    c.sport_code,
    c.entity,

    -- coverage
    c.coverage_status,
    c.quality_rating,
    c.availability_scope,
    c.free_plan_supported,
    c.paid_plan_supported,
    c.expected_depth,
    c.is_primary_source,
    c.is_fallback_source,
    c.is_merge_source,
    c.is_enabled,

    -- priority
    c.provider_priority,
    c.fetch_priority,
    c.merge_priority,

    -- targets
    t.total_targets,
    t.enabled_targets,

    -- runtime
    COALESCE(p.pending_cnt, 0) AS pending_cnt,
    COALESCE(p.running_cnt, 0) AS running_cnt,
    COALESCE(p.done_cnt, 0)    AS done_cnt,
    COALESCE(p.error_cnt, 0)   AS error_cnt,
    COALESCE(p.skipped_cnt, 0) AS skipped_cnt,

    CASE
        WHEN COALESCE(p.running_cnt, 0) > 0 THEN 'running'
        WHEN COALESCE(p.pending_cnt, 0) > 0 THEN 'pending'
        WHEN COALESCE(p.error_cnt, 0) > 0 THEN 'error'
        WHEN COALESCE(p.done_cnt, 0) > 0 THEN 'done'
        ELSE 'idle'
    END AS runtime_status,

    CASE
        WHEN c.coverage_status IN ('tech_ready', 'runtime_tested', 'production_ready')
         AND c.is_enabled = true
        THEN true
        ELSE false
    END AS is_ready,

    p.last_attempt,
    p.next_run,

    c.notes,
    c.limitations,
    c.next_action
FROM ops.provider_entity_coverage c
LEFT JOIN planner_agg p
    ON p.provider = c.provider
   AND p.sport_code = c.sport_code
   AND p.entity = c.entity
LEFT JOIN targets_agg t
    ON t.provider = c.provider
   AND t.sport_code = c.sport_code;