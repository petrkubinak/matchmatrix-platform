/* =============================================================================
CO:
    G4D-6 / STEP 1
    CONTROLLED ROUTING READINESS PRECHECK

K ČEMU:
    Ověří, zda existuje alespoň jedna route, kterou lze bezpečně vytvořit
    podle zmrazeného kontraktu.

    PRIMARY / FALLBACK / MERGE mohou vzniknout pouze tam, kde existuje
    odpovídající SOURCE_ENTITY_TIME_COVERAGE.

    PRIMARY navíc vyžaduje CONFIRMED coverage.

KDE:
    PostgreSQL matchmatrix / PC2

BEZPEČNOST:
    - pouze SELECT
    - žádný INSERT
    - žádný UPDATE
    - žádný DELETE
    - žádný ALTER
    - žádný APPLY
============================================================================= */


WITH coverage AS (
    SELECT
        c.coverage_id,
        c.source_id,
        c.sport_code,
        c.layer_type,
        c.entity,
        c.time_mode,
        c.coverage_status
    FROM ops.source_entity_time_coverage c
),

routing AS (
    SELECT
        r.route_id,
        r.source_id,
        r.sport_code,
        r.layer_type,
        r.entity,
        r.time_mode,
        r.source_role,
        r.decision_status,
        r.is_active
    FROM ops.data_acquisition_source_routing r
),

primary_ready AS (
    SELECT
        c.*
    FROM coverage c
    WHERE c.coverage_status = 'CONFIRMED'
),

nonblocked_ready AS (
    SELECT
        c.*
    FROM coverage c
    WHERE c.coverage_status IN (
        'TECH_READY',
        'RUNTIME_TESTED',
        'CONFIRMED'
    )
),

summary AS (

    SELECT
        10 AS sort_order,
        'SOURCE_ENTITY_TIME_COVERAGE_ROWS'::text AS check_id,
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS_ZERO_READY'
            ELSE 'INFO'
        END AS status,
        'rows=' || COUNT(*)::text AS detail
    FROM coverage


    UNION ALL


    SELECT
        20,
        'CONFIRMED_COVERAGE_ROWS',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS_ZERO_READY'
            ELSE 'INFO'
        END,
        'rows=' || COUNT(*)::text
    FROM coverage
    WHERE coverage_status = 'CONFIRMED'


    UNION ALL


    SELECT
        30,
        'PRIMARY_READY_SCOPES',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS_ZERO_READY'
            ELSE 'REVIEW_READY'
        END,
        'ready_rows=' || COUNT(*)::text
    FROM primary_ready


    UNION ALL


    SELECT
        40,
        'NONBLOCKED_COVERAGE_SCOPES',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS_ZERO_READY'
            ELSE 'INFO'
        END,
        'rows=' || COUNT(*)::text
    FROM nonblocked_ready


    UNION ALL


    SELECT
        50,
        'CURRENT_ROUTING_ROWS',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'REVIEW'
        END,
        'rows=' || COUNT(*)::text
    FROM routing


    UNION ALL


    SELECT
        60,
        'CURRENT_ACTIVE_ROUTING_ROWS',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'REVIEW'
        END,
        'rows=' || COUNT(*)::text
    FROM routing
    WHERE is_active = true


    UNION ALL


    SELECT
        70,
        'CURRENT_APPROVED_ROUTING_ROWS',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'REVIEW'
        END,
        'rows=' || COUNT(*)::text
    FROM routing
    WHERE decision_status = 'APPROVED'


    UNION ALL


    SELECT
        80,
        'ORPHAN_ROUTING_WITHOUT_COVERAGE',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM routing r
    WHERE NOT EXISTS (
        SELECT 1
        FROM coverage c
        WHERE c.source_id = r.source_id
          AND c.sport_code = r.sport_code
          AND c.layer_type = r.layer_type
          AND c.entity = r.entity
          AND c.time_mode = r.time_mode
    )


    UNION ALL


    SELECT
        90,
        'PRIMARY_WITHOUT_CONFIRMED_COVERAGE',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS'
            ELSE 'BLOCKER'
        END,
        'rows=' || COUNT(*)::text
    FROM routing r
    WHERE r.is_active = true
      AND r.source_role = 'PRIMARY'
      AND NOT EXISTS (
          SELECT 1
          FROM coverage c
          WHERE c.source_id = r.source_id
            AND c.sport_code = r.sport_code
            AND c.layer_type = r.layer_type
            AND c.entity = r.entity
            AND c.time_mode = r.time_mode
            AND c.coverage_status = 'CONFIRMED'
      )


    UNION ALL


    SELECT
        100,
        'G4D6_READY_ROUTES',
        CASE
            WHEN COUNT(*) = 0 THEN 'PASS_ZERO_READY'
            ELSE 'REVIEW_READY'
        END,
        'ready_routes=' || COUNT(*)::text
    FROM primary_ready


    UNION ALL


    SELECT
        110,
        'G4D6_STEP1_READINESS',
        CASE
            WHEN
                (SELECT COUNT(*) FROM primary_ready) = 0
                AND (SELECT COUNT(*) FROM routing) = 0
            THEN 'PASS_ZERO_READY'
            ELSE 'REVIEW'
        END,
        'No controlled routing APPLY is permitted without explicit CONFIRMED coverage.'
)

SELECT
    check_id,
    status,
    detail
FROM summary
ORDER BY sort_order;