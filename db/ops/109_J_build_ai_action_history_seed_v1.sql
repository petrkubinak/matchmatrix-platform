/*
===============================================================================
MATCHMATRIX SQL 109_J
BUILD AI ACTION HISTORY SEED V1
===============================================================================
*/

INSERT INTO ops.ai_action_execution_log (

    action_id,
    provider,
    execution_decision,
    action_type,
    action_status,
    recommendation_reason,
    scheduler_priority,
    recommended_cooldown_seconds,
    risk_score,
    provider_health_score,
    provider_health_status,
    provider_presence_status,
    execution_started_at,
    execution_finished_at,
    execution_result
)

SELECT
    q.action_id,
    q.provider,
    q.execution_decision,
    q.recommended_action,
    'DONE',
    q.recommendation_reason,
    q.scheduler_priority,
    q.recommended_cooldown_seconds,
    NULL,
    q.provider_health_score,
    q.provider_health_status,
    q.provider_presence_status,
    NOW(),
    NOW(),
    'SIMULATED_EXECUTION_OK'

FROM ops.v_ai_ops_actions_queue_v1 q

WHERE NOT EXISTS (
    SELECT 1
    FROM ops.ai_action_execution_log e
    WHERE e.action_id = q.action_id
);