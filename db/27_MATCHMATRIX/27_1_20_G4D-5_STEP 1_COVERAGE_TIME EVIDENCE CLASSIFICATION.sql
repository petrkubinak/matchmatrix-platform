/* =============================================================================
CO:
    G4D-5 / STEP 1
    COVERAGE / TIME EVIDENCE CLASSIFICATION V2

K ČEMU:
    READ ONLY klasifikace coverage evidence bez domýšlení source/time/scope.

BEZPEČNOST:
    pouze SELECT
============================================================================= */


/* ============================================================================
1. SUMMARY
============================================================================ */

WITH provider_cov AS (
    SELECT
        pec.id AS legacy_id,
        pec.provider,
        pec.sport_code,
        pec.entity,
        pec.coverage_status,
        ra.adapter_id,
        sab.source_id AS bound_source_id,

        CASE
            WHEN ra.adapter_id IS NULL
                THEN 'HOLD_ADAPTER_NOT_FOUND'
            WHEN sab.source_id IS NULL
                THEN 'HOLD_NO_SOURCE_ADAPTER_BINDING'
            ELSE 'SOURCE_ID_RESOLVED'
        END AS source_identity_status,

        'HOLD_NO_EXACT_TIME_MODE'::text AS time_status,
        'HOLD'::text AS migration_status

    FROM ops.provider_entity_coverage pec

    LEFT JOIN ops.runtime_adapter ra
      ON ra.adapter_code = pec.provider

    LEFT JOIN ops.source_adapter_binding sab
      ON sab.adapter_id = ra.adapter_id
     AND sab.is_active = true
     AND (
            sab.sport_code IS NULL
            OR sab.sport_code = pec.sport_code
         )
     AND (
            sab.entity IS NULL
            OR sab.entity = pec.entity
         )
),

source_cov AS (
    SELECT
        scm.coverage_id AS legacy_id,
        scm.source_name,
        scm.sport_code,
        scm.coverage_domain,
        scm.entity_type,
        scm.coverage_status,
        sa.source_id,

        CASE
            WHEN sa.source_id IS NULL
                THEN 'HOLD_SOURCE_ID_UNRESOLVED'
            ELSE 'SOURCE_ID_RESOLVED'
        END AS source_identity_status,

        CASE
            WHEN scm.coverage_domain = 'HISTORY'
                THEN 'HOLD_HISTORY_MODE_AMBIGUOUS'
            ELSE 'HOLD_NO_EXACT_TIME_MODE'
        END AS time_status,

        'HOLD_LAYER_ENTITY_MAPPING_NOT_FROZEN'::text
            AS scope_mapping_status,

        'HOLD'::text AS migration_status

    FROM ops.source_coverage_matrix scm

    LEFT JOIN ops.source_alias sa
      ON sa.alias_type = 'SOURCE_NAME'
     AND sa.valid_to IS NULL
     AND sa.normalized_alias =
         lower(
             regexp_replace(
                 btrim(scm.source_name),
                 '\s+',
                 ' ',
                 'g'
             )
         )
)

SELECT *
FROM (

    SELECT
        10 AS sort_order,
        'TARGET_COVERAGE_CURRENT_ROWS'::text AS check_id,
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'BLOCKER'
        END AS status,
        'rows=' || COUNT(*)::text AS detail
    FROM ops.source_entity_time_coverage

    UNION ALL

    SELECT
        20,
        'PROVIDER_ENTITY_COVERAGE_ROWS',
        CASE
            WHEN COUNT(*) = 107 THEN 'PASS'
            ELSE 'REVIEW'
        END,
        'rows=' || COUNT(*)::text
    FROM provider_cov

    UNION ALL

    SELECT
        30,
        'PROVIDER_ROWS_WITH_RUNTIME_ADAPTER',
        'INFO',
        'rows=' || COUNT(*)::text
    FROM provider_cov
    WHERE adapter_id IS NOT NULL

    UNION ALL

    SELECT
        40,
        'PROVIDER_ROWS_WITH_SOURCE_BINDING',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS_EXPECTED_HOLD'
            ELSE 'REVIEW'
        END,
        'rows=' || COUNT(*)::text
    FROM provider_cov
    WHERE bound_source_id IS NOT NULL

    UNION ALL

    SELECT
        50,
        'PROVIDER_READY_FOR_TIME_COVERAGE',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS_EXPECTED_HOLD'
            ELSE 'REVIEW'
        END,
        'ready_rows=' || COUNT(*)::text
    FROM provider_cov
    WHERE migration_status = 'READY'

    UNION ALL

    SELECT
        60,
        'SOURCE_COVERAGE_MATRIX_ROWS',
        CASE
            WHEN COUNT(*) = 7 THEN 'PASS'
            ELSE 'REVIEW'
        END,
        'rows=' || COUNT(*)::text
    FROM source_cov

    UNION ALL

    SELECT
        70,
        'SOURCE_COVERAGE_CANONICAL_ID_RESOLVED',
        'INFO',
        'rows=' || COUNT(*)::text
    FROM source_cov
    WHERE source_id IS NOT NULL

    UNION ALL

    SELECT
        80,
        'SOURCE_COVERAGE_EXACT_TIME_MODE',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS_EXPECTED_HOLD'
            ELSE 'REVIEW'
        END,
        'exact_time_rows=' || COUNT(*)::text
    FROM source_cov
    WHERE migration_status = 'READY'

    UNION ALL

    SELECT
        90,
        'READY_TARGET_ROWS',
        CASE
            WHEN (
                (SELECT COUNT(*) FROM provider_cov WHERE migration_status='READY')
                +
                (SELECT COUNT(*) FROM source_cov WHERE migration_status='READY')
            ) = 0
            THEN 'PASS_ZERO_READY'
            ELSE 'REVIEW_READY_ROWS'
        END,
        'ready_rows=' ||
        (
            (SELECT COUNT(*) FROM provider_cov WHERE migration_status='READY')
            +
            (SELECT COUNT(*) FROM source_cov WHERE migration_status='READY')
        )::text

    UNION ALL

    SELECT
        100,
        'G4D5_STEP1_CLASSIFICATION',
        'PASS',
        'No coverage row will be inserted without explicit source/scope/time evidence.'

) q
ORDER BY sort_order;


