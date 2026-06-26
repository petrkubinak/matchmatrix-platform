/*
===============================================================================
MATCHMATRIX SQL 108_Y
CREATE EXECUTION RISK VIEW V1
===============================================================================

CO TO JE:
- Risk engine pro AI OPS.

K ČEMU TO JE:
- Vyhodnocuje riziko spuštění providerů.

KDE TO UVIDÍME:
- MatchMatrix Control Panel V17+
- AI OPS Dashboard

JAK SE TO VYUŽIJE:
- Scheduler Autopilot
- Retry Engine
- Smart Cooldown
- Future AI Orchestrator
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_execution_risk AS

SELECT

    provider,

    provider_health_score,

    provider_health_status,

    CASE

        WHEN provider_health_status = 'CRITICAL'
            THEN 100

        WHEN provider_health_status = 'HIGH'
            THEN 75

        WHEN provider_health_status = 'WARNING'
            THEN 40

        WHEN provider_health_status = 'HEALTHY'
            THEN 10

        ELSE 50

    END AS risk_score,

    CASE

        WHEN provider_health_status = 'CRITICAL'
            THEN 'BLOCK'

        WHEN provider_health_status = 'HIGH'
            THEN 'WAIT'

        WHEN provider_health_status = 'WARNING'
            THEN 'RUN_WITH_CAUTION'

        WHEN provider_health_status = 'HEALTHY'
            THEN 'RUN_SAFE'

        ELSE 'REVIEW'

    END AS execution_decision,

    CASE

        WHEN provider_health_status = 'CRITICAL'
            THEN 3600

        WHEN provider_health_status = 'HIGH'
            THEN 1800

        WHEN provider_health_status = 'WARNING'
            THEN 600

        ELSE 0

    END AS recommended_cooldown_seconds,

    last_payload_at

FROM ops.v_provider_health

ORDER BY risk_score DESC, provider;