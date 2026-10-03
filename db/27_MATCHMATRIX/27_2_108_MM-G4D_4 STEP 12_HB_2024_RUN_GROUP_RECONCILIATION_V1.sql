-- ============================================================
-- MATCHMATRIX
-- MM-G4D_4 STEP 12
-- HB 2024 RUN GROUP RECONCILIATION V1
--
-- CO:
-- Rozdělí všechny api_handball / HB / fixtures / 2024
-- planner joby podle run_group a statusu.
--
-- K ČEMU:
-- Definitivně vysvětlit rozdíl mezi:
--   STEP 4  = 166 pending bez run_group filtru
--   STEP 11 = 155 pending v HB_HISTORICAL_CORE_2022_2024
--
-- OČEKÁVÁNÍ:
-- Po jednom úspěšném jobu má být celkem 165 pending,
-- z toho 155 v HB_HISTORICAL_CORE_2022_2024
-- a 10 v jiném run_group.
--
-- KDE:
-- PostgreSQL / matchmatrix / DBeaver
--
-- JAK:
-- READ ONLY.
-- ============================================================

SELECT
    COALESCE(p.run_group, '<NULL>') AS run_group,
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
  AND p.season = '2024'
GROUP BY
    COALESCE(p.run_group, '<NULL>'),
    p.status
ORDER BY
    run_group,
    p.status;