/*
===============================================================================
MATCHMATRIX SQL 109_I
CREATE AI ACTION HISTORY VIEW V1
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_ai_action_history_v1 AS

SELECT
    id,
    action_id,
    provider,
    action_type,
    action_status,
    execution_decision,
    recommendation_reason,
    scheduler_priority,
    recommended_cooldown_seconds,
    risk_score,
    provider_health_status,
    provider_presence_status,
    execution_started_at,
    execution_finished_at,
    execution_result,
    created_at,
    updated_at
FROM ops.ai_action_execution_log
ORDER BY created_at DESC, id DESC;