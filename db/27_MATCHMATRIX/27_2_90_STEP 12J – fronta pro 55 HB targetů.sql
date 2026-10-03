/*
CO:
  STEP 12J – kontrola planner fronty pro nerozhodnuté HB targety.

K ČEMU:
  Zjistit počet a skutečné stavy jobů pro jejich sezónu 2024.
  Dvě policy položky na target nesmějí zdvojovat počty jobů.

KDE:
  DBeaver / databáze matchmatrix na PC2.

JAK:
  Spustit celý dotaz. Pouze čtení.
*/

WITH selected_policies AS (
    SELECT
        ingest_target_id,
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
),
selected_targets AS (
    SELECT DISTINCT
        ingest_target_id,
        source_competition_key,
        source_season_key
    FROM selected_policies
    WHERE ingest_target_id IS NOT NULL
),
selected_jobs AS (
    SELECT
        p.id,
        p.provider_league_id,
        p.season,
        p.status,
        p.run_group,
        p.last_attempt
    FROM ops.ingest_planner p
    WHERE p.provider = 'api_handball'
      AND p.sport_code = 'HB'
      AND p.entity = 'fixtures'
      AND EXISTS (
          SELECT 1
          FROM selected_targets t
          WHERE t.source_competition_key =
                p.provider_league_id::text
            AND t.source_season_key = p.season::text
      )
),
scope_summary AS (
    SELECT
        COUNT(DISTINCT t.ingest_target_id) AS selected_targets,
        (
            SELECT COUNT(*)
            FROM selected_policies
        ) AS selected_policy_rows,
        (
            SELECT COUNT(*)
            FROM selected_jobs
        ) AS planner_jobs_total,
        COUNT(DISTINCT t.ingest_target_id) FILTER (
            WHERE NOT EXISTS (
                SELECT 1
                FROM selected_jobs p
                WHERE p.provider_league_id::text =
                      t.source_competition_key
                  AND p.season::text = t.source_season_key
            )
        ) AS targets_without_planner_jobs
    FROM selected_targets t
),
status_summary AS (
    SELECT
        status,
        run_group,
        COUNT(*) AS jobs_in_status,
        MAX(last_attempt) AS last_attempt
    FROM selected_jobs
    GROUP BY status, run_group
)
SELECT
    s.selected_targets,
    s.selected_policy_rows,
    s.planner_jobs_total,
    s.targets_without_planner_jobs,
    j.status AS planner_status,
    j.run_group,
    COALESCE(j.jobs_in_status, 0) AS jobs_in_status,
    j.last_attempt
FROM scope_summary s
LEFT JOIN status_summary j ON TRUE
ORDER BY j.run_group, j.status;