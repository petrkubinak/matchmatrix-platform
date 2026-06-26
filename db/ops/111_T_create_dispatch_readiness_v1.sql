CREATE OR REPLACE VIEW ops.v_dispatch_readiness_v1 AS
SELECT
    q.id AS dispatch_id,
    q.dispatch_status,
    q.provider,
    q.sport_code,
    q.entity,
    q.run_group,
    q.brain_score,

    COUNT(p.id) FILTER (
        WHERE p.status = 'pending'
    ) AS pending_planner_jobs,

    CASE
        WHEN COUNT(p.id) FILTER (WHERE p.status = 'pending') > 0
            THEN 'READY_TO_RUN'
        ELSE 'NO_PENDING_PLANNER_JOB'
    END AS readiness_status

FROM ops.dispatch_queue q
LEFT JOIN ops.ingest_planner p
    ON p.run_group = q.run_group
   AND p.provider = q.provider
   AND p.sport_code = q.sport_code
   AND p.entity = q.entity
WHERE q.dispatch_status IN ('PENDING', 'SELECTED')
GROUP BY
    q.id,
    q.dispatch_status,
    q.provider,
    q.sport_code,
    q.entity,
    q.run_group,
    q.brain_score;