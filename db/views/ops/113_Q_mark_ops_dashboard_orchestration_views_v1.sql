/*
===============================================================================
MATCHMATRIX SQL 113_Q
OPS DASHBOARD + ORCHESTRATION GOVERNANCE AUDIT V1
===============================================================================
*/

-- =====================================================
-- ACTIVE MASTER
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status='ACTIVE_MASTER',
    is_master=true,
    migration_action='KEEP',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name IN (

    -- OPS DASHBOARD
    'v_ops_dashboard_summary',
    'v_ops_dashboard_by_provider',
    'v_ops_dashboard_by_sport',

    -- PANEL CORE
    'v_panel_run_control',

    -- HK
    'v_ops_hk_job_catalog',
    'v_ops_hk_top_runnable_jobs',
    'v_ops_hk_core_runnable_jobs',
    'v_ops_hk_full_runnable_jobs',

    -- BK
    'v_ops_bk_top_runnable_jobs',

    -- ORCHESTRATION
    'v_orchestration_priority_queue_v4'
);

-- =====================================================
-- ACTIVE
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status='ACTIVE',
    migration_action='KEEP',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name IN (

    'v_ops_block_reason_translations_cs_v1',

    'v_ops_hk_top_ingest_jobs',
    'v_ops_hk_top_ingest_jobs_test_mode',
    'v_ops_hk_top_test_execution_order',
    'v_ops_hk_top_full_execution_order',

    'v_ops_hk_core_full_job_catalog',
    'v_ops_hk_full_job_catalog',

    'v_ops_bk_top_full_job_catalog',

    'v_ops_panel_action_queue',
    'v_ops_panel_top_queue',

    'v_panel_active_runs_v1',
    'v_panel_ai_recommendations_v1',
    'v_panel_ai_recommendations_summary_v1',
    'v_panel_cooldowns_v1',
    'v_panel_orchestration_summary_v1',
    'v_panel_run_next_button_source_v1'
);

-- =====================================================
-- LEGACY KEEP
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status='LEGACY_KEEP',
    master_replacement='ops.v_orchestration_priority_queue_v4',
    migration_action='KEEP',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name IN (
    'v_orchestration_priority_queue_v1',
    'v_orchestration_priority_queue_v2',
    'v_orchestration_priority_queue_v3'
);