/*
CO:
  STEP 12O – VALIDATE_ONLY dopadu pozastavení HB 2024.

K ČEMU:
  Ověřit 110 pravidel, 55 targetů a 57 čekajících jobů.
  Potvrdit uloženou opravu jobu 8874 a auditů 1996/1997.

KDE:
  DBeaver / databáze matchmatrix na PC2.

JAK:
  Spustit celý dotaz. Pouze čtení.
*/

WITH policies AS (
    SELECT
        r.policy_id,
        r.ingest_target_id,
        r.source_competition_key,
        r.source_season_key,
        r.time_mode
    FROM ops.harvest_scope_refresh_policy r
    WHERE r.source_id = 18
      AND r.sport_code = 'HB'
      AND r.layer_type = 'CORE'
      AND r.entity = 'fixtures'
      AND r.source_season_key = '2024'
      AND r.time_mode IN (
          'HISTORY_FAN',
          'HISTORY_PREDICTION'
      )
      AND r.policy_status = 'DRAFT'
      AND r.refresh_mode = 'UNDECIDED'
),
bad_policy_pairs AS (
    SELECT ingest_target_id
    FROM policies
    GROUP BY ingest_target_id
    HAVING ingest_target_id IS NULL
        OR COUNT(*) <> 2
        OR COUNT(DISTINCT time_mode) <> 2
        OR COUNT(DISTINCT source_competition_key) <> 1
),
targets AS (
    SELECT
        t.id,
        t.provider_league_id,
        t.season,
        t.enabled
    FROM ops.ingest_targets t
    WHERE t.provider = 'api_handball'
      AND t.sport_code = 'HB'
      AND t.season = '2024'
      AND t.run_group = 'HB_CORE'
      AND EXISTS (
          SELECT 1
          FROM policies r
          WHERE r.ingest_target_id = t.id
            AND r.source_competition_key =
                t.provider_league_id
            AND r.source_season_key = t.season
      )
),
scope_jobs AS (
    SELECT p.*
    FROM ops.ingest_planner p
    WHERE p.provider = 'api_handball'
      AND p.sport_code = 'HB'
      AND p.entity = 'fixtures'
      AND p.season = '2024'
      AND EXISTS (
          SELECT 1
          FROM targets t
          WHERE t.provider_league_id = p.provider_league_id
            AND t.season = p.season
      )
),
metrics AS (
    SELECT
        current_database() AS database_name,

        (SELECT COUNT(*) FROM policies)
            AS policy_rows,

        (SELECT COUNT(*) FROM bad_policy_pairs)
            AS bad_policy_pairs,

        (SELECT COUNT(*) FROM targets)
            AS target_rows,

        (SELECT COUNT(*) FROM targets WHERE enabled)
            AS enabled_targets,

        (SELECT COUNT(*) FROM scope_jobs)
            AS planner_rows_2024,

        (SELECT COUNT(*) FROM scope_jobs
         WHERE status = 'pending')
            AS pending_to_block,

        (SELECT COUNT(DISTINCT provider_league_id)
         FROM scope_jobs WHERE status = 'pending')
            AS competitions_with_pending,

        (SELECT COUNT(*) FROM scope_jobs
         WHERE status = 'running')
            AS running_in_scope,

        (SELECT COUNT(*) FROM scope_jobs
         WHERE id = 8874 AND status = 'error')
            AS repaired_planner_rows,

        (SELECT COUNT(*)
         FROM ops.job_runs j
         WHERE j.id IN (1996, 1997)
           AND j.status = 'error'
           AND j.finished_at IS NOT NULL
           AND j.details -> 'orphan_run_recovery'
                         ->> 'script_prefix' = '27_2_93')
            AS repaired_audit_rows,

        (SELECT COUNT(*)
         FROM ops.ingest_planner p
         WHERE p.provider = 'api_handball'
           AND p.sport_code = 'HB'
           AND p.entity = 'fixtures'
           AND p.season IN ('2022', '2023')
           AND p.status = 'pending'
           AND EXISTS (
               SELECT 1
               FROM targets t
               WHERE t.provider_league_id =
                     p.provider_league_id
           ))
            AS older_pending_outside_change
)
SELECT
    CASE
        WHEN m.database_name = 'matchmatrix'
         AND m.policy_rows = 110
         AND m.bad_policy_pairs = 0
         AND m.target_rows = 55
         AND m.enabled_targets = 55
         AND m.planner_rows_2024 = 149
         AND m.pending_to_block = 57
         AND m.competitions_with_pending = 55
         AND m.running_in_scope = 0
         AND m.repaired_planner_rows = 1
         AND m.repaired_audit_rows = 2
        THEN 'VALIDATE_ONLY_PASS'
        ELSE 'STOP_REVIEW_REQUIRED'
    END AS check_status,
    m.*,
    (
        SELECT jsonb_agg(p.id ORDER BY p.id)
        FROM scope_jobs p
        WHERE p.status = 'pending'
    ) AS pending_job_ids
FROM metrics m;