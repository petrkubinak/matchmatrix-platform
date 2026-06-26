/*
MATCHMATRIX SQL 107_T
Scheduler Health Score Engine V1

CO TO JE:
- Intelligent scheduler scoring layer.
- Vyhodnocuje stabilitu workerů a orchestration kvalitu.

K ČEMU TO JE:
- Scheduler začne preferovat stabilní workery.
- Rizikové workery dostanou penalty.
- Připravuje adaptive retry engine.

CO BUDE SCORE OVLIVŇOVAT:
- success rate
- failure count
- warning count
- average runtime
- execution history

KDE TO UVIDÍME:
- ops.v_scheduler_health_score_v1
- V17.4 Runtime Metrics Panel

JAK SE TO VYUŽIJE:
- autonomous scheduling
- retry governance
- execution confidence
- runtime prioritization
- orchestration intelligence
*/

CREATE OR REPLACE VIEW ops.v_scheduler_health_score_v1 AS
WITH base AS (

    SELECT
        m.job_code,
        m.total_runs,
        m.success_runs,
        m.failed_runs,
        m.warning_runs,
        m.success_rate_pct,
        m.avg_duration_seconds,
        m.runtime_health,
        m.last_started_at,
        m.last_status,

        /* SUCCESS SCORE */
        CASE
            WHEN m.success_rate_pct >= 98 THEN 100
            WHEN m.success_rate_pct >= 95 THEN 90
            WHEN m.success_rate_pct >= 90 THEN 80
            WHEN m.success_rate_pct >= 80 THEN 65
            WHEN m.success_rate_pct >= 70 THEN 50
            WHEN m.success_rate_pct >= 50 THEN 35
            ELSE 10
        END AS success_score,

        /* FAILURE PENALTY */
        CASE
            WHEN m.failed_runs >= 100 THEN 60
            WHEN m.failed_runs >= 50 THEN 40
            WHEN m.failed_runs >= 20 THEN 25
            WHEN m.failed_runs >= 10 THEN 15
            WHEN m.failed_runs >= 5 THEN 8
            ELSE 0
        END AS failure_penalty,

        /* WARNING PENALTY */
        CASE
            WHEN m.warning_runs >= 100 THEN 40
            WHEN m.warning_runs >= 50 THEN 25
            WHEN m.warning_runs >= 20 THEN 15
            WHEN m.warning_runs >= 10 THEN 8
            WHEN m.warning_runs >= 5 THEN 4
            ELSE 0
        END AS warning_penalty,

        /* RUNTIME PENALTY */
        CASE
            WHEN m.avg_duration_seconds >= 7200 THEN 35
            WHEN m.avg_duration_seconds >= 3600 THEN 25
            WHEN m.avg_duration_seconds >= 1800 THEN 15
            WHEN m.avg_duration_seconds >= 600 THEN 8
            ELSE 0
        END AS runtime_penalty

    FROM ops.v_scheduler_runtime_metrics_v1 m
)

SELECT
    b.job_code,

    b.total_runs,
    b.success_runs,
    b.failed_runs,
    b.warning_runs,

    b.success_rate_pct,
    b.avg_duration_seconds,

    b.success_score,
    b.failure_penalty,
    b.warning_penalty,
    b.runtime_penalty,

    GREATEST(
        0,
        (
            b.success_score
            - b.failure_penalty
            - b.warning_penalty
            - b.runtime_penalty
        )
    ) AS health_score,

    CASE
        WHEN (
            b.success_score
            - b.failure_penalty
            - b.warning_penalty
            - b.runtime_penalty
        ) >= 90
            THEN 'ELITE'

        WHEN (
            b.success_score
            - b.failure_penalty
            - b.warning_penalty
            - b.runtime_penalty
        ) >= 75
            THEN 'STABLE'

        WHEN (
            b.success_score
            - b.failure_penalty
            - b.warning_penalty
            - b.runtime_penalty
        ) >= 50
            THEN 'WARNING'

        WHEN (
            b.success_score
            - b.failure_penalty
            - b.warning_penalty
            - b.runtime_penalty
        ) >= 25
            THEN 'RISKY'

        ELSE 'CRITICAL'
    END AS scheduler_health_tier,

    CASE
        WHEN b.failed_runs >= 50
            THEN 'HIGH'

        WHEN b.failed_runs >= 10
            THEN 'MEDIUM'

        WHEN b.failed_runs >= 1
            THEN 'LOW'

        ELSE 'NONE'
    END AS retry_risk,

    CASE
        WHEN b.runtime_health = 'UNSTABLE'
            THEN true
        ELSE false
    END AS unstable_worker,

    b.runtime_health,
    b.last_status,
    b.last_started_at

FROM base b
ORDER BY
    health_score DESC,
    success_rate_pct DESC,
    total_runs DESC;