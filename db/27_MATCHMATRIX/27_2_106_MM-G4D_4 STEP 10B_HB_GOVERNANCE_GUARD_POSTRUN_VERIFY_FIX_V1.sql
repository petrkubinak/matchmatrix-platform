-- ============================================================
-- MATCHMATRIX
-- MM-G4D_4 STEP 10B
-- HB GOVERNANCE GUARD POSTRUN VERIFY FIX V1
--
-- CO:
-- Ověří databázový stav po prvním skutečném běhu
-- workeru s HB Governance Guard.
--
-- OPRAVA:
-- ops.ingest_planner.season je TEXT.
-- Porovnání sezón proto používá textové hodnoty.
--
-- K ČEMU:
-- Potvrdit, že:
--   1) planner_id 7304 přešel korektně do DONE,
--   2) 2022 a 2023 zůstaly nedotčené,
--   3) 2024 má po jednom úspěšném jobu o jeden pending méně,
--   4) vznikl korektní auditní záznam v ops.job_runs.
--
-- KDE:
-- PostgreSQL / matchmatrix / DBeaver
--
-- JAK:
-- READ ONLY.
-- ============================================================


-- ------------------------------------------------------------
-- 1. SOUHRN PLANNER FRONTY PODLE SEZÓNY
-- ------------------------------------------------------------

SELECT
    p.season,

    COUNT(*) AS total_jobs,

    COUNT(*) FILTER (
        WHERE p.status = 'pending'
    ) AS pending,

    COUNT(*) FILTER (
        WHERE p.status = 'running'
    ) AS running,

    COUNT(*) FILTER (
        WHERE p.status = 'done'
    ) AS done,

    COUNT(*) FILTER (
        WHERE p.status = 'error'
    ) AS error,

    COUNT(*) FILTER (
        WHERE p.status = 'pending'
          AND COALESCE(p.attempts, 0) < 3
          AND (
                p.next_run IS NULL
                OR p.next_run <= NOW()
              )
    ) AS base_claimable_now

FROM ops.ingest_planner p

WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures'
  AND p.run_group = 'HB_HISTORICAL_CORE_2022_2024'
  AND p.season IN ('2022', '2023', '2024')

GROUP BY p.season
ORDER BY p.season;


-- ------------------------------------------------------------
-- 2. DETAIL PRVNÍHO SKUTEČNĚ ZPRACOVANÉHO JOBU
-- ------------------------------------------------------------

SELECT
    p.id,
    p.provider,
    p.sport_code,
    p.entity,
    p.provider_league_id,
    p.season,
    p.run_group,
    p.priority,
    p.status,
    p.attempts,
    p.last_attempt,
    p.next_run,
    p.updated_at

FROM ops.ingest_planner p

WHERE p.id = 7304;


-- ------------------------------------------------------------
-- 3. AUDIT V OPS.JOB_RUNS
-- ------------------------------------------------------------

SELECT
    jr.id,
    jr.job_code,
    jr.started_at,
    jr.finished_at,
    jr.status,
    jr.message,
    jr.rows_affected,
    jr.params ->> 'planner_id' AS planner_id,
    jr.params ->> 'provider' AS provider,
    jr.params ->> 'sport' AS sport,
    jr.params ->> 'entity' AS entity,
    jr.params ->> 'season' AS season

FROM ops.job_runs jr

WHERE jr.job_code = 'ingest_planner_worker'
  AND jr.params ->> 'planner_id' = '7304'

ORDER BY jr.id DESC
LIMIT 5;