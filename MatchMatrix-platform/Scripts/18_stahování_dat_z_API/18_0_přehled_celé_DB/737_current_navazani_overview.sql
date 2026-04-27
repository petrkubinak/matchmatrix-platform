
-- 737_current_navazani_overview.sql
-- =========================================================
-- Přehled aktuálního navázání projektu
-- Postavený na reálných sloupcích OPS tabulek
-- =========================================================

WITH planner_agg AS (
    SELECT
        provider,
        sport_code,
        entity,
        COUNT(*) AS planner_rows,
        COUNT(*) FILTER (WHERE status = 'pending') AS planner_pending,
        COUNT(*) FILTER (WHERE status = 'running') AS planner_running,
        COUNT(*) FILTER (WHERE status = 'done')    AS planner_done,
        COUNT(*) FILTER (WHERE status = 'error')   AS planner_error,
        COUNT(*) FILTER (WHERE status = 'skipped') AS planner_skipped,
        MAX(updated_at) AS planner_last_updated_at
    FROM ops.ingest_planner
    GROUP BY provider, sport_code, entity
),
targets_agg AS (
    SELECT
        provider,
        sport_code,
        COUNT(*) AS total_targets,
        COUNT(*) FILTER (WHERE enabled = true) AS enabled_targets,
        MAX(updated_at) AS last_target_update
    FROM ops.ingest_targets
    GROUP BY provider, sport_code
)
SELECT
    rea.provider,
    rea.sport_code,
    rea.entity,

    rea.current_state,
    rea.state_reason,

    rea.panel_runner_exists,
    rea.planner_target_exists,
    rea.batch_target_exists,

    rea.pull_confirmed,
    rea.raw_confirmed,
    rea.staging_confirmed,
    rea.provider_map_confirmed,
    rea.public_merge_confirmed,
    rea.downstream_confirmed,

    rea.last_run_group,
    rea.last_run_at,
    rea.last_check_at,
    rea.last_log_summary,
    rea.db_evidence_summary,
    rea.next_action,
    rea.audit_note,

    pec.coverage_status,
    pec.is_enabled,
    pec.provider_priority,
    pec.merge_priority,
    pec.fetch_priority,
    pec.quality_rating,
    pec.availability_scope,
    pec.free_plan_supported,
    pec.paid_plan_supported,
    pec.expected_depth,
    pec.is_primary_source,
    pec.is_fallback_source,
    pec.is_merge_source,
    pec.source_endpoint,
    pec.target_table,
    pec.worker_script,
    pec.notes AS coverage_notes,
    pec.limitations AS coverage_limitations,
    pec.next_action AS coverage_next_action,

    sca.layer_type,
    sca.current_status AS sport_completion_status,
    sca.production_readiness,
    sca.provider_primary,
    sca.provider_fallback,
    sca.db_layer_ready,
    sca.planner_ready,
    sca.queue_ready,
    sca.public_ready,
    sca.key_gap,
    sca.next_step,
    sca.evidence_note,
    sca.priority_rank,

    COALESCE(ta.total_targets, 0) AS total_targets,
    COALESCE(ta.enabled_targets, 0) AS enabled_targets,

    COALESCE(pa.planner_rows, 0) AS planner_rows,
    COALESCE(pa.planner_pending, 0) AS planner_pending,
    COALESCE(pa.planner_running, 0) AS planner_running,
    COALESCE(pa.planner_done, 0) AS planner_done,
    COALESCE(pa.planner_error, 0) AS planner_error,
    COALESCE(pa.planner_skipped, 0) AS planner_skipped,

    GREATEST(
        COALESCE(rea.updated_at, '-infinity'::timestamptz),
        COALESCE(pec.updated_at, '-infinity'::timestamptz),
        COALESCE(sca.updated_at, '-infinity'::timestamptz),
        COALESCE(pa.planner_last_updated_at, '-infinity'::timestamptz),
        COALESCE(ta.last_target_update, '-infinity'::timestamptz)
    ) AS last_activity_at,

    CASE
        WHEN rea.current_state IN ('NOT_TESTED', 'MISSING', 'PLANNED', 'DESIGN_ONLY', 'OPS_ONLY') THEN 'BUILD_NEXT'
        WHEN rea.current_state IN ('PARTIAL', 'RUNNABLE', 'IN_PROGRESS') THEN 'CONTINUE'
        WHEN rea.current_state IN ('CONFIRMED', 'DONE', 'READY') THEN 'VERIFY_OR_CLOSE'
        ELSE 'REVIEW'
    END AS recommended_action_bucket

FROM ops.runtime_entity_audit rea
LEFT JOIN ops.provider_entity_coverage pec
       ON pec.provider = rea.provider
      AND pec.sport_code = rea.sport_code
      AND pec.entity = rea.entity
LEFT JOIN ops.sport_completion_audit sca
       ON sca.sport_code = rea.sport_code
      AND sca.entity = rea.entity
LEFT JOIN planner_agg pa
       ON pa.provider = rea.provider
      AND pa.sport_code = rea.sport_code
      AND pa.entity = rea.entity
LEFT JOIN targets_agg ta
       ON ta.provider = rea.provider
      AND ta.sport_code = rea.sport_code

ORDER BY
    COALESCE(sca.priority_rank, 999999),
    rea.sport_code,
    rea.provider,
    rea.entity;