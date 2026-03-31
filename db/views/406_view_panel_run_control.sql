-- ============================================================
-- MATCHMATRIX - PANEL RUN CONTROL VIEW
-- FILE: 406_view_panel_run_control.sql
-- Účel:
-- řízení toho, co panel smí nabídnout ke spuštění
-- ============================================================

CREATE OR REPLACE VIEW ops.v_panel_run_control AS
SELECT
    q.provider,
    q.sport_code,
    q.entity,

    q.coverage_status,
    q.runtime_status,
    q.queue_action,
    q.planner_priority_band,

    q.provider_priority,
    q.fetch_priority,
    q.merge_priority,

    q.pending_cnt,
    q.running_cnt,
    q.done_cnt,
    q.error_cnt,
    q.skipped_cnt,

    q.total_targets,
    q.enabled_targets,

    q.free_plan_supported,
    q.paid_plan_supported,
    q.availability_scope,
    q.quality_rating,
    q.expected_depth,

    q.is_primary_source,
    q.is_fallback_source,
    q.is_merge_source,
    q.is_enabled,
    q.pro_harvest_candidate,

    -- hlavní rozhodnutí pro panel
    CASE
        WHEN q.coverage_status = 'blocked' THEN false
        WHEN q.queue_action = 'BLOCKED' THEN false
        WHEN q.coverage_status = 'planned' THEN false
        WHEN q.entity IN ('coaches', 'players', 'odds')
             AND q.coverage_status NOT IN ('runtime_tested', 'production_ready')
        THEN false
        ELSE true
    END AS panel_can_run,

    -- doporučený režim spuštění
    CASE
        WHEN q.queue_action = 'RUN_NOW' THEN 'run_now'
        WHEN q.queue_action = 'RUN_VALIDATE' THEN 'validate'
        WHEN q.queue_action = 'MONITOR' THEN 'monitor'
        WHEN q.queue_action = 'WAIT_PLAN' THEN 'hold'
        WHEN q.queue_action = 'BLOCKED' THEN 'blocked'
        ELSE 'review'
    END AS panel_run_mode,

    -- vizuální status pro panel
    CASE
        WHEN q.coverage_status = 'blocked' OR q.queue_action = 'BLOCKED' THEN 'red'
        WHEN q.queue_action = 'RUN_NOW' THEN 'green'
        WHEN q.queue_action = 'RUN_VALIDATE' THEN 'yellow'
        WHEN q.queue_action = 'MONITOR' THEN 'blue'
        WHEN q.queue_action = 'WAIT_PLAN' THEN 'gray'
        ELSE 'orange'
    END AS panel_color,

    -- stručný text pro UI
    CASE
        WHEN q.coverage_status = 'blocked' THEN 'BLOCKED - nespouštět'
        WHEN q.queue_action = 'RUN_NOW' THEN 'RUN NOW - připraveno ke spuštění'
        WHEN q.queue_action = 'RUN_VALIDATE' THEN 'VALIDACE - spustit opatrně'
        WHEN q.queue_action = 'MONITOR' THEN 'MONITOR - zatím jen sledovat'
        WHEN q.queue_action = 'WAIT_PLAN' THEN 'WAIT PLAN - zatím ne'
        ELSE 'REVIEW - ruční kontrola'
    END AS panel_status_label,

    -- doporučené pořadí v panelu
    CASE
        WHEN q.queue_action = 'RUN_NOW' THEN 1
        WHEN q.queue_action = 'RUN_VALIDATE' THEN 2
        WHEN q.queue_action = 'MONITOR' THEN 3
        WHEN q.queue_action = 'WAIT_PLAN' THEN 8
        WHEN q.queue_action = 'BLOCKED' THEN 9
        ELSE 7
    END AS panel_sort_group,

    q.last_attempt,
    q.next_run,
    q.notes,
    q.limitations,
    q.next_action

FROM ops.v_run_ready_queue q
ORDER BY
    CASE
        WHEN q.queue_action = 'RUN_NOW' THEN 1
        WHEN q.queue_action = 'RUN_VALIDATE' THEN 2
        WHEN q.queue_action = 'MONITOR' THEN 3
        WHEN q.queue_action = 'WAIT_PLAN' THEN 8
        WHEN q.queue_action = 'BLOCKED' THEN 9
        ELSE 7
    END,
    q.fetch_priority,
    q.provider_priority,
    q.sport_code,
    q.entity,
    q.provider;