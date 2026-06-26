/*
===============================================================================
MATCHMATRIX SQL 113_I
PROVIDER GOVERNANCE AUDIT V1

CO TO JE:
- Označení provider view podle jejich role v architektuře.

K ČEMU TO JE:
- Oddělit MASTER routing vrstvu od pomocných engine a panelů.

KDE TO UVIDÍME:
- ops.database_object_governance

JAK SE TO VYUŽIJE:
- DB cleanup
- OPS panel
- Provider routing
===============================================================================
*/

-- =====================================================
-- ACTIVE MASTER
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'PROVIDER',
    what_is_it = 'Provider entity runtime status.',
    purpose = 'Spojuje provider coverage, planner a targety.',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'v_provider_entity_status';

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'PROVIDER',
    what_is_it = 'Kompletní provider health dashboard.',
    purpose = 'Hlavní health view providerů.',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name = 'v_provider_health_full';


-- =====================================================
-- ACTIVE
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE',
    domain_area = 'PROVIDER',
    migration_action = 'KEEP',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_provider_health',
    'v_provider_failure_summary_v1',
    'v_provider_alternative_lookup_v1',
    'v_provider_strategy_engine_v1',
    'v_provider_switch_candidates_v1'
);


-- =====================================================
-- ACTIVE REVIEW
-- =====================================================

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_REVIEW',
    domain_area = 'PROVIDER',
    migration_action = 'REVIEW',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE object_name IN (
    'v_provider_health_engine_v1',
    'v_provider_instability'
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
    'v_provider_alternative_panel_v1',
    'v_provider_strategy_panel_v1',
    'v_provider_switch_panel_v1'
);