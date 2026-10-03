-- ============================================================
-- MATCHMATRIX
-- MM-G4D_4 STEP 20
-- HB 2024 GOVERNANCE GUARD FINAL POSTCHECK V1
--
-- CO:
-- Finální ověření HB historical fronty po dokončení všech
-- governance-allowed jobů sezóny 2024.
--
-- K ČEMU:
-- Potvrdit:
--   1) 2024 pending = 0,
--   2) 2024 done = 156,
--   3) 2024 blocked = 55,
--   4) poslední dávka 80 skončila bez warning/error,
--   5) 2022 a 2023 zůstaly zcela nedotčené.
--
-- KDE:
-- PostgreSQL / matchmatrix / DBeaver
--
-- JAK:
-- READ ONLY.
-- ============================================================


-- ------------------------------------------------------------
-- 1. FINÁLNÍ STAV HISTORICKÉ FRONTY 2022–2024
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
-- 2. AUDIT POSLEDNÍ DÁVKY 80
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS job_runs,
    COUNT(*) FILTER (WHERE jr.status = 'ok') AS ok,
    COUNT(*) FILTER (WHERE jr.status = 'warning') AS warning,
    COUNT(*) FILTER (WHERE jr.status = 'error') AS error,
    MIN(jr.started_at) AS first_started,
    MAX(jr.finished_at) AS last_finished
FROM ops.job_runs jr
WHERE jr.job_code = 'ingest_planner_worker'
  AND jr.started_at >= TIMESTAMPTZ '2026-09-30 15:31:00+02'
  AND jr.params ->> 'provider' = 'api_handball'
  AND jr.params ->> 'sport' = 'HB'
  AND jr.params ->> 'entity' = 'fixtures'
  AND jr.params ->> 'run_group' = 'HB_HISTORICAL_CORE_2022_2024';


-- ------------------------------------------------------------
-- 3. OCHRANA 2022/2023
-- ------------------------------------------------------------

SELECT
    p.season,
    COUNT(*) FILTER (WHERE p.status = 'pending') AS pending,
    COUNT(*) FILTER (WHERE p.status = 'running') AS running,
    COUNT(*) FILTER (WHERE p.status = 'done') AS done,
    COUNT(*) FILTER (WHERE p.status = 'error') AS error,
    COUNT(*) FILTER (
        WHERE p.last_attempt >= TIMESTAMPTZ '2026-09-30 15:31:00+02'
    ) AS touched_since_final_batches
FROM ops.ingest_planner p
WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures'
  AND p.run_group = 'HB_HISTORICAL_CORE_2022_2024'
  AND p.season IN ('2022', '2023')
GROUP BY
    p.season
ORDER BY
    p.season;


-- ------------------------------------------------------------
-- 4. FINÁLNÍ KONTROLA 2024 – MUSÍ BÝT BEZ PENDING/RUNNING/ERROR
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_2024,
    COUNT(*) FILTER (WHERE p.status = 'done') AS done,
    COUNT(*) FILTER (WHERE p.status = 'blocked') AS blocked,
    COUNT(*) FILTER (WHERE p.status = 'pending') AS pending,
    COUNT(*) FILTER (WHERE p.status = 'running') AS running,
    COUNT(*) FILTER (WHERE p.status = 'error') AS error
FROM ops.ingest_planner p
WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures'
  AND p.run_group = 'HB_HISTORICAL_CORE_2022_2024'
  AND p.season = '2024';