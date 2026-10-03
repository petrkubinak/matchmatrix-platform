-- ============================================================
-- MATCHMATRIX
-- MM-G4D_4 STEP 4
-- HB WORKER GOVERNANCE GUARD PRECHECK V1
--
-- CO:
-- Simuluje novou claim logiku workeru pro
-- api_handball / HB / fixtures bez změny dat.
--
-- K ČEMU:
-- Ověřit, že nový governance guard:
--   - zablokuje HB 2022,
--   - zablokuje HB 2023,
--   - povolí HB 2024.
--
-- KDE:
-- PostgreSQL / matchmatrix / DBeaver
--
-- JAK:
-- READ ONLY.
-- Nic nemění a nespouští žádný harvest.
-- ============================================================

WITH planner AS (
    SELECT
        p.id,
        p.provider,
        p.sport_code,
        p.entity,
        p.provider_league_id,
        p.season,
        p.priority,
        p.attempts,
        p.next_run,

        (
            COALESCE(p.attempts, 0) < 3
            AND (
                p.next_run IS NULL
                OR p.next_run <= NOW()
            )
        ) AS base_claimable

    FROM ops.ingest_planner p

    WHERE p.provider = 'api_handball'
      AND p.sport_code = 'HB'
      AND p.entity = 'fixtures'
      AND p.status = 'pending'
),

guard_check AS (
    SELECT
        p.*,

        (
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
            )

            AND

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
                  AND t.enabled IS TRUE
                  AND r.entity = p.entity
                  AND r.source_competition_key::text =
                      t.provider_league_id::text
                  AND r.source_season_key::text =
                      t.season::text
                  AND r.policy_status = 'APPROVED'
            )
        ) AS governance_guard_allows

    FROM planner p
)

SELECT
    season,

    COUNT(*) AS pending_jobs,

    COUNT(*) FILTER (
        WHERE base_claimable
    ) AS claimable_without_guard,

    COUNT(*) FILTER (
        WHERE base_claimable
          AND governance_guard_allows
    ) AS claimable_with_guard,

    COUNT(*) FILTER (
        WHERE base_claimable
          AND NOT governance_guard_allows
    ) AS blocked_by_guard,

    MIN(id) FILTER (
        WHERE base_claimable
          AND governance_guard_allows
    ) AS next_allowed_planner_id

FROM guard_check

GROUP BY season
ORDER BY season;