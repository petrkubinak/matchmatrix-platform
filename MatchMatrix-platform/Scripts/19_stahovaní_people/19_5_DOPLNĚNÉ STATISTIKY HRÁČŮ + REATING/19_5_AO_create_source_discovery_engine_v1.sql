/*
===============================================================================
MATCHMATRIX 19_5_AO
SOURCE DISCOVERY ENGINE V1
===============================================================================

KAM ULOŽIT:
C:\MatchMatrix-platform\sql\governance\

NÁZEV SOUBORU:
19_5_AO_create_source_discovery_engine_v1.sql

CO TO JE:
Rozhodovací pohled pro hledání náhradních a doplňkových zdrojů dat.

K ČEMU TO JE:
Spojuje požadavky na entity s typy zdrojů, kde lze data hledat.

KDE TO UVIDÍME:
ops.v_source_discovery_engine_v1

JAK SE TO VYUŽIJE:
Autonomous Harvest, Data Gap Engine a Provider Routing získají doporučení,
kam sáhnout, když primární provider vrací 0 dat nebo neúplná data.
===============================================================================
*/

DROP VIEW IF EXISTS ops.v_source_discovery_engine_v1;

CREATE VIEW ops.v_source_discovery_engine_v1 AS
SELECT
    r.sport_code,
    r.entity_type,
    r.required_field,

    s.source_type,
    s.trust_level,
    s.automation_level,
    s.license_risk,
    s.priority_order,

    s.is_primary_candidate,
    s.is_fallback_candidate,
    s.discovery_note,
    s.expected_data,
    s.next_action,

    r.web_required,
    r.prediction_required,
    r.ticket_engine_required,
    r.importance_score,

    CASE
        WHEN s.license_risk = 'HIGH'
            THEN 'LICENSE_REVIEW_REQUIRED'
        WHEN s.automation_level >= 80
             AND s.trust_level >= 80
            THEN 'AUTO_DISCOVERY_READY'
        WHEN s.trust_level >= 90
             AND s.automation_level < 60
            THEN 'HIGH_TRUST_MANUAL_REVIEW'
        WHEN s.is_fallback_candidate = TRUE
            THEN 'FALLBACK_DISCOVERY_CANDIDATE'
        ELSE 'REVIEW_REQUIRED'
    END AS discovery_decision,

    CASE
        WHEN r.ticket_engine_required = TRUE THEN 100
        WHEN r.prediction_required = TRUE THEN 90
        WHEN r.web_required = TRUE THEN 70
        ELSE 50
    END
    + r.importance_score
    + s.trust_level
    + s.automation_level
    - CASE
        WHEN s.license_risk = 'HIGH' THEN 100
        WHEN s.license_risk = 'REVIEW' THEN 30
        ELSE 0
      END AS discovery_score,

    NOW() AS generated_at

FROM ops.entity_requirement_matrix r
JOIN ops.source_discovery_matrix s
    ON s.entity_type = r.entity_type
   AND s.is_enabled = TRUE
   AND (
        s.sport_code = r.sport_code
        OR s.sport_code = 'ALL'
   );