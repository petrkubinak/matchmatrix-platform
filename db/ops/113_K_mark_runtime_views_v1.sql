/*
===============================================================================
MATCHMATRIX SQL 113_K
RUNTIME GOVERNANCE AUDIT V1

CO TO JE:
- Označení Runtime subsystému.

K ČEMU TO JE:
- Oddělení Runtime MASTER view od pomocných alertů a cleanup logiky.

KDE TO UVIDÍME:
- OPS Panel
- Runtime Dashboard
- Autonomous OPS

JAK SE TO VYUŽIJE:
- Monitoring
- Scheduler
- Runtime governance
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
    'v_runtime_entity_audit_summary',
    'v_runtime_operations_center_feed_v1'
);

-- =====================================================
-- ACTIVE
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE',
    domain_area = 'RUNTIME',
    owner_layer = 'Runtime Layer',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_runtime_alerts_v1',
    'v_runtime_alerts_grouped_v1',
    'v_runtime_heartbeat_governance_v1'
);

-- =====================================================
-- ACTIVE REVIEW
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_REVIEW',
    domain_area = 'RUNTIME',
    owner_layer = 'Runtime Layer',
    migration_action = 'REVIEW',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_runtime_cleanup_guard_v1'
);