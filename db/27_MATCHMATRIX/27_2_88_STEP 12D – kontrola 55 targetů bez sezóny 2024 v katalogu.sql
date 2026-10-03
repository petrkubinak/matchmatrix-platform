-- CO: STEP 12D – kontrola 55 targetů bez sezóny 2024 v katalogu
-- K ČEMU: Ověřit uložená data a dovolené stavy zbývajících pravidel
-- KDE: DBeaver, databáze matchmatrix na PC2
-- JAK: Spustit celý dotaz; nic nezapisuje

WITH held(id) AS (
    SELECT unnest(ARRAY[
        5003,5009,5016,5017,5051,5063,5064,4887,4888,4892,4895,
        4921,4924,4925,4927,4932,4933,4937,4939,4940,4941,4942,
        4945,4946,4948,4950,4951,4952,4953,4954,4956,4957,4958,
        4959,4961,4962,4963,4964,4965,4966,4967,4969,4970,4972,
        4974,4978,4979,4983,4993,4997,4998,4999,5004,5005,5006
    ]::bigint[])
),
per_target AS (
    SELECT
        h.id,
        count(c.completion_id) AS completion_rows,
        count(DISTINCT c.time_mode) AS modes,
        bool_and(c.completion_status = 'NOT_STARTED') AS all_not_started,
        coalesce(sum(c.merged_count), 0) AS merged_mode_sum
    FROM held AS h
    LEFT JOIN ops.harvest_scope_completion AS c
        ON c.ingest_target_id = h.id
    GROUP BY h.id
)
SELECT
    count(*) AS targetu,
    count(*) FILTER (
        WHERE completion_rows = 2
          AND modes = 2
          AND all_not_started IS TRUE
          AND merged_mode_sum = 0
    ) AS bez_ulozenych_zapasu,
    array_agg(id ORDER BY id) FILTER (
        WHERE (
            completion_rows = 2
            AND modes = 2
            AND all_not_started IS TRUE
            AND merged_mode_sum = 0
        ) IS NOT TRUE
    ) AS targety_k_dalsimu_provereni,
    (
        SELECT string_agg(
            pc.conname || ': ' || pg_get_constraintdef(pc.oid),
            E'\n' ORDER BY pc.conname
        )
        FROM pg_constraint AS pc
        WHERE pc.conrelid =
              'ops.harvest_scope_refresh_policy'::regclass
          AND pc.contype = 'c'
          AND (
              pg_get_constraintdef(pc.oid) ILIKE '%policy_status%'
              OR pg_get_constraintdef(pc.oid) ILIKE '%refresh_mode%'
          )
    ) AS dovolene_stavy_pravidel
FROM per_target;