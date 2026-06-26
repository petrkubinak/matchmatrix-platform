/*
===============================================================================
MATCHMATRIX SQL 113_N
AUTONOMOUS + DEPENDENCY + COVERAGE GOVERNANCE AUDIT V1

CO TO JE:
- Označení Autonomous OPS engine
- Dependency orchestration engine
- Coverage reporting
- Repair queues
- Development task queue

K ČEMU TO JE:
- Oddělit produkční orchestration view od panelových a pomocných view.

KDE TO UVIDÍME:
- Autonomous OPS
- AI OPS
- OPS Panel
- Coverage Dashboard

JAK SE TO VYUŽIJE:
- Autonomous execution
- Dependency-aware execution
- Coverage roadmap
- Repair workflow
===============================================================================
*/

-- =====================================================
-- ACTIVE MASTER
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'AUTONOMOUS',
    owner_layer = 'Autonomous Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_autonomous_candidate_ranking_v1',
    'v_autonomous_execution_queue_v1',
    'v_autonomous_execution_summary_v1',
    'v_autonomous_next_ranked_candidate_v1',
    'v_autonomous_result_collector_v1',
    'v_autonomous_result_collector_summary_v1'
);

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'DEPENDENCY',
    owner_layer = 'Orchestration Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_dependency_resolver_v1',
    'v_dependency_aware_execution_queue_v1'
);

-- =====================================================
-- ACTIVE
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE',
    domain_area = 'REPAIR',
    owner_layer = 'AI OPS Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_block_reason_catalog_v1',
    'v_blocked_items_repair_queue_v1',
    'v_blocked_items_repair_summary_v1'
);

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE',
    domain_area = 'COVERAGE',
    owner_layer = 'Coverage Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_coverage_priority_dashboard_v1',
    'v_coverage_progress_by_sport_v1',
    'v_coverage_progress_dashboard_v1',
    'v_dashboard_summary'
);

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE',
    domain_area = 'DEVELOPMENT',
    owner_layer = 'Development Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_development_task_queue_v1',
    'v_development_task_queue_summary_v1'
);

-- =====================================================
-- ACTIVE PANEL
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_PANEL',
    domain_area = 'PANEL',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_blocked_items_repair_queue_cs_v1',
    'v_coverage_priority_panel_v1',
    'v_development_task_queue_panel_summary_v1'
);