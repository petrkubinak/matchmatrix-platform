/* =============================================================================
CO:
    G4D-3_STEP_4C-POST_POST-ROLLBACK VERIFICATION

K ČEMU:
    Ověří, že po úspěšném VALIDATE_ONLY testu nezůstala v živé DB
    žádná změna.

KDE:
    PostgreSQL matchmatrix / PC2

JAK:
    Spustit celý blok v DBeaveru.
    Pouze SELECT.
============================================================================= */

SELECT
    'SOURCE_MASTER' AS check_name,
    CASE
        WHEN to_regclass('ops.source_master') IS NULL
            THEN 'PASS_NOT_PRESENT'
        ELSE
            'BLOCKER_PRESENT'
    END AS status

UNION ALL

SELECT
    'ROUTING_SOURCE_ID_COLUMN',
    CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'ops'
              AND table_name = 'data_acquisition_source_routing'
              AND column_name = 'source_id'
        )
            THEN 'PASS_NOT_PRESENT'
        ELSE
            'BLOCKER_PRESENT'
    END

UNION ALL

SELECT
    'ROUTING_ROWS',
    CASE
        WHEN (
            SELECT COUNT(*)
            FROM ops.data_acquisition_source_routing
        ) = 0
            THEN 'PASS_ZERO'
        ELSE
            'BLOCKER_NONZERO'
    END

UNION ALL

SELECT
    'LEGACY_SOURCE_NAME_NOT_NULL',
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'ops'
              AND table_name = 'data_acquisition_source_routing'
              AND column_name = 'source_name'
              AND is_nullable = 'NO'
        )
            THEN 'PASS_ORIGINAL'
        ELSE
            'BLOCKER_CHANGED'
    END

UNION ALL

SELECT
    'LEGACY_SOURCE_ORIGIN_NOT_NULL',
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'ops'
              AND table_name = 'data_acquisition_source_routing'
              AND column_name = 'source_origin'
              AND is_nullable = 'NO'
        )
            THEN 'PASS_ORIGINAL'
        ELSE
            'BLOCKER_CHANGED'
    END

UNION ALL

SELECT
    'LEGACY_SOURCE_REF_ID_NOT_NULL',
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'ops'
              AND table_name = 'data_acquisition_source_routing'
              AND column_name = 'source_ref_id'
              AND is_nullable = 'NO'
        )
            THEN 'PASS_ORIGINAL'
        ELSE
            'BLOCKER_CHANGED'
    END

UNION ALL

SELECT
    'ORIGINAL_ACTIVE_SOURCE_INDEX',
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM pg_indexes
            WHERE schemaname = 'ops'
              AND tablename = 'data_acquisition_source_routing'
              AND indexname = 'uq_data_acq_source_routing_active_source'
              AND indexdef LIKE '%source_origin%'
              AND indexdef LIKE '%source_name%'
        )
            THEN 'PASS_ORIGINAL'
        ELSE
            'BLOCKER_CHANGED'
    END

UNION ALL

SELECT
    'ORIGINAL_APPROVED_PRIMARY_INDEX',
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM pg_indexes
            WHERE schemaname = 'ops'
              AND tablename = 'data_acquisition_source_routing'
              AND indexname =
                  'uq_data_acq_source_routing_one_approved_primary'
        )
            THEN 'PASS_ORIGINAL'
        ELSE
            'BLOCKER_CHANGED'
    END;