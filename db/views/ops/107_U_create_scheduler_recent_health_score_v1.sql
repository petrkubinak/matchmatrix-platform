/*
MATCHMATRIX SQL 107_U
Recent Scheduler Health Score V1

CO TO JE:
- Recent runtime health scoring layer.
- Hodnotí workery pouze podle posledních běhů.

K ČEMU TO JE:
- Rozliší historicky špatné workery od aktuálně opravených.
- Scheduler nebude zbytečně trestat worker za staré chyby.
- Připravuje adaptive retry a smart routing.

KDE TO UVIDÍME:
- ops.v_scheduler_recent_health_score_v1
- později Panel V17.4 Runtime Metrics

JAK SE TO VYUŽIJE:
- recent execution confidence
- adaptive scheduler
- smart retry engine
- blokace jen aktuálně rizikových workerů
*/

CREATE OR REPLACE VIEW ops.v_scheduler_recent_health_score_v1 AS
WITH recent_runs AS (
    SELECT
        jr.*,
        ROW_NUMBER() OVER (
            PARTITION BY jr.job_code
            ORDER BY jr.started_at DESC
        ) AS rn
    FROM ops.job_runs jr
    WHERE jr.started_at >= now() - interval '14 days'
),
metrics AS (
    SELECT
        job_code,

        COUNT(*) AS recent_total_runs,

        COUNT(*) FILTER (
            WHERE lower(status) IN ('done', 'success', 'ok', 'completed')
        ) AS recent_success_runs,

        COUNT(*) FILTER (
            WHERE lower(status) IN ('error', 'failed', 'fail')
        ) AS recent_failed_runs,

        COUNT(*) FILTER (
            WHERE lower(status) IN ('warning', 'partial')
        ) AS recent_warning_runs,

        ROUND(
            (
                COUNT(*) FILTER (
                    WHERE lower(status) IN ('done', 'success', 'ok', 'completed')
                )::numeric
                / NULLIF(COUNT(*)::numeric, 0)
            ) * 100,
            2
        ) AS recent_success_rate_pct,

        ROUND(
            AVG(
                EXTRACT(EPOCH FROM (finished_at - started_at))
            ) FILTER (
                WHERE finished_at IS NOT NULL
                  AND started_at IS NOT NULL
            )::numeric,
            2
        ) AS recent_avg_duration_seconds,

        MAX(started_at) AS recent_last_started_at,

        (
            ARRAY_AGG(status ORDER BY started_at DESC)
        )[1] AS recent_last_status,

        (
            ARRAY_AGG(message ORDER BY started_at DESC)
        )[1] AS recent_last_message

    FROM recent_runs
    WHERE rn <= 20
    GROUP BY job_code
),
score AS (
    SELECT
        m.*,

        CASE
            WHEN m.recent_success_rate_pct >= 98 THEN 100
            WHEN m.recent_success_rate_pct >= 95 THEN 90
            WHEN m.recent_success_rate_pct >= 90 THEN 80
            WHEN m.recent_success_rate_pct >= 80 THEN 65
            WHEN m.recent_success_rate_pct >= 70 THEN 50
            WHEN m.recent_success_rate_pct >= 50 THEN 35
            ELSE 10
        END AS recent_success_score,

        CASE
            WHEN m.recent_failed_runs >= 10 THEN 40
            WHEN m.recent_failed_runs >= 5 THEN 25
            WHEN m.recent_failed_runs >= 3 THEN 15
            WHEN m.recent_failed_runs >= 1 THEN 8
            ELSE 0
        END AS recent_failure_penalty,

        CASE
            WHEN m.recent_warning_runs >= 10 THEN 25
            WHEN m.recent_warning_runs >= 5 THEN 15
            WHEN m.recent_warning_runs >= 3 THEN 8
            WHEN m.recent_warning_runs >= 1 THEN 4
            ELSE 0
        END AS recent_warning_penalty,

        CASE
            WHEN m.recent_avg_duration_seconds >= 7200 THEN 35
            WHEN m.recent_avg_duration_seconds >= 3600 THEN 25
            WHEN m.recent_avg_duration_seconds >= 1800 THEN 15
            WHEN m.recent_avg_duration_seconds >= 600 THEN 8
            ELSE 0
        END AS recent_runtime_penalty

    FROM metrics m
)

SELECT
    s.job_code,

    s.recent_total_runs,
    s.recent_success_runs,
    s.recent_failed_runs,
    s.recent_warning_runs,

    s.recent_success_rate_pct,
    s.recent_avg_duration_seconds,

    s.recent_success_score,
    s.recent_failure_penalty,
    s.recent_warning_penalty,
    s.recent_runtime_penalty,

    GREATEST(
        0,
        s.recent_success_score
        - s.recent_failure_penalty
        - s.recent_warning_penalty
        - s.recent_runtime_penalty
    ) AS recent_health_score,

    CASE
        WHEN (
            s.recent_success_score
            - s.recent_failure_penalty
            - s.recent_warning_penalty
            - s.recent_runtime_penalty
        ) >= 90 THEN 'ELITE'
        WHEN (
            s.recent_success_score
            - s.recent_failure_penalty
            - s.recent_warning_penalty
            - s.recent_runtime_penalty
        ) >= 75 THEN 'STABLE'
        WHEN (
            s.recent_success_score
            - s.recent_failure_penalty
            - s.recent_warning_penalty
            - s.recent_runtime_penalty
        ) >= 50 THEN 'WARNING'
        WHEN (
            s.recent_success_score
            - s.recent_failure_penalty
            - s.recent_warning_penalty
            - s.recent_runtime_penalty
        ) >= 25 THEN 'RISKY'
        ELSE 'CRITICAL'
    END AS recent_health_tier,

    CASE
        WHEN s.recent_failed_runs >= 10 THEN 'HIGH'
        WHEN s.recent_failed_runs >= 3 THEN 'MEDIUM'
        WHEN s.recent_failed_runs >= 1 THEN 'LOW'
        ELSE 'NONE'
    END AS recent_retry_risk,

    s.recent_last_status,
    s.recent_last_message,
    s.recent_last_started_at

FROM score s
ORDER BY
    recent_health_score DESC,
    recent_success_rate_pct DESC,
    recent_total_runs DESC;