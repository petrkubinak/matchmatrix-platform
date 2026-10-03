-- CO: Precheck vratného pozastavení 167 HB jobů.
-- K ČEMU: Ověřit přesný rozsah a původní hodnoty next_run.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Spustit tento jediný SELECT a poslat výsledek.

WITH held_targets AS (
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
candidate_jobs AS (
    SELECT
        t.id AS target_id,
        p.id AS job_id,
        p.season::text AS season,
        p.run_group,
        p.next_run,
        p.attempts
    FROM held_targets AS h
    JOIN ops.ingest_targets AS t
      ON t.id = h.ingest_target_id
    JOIN ops.ingest_planner AS p
      ON p.provider = 'api_handball'
     AND p.sport_code = 'HB'
     AND p.entity = 'fixtures'
     AND p.provider_league_id::text = t.provider_league_id::text
     AND p.status = 'pending'
)
SELECT
    CASE WHEN GROUPING(season) = 1 THEN 'CELKEM' ELSE season END AS season,
    CASE WHEN GROUPING(run_group) = 1 THEN 'CELKEM' ELSE run_group END AS run_group,
    COUNT(*) AS pending_jobu,
    COUNT(DISTINCT target_id) AS targetu,
    COUNT(*) FILTER (WHERE next_run IS NULL) AS next_run_null,
    COUNT(*) FILTER (WHERE next_run IS NOT NULL) AS next_run_vyplneno,
    MIN(next_run) AS nejblizsi_next_run,
    MAX(next_run) AS nejvzdalenejsi_next_run,
    COUNT(*) FILTER (WHERE COALESCE(attempts, 0) >= 3) AS pokusy_na_vychozim_limitu
FROM candidate_jobs
GROUP BY GROUPING SETS ((season, run_group), ())
ORDER BY GROUPING(season) DESC, season, run_group;