/*
===============================================================================
MATCHMATRIX SQL 108_Z
CREATE PROVIDER INSTABILITY VIEW V1
===============================================================================

CO TO JE:
- Detektor nestability providerů.

K ČEMU TO JE:
- AI OPS Alert Center.
- Scheduler Autopilot.
- Retry Intelligence.

KDE TO UVIDÍME:
- MatchMatrix Control Panel V17+
- AI OPS Dashboard

JAK SE TO VYUŽIJE:
- Provider instability detection
- Auto suppression
- Autonomous retry engine
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_provider_instability AS

SELECT

    provider,

    provider_health_score,

    provider_health_status,

    CASE

        WHEN provider_health_status = 'CRITICAL'
            THEN 'UNSTABLE'

        WHEN provider_health_status = 'HIGH'
            THEN 'DEGRADED'

        WHEN provider_health_status = 'WARNING'
            THEN 'WATCH'

        WHEN provider_health_status = 'HEALTHY'
            THEN 'STABLE'

        ELSE 'UNKNOWN'

    END AS stability_level,

    CASE

        WHEN provider_health_status = 'CRITICAL'
            THEN TRUE

        WHEN provider_health_status = 'HIGH'
            THEN TRUE

        ELSE FALSE

    END AS requires_attention,

    CASE

        WHEN provider_health_status = 'CRITICAL'
            THEN 'BLOCK_AND_REVIEW'

        WHEN provider_health_status = 'HIGH'
            THEN 'COOLDOWN_AND_MONITOR'

        WHEN provider_health_status = 'WARNING'
            THEN 'MONITOR'

        ELSE 'NO_ACTION'

    END AS recommended_action,

    last_payload_at

FROM ops.v_provider_health

ORDER BY provider_health_score ASC, provider;