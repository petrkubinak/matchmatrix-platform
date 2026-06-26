/*
===============================================================================
MATCHMATRIX SQL 109_B
CREATE PROVIDER HEALTH FULL VIEW V1
===============================================================================

CO TO JE:
- Kompletní provider health view.
- Bere všechny providery z ops.provider_entity_coverage.
- Runtime data připojuje z ops.v_provider_health, pokud existují.

K ČEMU TO JE:
- Aby panel ukazoval i providery bez aktuálních payloadů:
  theodds, football_data, sportdataapi, pinnacle, betfair, sportradar atd.

KDE TO UVIDÍME:
- MatchMatrix Control Panel V17+
- AI OPS HEALTH

JAK SE TO VYUŽIJE:
- Full provider registry health
- AI OPS alerts
- Scheduler autopilot
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_provider_health_full AS

WITH provider_registry AS (

    SELECT
        provider,
        COUNT(*) AS coverage_entities,

        SUM(
            CASE WHEN is_enabled = TRUE THEN 1 ELSE 0 END
        ) AS enabled_entities,

        SUM(
            CASE WHEN coverage_status IN ('runtime_tested', 'tech_ready') THEN 1 ELSE 0 END
        ) AS ready_entities,

        SUM(
            CASE WHEN coverage_status = 'blocked' THEN 1 ELSE 0 END
        ) AS blocked_entities,

        SUM(
            CASE WHEN coverage_status = 'planned' THEN 1 ELSE 0 END
        ) AS planned_entities,

        MAX(updated_at) AS registry_updated_at

    FROM ops.provider_entity_coverage
    GROUP BY provider

)

SELECT
    pr.provider,
    pr.coverage_entities,
    pr.enabled_entities,
    pr.ready_entities,
    pr.blocked_entities,
    pr.planned_entities,

    COALESCE(vph.total_payloads, 0) AS total_payloads,
    COALESCE(vph.ok_payloads, 0) AS ok_payloads,
    COALESCE(vph.failed_payloads, 0) AS failed_payloads,
    COALESCE(vph.pending_payloads, 0) AS pending_payloads,
    COALESCE(vph.empty_payloads, 0) AS empty_payloads,
    COALESCE(vph.other_status_payloads, 0) AS other_status_payloads,

    COALESCE(vph.provider_health_score,
        CASE
            WHEN pr.ready_entities > 0 THEN 70
            WHEN pr.planned_entities > 0 THEN 40
            WHEN pr.blocked_entities > 0 THEN 10
            ELSE 30
        END
    ) AS provider_health_score,

    COALESCE(vph.provider_health_status,
        CASE
            WHEN pr.ready_entities > 0 THEN 'NO_RECENT_RUNTIME'
            WHEN pr.planned_entities > 0 THEN 'PLANNED'
            WHEN pr.blocked_entities > 0 THEN 'BLOCKED'
            ELSE 'UNKNOWN'
        END
    ) AS provider_health_status,

    CASE
        WHEN vph.provider IS NOT NULL THEN 'HAS_RUNTIME'
        WHEN pr.ready_entities > 0 THEN 'REGISTERED_READY_NO_RUNTIME'
        WHEN pr.planned_entities > 0 THEN 'REGISTERED_PLANNED'
        WHEN pr.blocked_entities > 0 THEN 'REGISTERED_BLOCKED'
        ELSE 'REGISTERED_UNKNOWN'
    END AS provider_presence_status,

    vph.last_payload_at,
    pr.registry_updated_at

FROM provider_registry pr
LEFT JOIN ops.v_provider_health vph
    ON vph.provider = pr.provider

ORDER BY provider_health_score DESC, pr.provider;