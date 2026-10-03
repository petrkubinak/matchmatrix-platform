/*
CO:
STEP 10Q – HARVEST COMPLETION PERSISTENCE + INTEGRITY SNAPSHOT

K ČEMU:
Po STEP 10P ověřit, že nový persistentní registr:

ops.harvest_scope_completion

je skutečně committed, má správný počet řádků,
správnou vazbu na 211 HB targetů a neporušil žádnou
governance hranici.

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. TABULKA EXISTUJE
   ========================================================= */

SELECT
    to_regclass(
        'ops.harvest_scope_completion'
    ) AS harvest_completion_registry;


/* =========================================================
   2. ROW-LEVEL STATUS
   ========================================================= */

SELECT
    completion_status,
    COUNT(*) AS rows_count,

    COUNT(DISTINCT ingest_target_id)
        AS distinct_targets,

    COALESCE(SUM(merged_count), 0)
        AS merged_count_sum

FROM ops.harvest_scope_completion

GROUP BY completion_status

ORDER BY completion_status;


/* =========================================================
   3. TIME MODE DISTRIBUCE
   ========================================================= */

SELECT
    time_mode,
    completion_status,
    COUNT(*) AS rows_count

FROM ops.harvest_scope_completion

GROUP BY
    time_mode,
    completion_status

ORDER BY
    time_mode,
    completion_status;


/* =========================================================
   4. TARGET-LEVEL STATUS

   Každý target musí mít přesně:
   HISTORY_FAN
   HISTORY_PREDICTION
   ========================================================= */

WITH target_status AS
(
    SELECT
        ingest_target_id,

        COUNT(*) AS rows_per_target,

        COUNT(DISTINCT time_mode)
            AS distinct_time_modes,

        CASE
            WHEN bool_and(
                completion_status = 'COMPLETE'
            )
                THEN 'COMPLETE'

            WHEN bool_and(
                completion_status = 'NOT_STARTED'
            )
                THEN 'NOT_STARTED'

            ELSE 'PARTIAL'
        END AS target_status

    FROM ops.harvest_scope_completion

    GROUP BY ingest_target_id
)

SELECT
    target_status,

    COUNT(*) AS targets,

    COUNT(*) FILTER (
        WHERE rows_per_target <> 2
    ) AS bad_row_count_targets,

    COUNT(*) FILTER (
        WHERE distinct_time_modes <> 2
    ) AS bad_time_mode_targets

FROM target_status

GROUP BY target_status

ORDER BY target_status;


/* =========================================================
   5. COMPLETE ROWS – MUSÍ BÝT PLNĚ DOLOŽENÉ
   ========================================================= */

SELECT
    completion_id,
    time_mode,

    canonical_league_id,
    source_competition_key,
    source_season_key,

    expected_count,
    source_observed_count,
    merged_count,

    verification_status,

    scope_coverage_id,
    audit_evidence_id,

    completed_at,
    verified_at

FROM ops.harvest_scope_completion

WHERE completion_status = 'COMPLETE'

ORDER BY
    source_competition_key::integer,
    time_mode;


/* =========================================================
   6. COMPLETE INTEGRITY
   ========================================================= */

SELECT
    COUNT(*) AS complete_rows,

    COUNT(*) FILTER (
        WHERE expected_count IS NULL
           OR source_observed_count IS NULL
           OR merged_count IS NULL
    ) AS missing_counts,

    COUNT(*) FILTER (
        WHERE expected_count <> source_observed_count
           OR source_observed_count <> merged_count
    ) AS count_mismatch,

    COUNT(*) FILTER (
        WHERE verification_status <> 'RECONCILED'
    ) AS bad_verification,

    COUNT(*) FILTER (
        WHERE scope_coverage_id IS NULL
    ) AS missing_scope_coverage,

    COUNT(*) FILTER (
        WHERE audit_evidence_id IS NULL
    ) AS missing_evidence,

    COUNT(*) FILTER (
        WHERE completed_at IS NULL
           OR verified_at IS NULL
    ) AS missing_completion_timestamp

FROM ops.harvest_scope_completion

WHERE completion_status = 'COMPLETE';


/* =========================================================
   7. PARTIAL INTEGRITY
   ========================================================= */

SELECT
    COUNT(*) AS partial_rows,

    COUNT(*) FILTER (
        WHERE merged_count IS NULL
           OR merged_count <= 0
    ) AS partial_without_stored_data,

    COUNT(*) FILTER (
        WHERE completion_status = 'PARTIAL'
          AND verification_status <> 'UNVERIFIED'
    ) AS unexpected_verification

FROM ops.harvest_scope_completion

WHERE completion_status = 'PARTIAL';


/* =========================================================
   8. NOT_STARTED INTEGRITY
   ========================================================= */

SELECT
    COUNT(*) AS not_started_rows,

    COUNT(*) FILTER (
        WHERE COALESCE(harvested_count, 0) <> 0
           OR COALESCE(parsed_count, 0) <> 0
           OR COALESCE(merged_count, 0) <> 0
    ) AS rows_with_data,

    COUNT(*) FILTER (
        WHERE completed_at IS NOT NULL
    ) AS rows_with_completed_at

FROM ops.harvest_scope_completion

WHERE completion_status = 'NOT_STARTED';


/* =========================================================
   9. DATASET IDENTITY DUPLICITY
   ========================================================= */

SELECT
    source_id,
    sport_code,
    layer_type,
    entity,
    time_mode,
    scope_key,
    COUNT(*) AS rows_count

FROM ops.harvest_scope_completion

GROUP BY
    source_id,
    sport_code,
    layer_type,
    entity,
    time_mode,
    scope_key

HAVING COUNT(*) > 1

ORDER BY rows_count DESC;


/* =========================================================
   10. CELKOVÝ SNAPSHOT
   ========================================================= */

SELECT

    (SELECT COUNT(*)
     FROM ops.harvest_scope_completion)
        AS completion_rows,

    (SELECT COUNT(DISTINCT ingest_target_id)
     FROM ops.harvest_scope_completion)
        AS completion_targets,

    (SELECT COUNT(*)
     FROM ops.harvest_scope_completion
     WHERE completion_status = 'COMPLETE')
        AS complete_rows,

    (SELECT COUNT(*)
     FROM ops.harvest_scope_completion
     WHERE completion_status = 'PARTIAL')
        AS partial_rows,

    (SELECT COUNT(*)
     FROM ops.harvest_scope_completion
     WHERE completion_status = 'NOT_STARTED')
        AS not_started_rows,

    (SELECT COUNT(*)
     FROM ops.harvest_scope_completion
     WHERE scope_coverage_id IS NOT NULL)
        AS linked_exact_coverage_rows,

    (SELECT COUNT(*)
     FROM ops.harvest_scope_completion
     WHERE audit_evidence_id IS NOT NULL)
        AS linked_evidence_rows,

    (SELECT COUNT(*)
     FROM ops.source_entity_time_coverage
     WHERE source_id = 18
       AND coverage_status = 'CONFIRMED')
        AS parent_confirmed,

    (SELECT COUNT(*)
     FROM ops.source_adapter_binding
     WHERE source_id = 18
       AND is_active = true)
        AS active_bindings,

    (SELECT COUNT(*)
     FROM ops.data_acquisition_source_routing
     WHERE source_id = 18)
        AS routes;