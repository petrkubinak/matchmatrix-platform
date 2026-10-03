-- ============================================================
-- MATCHMATRIX
-- MM-G4D_4 STEP 11
-- HB 2024 PLANNER STATUS RECONCILIATION V1
--
-- CO:
-- Rozloží všech 211 HB 2024 planner jobů podle skutečného
-- statusu a zobrazí poslední změněné řádky.
--
-- K ČEMU:
-- Vysvětlit rozdíl:
-- před testem pending = 166
-- po jednom testovacím jobu pending = 155
--
-- KDE:
-- PostgreSQL / matchmatrix / DBeaver
--
-- JAK:
-- READ ONLY.
-- ============================================================


-- ------------------------------------------------------------
-- 1. PŘESNÉ ROZDĚLENÍ VŠECH STATUSŮ
-- ------------------------------------------------------------

SELECT
    p.status,
    COUNT(*) AS jobs,
    MIN(p.id) AS min_planner_id,
    MAX(p.id) AS max_planner_id,
    MIN(p.updated_at) AS oldest_update,
    MAX(p.updated_at) AS newest_update

FROM ops.ingest_planner p

WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures'
  AND p.run_group = 'HB_HISTORICAL_CORE_2022_2024'
  AND p.season = '2024'

GROUP BY p.status
ORDER BY p.status;


-- ------------------------------------------------------------
-- 2. POSLEDNÍ ZMĚNĚNÉ JOBY 2024
-- ------------------------------------------------------------

SELECT
    p.id,
    p.provider_league_id,
    p.season,
    p.priority,
    p.status,
    p.attempts,
    p.last_attempt,
    p.next_run,
    p.updated_at

FROM ops.ingest_planner p

WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures'
  AND p.run_group = 'HB_HISTORICAL_CORE_2022_2024'
  AND p.season = '2024'

ORDER BY p.updated_at DESC NULLS LAST, p.id DESC
LIMIT 30;


-- ------------------------------------------------------------
-- 3. JOBY ZMĚNĚNÉ DNES PO 14:45
-- ------------------------------------------------------------

SELECT
    p.id,
    p.provider_league_id,
    p.status,
    p.attempts,
    p.last_attempt,
    p.next_run,
    p.updated_at

FROM ops.ingest_planner p

WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures'
  AND p.run_group = 'HB_HISTORICAL_CORE_2022_2024'
  AND p.season = '2024'
  AND p.updated_at >= TIMESTAMPTZ '2026-09-30 14:45:00+02'

ORDER BY p.updated_at, p.id;