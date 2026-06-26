CREATE OR REPLACE VIEW ops.v_orchestration_priority_queue_v4 AS
WITH base AS (
    SELECT
        q.*,

        ec.execution_confidence_score,
        ec.execution_decision,
        ec.scheduler_priority_adjustment,
        ec.autonomous_safe,
        ec.retry_policy,

        ROW_NUMBER() OVER (
            PARTITION BY q.worker_code
            ORDER BY
                q.orchestration_priority_rank ASC,
                q.planner_priority ASC NULLS LAST,
                q.effective_layer_order ASC
        ) AS worker_dedup_rank

    FROM ops.v_orchestration_priority_queue_v3 q
    LEFT JOIN ops.v_scheduler_execution_confidence_v1 ec
        ON ec.job_code =
            CASE
                WHEN q.worker_code = 'CORE_INGEST_V3'
                    THEN 'ingest_cycle_v3'
                WHEN q.worker_code = 'PEOPLE_PIPELINE_V22'
                    THEN 'people_pipeline_v22_from_planner'
                ELSE q.worker_code
            END
),
filtered AS (
    SELECT *
    FROM base
    WHERE worker_dedup_rank = 1
      AND COALESCE(execution_decision, 'RUN') NOT IN ('BLOCK', 'BLOCK_TEMPORARY')
)

SELECT
    f.*,

    (
        (100000 - COALESCE(f.orchestration_priority_rank, 99999))
        + (1000 - COALESCE(f.planner_priority, 999))
        + COALESCE(f.scheduler_priority_adjustment, 0)
    ) AS final_priority_score,

    CASE
        WHEN f.autonomous_safe = true THEN 'SAFE_AUTONOMOUS'
        WHEN f.execution_decision = 'RUN_WITH_CAUTION' THEN 'CAUTION'
        WHEN f.execution_decision = 'RETRY_LIMITED' THEN 'LIMITED'
        ELSE 'STANDARD'
    END AS orchestration_mode

FROM filtered f
ORDER BY
    final_priority_score DESC,
    autonomous_safe DESC,
    effective_layer_order ASC;