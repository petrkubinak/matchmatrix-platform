/* =============================================================================
CO:
    G4D / FINAL CLOSURE SNAPSHOT

K ČEMU:
    Finální stav po dokončení G4D-1 až G4D-7.

BEZPEČNOST:
    pouze SELECT
============================================================================= */

SELECT
    'SOURCE_MASTER' AS object_name,
    COUNT(*) AS rows
FROM ops.source_master

UNION ALL
SELECT 'SOURCE_ALIAS', COUNT(*)
FROM ops.source_alias

UNION ALL
SELECT 'SOURCE_SPORT', COUNT(*)
FROM ops.source_sport

UNION ALL
SELECT 'SOURCE_AUDIT_EVIDENCE', COUNT(*)
FROM ops.source_audit_evidence

UNION ALL
SELECT 'RUNTIME_ADAPTER', COUNT(*)
FROM ops.runtime_adapter

UNION ALL
SELECT 'SOURCE_ENTITY_TIME_COVERAGE', COUNT(*)
FROM ops.source_entity_time_coverage

UNION ALL
SELECT 'SOURCE_ADAPTER_BINDING', COUNT(*)
FROM ops.source_adapter_binding

UNION ALL
SELECT 'SOURCE_ROUTING', COUNT(*)
FROM ops.data_acquisition_source_routing

UNION ALL
SELECT 'LEGACY_PROVIDER_ENTITY_COVERAGE', COUNT(*)
FROM ops.provider_entity_coverage

UNION ALL
SELECT 'LEGACY_PROVIDER_SPORT_MATRIX', COUNT(*)
FROM ops.provider_sport_matrix

ORDER BY object_name;