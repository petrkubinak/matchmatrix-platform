-- CO: STEP 12B – kontrola pravidel před hromadným schválením
-- K ČEMU: Ověřit 12 již schválených, 300 navržených a 110 k prověření
-- KDE: DBeaver, databáze matchmatrix na PC2
-- JAK: Spustit celý dotaz a poslat výsledek; pouze čtení

WITH excluded_targets AS (
    SELECT unnest(ARRAY[
        5003,5009,5016,5017,5051,5063,5064,4887,4888,4892,4895,
        4921,4924,4925,4927,4932,4933,4937,4939,4940,4941,4942,
        4945,4946,4948,4950,4951,4952,4953,4954,4956,4957,4958,
        4959,4961,4962,4963,4964,4965,4966,4967,4969,4970,4972,
        4974,4978,4979,4983,4993,4997,4998,4999,5004,5005,5006
    ]::bigint[]) AS ingest_target_id
),
classified AS (
    SELECT
        p.policy_id,
        p.ingest_target_id,
        p.time_mode,
        p.policy_status,
        p.refresh_mode,
        CASE
            WHEN t.id IS NULL
              OR p.source_id IS DISTINCT FROM 18
              OR p.sport_code IS DISTINCT FROM 'HB'
              OR p.layer_type IS DISTINCT FROM 'CORE'
              OR p.entity IS DISTINCT FROM 'fixtures'
              OR p.scope_type IS DISTINCT FROM 'COMPETITION_SEASON'
              OR p.time_mode NOT IN ('HISTORY_FAN', 'HISTORY_PREDICTION')
              OR t.provider IS DISTINCT FROM 'api_handball'
              OR t.season::text IS DISTINCT FROM '2024'
                THEN 'MIMO_SCOPE'
            WHEN p.ingest_target_id IN (5020,4890,4872,4882,4943,4944)
                THEN '12_JIZ_SCHVALENO'
            WHEN e.ingest_target_id IS NOT NULL
                THEN '110_PROVERIT_SEZONU'
            ELSE '300_NAVRH_MANUAL'
        END AS skupina
    FROM ops.harvest_scope_refresh_policy AS p
    LEFT JOIN ops.ingest_targets AS t
        ON t.id = p.ingest_target_id
    LEFT JOIN excluded_targets AS e
        ON e.ingest_target_id = p.ingest_target_id
),
target_map AS (
    SELECT DISTINCT
        t.id,
        t.provider_league_id,
        t.canonical_league_id
    FROM ops.harvest_scope_refresh_policy AS p
    JOIN ops.ingest_targets AS t
        ON t.id = p.ingest_target_id
),
map_audit AS (
    SELECT
        count(*) AS pocet_targetu,
        md5(string_agg(
            id::text || ':' ||
            provider_league_id::text || ':' ||
            canonical_league_id::text,
            ',' ORDER BY id
        )) = '6ef6119c436655559822f685a43ea8f4' AS mapa_sedi
    FROM target_map
)
SELECT
    c.skupina,
    c.policy_status,
    c.refresh_mode,
    count(*) AS pravidel,
    count(DISTINCT c.ingest_target_id) AS targetu,
    count(DISTINCT c.time_mode) AS rezimu,
    m.pocet_targetu,
    m.mapa_sedi
FROM classified AS c
CROSS JOIN map_audit AS m
GROUP BY c.skupina, c.policy_status, c.refresh_mode,
         m.pocet_targetu, m.mapa_sedi
ORDER BY c.skupina, c.policy_status, c.refresh_mode;