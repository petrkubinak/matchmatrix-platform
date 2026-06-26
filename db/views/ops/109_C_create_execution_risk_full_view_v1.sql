/*
===============================================================================
MATCHMATRIX SQL 109_C
CREATE EXECUTION RISK FULL VIEW V1
===============================================================================

CO TO JE:
- Full execution risk view nad kompletním provider registry.

K ČEMU TO JE:
- Aby AI OPS rozhodovalo i o providerech bez posledního runtime payloadu.

KDE TO UVIDÍME:
- MatchMatrix Control Panel V17+
- AI OPS HEALTH / Risk sekce

JAK SE TO VYUŽIJE:
- Scheduler Autopilot
- Smart cooldown
- Provider instability alerts
- Autonomous retry engine
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_execution_risk_full AS

SELECT
    provider,
    provider_health_score,
    provider_health_status,
    provider_presence_status,
    coverage_entities,
    ready_entities,
    blocked_entities,
    planned_entities,
    total_payloads,

    CASE
        WHEN provider_health_status = 'CRITICAL' THEN 100
        WHEN provider_health_status = 'HIGH' THEN 75
        WHEN provider_health_status = 'WARNING' THEN 40
        WHEN provider_health_status = 'NO_RECENT_RUNTIME' THEN 35
        WHEN provider_health_status = 'PLANNED' THEN 25
        WHEN provider_health_status = 'BLOCKED' THEN 90
        WHEN provider_health_status = 'HEALTHY' THEN 10
        ELSE 50
    END AS risk_score,

    CASE
        WHEN provider_health_status = 'CRITICAL' THEN 'BLOCK'
        WHEN provider_health_status = 'BLOCKED' THEN 'BLOCK'
        WHEN provider_health_status = 'HIGH' THEN 'WAIT'
        WHEN provider_health_status = 'WARNING' THEN 'RUN_WITH_CAUTION'
        WHEN provider_health_status = 'NO_RECENT_RUNTIME' THEN 'SMOKE_TEST'
        WHEN provider_health_status = 'PLANNED' THEN 'PLANNED_ONLY'
        WHEN provider_health_status = 'HEALTHY' THEN 'RUN_SAFE'
        ELSE 'REVIEW'
    END AS execution_decision,

    CASE
        WHEN provider_health_status = 'CRITICAL' THEN 3600
        WHEN provider_health_status = 'BLOCKED' THEN 3600
        WHEN provider_health_status = 'HIGH' THEN 1800
        WHEN provider_health_status = 'WARNING' THEN 600
        WHEN provider_health_status = 'NO_RECENT_RUNTIME' THEN 0
        ELSE 0
    END AS recommended_cooldown_seconds,

    last_payload_at,
    registry_updated_at

FROM ops.v_provider_health_full

ORDER BY risk_score DESC, provider;