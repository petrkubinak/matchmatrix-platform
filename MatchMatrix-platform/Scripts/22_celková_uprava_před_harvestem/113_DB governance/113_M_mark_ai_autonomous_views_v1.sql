/*
===============================================================================
MATCHMATRIX SQL 113_M
AI AUTONOMOUS GOVERNANCE AUDIT V1

CO TO JE:
- Označení AI Autonomous a Automation Queue subsystému.

K ČEMU TO JE:
- Oddělení produkčních AI queue view od historických verzí.

KDE TO UVIDÍME:
- AI OPS Dashboard
- Autonomous OPS
- Scheduler

JAK SE TO VYUŽIJE:
- Worker selection
- Candidate ranking
- Automation execution
===============================================================================
*/

-- =====================================================
-- ACTIVE MASTER
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'AI_OPS',
    owner_layer = 'Autonomous Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_ai_worker_selector_v1',
    'v_automation_execution_queue_v2',
    'v_autonomous_candidate_ranking_summary_v1'
);

-- =====================================================
-- ACTIVE
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE',
    domain_area = 'AI_OPS',
    owner_layer = 'Autonomous Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_ai_ops_summary_v1',
    'v_ai_self_improvement_engine_v1',
    'v_api_budget_today',
    'v_auto_healing_cleanup_engine_v1'
);

-- =====================================================
-- ACTIVE PANEL
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_PANEL',
    domain_area = 'PANEL',
    owner_layer = 'Autonomous Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_ai_self_improvement_panel_v1',
    'v_autonomous_candidate_ranking_panel_v1'
);

-- =====================================================
-- LEGACY
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'LEGACY_KEEP',
    is_master = false,
    master_replacement = 'ops.v_automation_execution_queue_v2',
    cleanup_note = 'Používá starý routing master. Nahrazeno verzí V2.',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'v_automation_execution_queue';