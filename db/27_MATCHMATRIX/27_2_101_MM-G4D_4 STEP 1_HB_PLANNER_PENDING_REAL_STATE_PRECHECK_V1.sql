-- ============================================================
-- MATCHMATRIX
-- MM-G4D_4 STEP 1
-- HB PLANNER PENDING REAL STATE PRECHECK V1
--
-- CO:
-- Zjistí skutečný stav pending jobů přímo v ops.ingest_planner
-- bez JOINů na targety nebo refresh policy.
--
-- K ČEMU:
-- Ověřit skutečný počet planner jobů podle sezóny a zabránit
-- zkreslení způsobenému násobením řádků při JOINu.
--
-- KDE:
-- PostgreSQL / databáze matchmatrix / DBeaver
--
-- JAK:
-- READ ONLY. Skript nic nemění.
-- ============================================================

SELECT
    p.season,
    COUNT(*) AS pending_jobs,
    COUNT(*) FILTER (
        WHERE COALESCE(p.attempts, 0) < 3
          AND (
                p.next_run IS NULL
                OR p.next_run <= NOW()
              )
    ) AS claimable_now,
    MIN(p.id) AS min_planner_id,
    MAX(p.id) AS max_planner_id
FROM ops.ingest_planner p
WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures'
  AND p.status = 'pending'
GROUP BY p.season
ORDER BY p.season;