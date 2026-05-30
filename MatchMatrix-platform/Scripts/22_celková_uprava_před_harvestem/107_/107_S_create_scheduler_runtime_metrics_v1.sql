/*
MATCHMATRIX SQL 107_S
Create scheduler runtime metrics V1

CO TO JE:
- Vytvoří runtime metrický view nad ops.job_runs.

K ČEMU TO JE:
- Scheduler uvidí historii úspěšnosti workerů.
- Panel ukáže stabilitu, chyby a průměrnou dobu běhu.
- Připravuje základ pro adaptive scheduler a retry scoring.

KDE TO UVIDÍME:
- ops.v_scheduler_runtime_metrics_v1
- později Panel V17.4 Runtime Metrics

JAK SE TO VYUŽIJE NA WEBU/APLIKACI:
- interní admin dashboard
- health scoring workerů
- detekce nestabilních pipeline
- automatické řazení bezpečných jobů
*/

CREATE OR REPLACE VIEW ops.v_scheduler_runtime_metrics_v1 AS
SELECT
    jr.job_code,

    COUNT(*) AS total_runs,

    COUNT(*) FILTER (
        WHERE lower(jr.status) IN ('done', 'success', 'ok', 'completed')
    ) AS success_runs,

    COUNT(*) FILTER (
        WHERE lower(jr.status) IN ('error', 'failed', 'fail')
    ) AS failed_runs,

    COUNT(*) FILTER (
        WHERE lower(jr.status) IN ('warning', 'partial')
    ) AS warning_runs,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE lower(jr.status) IN ('done', 'success', 'ok', 'completed')
            )::numeric
            / NULLIF(COUNT(*)::numeric, 0)
        ) * 100,
        2
    ) AS success_rate_pct,

    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (jr.finished_at - jr.started_at))
        ) FILTER (
            WHERE jr.finished_at IS NOT NULL
              AND jr.started_at IS NOT NULL
        )::numeric,
        2
    ) AS avg_duration_seconds,

    MAX(jr.started_at) AS last_started_at,
    MAX(jr.finished_at) AS last_finished_at,

    (
        ARRAY_AGG(jr.status ORDER BY jr.started_at DESC)
    )[1] AS last_status,

    (
        ARRAY_AGG(jr.message ORDER BY jr.started_at DESC)
    )[1] AS last_message,

    SUM(COALESCE(jr.rows_affected, 0)) AS total_rows_affected,

    CASE
        WHEN COUNT(*) FILTER (WHERE lower(jr.status) IN ('error', 'failed', 'fail')) >= 3
            THEN 'UNSTABLE'
        WHEN COUNT(*) FILTER (WHERE lower(jr.status) IN ('warning', 'partial')) >= 3
            THEN 'WARNING'
        WHEN COUNT(*) FILTER (WHERE lower(jr.status) IN ('done', 'success', 'ok', 'completed')) > 0
            THEN 'STABLE'
        ELSE 'UNKNOWN'
    END AS runtime_health

FROM ops.job_runs jr
GROUP BY
    jr.job_code
ORDER BY
    runtime_health,
    success_rate_pct DESC NULLS LAST,
    last_started_at DESC NULLS LAST;