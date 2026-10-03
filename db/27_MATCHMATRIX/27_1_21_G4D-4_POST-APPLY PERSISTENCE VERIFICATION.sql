/* =============================================================================
CO:
    G4D-4 / POST-APPLY PERSISTENCE VERIFICATION

K ČEMU:
    Ověří, zda první běh G4D-4 skutečně prošel COMMITem
    a zda jsou změny trvale uloženy.

BEZPEČNOST:
    POUZE SELECT
============================================================================= */

SELECT *
FROM (
    SELECT
        10 AS sort_order,
        'TARGET_TABLES_PRESENT'::text AS check_id,
        CASE WHEN (
            SELECT COUNT(*)
            FROM (VALUES
                ('ops.source_master'),
                ('ops.source_alias'),
                ('ops.source_sport'),
                ('ops.source_entity_time_coverage'),
                ('ops.source_audit_evidence'),
                ('ops.runtime_adapter'),
                ('ops.source_adapter_binding')
            ) AS t(object_name)
            WHERE to_regclass(t.object_name) IS NOT NULL
        ) = 7
        THEN 'PASS'
        ELSE 'BLOCKER'
        END AS status,
        (
            SELECT COUNT(*)::text || '/7 target tables present'
            FROM (VALUES
                ('ops.source_master'),
                ('ops.source_alias'),
                ('ops.source_sport'),
                ('ops.source_entity_time_coverage'),
                ('ops.source_audit_evidence'),
                ('ops.runtime_adapter'),
                ('ops.source_adapter_binding')
            ) AS t(object_name)
            WHERE to_regclass(t.object_name) IS NOT NULL
        ) AS detail

    UNION ALL

    SELECT
        20,
        'SAFE_SEED_COUNTS',
        CASE WHEN
            (SELECT COUNT(*) FROM ops.source_master) = 17
            AND (SELECT COUNT(*) FROM ops.source_alias) = 35
            AND (SELECT COUNT(*) FROM ops.source_sport) = 17
            AND (SELECT COUNT(*) FROM ops.source_audit_evidence) = 57
            AND (SELECT COUNT(*) FROM ops.runtime_adapter) = 27
        THEN 'PASS'
        ELSE 'BLOCKER'
        END,
        format(
            'master=%s; alias=%s; sport=%s; evidence=%s; adapter=%s',
            (SELECT COUNT(*) FROM ops.source_master),
            (SELECT COUNT(*) FROM ops.source_alias),
            (SELECT COUNT(*) FROM ops.source_sport),
            (SELECT COUNT(*) FROM ops.source_audit_evidence),
            (SELECT COUNT(*) FROM ops.runtime_adapter)
        )

    UNION ALL

    SELECT
        30,
        'HOLD_TARGETS_EMPTY',
        CASE WHEN
            (SELECT COUNT(*) FROM ops.source_entity_time_coverage) = 0
            AND (SELECT COUNT(*) FROM ops.source_adapter_binding) = 0
            AND (SELECT COUNT(*) FROM ops.data_acquisition_source_routing) = 0
        THEN 'PASS'
        ELSE 'BLOCKER'
        END,
        format(
            'coverage=%s; binding=%s; routing=%s',
            (SELECT COUNT(*) FROM ops.source_entity_time_coverage),
            (SELECT COUNT(*) FROM ops.source_adapter_binding),
            (SELECT COUNT(*) FROM ops.data_acquisition_source_routing)
        )

    UNION ALL

    SELECT
        40,
        'ROUTING_SOURCE_ID',
        CASE WHEN EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'ops'
              AND table_name = 'data_acquisition_source_routing'
              AND column_name = 'source_id'
              AND data_type = 'bigint'
              AND is_nullable = 'NO'
        )
        THEN 'PASS'
        ELSE 'BLOCKER'
        END,
        'source_id BIGINT NOT NULL'

    UNION ALL

    SELECT
        50,
        'ROUTING_LEGACY_NULLABLE',
        CASE WHEN (
            SELECT COUNT(*)
            FROM information_schema.columns
            WHERE table_schema = 'ops'
              AND table_name = 'data_acquisition_source_routing'
              AND column_name IN (
                  'source_name',
                  'source_origin',
                  'source_ref_id'
              )
              AND is_nullable = 'YES'
        ) = 3
        THEN 'PASS'
        ELSE 'BLOCKER'
        END,
        'source_name/source_origin/source_ref_id nullable'

    UNION ALL

    SELECT
        60,
        'CANONICAL_ROUTING_INDEX',
        CASE WHEN EXISTS (
            SELECT 1
            FROM pg_indexes
            WHERE schemaname = 'ops'
              AND tablename = 'data_acquisition_source_routing'
              AND indexname = 'uq_data_acq_source_routing_active_source'
              AND indexdef LIKE '%source_id%'
        )
        THEN 'PASS'
        ELSE 'BLOCKER'
        END,
        'active route uniqueness uses source_id'

    UNION ALL

    SELECT
        70,
        'ONE_ACTIVE_PRIMARY_INDEX',
        CASE WHEN EXISTS (
            SELECT 1
            FROM pg_indexes
            WHERE schemaname = 'ops'
              AND tablename = 'data_acquisition_source_routing'
              AND indexname = 'uq_data_acq_source_routing_one_active_primary'
              AND indexdef NOT LIKE '%decision_status%'
        )
        THEN 'PASS'
        ELSE 'BLOCKER'
        END,
        'max one active PRIMARY per exact scope'

    UNION ALL

    SELECT
        80,
        'TARGET_ROLE_CONTRACT',
        CASE WHEN EXISTS (
            SELECT 1
            FROM pg_constraint c
            WHERE c.conrelid =
                'ops.data_acquisition_source_routing'::regclass
              AND c.conname =
                'ck_data_acq_source_routing_source_role'
              AND pg_get_constraintdef(c.oid,true) LIKE '%VALIDATION%'
              AND pg_get_constraintdef(c.oid,true) LIKE '%NOT_USED%'
              AND pg_get_constraintdef(c.oid,true) NOT LIKE '%REFERENCE%'
        )
        THEN 'PASS'
        ELSE 'BLOCKER'
        END,
        'PRIMARY/FALLBACK/MERGE/VALIDATION/NOT_USED'

    UNION ALL

    SELECT
        90,
        'APPROVAL_PROTECTION',
        CASE WHEN EXISTS (
            SELECT 1
            FROM pg_constraint c
            WHERE c.conrelid =
                'ops.data_acquisition_source_routing'::regclass
              AND c.conname =
                'ck_data_acq_source_routing_approval'
        )
        THEN 'PASS'
        ELSE 'BLOCKER'
        END,
        'approval constraint present'
) q
ORDER BY sort_order;