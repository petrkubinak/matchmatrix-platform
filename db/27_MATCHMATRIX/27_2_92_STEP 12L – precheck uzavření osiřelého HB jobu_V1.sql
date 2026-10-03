/*
CO:
  STEP 12L – VALIDATE_ONLY před uzavřením osiřelého HB jobu.

K ČEMU:
  Ověřit přesně 1 planner řádek a 2 neuzavřené audity.
  Odhalit případné další otevřené audity stejného jobu.

KDE:
  DBeaver / databáze matchmatrix na PC2.

JAK:
  Spustit celý dotaz. Pouze čtení.
*/

WITH planner_candidate AS (
    SELECT
        p.id,
        p.status,
        p.last_attempt
    FROM ops.ingest_planner p
    WHERE p.id = 8874
      AND p.provider = 'api_handball'
      AND p.sport_code = 'HB'
      AND p.entity = 'fixtures'
      AND p.provider_league_id::text = '180'
      AND p.season::text = '2024'
      AND p.run_group = 'PC2_CORE_HB'
      AND p.status = 'running'
      AND p.attempts = 2
      AND p.last_attempt < NOW() - INTERVAL '7 days'
),
audit_candidates AS (
    SELECT
        j.id,
        j.status,
        j.started_at
    FROM ops.job_runs j
    WHERE j.id IN (1996, 1997)
      AND j.job_code = 'ingest_planner_worker'
      AND j.status = 'running'
      AND j.finished_at IS NULL
      AND j.started_at < NOW() - INTERVAL '7 days'
      AND (
          j.params ->> 'planner_id' = '8874'
          OR j.details ->> 'planner_id' = '8874'
      )
),
other_open_audits AS (
    SELECT j.id
    FROM ops.job_runs j
    WHERE j.id NOT IN (1996, 1997)
      AND j.status = 'running'
      AND j.finished_at IS NULL
      AND (
          j.params ->> 'planner_id' = '8874'
          OR j.details ->> 'planner_id' = '8874'
      )
),
counts AS (
    SELECT
        (SELECT COUNT(*) FROM planner_candidate)
            AS planner_rows,
        (SELECT COUNT(*) FROM audit_candidates)
            AS audit_rows,
        (SELECT COUNT(*) FROM other_open_audits)
            AS other_open_audit_rows
),
candidates AS (
    SELECT
        'PLANNER'::text AS object_type,
        id AS record_id,
        status AS current_status,
        last_attempt AS attempt_time
    FROM planner_candidate

    UNION ALL

    SELECT
        'JOB_RUN',
        id,
        status,
        started_at
    FROM audit_candidates
)
SELECT
    CASE
        WHEN n.planner_rows = 1
         AND n.audit_rows = 2
         AND n.other_open_audit_rows = 0
        THEN 'VALIDATE_ONLY_PASS'
        ELSE 'STOP_REVIEW_REQUIRED'
    END AS check_status,
    c.object_type,
    c.record_id,
    c.current_status,
    'error'::text AS proposed_status,
    c.attempt_time,
    n.planner_rows,
    n.audit_rows,
    n.other_open_audit_rows
FROM counts n
LEFT JOIN candidates c ON TRUE
ORDER BY c.object_type, c.record_id;