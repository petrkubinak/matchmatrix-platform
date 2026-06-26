/*
MATCHMATRIX SQL 108_E
Recent Failures View V1

CO TO JE:
- Runtime failure dashboard view.
- Poslední chyby orchestrace.

K ČEMU TO JE:
- Panel V17.6 ukáže:
  - failed workery
  - retry pressure
  - unstable runtime
  - failed merges
  - failed pipelines

KDE TO UVIDÍME:
- ops.v_recent_failures_v1
- Runtime Failure Dashboard

JAK SE TO VYUŽIJE:
- orchestration diagnostics
- autonomous retry governance
- runtime monitoring
- unstable worker detection
*/

CREATE OR REPLACE VIEW ops.v_recent_failures_v1 AS
SELECT
    jr.id,
    jr.job_code,

    jr.started_at,
    jr.finished_at,

    EXTRACT(
        EPOCH FROM (
            COALESCE(jr.finished_at, now())
            - jr.started_at
        )
    )::integer AS duration_seconds,

    jr.status,
    jr.message,

    jr.rows_affected,

    CASE
        WHEN jr.status IN ('failed', 'error')
            THEN 'FAILED'

        WHEN jr.status = 'warning'
            THEN 'WARNING'

        ELSE 'UNKNOWN'
    END AS failure_state,

    CASE
        WHEN jr.status IN ('failed', 'error')
            THEN 'RED'

        WHEN jr.status = 'warning'
            THEN 'YELLOW'

        ELSE 'PURPLE'
    END AS failure_color,

    CASE
        WHEN jr.message ILIKE '%timeout%'
            THEN 'TIMEOUT'

        WHEN jr.message ILIKE '%lock%'
            THEN 'LOCK'

        WHEN jr.message ILIKE '%planner%'
            THEN 'PLANNER'

        WHEN jr.message ILIKE '%merge%'
            THEN 'MERGE'

        WHEN jr.message ILIKE '%provider%'
            THEN 'PROVIDER'

        ELSE 'GENERAL'
    END AS failure_category

FROM ops.job_runs jr
WHERE jr.status IN (
    'failed',
    'error',
    'warning'
)
ORDER BY jr.started_at DESC
LIMIT 100;