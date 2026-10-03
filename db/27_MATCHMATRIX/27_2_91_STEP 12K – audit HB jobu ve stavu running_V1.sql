/*
CO:
  STEP 12K – audit HB jobu vedeného jako running.

K ČEMU:
  Zobrazit posledních pět auditních běhů tohoto jobu
  před rozhodnutím o dalším zacházení s frontou.

KDE:
  DBeaver / databáze matchmatrix na PC2.

JAK:
  Spustit celý dotaz. Pouze čtení.
*/

WITH selected_targets AS (
    SELECT DISTINCT
        source_competition_key,
        source_season_key
    FROM ops.harvest_scope_refresh_policy
    WHERE source_id = 18
      AND sport_code = 'HB'
      AND layer_type = 'CORE'
      AND entity = 'fixtures'
      AND source_season_key = '2024'
      AND time_mode IN (
          'HISTORY_FAN',
          'HISTORY_PREDICTION'
      )
      AND policy_status = 'DRAFT'
      AND refresh_mode = 'UNDECIDED'
      AND ingest_target_id IS NOT NULL
)
SELECT
    p.id AS planner_id,
    p.provider_league_id,
    p.season,
    p.run_group,
    p.status AS planner_status,
    p.attempts,
    p.last_attempt,
    p.updated_at AS planner_updated_at,

    r.id AS job_run_id,
    r.job_code,
    r.started_at,
    r.finished_at,
    r.status AS job_run_status,
    r.message,

    r.details ->> 'result' AS child_result,
    r.details ->> 'returncode' AS child_returncode,
    r.details ->> 'timed_out' AS child_timed_out,
    RIGHT(
        r.details ->> 'output_text',
        5000
    ) AS output_tail

FROM ops.ingest_planner p

LEFT JOIN LATERAL (
    SELECT
        j.id,
        j.job_code,
        j.started_at,
        j.finished_at,
        j.status,
        j.message,
        j.details
    FROM ops.job_runs j
    WHERE (
        j.params ->> 'planner_id' = p.id::text
        OR j.details ->> 'planner_id' = p.id::text
    )
    ORDER BY
        j.started_at DESC NULLS LAST,
        j.id DESC
    LIMIT 5
) r ON TRUE

WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures'
  AND p.status = 'running'
  AND EXISTS (
      SELECT 1
      FROM selected_targets t
      WHERE t.source_competition_key =
            p.provider_league_id::text
        AND t.source_season_key = p.season::text
  )

ORDER BY
    p.id,
    r.started_at DESC NULLS LAST,
    r.id DESC;