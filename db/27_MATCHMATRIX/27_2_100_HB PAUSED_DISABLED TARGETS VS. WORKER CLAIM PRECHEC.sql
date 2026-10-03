-- ============================================================
-- MATCHMATRIX
-- HB PAUSED/DISABLED TARGETS VS. WORKER CLAIM PRECHECK
-- READ ONLY
--
-- CO:
-- Ověří pending api_handball / HB / fixtures joby,
-- které by současný run_ingest_planner_jobs.py mohl převzít.
--
-- K ČEMU:
-- Zjistit, zda worker může spustit job přesto,
-- že jeho ingest target je disabled nebo refresh policy PAUSED.
--
-- BEZ ZMĚN DAT.
-- ============================================================

SELECT
    p.season,
    t.enabled AS target_enabled,
    r.policy_status,
    r.refresh_mode,

    COUNT(*) AS planner_jobs,

    COUNT(*) FILTER (
        WHERE COALESCE(p.attempts, 0) < 3
          AND (
                p.next_run IS NULL
                OR p.next_run <= NOW()
              )
    ) AS claimable_now

FROM ops.ingest_planner p

JOIN ops.ingest_targets t
  ON t.provider = p.provider
 AND t.sport_code = p.sport_code
 AND t.provider_league_id::text = p.provider_league_id::text
 AND t.season::text = p.season::text

LEFT JOIN ops.harvest_scope_refresh_policy r
  ON r.ingest_target_id = t.id
 AND r.entity = p.entity
 AND r.source_competition_key::text = t.provider_league_id::text
 AND r.source_season_key::text = t.season::text

WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures'
  AND p.status = 'pending'

GROUP BY
    p.season,
    t.enabled,
    r.policy_status,
    r.refresh_mode

ORDER BY
    p.season,
    t.enabled,
    r.policy_status,
    r.refresh_mode;