/* ============================================================================
2. PROVIDER DETAIL
============================================================================ */

WITH provider_cov AS (
    SELECT
        pec.id AS legacy_id,
        pec.provider,
        pec.sport_code,
        pec.entity,
        pec.coverage_status,
        ra.adapter_id,
        sab.source_id AS bound_source_id,

        CASE
            WHEN ra.adapter_id IS NULL
                THEN 'HOLD_ADAPTER_NOT_FOUND'
            WHEN sab.source_id IS NULL
                THEN 'HOLD_NO_SOURCE_ADAPTER_BINDING'
            ELSE 'SOURCE_ID_RESOLVED'
        END AS source_identity_status,

        'HOLD_NO_EXACT_TIME_MODE'::text AS time_status

    FROM ops.provider_entity_coverage pec

    LEFT JOIN ops.runtime_adapter ra
      ON ra.adapter_code = pec.provider

    LEFT JOIN ops.source_adapter_binding sab
      ON sab.adapter_id = ra.adapter_id
     AND sab.is_active = true
     AND (
            sab.sport_code IS NULL
            OR sab.sport_code = pec.sport_code
         )
     AND (
            sab.entity IS NULL
            OR sab.entity = pec.entity
         )
)

SELECT
    source_identity_status,
    time_status,
    COUNT(*) AS rows
FROM provider_cov
GROUP BY
    source_identity_status,
    time_status
ORDER BY
    source_identity_status,
    time_status;


/* ============================================================================
3. SOURCE COVERAGE DETAIL
============================================================================ */

WITH source_cov AS (
    SELECT
        scm.coverage_id AS legacy_id,
        scm.source_name,
        scm.sport_code,
        scm.coverage_domain,
        scm.entity_type,
        scm.coverage_status,
        sa.source_id,

        CASE
            WHEN sa.source_id IS NULL
                THEN 'HOLD_SOURCE_ID_UNRESOLVED'
            ELSE 'SOURCE_ID_RESOLVED'
        END AS source_identity_status,

        CASE
            WHEN scm.coverage_domain = 'HISTORY'
                THEN 'HOLD_HISTORY_MODE_AMBIGUOUS'
            ELSE 'HOLD_NO_EXACT_TIME_MODE'
        END AS time_status,

        'HOLD_LAYER_ENTITY_MAPPING_NOT_FROZEN'::text
            AS scope_mapping_status,

        'HOLD'::text AS migration_status,

        CASE
            WHEN sa.source_id IS NULL THEN
                'Canonical source identity cannot be resolved.'

            WHEN scm.coverage_domain = 'HISTORY' THEN
                'Historical coverage exists, but target requires exact HISTORY_FAN or HISTORY_PREDICTION.'

            ELSE
                'Coverage evidence exists, but exact layer/entity/time_mode target tuple is not explicitly evidenced.'
        END AS reason

    FROM ops.source_coverage_matrix scm

    LEFT JOIN ops.source_alias sa
      ON sa.alias_type = 'SOURCE_NAME'
     AND sa.valid_to IS NULL
     AND sa.normalized_alias =
         lower(
             regexp_replace(
                 btrim(scm.source_name),
                 '\s+',
                 ' ',
                 'g'
             )
         )
)

SELECT
    legacy_id,
    source_name,
    sport_code,
    coverage_domain,
    entity_type,
    coverage_status,
    source_id,
    source_identity_status,
    time_status,
    scope_mapping_status,
    migration_status,
    reason
FROM source_cov
ORDER BY legacy_id;