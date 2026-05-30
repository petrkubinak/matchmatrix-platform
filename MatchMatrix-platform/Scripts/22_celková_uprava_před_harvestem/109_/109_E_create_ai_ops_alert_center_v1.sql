/*
===============================================================================
MATCHMATRIX SQL 109_E
CREATE AI OPS ALERT CENTER V1
===============================================================================

CO TO JE:
- AI OPS alert center nad full execution riskem.

K ČEMU TO JE:
- Převádí BLOCK / WAIT / SMOKE_TEST / PLANNED_ONLY na přehledné alerty.

KDE TO UVIDÍME:
- MatchMatrix Control Panel V17+
- Budoucí záložka AI OPS ALERTS

JAK SE TO VYUŽIJE:
- Blinking critical states
- Alert grouping
- Noise filtering
- Scheduler autopilot
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_ai_ops_alert_center_v1 AS

SELECT
    provider,

    provider_health_status,
    provider_presence_status,
    execution_decision,
    risk_score,

    CASE
        WHEN execution_decision = 'BLOCK' THEN 'CRITICAL'
        WHEN execution_decision = 'WAIT' THEN 'HIGH'
        WHEN execution_decision = 'RUN_WITH_CAUTION' THEN 'WARNING'
        WHEN execution_decision = 'SMOKE_TEST' THEN 'INFO'
        WHEN execution_decision = 'PLANNED_ONLY' THEN 'INFO'
        WHEN execution_decision = 'RUN_SAFE' THEN 'OK'
        ELSE 'REVIEW'
    END AS ai_alert_severity,

    CASE
        WHEN execution_decision = 'BLOCK'
            THEN 'Provider is blocked for autonomous execution.'

        WHEN execution_decision = 'WAIT'
            THEN 'Provider should wait because recent runtime health is degraded.'

        WHEN execution_decision = 'RUN_WITH_CAUTION'
            THEN 'Provider can run, but with caution and cooldown.'

        WHEN execution_decision = 'SMOKE_TEST'
            THEN 'Provider is registered and ready, but has no recent runtime data.'

        WHEN execution_decision = 'PLANNED_ONLY'
            THEN 'Provider is planned but not runtime-ready.'

        WHEN execution_decision = 'RUN_SAFE'
            THEN 'Provider is healthy and safe to run.'

        ELSE 'Provider requires manual review.'
    END AS ai_alert_message,

    recommended_cooldown_seconds,
    coverage_entities,
    ready_entities,
    blocked_entities,
    planned_entities,
    total_payloads,
    last_payload_at,
    registry_updated_at

FROM ops.v_execution_risk_full

WHERE execution_decision <> 'RUN_SAFE'

ORDER BY
    risk_score DESC,
    provider;