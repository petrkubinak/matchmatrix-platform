/*
===============================================================================
MATCHMATRIX SQL 113_O
DISPATCH + EXECUTION + FB ORCHESTRATION GOVERNANCE AUDIT V1

CO TO JE:
- Označení Dispatch Engine
- Execution Risk Engine
- Football orchestration layer
- Fix Task AI OPS layer

K ČEMU TO JE:
- Oddělit produkční orchestration od testovacích FB view.

KDE TO UVIDÍME:
- Autonomous OPS
- Dispatch Engine
- Football Orchestrator
- AI Repair Center

JAK SE TO VYUŽIJE:
- Scheduler
- Run Next
- Dispatch
- AI Repair
===============================================================================
*/

-- =====================================================
-- ACTIVE MASTER
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'DISPATCH',
    owner_layer = 'Dispatch Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_dispatch_readiness_v1',
    'v_dispatch_ready_commands_v1',
    'v_dispatch_summary_v1'
);

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'EXECUTION',
    owner_layer = 'Execution Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_execution_priority_queue_v1',
    'v_execution_risk_full'
);

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'FOOTBALL',
    owner_layer = 'Football Orchestration',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_fb_job_catalog',
    'v_fb_test_mode_orchestrator',
    'v_fb_test_execution_order'
);

-- =====================================================
-- ACTIVE
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE',
    domain_area = 'EXECUTION',
    owner_layer = 'Execution Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_execution_lock_guard_v1',
    'v_execution_risk'
);

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE',
    domain_area = 'FOOTBALL',
    owner_layer = 'Football Orchestration',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_fb_provider_reality',
    'v_fb_test_phase1',
    'v_fix_task_ai_ops_v1'
);

-- =====================================================
-- ACTIVE REVIEW
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_REVIEW',
    domain_area = 'FOOTBALL',
    owner_layer = 'Football Legacy Planning',
    migration_action = 'REVIEW',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_fb_api_expansion_ingest_jobs',
    'v_fb_api_expansion_ingest_jobs_test_mode',
    'v_fb_eu_ingest_jobs',
    'v_fb_eu_ingest_jobs_test_mode',
    'v_fb_fd_core_ingest_jobs',
    'v_fb_fd_core_ingest_jobs_test_mode',
    'v_fb_test_mode_all_layers'
);