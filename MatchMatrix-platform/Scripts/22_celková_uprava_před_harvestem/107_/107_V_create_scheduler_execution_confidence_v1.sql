/*
MATCHMATRIX SQL 107_V
Scheduler Execution Confidence Engine V1

CO TO JE:
- Finální orchestration confidence layer.
- Kombinuje:
    historical health
    +
    recent health

K ČEMU TO JE:
- Scheduler získá skutečné execution decision rules.
- Runtime orchestrace začne být autonomní.
- Scheduler bude umět:
    RUN
    RUN_WITH_CAUTION
    RETRY_LIMITED
    BLOCK_TEMPORARY
    BLOCK

KDE TO UVIDÍME:
- ops.v_scheduler_execution_confidence_v1
- V17.4 Runtime Metrics Panel

JAK SE TO VYUŽIJE:
- autonomous orchestration
- smart retry
- intelligent blocking
- self-healing scheduler
- orchestration confidence engine
*/

CREATE OR REPLACE VIEW ops.v_scheduler_execution_confidence_v1 AS
SELECT
    h.job_code,

    /* HISTORICAL */
    h.health_score,
    h.scheduler_health_tier,
    h.retry_risk,
    h.unstable_worker,

    /* RECENT */
    r.recent_health_score,
    r.recent_health_tier,
    r.recent_retry_risk,

    /* LAST STATUS */
    r.recent_last_status,
    r.recent_last_started_at,

    /* COMBINED SCORE */
    ROUND(
        (
            (h.health_score * 0.35)
            +
            (r.recent_health_score * 0.65)
        )::numeric,
        2
    ) AS execution_confidence_score,

    /* EXECUTION DECISION */
    CASE

        /* HARD BLOCK */
        WHEN r.recent_health_tier = 'CRITICAL'
             AND r.recent_retry_risk = 'HIGH'
            THEN 'BLOCK'

        /* TEMP BLOCK */
        WHEN r.recent_health_tier = 'CRITICAL'
            THEN 'BLOCK_TEMPORARY'

        /* LIMITED RETRY */
        WHEN r.recent_health_tier = 'RISKY'
            THEN 'RETRY_LIMITED'

        /* WARNING */
        WHEN r.recent_health_tier = 'WARNING'
            THEN 'RUN_WITH_CAUTION'

        /* SAFE */
        WHEN r.recent_health_tier IN ('STABLE', 'ELITE')
            THEN 'RUN'

        ELSE 'UNKNOWN'
    END AS execution_decision,

    /* EXECUTION PRIORITY BOOST */
    CASE

        WHEN r.recent_health_tier = 'ELITE'
             AND h.scheduler_health_tier IN ('ELITE', 'STABLE')
            THEN 25

        WHEN r.recent_health_tier = 'STABLE'
            THEN 15

        WHEN r.recent_health_tier = 'WARNING'
            THEN 0

        WHEN r.recent_health_tier = 'RISKY'
            THEN -20

        WHEN r.recent_health_tier = 'CRITICAL'
            THEN -50

        ELSE 0
    END AS scheduler_priority_adjustment,

    /* AUTONOMOUS SAFE FLAG */
    CASE
        WHEN r.recent_health_tier IN ('ELITE', 'STABLE')
             AND r.recent_retry_risk IN ('NONE', 'LOW')
            THEN true
        ELSE false
    END AS autonomous_safe,

    /* RETRY POLICY */
    CASE

        WHEN r.recent_health_tier = 'ELITE'
            THEN 'NORMAL'

        WHEN r.recent_health_tier = 'STABLE'
            THEN 'NORMAL'

        WHEN r.recent_health_tier = 'WARNING'
            THEN 'REDUCED_RETRY'

        WHEN r.recent_health_tier = 'RISKY'
            THEN 'LIMITED_RETRY'

        WHEN r.recent_health_tier = 'CRITICAL'
            THEN 'NO_RETRY'

        ELSE 'UNKNOWN'
    END AS retry_policy

FROM ops.v_scheduler_health_score_v1 h
JOIN ops.v_scheduler_recent_health_score_v1 r
    ON h.job_code = r.job_code

ORDER BY
    execution_confidence_score DESC,
    autonomous_safe DESC,
    execution_decision;