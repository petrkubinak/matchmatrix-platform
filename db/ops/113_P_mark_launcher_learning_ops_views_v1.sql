
/*
===============================================================================
MATCHMATRIX SQL 113_P
HARVEST + LAUNCHER + LEARNING + OPS/BK GOVERNANCE AUDIT V1

CO TO JE:
- Označení Harvest E2E Control
- Implementation Readiness
- Launcher vrstvy
- Learning vrstvy
- Operations Center summary
- BK orchestration katalogů

K ČEMU TO JE:
- Oddělit aktuální MASTER view od panelových, pomocných a starších verzí.

KDE TO UVIDÍME:
- OPS Panel
- Launcher
- Learning / Self-improvement
- Harvest control
- BK orchestration

JAK SE TO VYUŽIJE:
- Runtime řízení
- Autonomní spouštění
- Learning z oprav
- Přehled implementace a dalšího vývoje
===============================================================================
*/

-- =====================================================
-- ACTIVE MASTER
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'HARVEST',
    owner_layer = 'Harvest Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'v_harvest_e2e_control';

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'IMPLEMENTATION',
    owner_layer = 'Implementation Readiness Layer',
    master_replacement = NULL,
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'v_implementation_readiness_v2';

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'LAUNCHER',
    owner_layer = 'Launcher Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_launcher_dispatch_v1',
    'v_launcher_dispatch_next_v1',
    'v_launcher_dispatch_summary_v1',
    'v_launcher_permission_v1',
    'v_launcher_next_action_v1',
    'v_launcher_permission_summary_v1'
);

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'LEARNING',
    owner_layer = 'Learning Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_learning_summary_v1',
    'v_learning_recommendations_v1',
    'v_learning_evaluation_candidates_v1',
    'v_learning_evaluation_summary_v1'
);

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'OPS',
    owner_layer = 'Operations Center',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'v_operations_center_summary_v1';

-- =====================================================
-- ACTIVE
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE',
    is_master = false,
    domain_area = 'RUNTIME',
    owner_layer = 'Job Runs Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'v_job_runs_recent';

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE',
    is_master = false,
    domain_area = 'DEVELOPMENT',
    owner_layer = 'Development Planning Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'v_next_development_plan_v1';

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE',
    is_master = false,
    domain_area = 'BASKETBALL',
    owner_layer = 'BK Orchestration Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_ops_bk_core_full_job_catalog',
    'v_ops_bk_core_runnable_jobs'
);

-- =====================================================
-- ACTIVE PANEL
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_PANEL',
    is_master = false,
    domain_area = 'PANEL',
    owner_layer = 'Learning Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'v_learning_panel_v1';

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_PANEL',
    is_master = false,
    domain_area = 'PANEL',
    owner_layer = 'Development Planning Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'v_next_development_plan_panel_v1';

-- =====================================================
-- LEGACY KEEP
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'LEGACY_KEEP',
    is_master = false,
    domain_area = 'IMPLEMENTATION',
    owner_layer = 'Implementation Readiness Layer',
    master_replacement = 'ops.v_implementation_readiness_v2',
    cleanup_note = 'Starší verze. V2 lépe rozlišuje CORE / PEOPLE / MEDIA / ODDS.',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'v_implementation_readiness_v1';