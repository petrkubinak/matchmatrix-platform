/* =============================================================================
CO:
    G4D-3_STEP 4D-1_MISSING AUDIT EVIDENCE EXPORT

K ČEMU:
    Doplní dva evidence objekty, které byly omylem vynechány
    z datové části STEP 4D:

        ops.source_verification_log
        ops.source_review_results

KDE:
    PostgreSQL matchmatrix / PC2

JAK:
    Spustit celý blok.
    Výsledkem je jedna tabulka.

BEZPEČNOST:
    pouze SELECT
    žádný APPLY
============================================================================= */

WITH report AS (

    /* ========================================================================
    01 — SOURCE REVIEW RESULTS
    ======================================================================== */

    SELECT
        10 AS sort_group,
        ROW_NUMBER() OVER (
            ORDER BY
                sport_code,
                source_name,
                review_area,
                review_item,
                review_result_id
        )::bigint AS sort_item,

        'SOURCE_REVIEW_RESULTS'::text AS section,
        review_result_id::bigint AS source_row_id,
        to_jsonb(r)::text AS detail

    FROM ops.source_review_results r


    UNION ALL


    /* ========================================================================
    02 — SOURCE VERIFICATION LOG
    ======================================================================== */

    SELECT
        20 AS sort_group,
        ROW_NUMBER() OVER (
            ORDER BY
                sport_code,
                source_name,
                verification_area,
                verification_item,
                verification_id
        )::bigint AS sort_item,

        'SOURCE_VERIFICATION_LOG'::text AS section,
        verification_id::bigint AS source_row_id,
        to_jsonb(v)::text AS detail

    FROM ops.source_verification_log v


    UNION ALL


    /* ========================================================================
    03 — ROW COUNTS
    ======================================================================== */

    SELECT
        30,
        1,
        'ROW_COUNT_SOURCE_REVIEW_RESULTS',
        NULL::bigint,
        COUNT(*)::text
    FROM ops.source_review_results


    UNION ALL


    SELECT
        30,
        2,
        'ROW_COUNT_SOURCE_VERIFICATION_LOG',
        NULL::bigint,
        COUNT(*)::text
    FROM ops.source_verification_log


    UNION ALL


    /* ========================================================================
    04 — TOTAL
    ======================================================================== */

    SELECT
        40,
        1,
        'ROW_COUNT_TOTAL',
        NULL::bigint,
        (
            (SELECT COUNT(*) FROM ops.source_review_results)
            +
            (SELECT COUNT(*) FROM ops.source_verification_log)
        )::text
)

SELECT
    section,
    source_row_id,
    detail
FROM report
ORDER BY
    sort_group,
    sort_item,
    source_row_id;