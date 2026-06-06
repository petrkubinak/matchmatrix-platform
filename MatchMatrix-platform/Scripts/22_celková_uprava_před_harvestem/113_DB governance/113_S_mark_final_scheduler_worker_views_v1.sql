/*
===============================================================================
MATCHMATRIX SQL 113_S
FINAL SCHEDULER + WORKER GOVERNANCE AUDIT V1
===============================================================================
*/

-- =====================================================
-- ACTIVE MASTER
-- =====================================================

UPDATE ops.database_object_governance
SET governance_status='ACTIVE_MASTER',
    is_master=true,
    migration_action='KEEP',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name IN (

    -- SAFE EXECUTION
    'v_safe_execution_queue_v2',
    'v_safe_run_next_queue_v1',
    'v_safe_run_next_summary_v1',

    -- SCHEDULER
    'v_scheduler_autopilot_v1',
    'v_scheduler_candidates_v1',
    'v_scheduler_execution_confidence_v1',
    'v_scheduler_health_score_v1',
    'v_scheduler_queue_summary_v1',
    'v_scheduler_ready_governance_v1',
    'v_scheduler_recent_health_score_v1',
    'v_scheduler_runtime_dashboard_v1',
    'v_scheduler_runtime_metrics_v1',

    -- TOP INGEST
    'v_top_ingest_targets',
    'v_top_ingest_jobs',
    'v_top_ingest_jobs_ordered',
    'v_top_ingest_jobs_runnable',

    -- WORKERS
    'v_worker_resolver_v1',
    'v_worker_launcher_candidates_v1',
    'v_worker_launcher_next_v1',
    'v_worker_launcher_summary_v1'
);

-- =====================================================
-- ACTIVE
-- =====================================================

UPDATE ops.database_object_governance
SET governance_status='ACTIVE',
    migration_action='KEEP',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name IN (

    'v_smart_core_quota_queue_v1',
    'v_sport_completion_summary',
    'v_sport_daily_budget_monitor_v1',
    'v_top_development_tasks_v1',

    'v_worker_capability_registry_v1',
    'v_worker_health_inspector_v1',
    'v_worker_locks_active'
);

-- =====================================================
-- ACTIVE PANEL
-- =====================================================

UPDATE ops.database_object_governance
SET governance_status='ACTIVE_PANEL',
    migration_action='KEEP',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name IN (

    'v_top_development_tasks_panel_v1',
    'v_worker_execution_rules_panel_v1',
    'v_worker_registry_panel_v1'
);

-- =====================================================
-- LEGACY KEEP
-- =====================================================

UPDATE ops.database_object_governance
SET governance_status='LEGACY_KEEP',
    master_replacement='ops.v_safe_execution_queue_v2',
    migration_action='KEEP',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name='v_safe_execution_queue_v1';

UPDATE ops.database_object_governance
SET governance_status='LEGACY_KEEP',
    master_replacement='ops.v_top_ingest_jobs_runnable',
    migration_action='KEEP',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name IN (
    'v_top_ingest_jobs_test_mode',
    'v_top_ingest_jobs_full_mode'
);

-- =====================================================
-- ACTIVE REVIEW
-- =====================================================

UPDATE ops.database_object_governance
SET governance_status='ACTIVE_REVIEW',
    migration_action='REVIEW',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name='v_panel_run_next_button_state_v1';