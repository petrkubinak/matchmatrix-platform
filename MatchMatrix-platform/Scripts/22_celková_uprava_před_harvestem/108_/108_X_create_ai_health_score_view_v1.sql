/*
===============================================================================
MATCHMATRIX SQL 108_X
CREATE AI HEALTH SCORE VIEW V1
===============================================================================

CO TO JE:
- Centrální AI OPS Health Score.

K ČEMU TO JE:
- Jedno číslo vyjadřující zdraví celé platformy.

KDE TO UVIDÍME:
- MatchMatrix Control Panel V17+
- AI OPS Dashboard

JAK SE TO VYUŽIJE:
- Scheduler Autopilot
- Execution Risk Prediction
- Autonomous Retry Engine
- Global OPS Monitoring
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_ai_health_score AS

WITH provider_stats AS (

    SELECT
        COUNT(*) AS provider_count,
        ROUND(AVG(provider_health_score), 2) AS avg_provider_score,

        SUM(
            CASE
                WHEN provider_health_status = 'HEALTHY'
                THEN 1 ELSE 0
            END
        ) AS healthy_count,

        SUM(
            CASE
                WHEN provider_health_status = 'WARNING'
                THEN 1 ELSE 0
            END
        ) AS warning_count,

        SUM(
            CASE
                WHEN provider_health_status = 'HIGH'
                THEN 1 ELSE 0
            END
        ) AS high_count,

        SUM(
            CASE
                WHEN provider_health_status = 'CRITICAL'
                THEN 1 ELSE 0
            END
        ) AS critical_count

    FROM ops.v_provider_health

)

SELECT

    NOW() AS calculated_at,

    provider_count,

    healthy_count,
    warning_count,
    high_count,
    critical_count,

    avg_provider_score,

    GREATEST(
        0,
        LEAST(
            100,
            ROUND(
                avg_provider_score
                - (critical_count * 15)
                - (high_count * 5)
            ,0)
        )
    ) AS global_health_score,

    CASE

        WHEN avg_provider_score >= 90
             AND critical_count = 0
            THEN 'EXCELLENT'

        WHEN avg_provider_score >= 75
             AND critical_count = 0
            THEN 'GOOD'

        WHEN avg_provider_score >= 50
            THEN 'WARNING'

        ELSE 'CRITICAL'

    END AS health_status

FROM provider_stats;