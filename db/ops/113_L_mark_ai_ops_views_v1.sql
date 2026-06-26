/*
===============================================================================
MATCHMATRIX SQL 113_L
AI OPS + ACTIVE RUNS GOVERNANCE AUDIT V1

CO TO JE:
- Označení AI OPS dashboardů, AI queue a Active Runs subsystému.

K ČEMU TO JE:
- Oddělení MASTER AI view od pomocných alertů a historie.

KDE TO UVIDÍME:
- OPS Panel
- AI OPS Dashboard
- Autonomous OPS

JAK SE TO VYUŽIJE:
- Scheduler
- Autonomous OPS
- Runtime monitoring
===============================================================================
*/

-- =====================================================
-- ACTIVE MASTER
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'RUNTIME',
    owner_layer = 'Runtime Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_active_runs_live_v2',
    'v_active_runs_summary_v1'
);

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'AI_OPS',
    owner_layer = 'AI OPS Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_ai_ops_actions_queue_v1',
    'v_ai_ops_dashboard_panel_v1',
    'v_ai_ops_dashboard_panel_summary_v1'
);

-- =====================================================
-- ACTIVE
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE',
    domain_area = 'AI_OPS',
    owner_layer = 'AI OPS Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_ai_action_history_v1',
    'v_ai_health_score',
    'v_ai_ops_alert_center_v1'
);

-- =====================================================
-- LEGACY
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'LEGACY_KEEP',
    is_master = false,
    master_replacement = 'ops.v_active_runs_live_v2',
    cleanup_note = 'V1 nahrazena verzí V2.',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'v_active_runs_live_v1';

-- =====================================================
-- ACTIVE REVIEW
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_REVIEW',
    domain_area = 'PROVIDER',
    owner_layer = 'Coverage Layer',
    cleanup_note = 'Historický coverage report. Ověřit, zda je stále využíván.',
    migration_action = 'REVIEW',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'api_football_coverage';