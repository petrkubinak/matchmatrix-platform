/*
CO:
  STEP 12S – kontrola uloženého pozastavení HB 2024.

K ČEMU:
  Ověřit audit 2130, zálohy původních řádků
  a aktuální stavy pravidel, targetů a planner fronty.

KDE:
  PC2 / PostgreSQL matchmatrix / DBeaver.

JAK:
  Spustit celý dotaz a poslat výsledek.
  READ ONLY – bez změn dat.
*/

WITH audit AS (
    SELECT j.id, j.params, j.details
    FROM ops.job_runs j
    WHERE j.id = 2130
      AND j.job_code = 'hb_scope_pause_admin'
      AND j.params ->> 'script_prefix' = '27_2_96'
      AND j.status = 'ok'
      AND j.finished_at IS NOT NULL
      AND j.rows_affected = 222
),
targets AS (
    SELECT t.*
    FROM ops.ingest_targets t
    WHERE t.id IN (
        SELECT x.value::bigint
        FROM audit a
        CROSS JOIN LATERAL
            jsonb_array_elements_text(
                a.params -> 'target_ids'
            ) AS x(value)
    )
),
policies AS (
    SELECT r.*
    FROM ops.harvest_scope_refresh_policy r
    WHERE r.policy_id IN (
        SELECT x.value::bigint
        FROM audit a
        CROSS JOIN LATERAL
            jsonb_array_elements_text(
                a.params -> 'policy_ids'
            ) AS x(value)
    )
),
changed_jobs AS (
    SELECT p.*
    FROM ops.ingest_planner p
    WHERE p.id IN (
        SELECT x.value::bigint
        FROM audit a
        CROSS JOIN LATERAL
            jsonb_array_elements_text(
                a.params -> 'planner_ids'
            ) AS x(value)
    )
),
scope_jobs AS (
    SELECT p.*
    FROM ops.ingest_planner p
    WHERE p.provider = 'api_handball'
      AND p.sport_code = 'HB'
      AND p.entity = 'fixtures'
      AND p.season IN ('2022', '2023', '2024')
      AND EXISTS (
          SELECT 1
          FROM targets t
          WHERE t.provider_league_id = p.provider_league_id
      )
),
checks (check_order, check_name, expected, actual) AS (
    VALUES
    (
        1, 'AUDIT_RECORD', 1,
        (SELECT COUNT(*) FROM audit)
    ),
    (
        2, 'BACKUP_POLICIES', 110,
        COALESCE((
            SELECT jsonb_array_length(
                a.details #> '{before,policies}'
            )
            FROM audit a
        ), 0)
    ),
    (
        3, 'BACKUP_TARGETS', 55,
        COALESCE((
            SELECT jsonb_array_length(
                a.details #> '{before,targets}'
            )
            FROM audit a
        ), 0)
    ),
    (
        4, 'BACKUP_PLANNER', 57,
        COALESCE((
            SELECT jsonb_array_length(
                a.details #> '{before,planner}'
            )
            FROM audit a
        ), 0)
    ),
    (
        5, 'POLICIES_PAUSED_UNDECIDED', 110,
        (
            SELECT COUNT(*)
            FROM policies
            WHERE policy_status = 'PAUSED'
              AND refresh_mode = 'UNDECIDED'
              AND source_season_key = '2024'
        )
    ),
    (
        6, 'TARGETS_DISABLED', 55,
        (
            SELECT COUNT(*)
            FROM targets
            WHERE enabled = false
              AND provider = 'api_handball'
              AND sport_code = 'HB'
              AND season = '2024'
              AND run_group = 'HB_CORE'
        )
    ),
    (
        7, 'EXACT_JOBS_BLOCKED', 57,
        (
            SELECT COUNT(*)
            FROM changed_jobs
            WHERE status = 'blocked'
              AND provider = 'api_handball'
              AND sport_code = 'HB'
              AND entity = 'fixtures'
              AND season = '2024'
        )
    ),
    (
        8, 'SCOPE_2024_TOTAL', 149,
        (SELECT COUNT(*) FROM scope_jobs WHERE season = '2024')
    ),
    (
        9, 'SCOPE_2024_PENDING', 0,
        (
            SELECT COUNT(*)
            FROM scope_jobs
            WHERE season = '2024' AND status = 'pending'
        )
    ),
    (
        10, 'SCOPE_2024_RUNNING', 0,
        (
            SELECT COUNT(*)
            FROM scope_jobs
            WHERE season = '2024' AND status = 'running'
        )
    ),
    (
        11, 'SCOPE_2024_DONE', 87,
        (
            SELECT COUNT(*)
            FROM scope_jobs
            WHERE season = '2024' AND status = 'done'
        )
    ),
    (
        12, 'SCOPE_2024_ERROR', 5,
        (
            SELECT COUNT(*)
            FROM scope_jobs
            WHERE season = '2024' AND status = 'error'
        )
    ),
    (
        13, 'SCOPE_2022_PENDING', 55,
        (
            SELECT COUNT(*)
            FROM scope_jobs
            WHERE season = '2022' AND status = 'pending'
        )
    ),
    (
        14, 'SCOPE_2023_PENDING', 55,
        (
            SELECT COUNT(*)
            FROM scope_jobs
            WHERE season = '2023' AND status = 'pending'
        )
    )
)
SELECT
    CASE
        WHEN bool_and(actual = expected) OVER ()
            THEN 'INTEGRITY_PASS'
        ELSE 'STOP_REVIEW_REQUIRED'
    END AS overall_status,
    check_name,
    expected,
    actual,
    CASE
        WHEN actual = expected THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM checks
ORDER BY check_order;