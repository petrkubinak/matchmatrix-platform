-- ============================================================
-- MATCHMATRIX - RUN READY QUEUE VIEW
-- FILE: 405_view_run_ready_queue.sql
-- Účel:
-- Fronta entit připravených ke spuštění pro panel a planner
-- ============================================================

CREATE OR REPLACE VIEW ops.v_run_ready_queue AS
SELECT
    s.provider,
    s.sport_code,
    s.entity,

    -- coverage / provider logika
    s.coverage_status,
    s.quality_rating,
    s.availability_scope,
    s.free_plan_supported,
    s.paid_plan_supported,
    s.expected_depth,
    s.is_primary_source,
    s.is_fallback_source,
    s.is_merge_source,
    s.is_enabled,

    -- priority
    s.provider_priority,
    s.fetch_priority,
    s.merge_priority,

    -- runtime
    s.runtime_status,
    s.pending_cnt,
    s.running_cnt,
    s.done_cnt,
    s.error_cnt,
    s.skipped_cnt,
    s.last_attempt,
    s.next_run,

    -- targets
    s.total_targets,
    s.enabled_targets,

    -- odvozené sloupce pro panel/planner
    CASE
        WHEN s.coverage_status = 'runtime_tested' AND s.pending_cnt > 0 THEN 'RUN_NOW'
        WHEN s.coverage_status = 'tech_ready' AND s.pending_cnt > 0 THEN 'RUN_VALIDATE'
        WHEN s.coverage_status IN ('runtime_tested', 'tech_ready')
             AND s.pending_cnt = 0
             AND COALESCE(s.running_cnt, 0) = 0
             AND COALESCE(s.done_cnt, 0) > 0
        THEN 'MONITOR'
        WHEN s.coverage_status = 'planned' THEN 'WAIT_PLAN'
        WHEN s.coverage_status = 'blocked' THEN 'BLOCKED'
        ELSE 'REVIEW'
    END AS queue_action,

    CASE
        WHEN s.coverage_status = 'runtime_tested' THEN 1
        WHEN s.coverage_status = 'tech_ready' THEN 2
        WHEN s.coverage_status = 'planned' THEN 3
        WHEN s.coverage_status = 'blocked' THEN 9
        ELSE 8
    END AS queue_group,

    CASE
        WHEN s.is_ready = true
         AND COALESCE(s.pending_cnt, 0) > 0
         AND COALESCE(s.running_cnt, 0) = 0
        THEN true
        ELSE false
    END AS can_run_now,

    CASE
        WHEN s.coverage_status IN ('runtime_tested', 'tech_ready')
         AND s.paid_plan_supported = true
        THEN true
        ELSE false
    END AS pro_harvest_candidate,

    CASE
        WHEN s.coverage_status = 'runtime_tested'
         AND s.is_primary_source = true
        THEN 'HIGH'
        WHEN s.coverage_status IN ('runtime_tested', 'tech_ready')
         AND s.is_primary_source = true
        THEN 'MEDIUM'
        WHEN s.coverage_status IN ('runtime_tested', 'tech_ready')
        THEN 'LOW'
        ELSE 'HOLD'
    END AS planner_priority_band,

    s.notes,
    s.limitations,
    s.next_action

FROM ops.v_provider_entity_status s
WHERE s.is_enabled = true
ORDER BY
    CASE
        WHEN s.coverage_status = 'runtime_tested' THEN 1
        WHEN s.coverage_status = 'tech_ready' THEN 2
        WHEN s.coverage_status = 'planned' THEN 3
        WHEN s.coverage_status = 'blocked' THEN 9
        ELSE 8
    END,
    s.fetch_priority,
    s.provider_priority,
    s.sport_code,
    s.entity,
    s.provider;