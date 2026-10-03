-- ============================================================
-- MATCHMATRIX
-- MM-G4D_4 STEP 2
-- HB PLANNER GOVERNANCE CLAIMABILITY PRECHECK V1
--
-- CO:
-- Porovná skutečnou HB planner frontu s ingest targety
-- a refresh policy bez násobení planner řádků JOINem.
--
-- K ČEMU:
-- Zjistit, kolik pending jobů je:
-- 1) claimable současným workerem,
-- 2) kryto enabled ingest targetem,
-- 3) kryto APPROVED refresh policy,
-- 4) současně bezpečně povoleno oběma governance vrstvami.
--
-- KDE:
-- PostgreSQL / matchmatrix / DBeaver
--
-- JAK:
-- READ ONLY.
-- Nic nemění.
-- ============================================================

WITH planner AS (
    SELECT
        p.id,
        p.provider,
        p.sport_code,
        p.entity,
        p.provider_league_id,
        p.season,
        p.run_group,
        p.attempts,
        p.next_run,

        (
            COALESCE(p.attempts, 0) < 3
            AND (
                p.next_run IS NULL
                OR p.next_run <= NOW()
            )
        ) AS worker_claimable

    FROM ops.ingest_planner p

    WHERE p.provider = 'api_handball'
      AND p.sport_code = 'HB'
      AND p.entity = 'fixtures'
      AND p.status = 'pending'
),

classified AS (
    SELECT
        p.*,

        /* ----------------------------------------------------
           EXISTUJE odpovídající povolený ingest target?
           ---------------------------------------------------- */
        EXISTS (
            SELECT 1
            FROM ops.ingest_targets t
            WHERE t.provider = p.provider
              AND t.sport_code = p.sport_code
              AND t.provider_league_id::text =
                  p.provider_league_id::text
              AND t.season::text =
                  p.season::text
              AND t.enabled IS TRUE
        ) AS has_enabled_target,

        /* ----------------------------------------------------
           EXISTUJE odpovídající APPROVED refresh policy
           navázaná na odpovídající ingest target?
           ---------------------------------------------------- */
        EXISTS (
            SELECT 1
            FROM ops.ingest_targets t
            JOIN ops.harvest_scope_refresh_policy r
              ON r.ingest_target_id = t.id
            WHERE t.provider = p.provider
              AND t.sport_code = p.sport_code
              AND t.provider_league_id::text =
                  p.provider_league_id::text
              AND t.season::text =
                  p.season::text
              AND r.entity = p.entity
              AND r.source_competition_key::text =
                  t.provider_league_id::text
              AND r.source_season_key::text =
                  t.season::text
              AND r.policy_status = 'APPROVED'
        ) AS has_approved_policy

    FROM planner p
)

SELECT
    season,

    COUNT(*) AS pending_jobs,

    COUNT(*) FILTER (
        WHERE worker_claimable
    ) AS worker_claimable_now,

    COUNT(*) FILTER (
        WHERE has_enabled_target
    ) AS enabled_target_jobs,

    COUNT(*) FILTER (
        WHERE has_approved_policy
    ) AS approved_policy_jobs,

    COUNT(*) FILTER (
        WHERE worker_claimable
          AND has_enabled_target
          AND has_approved_policy
    ) AS governance_allowed_claimable,

    COUNT(*) FILTER (
        WHERE worker_claimable
          AND NOT has_enabled_target
    ) AS worker_would_claim_disabled_target,

    COUNT(*) FILTER (
        WHERE worker_claimable
          AND NOT has_approved_policy
    ) AS worker_would_claim_without_approved_policy

FROM classified

GROUP BY season
ORDER BY season;