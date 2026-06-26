/*
===============================================================================
MATCHMATRIX SQL 113_J
PEOPLE PIPELINE GOVERNANCE V1

CO TO JE:
- Označí aktuální PEOPLE pipeline view.

K ČEMU TO JE:
- Oddělí současný pipeline audit RAW -> STAGING -> PUBLIC -> MAP
  od budoucí PEOPLE MASTER READINESS vrstvy.

KDE TO UVIDÍME:
- OPS Panel -> PEOPLE PIPELINE

JAK SE TO VYUŽIJE:
- Governance audit
- People layer audit
- Pozdější people master matrix
===============================================================================
*/

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'PEOPLE',
    owner_layer = 'People Layer',
    what_is_it = 'Detailní audit PEOPLE pipeline podle providerů.',
    purpose = 'Měří průchod hráčů přes RAW payloady, staging, public.players a player_provider_map.',
    app_usage = 'OPS Panel -> PEOPLE PIPELINE -> detail podle providerů.',
    depends_on = 'staging.stg_api_payloads, staging.stg_provider_players, public.players, public.player_provider_map',
    risk_if_wrong = 'Panel může ukazovat špatný stav PEOPLE pipeline a coverage hráčů.',
    migration_action = 'KEEP',
    cleanup_note = 'Neměří profily, fotky, trenéry, rankingy ani detailní statistiky.',
    reviewed_at = NOW(),
    reviewed_by = 'ChatGPT + Petr manual DB audit',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name = 'v_people_pipeline_audit_v1';

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    domain_area = 'PEOPLE',
    owner_layer = 'People Layer',
    what_is_it = 'Souhrnný audit PEOPLE pipeline podle sportů.',
    purpose = 'Agreguje stav PEOPLE pipeline ze sportovního pohledu.',
    app_usage = 'OPS Panel -> PEOPLE PIPELINE -> summary podle sportů.',
    depends_on = 'ops.v_people_pipeline_audit_v1, public.sports',
    risk_if_wrong = 'Panel může chybně vyhodnotit, které sporty mají hráče v public vrstvě.',
    migration_action = 'KEEP',
    cleanup_note = 'Není to finální PEOPLE completeness. Budoucí master bude ops.v_people_master_readiness_v1.',
    reviewed_at = NOW(),
    reviewed_by = 'ChatGPT + Petr manual DB audit',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name = 'v_people_pipeline_summary_v1';