-- ============================================================
-- MATCHMATRIX
-- MM-G4D_4 STEP 14
-- HB GOVERNANCE GUARD BATCH5 POSTCHECK V1
--
-- CO:
-- Ověří databázový stav po kontrolované dávce 5 jobů.
--
-- K ČEMU:
-- Potvrdit:
--   1) všech 5 planner jobů přešlo do DONE,
--   2) vzniklo 5 OK auditních job_runs,
--   3) HB historical 2024 má 150 pending a 6 done,
--   4) 2022/2023 zůstaly nedotčené.
--
-- KDE:
-- PostgreSQL / matchmatrix / DBeaver
--
-- JAK:
-- READ ONLY.
-- ============================================================


-- ------------------------------------------------------------
-- 1. STAV HISTORICKÉ FRONTY 2022–2024
-- ------------------------------------------------------------

SELECT
    p.season,
    p.status,
    COUNT(*) AS jobs
FROM ops.ingest_planner p
WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures'
  AND p.run_group = 'HB_HISTORICAL_CORE_2022_2024'
  AND p.season IN ('2022', '2023', '2024')
GROUP BY
    p.season,
    p.status
ORDER BY
    p.season,
    p.status;


-- ------------------------------------------------------------
-- 2. DETAIL PĚTI NOVĚ ZPRACOVANÝCH JOBŮ
-- ------------------------------------------------------------

SELECT
    p.id,
    p.provider_league_id,
    p.season,
    p.run_group,
    p.status,
    p.attempts,
    p.last_attempt,
    p.next_run,
    p.updated_at
FROM ops.ingest_planner p
WHERE p.id IN (7310, 7326, 7332, 7336, 7341)
ORDER BY p.id;


-- ------------------------------------------------------------
-- 3. JOB_RUNS AUDIT PRO TĚCHTO 5 JOBŮ
-- ------------------------------------------------------------

SELECT
    jr.id AS job_run_id,
    jr.status,
    jr.message,
    jr.rows_affected,
    jr.started_at,
    jr.finished_at,
    jr.params ->> 'planner_id' AS planner_id,
    jr.params ->> 'season' AS season,
    jr.params ->> 'provider_league_id' AS provider_league_id
FROM ops.job_runs jr
WHERE jr.job_code = 'ingest_planner_worker'
  AND jr.params ->> 'planner_id'
      IN ('7310', '7326', '7332', '7336', '7341')
ORDER BY jr.id;


-- ------------------------------------------------------------
-- 4. BEZPEČNOSTNÍ KONTROLA 2022/2023
-- ------------------------------------------------------------

SELECT
    p.season,
    COUNT(*) FILTER (WHERE p.status = 'pending') AS pending,
    COUNT(*) FILTER (WHERE p.status = 'running') AS running,
    COUNT(*) FILTER (WHERE p.status = 'done') AS done,
    COUNT(*) FILTER (WHERE p.status = 'error') AS error,
    COUNT(*) FILTER (
        WHERE p.last_attempt >= TIMESTAMPTZ '2026-09-30 15:18:00+02'
    ) AS touched_since_batch5
FROM ops.ingest_planner p
WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures'
  AND p.run_group = 'HB_HISTORICAL_CORE_2022_2024'
  AND p.season IN ('2022', '2023')
GROUP BY p.season
ORDER BY p.season;