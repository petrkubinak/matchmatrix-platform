-- ============================================================
-- MATCHMATRIX
-- MM-G4D_4 STEP 16
-- HB GOVERNANCE GUARD BATCH20 POSTCHECK V1
--
-- CO:
-- Ověří stav planner fronty po kontrolované dávce 20 jobů.
--
-- K ČEMU:
-- Potvrdit:
--   1) 2022 a 2023 zůstaly nedotčené,
--   2) 2024 má po celkem 26 úspěšných jobech správný stav,
--   3) během poslední dávky nevznikl error/running stav,
--   4) job_runs obsahují 20 nových OK auditních záznamů.
--
-- KDE:
-- PostgreSQL / matchmatrix / DBeaver
--
-- JAK:
-- READ ONLY.
-- ============================================================


-- 1. STAV HISTORICKÉ FRONTY
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
GROUP BY p.season, p.status
ORDER BY p.season, p.status;


-- 2. BEZPEČNOSTNÍ KONTROLA 2022/2023
SELECT
    p.season,
    COUNT(*) FILTER (WHERE p.status = 'pending') AS pending,
    COUNT(*) FILTER (WHERE p.status = 'running') AS running,
    COUNT(*) FILTER (WHERE p.status = 'done') AS done,
    COUNT(*) FILTER (WHERE p.status = 'error') AS error,
    COUNT(*) FILTER (
        WHERE p.last_attempt >= TIMESTAMPTZ '2026-09-30 15:24:00+02'
    ) AS touched_since_batch20
FROM ops.ingest_planner p
WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures'
  AND p.run_group = 'HB_HISTORICAL_CORE_2022_2024'
  AND p.season IN ('2022', '2023')
GROUP BY p.season
ORDER BY p.season;


-- 3. AUDIT POSLEDNÍ DÁVKY 20 JOBŮ
SELECT
    COUNT(*) AS job_runs,
    COUNT(*) FILTER (WHERE jr.status = 'ok') AS ok,
    COUNT(*) FILTER (WHERE jr.status = 'warning') AS warning,
    COUNT(*) FILTER (WHERE jr.status = 'error') AS error,
    MIN(jr.started_at) AS first_started,
    MAX(jr.finished_at) AS last_finished
FROM ops.job_runs jr
WHERE jr.job_code = 'ingest_planner_worker'
  AND jr.started_at >= TIMESTAMPTZ '2026-09-30 15:24:00+02'
  AND jr.params ->> 'provider' = 'api_handball'
  AND jr.params ->> 'sport' = 'HB'
  AND jr.params ->> 'entity' = 'fixtures'
  AND jr.params ->> 'run_group' = 'HB_HISTORICAL_CORE_2022_2024';