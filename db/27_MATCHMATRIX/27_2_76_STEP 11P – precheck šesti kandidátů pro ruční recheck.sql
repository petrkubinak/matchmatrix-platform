-- CO: STEP 11P – precheck šesti kandidátů pro ruční recheck
-- K ČEMU: Ověřit 12 návrhů politik po dvojicích na šest fyzických targetů.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz.

WITH candidates AS (
    SELECT
        p.policy_id,
        p.ingest_target_id,
        p.scope_key,
        p.time_mode,
        p.policy_status,
        p.refresh_mode,
        h.verification_status,
        h.expected_count,
        h.merged_count,
        sc.scope_coverage_id,
        sc.scope_status
    FROM ops.harvest_scope_refresh_policy p
    JOIN ops.harvest_scope_completion h
        ON h.source_id = p.source_id
       AND h.sport_code = p.sport_code
       AND h.layer_type = p.layer_type
       AND h.entity = p.entity
       AND h.time_mode = p.time_mode
       AND h.scope_key = p.scope_key
    LEFT JOIN ops.source_entity_time_scope_coverage sc
        ON sc.scope_coverage_id = p.scope_coverage_id
    WHERE p.source_id = 18
      AND p.sport_code = 'HB'
      AND p.layer_type = 'CORE'
      AND p.entity = 'fixtures'
      AND p.time_mode IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
      AND h.completion_status = 'COMPLETE'
),
pairs AS (
    SELECT
        ingest_target_id,
        scope_key,
        count(*) AS policy_rows,
        count(DISTINCT time_mode) AS distinct_modes,
        bool_or(time_mode = 'HISTORY_FAN') AS has_fan,
        bool_or(time_mode = 'HISTORY_PREDICTION') AS has_prediction,
        bool_and(
            policy_status = 'DRAFT'
            AND refresh_mode = 'UNDECIDED'
            AND verification_status IN ('COUNT_MATCH', 'RECONCILED')
            AND expected_count = merged_count
            AND scope_coverage_id IS NOT NULL
            AND scope_status = 'CONFIRMED'
        ) AS evidence_ok
    FROM candidates
    GROUP BY ingest_target_id, scope_key
),
audit AS (
    SELECT
        count(*) AS target_pairs,
        coalesce(sum(policy_rows), 0) AS policy_rows,
        count(*) FILTER (
            WHERE policy_rows = 2
              AND distinct_modes = 2
              AND has_fan
              AND has_prediction
              AND evidence_ok IS TRUE
        ) AS ready_pairs
    FROM pairs
)
SELECT *,
       CASE
           WHEN target_pairs = 6
            AND policy_rows = 12
            AND ready_pairs = 6
           THEN 'PASS'
           ELSE 'REVIEW'
       END AS audit_result
FROM audit;
