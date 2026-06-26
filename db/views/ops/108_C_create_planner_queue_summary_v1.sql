/*
MATCHMATRIX SQL 108_C
Planner Queue Summary V1

CO TO JE:
- Souhrn planner queue.
- Počítá pending/running/done/error joby.

K ČEMU TO JE:
- Panel V17.6 dostane:
  - pending jobs
  - running jobs
  - failed jobs
  - planner load

KDE TO UVIDÍME:
- ops.v_planner_queue_summary_v1
- horní KPI panel

JAK SE TO VYUŽIJE:
- scheduler governance
- planner diagnostics
- autonomous orchestration
- queue monitoring
*/

CREATE OR REPLACE VIEW ops.v_planner_queue_summary_v1 AS
SELECT

    COUNT(*) AS total_jobs,

    COUNT(*) FILTER (
        WHERE status = 'pending'
    ) AS pending_jobs,

    COUNT(*) FILTER (
        WHERE status = 'running'
    ) AS running_jobs,

    COUNT(*) FILTER (
        WHERE status = 'done'
    ) AS done_jobs,

    COUNT(*) FILTER (
        WHERE status IN ('error', 'failed')
    ) AS failed_jobs,

    COUNT(*) FILTER (
        WHERE attempts >= 3
          AND status <> 'done'
    ) AS retry_risk_jobs,

    MAX(created_at) AS newest_job_created_at,
    MAX(updated_at) AS last_job_update_at,

    CASE
        WHEN COUNT(*) FILTER (
            WHERE status IN ('error', 'failed')
        ) > 50
            THEN 'CRITICAL'

        WHEN COUNT(*) FILTER (
            WHERE status = 'pending'
        ) > 500
            THEN 'BUSY'

        WHEN COUNT(*) FILTER (
            WHERE status = 'running'
        ) > 0
            THEN 'ACTIVE'

        ELSE 'NORMAL'
    END AS planner_state,

    CASE
        WHEN COUNT(*) FILTER (
            WHERE status IN ('error', 'failed')
        ) > 50
            THEN 'RED'

        WHEN COUNT(*) FILTER (
            WHERE status = 'pending'
        ) > 500
            THEN 'YELLOW'

        WHEN COUNT(*) FILTER (
            WHERE status = 'running'
        ) > 0
            THEN 'GREEN'

        ELSE 'PURPLE'
    END AS planner_color

FROM ops.ingest_planner;