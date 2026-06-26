/*
MATCHMATRIX SQL 108_Q
Parser Flow Audit V1

CO TO JE:
- Auditní view pro sjednocení parser/ingest flow.

K ČEMU TO JE:
- Odhalí, co jede přes unified flow, legacy flow nebo hybrid flow.

KDE TO UVIDÍME:
- ops.v_parser_flow_audit_v1
- později panel V18

JAK SE TO VYUŽIJE:
- sjednocení všech workerů
- migrace na staging.stg_api_payloads
- kontrola parserů
- jednotný monitoring
*/

CREATE OR REPLACE VIEW ops.v_parser_flow_audit_v1 AS

SELECT
    provider,
    sport_code,
    entity,
    worker_script,

    source_endpoint,
    target_table,

    CASE
        WHEN target_table ILIKE '%stg_api_payloads%'
            THEN 'UNIFIED_RAW'

        WHEN target_table ILIKE '%stg_provider_%'
            THEN 'UNIFIED_STAGING'

        WHEN target_table ILIKE '%api_football_%'
          OR target_table ILIKE '%api_hockey_%'
          OR target_table ILIKE '%api_tennis_%'
            THEN 'LEGACY_STAGING'

        WHEN target_table ILIKE '%public.%'
            THEN 'DIRECT_PUBLIC_OR_MERGE'

        ELSE 'UNKNOWN'
    END AS flow_type,

    CASE
        WHEN worker_script IS NULL OR worker_script = ''
            THEN 'MISSING_WORKER'

        WHEN target_table IS NULL OR target_table = ''
            THEN 'MISSING_TARGET'

        WHEN target_table ILIKE '%stg_api_payloads%'
            THEN 'OK_UNIFIED_RAW'

        WHEN target_table ILIKE '%stg_provider_%'
            THEN 'OK_UNIFIED_STAGING'

        WHEN target_table ILIKE '%api_football_%'
          OR target_table ILIKE '%api_hockey_%'
          OR target_table ILIKE '%api_tennis_%'
            THEN 'NEEDS_MIGRATION'

        ELSE 'REVIEW'
    END AS migration_state,

    notes,
    limitations,
    next_action,
    updated_at

FROM ops.provider_entity_coverage;