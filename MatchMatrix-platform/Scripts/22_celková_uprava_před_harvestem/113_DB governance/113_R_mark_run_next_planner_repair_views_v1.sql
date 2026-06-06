/*
===============================================================================
MATCHMATRIX SQL 113_R
RUN NEXT + PLANNER + REPAIR + RANKED LAUNCHER GOVERNANCE AUDIT V1
===============================================================================
*/

-- ACTIVE MASTER
UPDATE ops.database_object_governance
SET
    governance_status='ACTIVE_MASTER',
    is_master=true,
    migration_action='KEEP',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name IN (
    'v_planner_pending_guard_v2',
    'v_planner_queue_summary_v1',
    'v_run_next_queue_v1',
    'v_run_next_audit_v1',
    'v_run_ready_queue',
    'v_ranked_launcher_dispatch_v1',
    'v_ranked_launcher_dispatch_next_v1',
    'v_ranked_launcher_dispatch_summary_v1'
);

-- ACTIVE
UPDATE ops.database_object_governance
SET
    governance_status='ACTIVE',
    is_master=false,
    migration_action='KEEP',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name IN (
    'v_ops_hk_top_full_runnable_jobs',
    'v_panel_run_next_button_state_v1',
    'v_panel_runtime_summary_v1',
    'v_parser_flow_audit_v1',
    'v_planner_cooldown_candidates_v2',
    'v_planner_target_quality_guard_v1',
    'v_player_enrichment_queue',
    'v_recent_failures_v1',
    'v_repair_learning_capture_summary_v1',
    'v_repair_learning_pending_capture_v1',
    'v_repair_learning_recommendations_v1',
    'v_repair_learning_stats_v1',
    'v_repair_reset_audit_recent_v1',
    'v_repair_reset_candidate_next_v1',
    'v_repair_reset_candidates_v1',
    'v_repair_reset_summary_v1',
    'v_run_next_execution_candidate_v1',
    'v_run_next_execution_queue_v1',
    'v_run_next_execution_summary_v1'
);

-- ACTIVE PANEL
UPDATE ops.database_object_governance
SET
    governance_status='ACTIVE_PANEL',
    is_master=false,
    migration_action='KEEP',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name IN (
    'v_ranked_launcher_dispatch_panel_v1'
);

-- LEGACY KEEP
UPDATE ops.database_object_governance
SET
    governance_status='LEGACY_KEEP',
    is_master=false,
    migration_action='KEEP',
    reviewed_at=NOW(),
    updated_at=NOW()
WHERE object_name IN (
    'v_planner_cooldown_candidates_v1',
    'v_planner_pending_guard_v1'
);

UPDATE ops.database_object_governance
SET master_replacement='ops.v_planner_cooldown_candidates_v2'
WHERE object_name='v_planner_cooldown_candidates_v1';

UPDATE ops.database_object_governance
SET master_replacement='ops.v_planner_pending_guard_v2'
WHERE object_name='v_planner_pending_guard_v1';