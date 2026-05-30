/*
MATCHMATRIX SQL 107_C
Create worker resolver view V1

CO TO JE:
- View, které propojí scheduler kandidáty s ops.worker_registry.
- Řekne, jestli má kandidát skutečně registrovaný a povolený worker.

K ČEMU TO JE:
- Aby scheduler/panel nespouštěl routy bez production-safe workeru.
- Aby GAP_NO_WORKER nebyl jen textový warning, ale tvrdý execution filtr.

NA CO TO BUDE:
- SAFE SCHEDULER
- RUN NEXT engine
- automation daemon
- runtime governance

KDE TO POUŽIJEME:
- ops.v_worker_resolver_v1
- ops.v_scheduler_candidates_v1
- ops.v_execution_priority_queue_v1
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17.py
*/

CREATE OR REPLACE VIEW ops.v_worker_resolver_v1 AS
SELECT
    q.sport_code,
    q.entity,
    q.candidate_provider,
    q.run_group,
    q.resolved_worker_script,

    wr.worker_code,
    wr.worker_name,
    wr.layer_code,
    wr.supports_scheduler,
    wr.supports_retry,
    wr.supports_parallel,
    wr.timeout_sec,
    wr.max_attempts,
    wr.is_enabled,
    wr.is_production_safe,
    wr.worker_status,

    CASE
        WHEN wr.id IS NULL THEN false
        WHEN wr.is_enabled IS NOT TRUE THEN false
        WHEN wr.is_production_safe IS NOT TRUE THEN false
        WHEN wr.supports_scheduler IS NOT TRUE THEN false
        WHEN wr.worker_status NOT IN ('runtime_tested', 'production_ready') THEN false
        ELSE true
    END AS worker_can_run,

    CASE
        WHEN wr.id IS NULL THEN 'NO_WORKER_REGISTERED'
        WHEN wr.is_enabled IS NOT TRUE THEN 'WORKER_DISABLED'
        WHEN wr.is_production_safe IS NOT TRUE THEN 'WORKER_NOT_PRODUCTION_SAFE'
        WHEN wr.supports_scheduler IS NOT TRUE THEN 'WORKER_NOT_SCHEDULER_ENABLED'
        WHEN wr.worker_status NOT IN ('runtime_tested', 'production_ready') THEN 'WORKER_NOT_RUNTIME_READY'
        ELSE 'WORKER_READY'
    END AS worker_resolution_state

FROM ops.v_automation_ready_queue_v4 q
LEFT JOIN ops.worker_registry wr
    ON wr.worker_script = q.resolved_worker_script;