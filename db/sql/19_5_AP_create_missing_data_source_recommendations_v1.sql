/*
===============================================================================
MATCHMATRIX 19_5_AP
MISSING DATA SOURCE RECOMMENDATIONS V1
===============================================================================

KAM ULOŽIT:
C:\MatchMatrix-platform\sql\governance\

NÁZEV SOUBORU:
19_5_AP_create_missing_data_source_recommendations_v1.sql

CO TO JE:
Pohled, který propojí datové mezery se Source Discovery Engine.

K ČEMU TO JE:
Ukáže, kde chybí data a jaký náhradní zdroj má systém zkusit.

KDE TO UVIDÍME:
ops.v_missing_data_source_recommendations_v1

JAK SE TO VYUŽIJE:
Autonomní harvest při chybě / 0 datech dostane doporučení:
API provider, official team site, official league site, RSS, sitemap,
Wikidata, Wikimedia, CSV nebo paid feed.
===============================================================================
*/

DROP VIEW IF EXISTS ops.v_missing_data_source_recommendations_v1;

CREATE VIEW ops.v_missing_data_source_recommendations_v1 AS
SELECT
    g.provider,
    g.sport_code,
    g.entity AS entity_type,

    g.coverage_status,
    g.gap_status_code,
    g.gap_reason_cz,
    g.next_action AS gap_next_action,

    d.required_field,
    d.source_type,
    d.discovery_decision,
    d.discovery_score,
    d.license_risk,
    d.trust_level,
    d.automation_level,
    d.discovery_note,
    d.expected_data,
    d.next_action AS discovery_next_action,

    CASE
        WHEN d.discovery_decision = 'AUTO_DISCOVERY_READY'
            THEN 'AUTO_DISCOVERY'
        WHEN d.discovery_decision = 'HIGH_TRUST_MANUAL_REVIEW'
            THEN 'MANUAL_SOURCE_REVIEW'
        WHEN d.discovery_decision = 'LICENSE_REVIEW_REQUIRED'
            THEN 'LICENSE_REVIEW'
        ELSE 'FALLBACK_REVIEW'
    END AS recommended_mode,

    NOW() AS generated_at

FROM ops.v_data_gap_engine_v2 g
JOIN ops.v_source_discovery_engine_v1 d
    ON d.entity_type = UPPER(g.entity)
   AND (
        d.sport_code = g.sport_code
        OR d.sport_code = 'ALL'
   )
WHERE g.coverage_status NOT IN ('CONFIRMED', 'READY', 'DONE')
ORDER BY
    g.sport_code,
    g.entity,
    d.discovery_score DESC;