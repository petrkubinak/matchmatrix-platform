/*
MATCHMATRIX SQL 18_5_D
GOVERNANCE PANEL SOURCE REGISTRATION V1

CO TO JE:
- Registruje nové Governance Dashboard view do ops.database_object_governance.

K ČEMU TO JE:
- Aby governance dashboard, KPI a detail byly vedené jako oficiální ACTIVE_MASTER objekty.
- Aby panel V18 mohl tyto view používat jako bezpečné zdroje.

KDE TO UVIDÍME:
- ops.database_object_governance
- OPS Panel V18
- Governance Dashboard
- Project Governance přehled

JAK SE TO VYUŽIJE:
- Panel V18 bude číst:
    ops.v_governance_dashboard_v1
    ops.v_governance_summary_kpi_v1
    ops.v_governance_panel_detail_v1
- Governance bude mít jeden oficiální zdroj pravdy.
*/

INSERT INTO ops.database_object_governance (
    schema_name,
    object_name,
    object_type,
    governance_status,
    is_master,
    used_by,
    purpose_note,
    cleanup_note,
    reviewed_at,
    reviewed_by,
    domain_area,
    owner_layer,
    what_is_it,
    purpose,
    web_usage,
    app_usage,
    depends_on,
    used_by_objects,
    risk_if_wrong,
    migration_action
)
VALUES
(
    'ops',
    'v_governance_dashboard_v1',
    'VIEW',
    'ACTIVE_MASTER',
    true,
    'OPS Panel V18, Governance Dashboard, AI Recommendations',
    'Central Governance Dashboard source.',
    'KEEP',
    now(),
    '18_5_D_governance_panel_source_registration_v1',
    'governance',
    'OPS',
    'Hlavní datový zdroj pro governance stav projektu.',
    'Sjednocuje stav Team, Player a League Governance.',
    'Zobrazí celkový governance stav na web/admin dashboardu.',
    'Použije se v OPS Panelu V18 jako hlavní governance zdroj.',
    'ops.runtime_entity_audit',
    'ops.v_governance_summary_kpi_v1, ops.v_governance_panel_detail_v1',
    'Pokud bude špatně, panel ukáže chybný stav governance.',
    'KEEP_ACTIVE_MASTER'
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    governance_status = EXCLUDED.governance_status,
    is_master = EXCLUDED.is_master,
    used_by = EXCLUDED.used_by,
    purpose_note = EXCLUDED.purpose_note,
    cleanup_note = EXCLUDED.cleanup_note,
    reviewed_at = now(),
    reviewed_by = EXCLUDED.reviewed_by,
    domain_area = EXCLUDED.domain_area,
    owner_layer = EXCLUDED.owner_layer,
    what_is_it = EXCLUDED.what_is_it,
    purpose = EXCLUDED.purpose,
    web_usage = EXCLUDED.web_usage,
    app_usage = EXCLUDED.app_usage,
    depends_on = EXCLUDED.depends_on,
    used_by_objects = EXCLUDED.used_by_objects,
    risk_if_wrong = EXCLUDED.risk_if_wrong,
    migration_action = EXCLUDED.migration_action,
    updated_at = now();

INSERT INTO ops.database_object_governance (
    schema_name,
    object_name,
    object_type,
    governance_status,
    is_master,
    used_by,
    purpose_note,
    cleanup_note,
    reviewed_at,
    reviewed_by,
    domain_area,
    owner_layer,
    what_is_it,
    purpose,
    web_usage,
    app_usage,
    depends_on,
    used_by_objects,
    risk_if_wrong,
    migration_action
)
VALUES
(
    'ops',
    'v_governance_summary_kpi_v1',
    'VIEW',
    'ACTIVE_MASTER',
    true,
    'OPS Panel V18, KPI Header',
    'Governance KPI source.',
    'KEEP',
    now(),
    '18_5_D_governance_panel_source_registration_v1',
    'governance',
    'OPS',
    'Souhrnné KPI governance vrstvy.',
    'Počítá celkové governance skóre, počet hotových a částečných oblastí.',
    'Zobrazí KPI Governance Score.',
    'Použije se v horním KPI bloku panelu.',
    'ops.v_governance_dashboard_v1',
    'OPS Panel V18',
    'Pokud bude špatně, KPI bude ukazovat špatné procento připravenosti.',
    'KEEP_ACTIVE_MASTER'
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    governance_status = EXCLUDED.governance_status,
    is_master = EXCLUDED.is_master,
    used_by = EXCLUDED.used_by,
    purpose_note = EXCLUDED.purpose_note,
    cleanup_note = EXCLUDED.cleanup_note,
    reviewed_at = now(),
    reviewed_by = EXCLUDED.reviewed_by,
    domain_area = EXCLUDED.domain_area,
    owner_layer = EXCLUDED.owner_layer,
    what_is_it = EXCLUDED.what_is_it,
    purpose = EXCLUDED.purpose,
    web_usage = EXCLUDED.web_usage,
    app_usage = EXCLUDED.app_usage,
    depends_on = EXCLUDED.depends_on,
    used_by_objects = EXCLUDED.used_by_objects,
    risk_if_wrong = EXCLUDED.risk_if_wrong,
    migration_action = EXCLUDED.migration_action,
    updated_at = now();

INSERT INTO ops.database_object_governance (
    schema_name,
    object_name,
    object_type,
    governance_status,
    is_master,
    used_by,
    purpose_note,
    cleanup_note,
    reviewed_at,
    reviewed_by,
    domain_area,
    owner_layer,
    what_is_it,
    purpose,
    web_usage,
    app_usage,
    depends_on,
    used_by_objects,
    risk_if_wrong,
    migration_action
)
VALUES
(
    'ops',
    'v_governance_panel_detail_v1',
    'VIEW',
    'ACTIVE_MASTER',
    true,
    'OPS Panel V18, Governance Detail',
    'Governance detail source.',
    'KEEP',
    now(),
    '18_5_D_governance_panel_source_registration_v1',
    'governance',
    'OPS',
    'Detailní český přehled governance oblastí.',
    'Ukazuje Týmy, Hráče, Ligy a Provider Mapy v čitelném stavu.',
    'Zobrazí detail governance pro admin/web přehled.',
    'Použije se v detailní tabulce Governance panelu.',
    'ops.v_governance_dashboard_v1',
    'OPS Panel V18',
    'Pokud bude špatně, detail governance bude zavádějící.',
    'KEEP_ACTIVE_MASTER'
)
ON CONFLICT (schema_name, object_name) DO UPDATE SET
    governance_status = EXCLUDED.governance_status,
    is_master = EXCLUDED.is_master,
    used_by = EXCLUDED.used_by,
    purpose_note = EXCLUDED.purpose_note,
    cleanup_note = EXCLUDED.cleanup_note,
    reviewed_at = now(),
    reviewed_by = EXCLUDED.reviewed_by,
    domain_area = EXCLUDED.domain_area,
    owner_layer = EXCLUDED.owner_layer,
    what_is_it = EXCLUDED.what_is_it,
    purpose = EXCLUDED.purpose,
    web_usage = EXCLUDED.web_usage,
    app_usage = EXCLUDED.app_usage,
    depends_on = EXCLUDED.depends_on,
    used_by_objects = EXCLUDED.used_by_objects,
    risk_if_wrong = EXCLUDED.risk_if_wrong,
    migration_action = EXCLUDED.migration_action,
    updated_at = now();