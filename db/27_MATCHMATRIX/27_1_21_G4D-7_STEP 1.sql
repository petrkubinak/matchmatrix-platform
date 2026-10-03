/* =============================================================================
CO:
    G4D-7 / STEP 1
    LEGACY CLEANUP READINESS PRECHECK

K ČEMU:
    Ověří, zda je některý legacy objekt bezpečně připraven k odstranění.

KDE:
    PostgreSQL matchmatrix / PC2

BEZPEČNOST:
    pouze SELECT
    žádný DROP
    žádný ALTER
    žádný DELETE
============================================================================= */

WITH state AS (

    SELECT
        (SELECT COUNT(*) FROM ops.source_master) AS source_master_rows,
        (SELECT COUNT(*) FROM ops.source_alias) AS source_alias_rows,
        (SELECT COUNT(*) FROM ops.source_sport) AS source_sport_rows,
        (SELECT COUNT(*) FROM ops.source_audit_evidence) AS source_audit_rows,
        (SELECT COUNT(*) FROM ops.runtime_adapter) AS runtime_adapter_rows,

        (SELECT COUNT(*) FROM ops.source_entity_time_coverage) AS coverage_rows,
        (SELECT COUNT(*) FROM ops.source_adapter_binding) AS binding_rows,
        (SELECT COUNT(*) FROM ops.data_acquisition_source_routing) AS routing_rows,

        (SELECT COUNT(*) FROM ops.provider_entity_coverage) AS legacy_provider_coverage_rows,
        (SELECT COUNT(*) FROM ops.provider_sport_matrix) AS legacy_provider_sport_rows,

        (SELECT COUNT(*) FROM ops.source_discovery_audit_tracker) AS audit_tracker_rows,
        (SELECT COUNT(*) FROM ops.source_commercial_model) AS commercial_rows,
        (SELECT COUNT(*) FROM ops.source_legal_audit) AS legal_rows,
        (SELECT COUNT(*) FROM ops.source_activation_roadmap) AS activation_rows,
        (SELECT COUNT(*) FROM ops.source_intelligence_map) AS intelligence_rows,
        (SELECT COUNT(*) FROM ops.source_quality_score) AS quality_rows,
        (SELECT COUNT(*) FROM ops.source_coverage_matrix) AS source_coverage_rows,
        (SELECT COUNT(*) FROM ops.source_review_results) AS review_rows,
        (SELECT COUNT(*) FROM ops.source_verification_log) AS verification_rows
)

SELECT *
FROM (

    SELECT
        10 AS sort_order,
        'CANONICAL_IDENTITY_LAYER' AS check_id,
        CASE
            WHEN source_master_rows = 17
             AND source_alias_rows = 35
             AND source_sport_rows = 17
            THEN 'PASS'
            ELSE 'BLOCKER'
        END AS status,
        format(
            'master=%s; alias=%s; sport=%s',
            source_master_rows,
            source_alias_rows,
            source_sport_rows
        ) AS detail
    FROM state

    UNION ALL

    SELECT
        20,
        'CANONICAL_EVIDENCE_LAYER',
        CASE
            WHEN source_audit_rows = 57
            THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'source_audit_evidence=' || source_audit_rows
    FROM state

    UNION ALL

    SELECT
        30,
        'CANONICAL_RUNTIME_LAYER',
        CASE
            WHEN runtime_adapter_rows = 27
            THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'runtime_adapter=' || runtime_adapter_rows
    FROM state

    UNION ALL

    SELECT
        40,
        'COVERAGE_MIGRATION_COMPLETE',
        CASE
            WHEN coverage_rows > 0
            THEN 'REVIEW'
            ELSE 'NOT_READY'
        END,
        'canonical_coverage_rows=' || coverage_rows
    FROM state

    UNION ALL

    SELECT
        50,
        'ADAPTER_BINDING_MIGRATION_COMPLETE',
        CASE
            WHEN binding_rows > 0
            THEN 'REVIEW'
            ELSE 'NOT_READY'
        END,
        'canonical_binding_rows=' || binding_rows
    FROM state

    UNION ALL

    SELECT
        60,
        'ROUTING_POPULATED',
        CASE
            WHEN routing_rows > 0
            THEN 'REVIEW'
            ELSE 'NOT_READY'
        END,
        'canonical_routing_rows=' || routing_rows
    FROM state

    UNION ALL

    SELECT
        70,
        'LEGACY_PROVIDER_COVERAGE_RETENTION',
        CASE
            WHEN legacy_provider_coverage_rows > 0
             AND coverage_rows = 0
            THEN 'KEEP_REQUIRED'
            ELSE 'REVIEW'
        END,
        format(
            'legacy_provider_coverage=%s; canonical_coverage=%s',
            legacy_provider_coverage_rows,
            coverage_rows
        )
    FROM state

    UNION ALL

    SELECT
        80,
        'LEGACY_PROVIDER_SPORT_RETENTION',
        CASE
            WHEN legacy_provider_sport_rows > 0
             AND binding_rows = 0
            THEN 'KEEP_REQUIRED'
            ELSE 'REVIEW'
        END,
        format(
            'legacy_provider_sport=%s; canonical_bindings=%s',
            legacy_provider_sport_rows,
            binding_rows
        )
    FROM state

    UNION ALL

    SELECT
        90,
        'SPECIALIZED_AUDIT_TABLES_RETENTION',
        'KEEP_REQUIRED',
        format(
            'audit=%s; commercial=%s; legal=%s; activation=%s; intelligence=%s; quality=%s; coverage=%s; review=%s; verification=%s',
            audit_tracker_rows,
            commercial_rows,
            legal_rows,
            activation_rows,
            intelligence_rows,
            quality_rows,
            source_coverage_rows,
            review_rows,
            verification_rows
        )
    FROM state

    UNION ALL

    SELECT
        100,
        'DESTRUCTIVE_CLEANUP_READY',
        CASE
            WHEN coverage_rows = 0
             OR binding_rows = 0
             OR routing_rows = 0
            THEN 'PASS_NOT_READY'
            ELSE 'REVIEW'
        END,
        'No legacy object may be dropped while canonical coverage/binding/routing remain unresolved.'
    FROM state

    UNION ALL

    SELECT
        110,
        'G4D7_STEP1',
        'PASS',
        'Cleanup readiness audit only; no destructive operation executed.'

) q
ORDER BY sort_order;