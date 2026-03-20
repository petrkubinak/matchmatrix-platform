--Hlavní souhrn
SELECT * FROM ops.v_ops_dashboard_summary;


--Planner stavy
SELECT *
FROM ops.v_ingest_planner_status
ORDER BY provider, sport_code, entity, run_group, status;


--Fronta k řešení
SELECT *
FROM ops.v_ingest_planner_queue
ORDER BY status, priority, id
LIMIT 200;


--Poslední běhy jobů
SELECT
    id,
    job_code,
    started_at,
    finished_at,
    status,
    rows_affected,
    duration_sec,
    message
FROM ops.v_job_runs_recent
LIMIT 50;

--Aktivní locky
SELECT *
FROM ops.v_worker_locks_active;