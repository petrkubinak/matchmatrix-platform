/*
===============================================================================
MATCHMATRIX SQL 109_F
CREATE SCHEDULER AUTOPILOT V1
===============================================================================

CO TO JE:
- Scheduler Autopilot Recommendation Engine.

K ČEMU TO JE:
- Převádí AI OPS Risk Engine na konkrétní doporučení scheduleru.

KDE TO UVIDÍME:
- AI OPS záložka
- Scheduler Autopilot panel

JAK SE TO VYUŽIJE:
- Autonomous Scheduler
- Smart Cooldown
- Retry Intelligence
- Provider Routing
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_scheduler_autopilot_v1 AS

SELECT

    provider,

    execution_decision,

    risk_score,

    CASE

        WHEN execution_decision = 'BLOCK'
            THEN 'Critical provider health'

        WHEN execution_decision = 'WAIT'
            THEN 'Runtime health degraded'

        WHEN execution_decision = 'RUN_WITH_CAUTION'
            THEN 'Provider partially healthy'

        WHEN execution_decision = 'SMOKE_TEST'
            THEN 'Ready but missing runtime validation'

        WHEN execution_decision = 'PLANNED_ONLY'
            THEN 'Provider not runtime ready'

        WHEN execution_decision = 'RUN_SAFE'
            THEN 'Healthy provider'

        ELSE 'Manual review required'

    END AS recommendation_reason,

    CASE

        WHEN execution_decision = 'BLOCK'
            THEN 'DISABLE_PROVIDER'

        WHEN execution_decision = 'WAIT'
            THEN 'COOLDOWN'

        WHEN execution_decision = 'RUN_WITH_CAUTION'
            THEN 'LIMITED_EXECUTION'

        WHEN execution_decision = 'SMOKE_TEST'
            THEN 'RUN_SMOKE_TEST'

        WHEN execution_decision = 'PLANNED_ONLY'
            THEN 'WAIT_FOR_IMPLEMENTATION'

        WHEN execution_decision = 'RUN_SAFE'
            THEN 'NORMAL_EXECUTION'

        ELSE 'MANUAL_REVIEW'

    END AS recommended_action,

    recommended_cooldown_seconds,

    CASE

        WHEN execution_decision = 'BLOCK' THEN 100
        WHEN execution_decision = 'WAIT' THEN 80
        WHEN execution_decision = 'RUN_WITH_CAUTION' THEN 60
        WHEN execution_decision = 'SMOKE_TEST' THEN 40
        WHEN execution_decision = 'PLANNED_ONLY' THEN 20
        WHEN execution_decision = 'RUN_SAFE' THEN 10
        ELSE 50

    END AS scheduler_priority,

    provider_health_score,
    provider_health_status,
    provider_presence_status,
    total_payloads,
    last_payload_at

FROM ops.v_execution_risk_full

ORDER BY
    scheduler_priority DESC,
    provider;