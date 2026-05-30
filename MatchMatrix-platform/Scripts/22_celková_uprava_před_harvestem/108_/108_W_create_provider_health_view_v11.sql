/*
===============================================================================
MATCHMATRIX SQL 108_W
CREATE PROVIDER HEALTH VIEW V1
===============================================================================

CO TO JE:
- Provider health view počítaná z reálných payloadů ve staging.stg_api_payloads.

K ČEMU TO JE:
- Ukáže stabilitu providerů podle parse_status.
- Připraví základ pro AI OPS SCORE, retry engine a scheduler autopilot.

KDE TO UVIDÍME:
- MatchMatrix Control Panel V17+
- AI OPS / Provider Health sekce

JAK SE TO VYUŽIJE:
- Provider instability detection
- Execution risk prediction
- Smart cooldown
- Autonomous retry engine
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_provider_health AS

WITH base AS (

    SELECT
        provider,
        sport_code,
        entity_type,
        parse_status,
        fetched_at
    FROM staging.stg_api_payloads
    WHERE fetched_at >= NOW() - INTERVAL '30 days'

),

agg AS (

    SELECT
        provider,

        COUNT(*) AS total_payloads,

        SUM(
            CASE
                WHEN LOWER(COALESCE(parse_status, '')) IN ('parsed', 'done', 'ok', 'success')
                THEN 1 ELSE 0
            END
        ) AS ok_payloads,

        SUM(
            CASE
                WHEN LOWER(COALESCE(parse_status, '')) IN ('failed', 'error')
                THEN 1 ELSE 0
            END
        ) AS failed_payloads,

        SUM(
            CASE
                WHEN LOWER(COALESCE(parse_status, '')) IN ('pending')
                THEN 1 ELSE 0
            END
        ) AS pending_payloads,

        SUM(
            CASE
                WHEN LOWER(COALESCE(parse_status, '')) IN ('empty')
                THEN 1 ELSE 0
            END
        ) AS empty_payloads,

        MAX(fetched_at) AS last_payload_at

    FROM base
    GROUP BY provider

)

SELECT
    provider,
    total_payloads,
    ok_payloads,
    failed_payloads,
    pending_payloads,
    empty_payloads,

    ROUND(
        CASE
            WHEN total_payloads = 0 THEN 0
            ELSE ok_payloads::numeric * 100.0 / total_payloads
        END,
        2
    ) AS success_rate,

    ROUND(
        CASE
            WHEN total_payloads = 0 THEN 0
            ELSE failed_payloads::numeric * 100.0 / total_payloads
        END,
        2
    ) AS error_rate,

    CASE
        WHEN total_payloads = 0 THEN 0
        ELSE GREATEST(
            0,
            LEAST(
                100,
                ROUND(
                    (
                        (ok_payloads::numeric * 100.0 / total_payloads)
                        - (failed_payloads::numeric * 50.0 / total_payloads)
                        - (pending_payloads::numeric * 10.0 / total_payloads)
                    ),
                    0
                )
            )
        )
    END AS provider_health_score,

    CASE
        WHEN total_payloads = 0 THEN 'UNKNOWN'
        WHEN failed_payloads > 0
             AND failed_payloads::numeric / total_payloads >= 0.30
            THEN 'CRITICAL'
        WHEN failed_payloads > 0
             AND failed_payloads::numeric / total_payloads >= 0.15
            THEN 'HIGH'
        WHEN pending_payloads > 0
             AND pending_payloads::numeric / total_payloads >= 0.30
            THEN 'WARNING'
        WHEN ok_payloads::numeric / total_payloads >= 0.90
            THEN 'HEALTHY'
        ELSE 'WARNING'
    END AS provider_health_status,

    last_payload_at

FROM agg

ORDER BY provider_health_score DESC, provider;