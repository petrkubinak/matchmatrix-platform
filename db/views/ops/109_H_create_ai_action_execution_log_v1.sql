/*
===============================================================================
MATCHMATRIX SQL 109_H
CREATE AI ACTION EXECUTION LOG V1
===============================================================================

CO TO JE:
- Historická tabulka pro AI OPS akce.

K ČEMU TO JE:
- Abychom evidovali, co AI doporučila, co bylo vykonáno a jak to dopadlo.

KDE TO UVIDÍME:
- AI OPS záložka
- Budoucí AI ACTION HISTORY panel

JAK SE TO VYUŽIJE:
- Autonomous Retry Engine
- Scheduler Autopilot
- Provider Auto Suppression
- Self-Healing Infrastructure
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.ai_action_execution_log (

    id BIGSERIAL PRIMARY KEY,

    action_id BIGINT,

    provider TEXT,
    execution_decision TEXT,
    action_type TEXT,
    action_status TEXT DEFAULT 'PENDING',

    recommendation_reason TEXT,

    scheduler_priority INTEGER,
    recommended_cooldown_seconds INTEGER,
    risk_score INTEGER,

    provider_health_score INTEGER,
    provider_health_status TEXT,
    provider_presence_status TEXT,

    execution_started_at TIMESTAMPTZ,
    execution_finished_at TIMESTAMPTZ,
    execution_result TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_ai_action_execution_log_provider
ON ops.ai_action_execution_log(provider);

CREATE INDEX IF NOT EXISTS ix_ai_action_execution_log_status
ON ops.ai_action_execution_log(action_status);

CREATE INDEX IF NOT EXISTS ix_ai_action_execution_log_created_at
ON ops.ai_action_execution_log(created_at DESC);