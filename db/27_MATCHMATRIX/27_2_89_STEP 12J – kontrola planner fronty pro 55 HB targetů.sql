-- CO: STEP 12J – kontrola planner fronty pro 55 HB targetů.
-- K ČEMU: Zjistit stav jobů pro targety s DRAFT/UNDECIDED policy.
-- KDE: PostgreSQL matchmatrix na PC2, například DBeaver.
-- JAK: Spustit celý tento jediný SELECT a poslat výsledek.

WITH held_ids AS (
    SELECT r.ingest_target_id
    FROM ops.harvest_scope_refresh_policy AS r
    WHERE r.source_id = 18
      AND r.sport_code = 'HB'
      AND r.layer_type = 'CORE'
      AND r.entity = 'fixtures'
      AND r.policy_status = 'DRAFT'
      AND r.refresh_mode = 'UNDECIDED'
      AND r.ingest_target_id IS NOT NULL
    GROUP BY r.ingest_target_id
    HAVING COUNT(*) = 2
       AND COUNT(DISTINCT r.time_mode) = 2
),
held_targets AS (
    SELECT
        t.id AS target_id,
        t.provider_league_id,
        t.season
    FROM held_ids AS h
    JOIN ops.ingest_targets AS t
      ON t.id = h.ingest_target_id
)
SELECT
    CASE WHEN GROUPING(h.target_id) = 1
         THEN 'CELKEM'
         ELSE h.target_id::text
    END AS radek,
    h.provider_league_id,
    h.season AS target_season,
    COUNT(DISTINCT h.target_id) AS targetu,
    COUNT(p.id) AS jobu_celkem,
    COUNT(p.id) FILTER (WHERE p.status = 'pending') AS pending,
    COUNT(p.id) FILTER (
        WHERE p.status = 'pending'
          AND p.season::text = h.season::text
    ) AS pending_pro_target_season,
    COUNT(p.id) FILTER (
        WHERE p.status = 'pending'
          AND p.season::text IS DISTINCT FROM h.season::text
    ) AS pending_jine_sezony,
    COUNT(p.id) FILTER (
        WHERE p.status = 'pending'
          AND COALESCE(p.attempts, 0) < 3
          AND (p.next_run IS NULL OR p.next_run <= NOW())
    ) AS pending_pripraveno_dle_vychoziho_limitu,
    COUNT(p.id) FILTER (WHERE p.status = 'running') AS running,
    COUNT(p.id) FILTER (WHERE p.status = 'done') AS done,
    COUNT(p.id) FILTER (WHERE p.status = 'error') AS error,
    STRING_AGG(
        DISTINCT p.season::text, ', '
        ORDER BY p.season::text
    ) AS sezony_ve_fronte
FROM held_targets AS h
LEFT JOIN ops.ingest_planner AS p
  ON p.provider = 'api_handball'
 AND p.sport_code = 'HB'
 AND p.entity = 'fixtures'
 AND p.provider_league_id::text = h.provider_league_id::text
GROUP BY GROUPING SETS (
    (h.target_id, h.provider_league_id, h.season),
    ()
)
ORDER BY GROUPING(h.target_id) DESC, h.provider_league_id;