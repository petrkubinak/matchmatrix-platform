/*
================================================================================
MATCHMATRIX 19_5_AR - SOURCE DISCOVERY QUEUE V1
================================================================================

KAM ULOŽIT:
C:\MatchMatrix-platform\sql\governance\

NÁZEV SOUBORU:
19_5_AR_create_source_discovery_queue_v1.sql

CO TO JE:
-----------
Akční fronta pro hledání nových, náhradních a doplňkových zdrojů dat.

K ČEMU TO JE:
--------------
Převádí Source Discovery Summary na konkrétní úkoly pro autonomní systém.

KDE TO UVIDÍME:
----------------
ops.v_source_discovery_queue_v1

OPS Panel:
- Source Discovery
- Provider Discovery
- Autonomous Harvest
- Data Gap

JAK SE TO VYUŽIJE:
------------------
Autonomní systém z této fronty vybere úkol:

- AUTO_DISCOVERY
- MANUAL_SOURCE_REVIEW
- FALLBACK_REVIEW
- LICENSE_REVIEW

a podle sportu/entity/provideru začne hledat vhodný zdroj.

PŘÍKLAD:
--------
HB players api_handball BLOCKED
↓
OFFICIAL_TEAM_SITE / OFFICIAL_LEAGUE_SITE / FEDERATION_SITE
↓
Source Discovery task

VÝSTUP:
--------
queue_priority
sport_code
entity_type
provider
coverage_status
source_type
recommended_mode
missing_fields
best_score
discovery_task_type
task_status
suggested_action

================================================================================
*/

DROP VIEW IF EXISTS ops.v_source_discovery_queue_v1;

CREATE VIEW ops.v_source_discovery_queue_v1 AS

SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            CASE
                WHEN recommended_mode = 'AUTO_DISCOVERY' THEN 1
                WHEN recommended_mode = 'FALLBACK_REVIEW' THEN 2
                WHEN recommended_mode = 'MANUAL_SOURCE_REVIEW' THEN 3
                WHEN recommended_mode = 'LICENSE_REVIEW' THEN 4
                ELSE 9
            END,
            best_score DESC,
            missing_fields DESC,
            sport_code,
            entity_type
    ) AS queue_priority,

    sport_code,
    entity_type,
    provider,
    coverage_status,
    source_type,
    recommended_mode,
    missing_fields,
    best_score,

    CASE
        WHEN recommended_mode = 'AUTO_DISCOVERY'
            THEN 'AUTO_SOURCE_DISCOVERY'
        WHEN recommended_mode = 'FALLBACK_REVIEW'
            THEN 'FALLBACK_SOURCE_REVIEW'
        WHEN recommended_mode = 'MANUAL_SOURCE_REVIEW'
            THEN 'MANUAL_SOURCE_VALIDATION'
        WHEN recommended_mode = 'LICENSE_REVIEW'
            THEN 'LICENSE_AND_TERMS_CHECK'
        ELSE 'REVIEW_REQUIRED'
    END AS discovery_task_type,

    CASE
        WHEN coverage_status IN ('blocked', 'BLOCKED')
            THEN 'HIGH_PRIORITY'
        WHEN coverage_status IN ('planned', 'PLANNED')
            THEN 'PLANNED'
        WHEN coverage_status IN ('runtime_tested', 'tech_ready')
            THEN 'VERIFY_AND_SCALE'
        ELSE 'REVIEW'
    END AS task_status,

    CASE
        WHEN recommended_mode = 'AUTO_DISCOVERY'
            THEN 'Spustit automatické vyhledání/ověření zdroje.'
        WHEN recommended_mode = 'FALLBACK_REVIEW'
            THEN 'Prověřit fallback zdroj a rozhodnout, zda jej povolit.'
        WHEN recommended_mode = 'MANUAL_SOURCE_REVIEW'
            THEN 'Ručně ověřit oficiální zdroj a možnost automatizace.'
        WHEN recommended_mode = 'LICENSE_REVIEW'
            THEN 'Prověřit licenci, Terms of Use a právní použitelnost.'
        ELSE 'Provést ruční kontrolu.'
    END AS suggested_action,

    NOW() AS generated_at

FROM ops.v_source_discovery_summary_v1;