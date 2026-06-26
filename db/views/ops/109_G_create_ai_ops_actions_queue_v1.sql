/*
===============================================================================
MATCHMATRIX SQL 109_G
CREATE AI OPS ACTIONS QUEUE V1
===============================================================================

CO TO JE:
- AI Action Queue.

K ČEMU TO JE:
- Převádí Scheduler Autopilot doporučení na konkrétní AI akce.

KDE TO UVIDÍME:
- AI OPS záložka
- Budoucí Autonomous Scheduler

JAK SE TO VYUŽIJE:
- Retry Engine
- Cooldown Engine
- Provider Auto Suppression
- Scheduler Autopilot
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_ai_ops_actions_queue_v1 AS

SELECT

    ROW_NUMBER() OVER (
        ORDER BY
            scheduler_priority DESC,
            provider
    ) AS action_id,

    provider,

    execution_decision,

    recommended_action,

    recommendation_reason,

    scheduler_priority,

    recommended_cooldown_seconds,

    CASE

        WHEN recommended_action = 'DISABLE_PROVIDER'
            THEN 'PENDING'

        WHEN recommended_action = 'COOLDOWN'
            THEN 'PENDING'

        WHEN recommended_action = 'LIMITED_EXECUTION'
            THEN 'PENDING'

        WHEN recommended_action = 'RUN_SMOKE_TEST'
            THEN 'PENDING'

        WHEN recommended_action = 'WAIT_FOR_IMPLEMENTATION'
            THEN 'ON_HOLD'

        WHEN recommended_action = 'NORMAL_EXECUTION'
            THEN 'READY'

        ELSE 'REVIEW'

    END AS action_status,

    NOW() AS generated_at,

    provider_health_score,
    provider_health_status,
    provider_presence_status,
    total_payloads,
    last_payload_at

FROM ops.v_scheduler_autopilot_v1

ORDER BY
    scheduler_priority DESC,
    provider;