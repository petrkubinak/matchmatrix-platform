/*
MATCHMATRIX SQL 107_Z
Scheduler Runtime Dashboard V1

CO TO JE:
- Finální dashboard view orchestration runtime systému.
- Spojuje všechny orchestration intelligence vrstvy.

SPOJUJE:
- runtime metrics
- historical health
- recent health
- execution confidence
- RUN NEXT audit

K ČEMU TO JE:
- Kompletní runtime governance dashboard.
- Panel V17.4 bude číst pouze toto view.

KDE TO UVIDÍME:
- ops.v_scheduler_runtime_dashboard_v1
- matchmatrix_control_panel_V17_4.py

JAK SE TO VYUŽIJE:
- autonomous scheduler
- orchestration diagnostics
- runtime analytics
- health governance
- retry governance
- intelligent orchestration monitoring
*/

CREATE OR REPLACE VIEW ops.v_scheduler_runtime_dashboard_v1 AS
SELECT
    /* CORE */
    a.worker_code,
    a.worker_name,

    a.sport_code,
    a.entity,
    a.candidate_provider,
    a.run_group,

    /* EXECUTION */
    ec.execution_decision,
    ec.retry_policy,
    ec.autonomous_safe,

    ec.execution_confidence_score,
    ec.scheduler_priority_adjustment,

    /* HISTORICAL HEALTH */
    hs.health_score,
    hs.scheduler_health_tier,
    hs.retry_risk,
    hs.unstable_worker,

    /* RECENT HEALTH */
    rh.recent_health_score,
    rh.recent_health_tier,
    rh.recent_retry_risk,

    /* RUNTIME METRICS */
    rm.total_runs,
    rm.success_runs,
    rm.failed_runs,
    rm.warning_runs,

    rm.success_rate_pct,
    rm.avg_duration_seconds,

    rm.last_started_at,
    rm.last_finished_at,
    rm.last_status,
    rm.last_message,

    /* RUN NEXT */
    a.audit_reason,
    a.included_in_run_next,

    a.final_priority_score,
    a.orchestration_mode,

    /* ORCHESTRATION */
    a.ready_for_scheduler,
    a.final_ready_for_run_next,
    a.worker_already_running,
    a.has_pending_planner_job,

/* PANEL FLAGS */
CASE
    WHEN a.included_in_run_next = true
        THEN 'READY'

    WHEN ec.execution_decision IN ('BLOCK', 'BLOCK_TEMPORARY')
        THEN 'BLOCKED'

    WHEN ec.execution_decision = 'RETRY_LIMITED'
        THEN 'LIMITED'

    ELSE 'WAITING'
END AS dashboard_state,

CASE
    WHEN a.included_in_run_next = true
         AND ec.execution_decision = 'RUN'
         AND ec.autonomous_safe = true
        THEN 'GREEN'

    WHEN ec.execution_decision = 'RETRY_LIMITED'
      OR rh.recent_health_tier = 'RISKY'
        THEN 'YELLOW'

    WHEN ec.execution_decision IN ('BLOCK', 'BLOCK_TEMPORARY')
      OR rh.recent_health_tier = 'CRITICAL'
        THEN 'RED'

    ELSE 'YELLOW'
END AS dashboard_health_color

FROM ops.v_run_next_audit_v1 a

LEFT JOIN ops.v_scheduler_execution_confidence_v1 ec
    ON a.worker_code =
        CASE
            WHEN ec.job_code = 'ingest_cycle_v3'
                THEN 'CORE_INGEST_V3'
            WHEN ec.job_code = 'people_pipeline_v22_from_planner'
                THEN 'PEOPLE_PIPELINE_V22'
            ELSE ec.job_code
        END

LEFT JOIN ops.v_scheduler_health_score_v1 hs
    ON a.worker_code =
        CASE
            WHEN hs.job_code = 'ingest_cycle_v3'
                THEN 'CORE_INGEST_V3'
            WHEN hs.job_code = 'people_pipeline_v22_from_planner'
                THEN 'PEOPLE_PIPELINE_V22'
            ELSE hs.job_code
        END

LEFT JOIN ops.v_scheduler_recent_health_score_v1 rh
    ON a.worker_code =
        CASE
            WHEN rh.job_code = 'ingest_cycle_v3'
                THEN 'CORE_INGEST_V3'
            WHEN rh.job_code = 'people_pipeline_v22_from_planner'
                THEN 'PEOPLE_PIPELINE_V22'
            ELSE rh.job_code
        END

LEFT JOIN ops.v_scheduler_runtime_metrics_v1 rm
    ON a.worker_code =
        CASE
            WHEN rm.job_code = 'ingest_cycle_v3'
                THEN 'CORE_INGEST_V3'
            WHEN rm.job_code = 'people_pipeline_v22_from_planner'
                THEN 'PEOPLE_PIPELINE_V22'
            ELSE rm.job_code
        END

ORDER BY
    a.included_in_run_next DESC,
    ec.execution_confidence_score DESC,
    a.final_priority_score DESC;