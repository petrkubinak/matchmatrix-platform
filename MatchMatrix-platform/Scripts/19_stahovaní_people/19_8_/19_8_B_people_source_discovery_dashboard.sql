/*
===============================================================================
MATCHMATRIX 19_8_B – PEOPLE SOURCE DISCOVERY DASHBOARD
===============================================================================

CO TO JE:
Dashboard nad registrem People Source Discovery.

K ČEMU TO JE:
Poskytuje centrální přehled všech providerů používaných
nebo zkoumaných pro People Layer.

Umožňuje rychle zjistit:

- které sporty mají pokrytí hráčů
- které sporty mají pokrytí trenérů
- které sporty mají fotografie
- které sporty mají datum narození
- které sporty mají národnost
- které sporty mají pozice
- které providery je potřeba nahradit

KDE TO UVIDÍME:

OPS Panel
→ PEOPLE
→ SOURCE DISCOVERY DASHBOARD

Databáze:
ops.v_people_source_discovery_dashboard_v1

JAK SE TO VYUŽIJE:

- Source Discovery
- People Layer Planning
- PC2 Harvest Planning
- Provider Selection
- Future Paid Provider Planning
- Photo Layer 2.0

NAVAZUJE NA:

19_7_A People Source Gap Analysis
19_7_A2 People Source Gap Analysis Fix
19_7_B People Provider Roadmap
19_7_C People PC2 Work Queue
19_8_A People Source Discovery Registry

DALŠÍ KROK:

19_8_C People Provider Scorecard
19_8_D People Provider Master Matrix

===============================================================================
*/

DROP VIEW IF EXISTS ops.v_people_source_discovery_dashboard_v1;

CREATE VIEW ops.v_people_source_discovery_dashboard_v1 AS
SELECT

    registry_id,

    sport_code,

    entity_type,

    provider_name,

    access_type,

    status,

    quality_score,

    supports_players,
    supports_coaches,
    supports_photos,
    supports_birth_date,
    supports_nationality,
    supports_position,

    CASE

        WHEN
            supports_players = TRUE
            AND supports_birth_date = TRUE
            AND supports_nationality = TRUE
            AND supports_position = TRUE
        THEN 'FULL_PROFILE'

        WHEN
            supports_players = TRUE
        THEN 'PARTIAL_PROFILE'

        ELSE 'SOURCE_GAP'

    END AS profile_support_level,

    CASE

        WHEN quality_score >= 90 THEN 'READY'
        WHEN quality_score >= 70 THEN 'GOOD'
        WHEN quality_score >= 50 THEN 'PARTIAL'
        ELSE 'RESEARCH'

    END AS provider_rating,

    notes,

    discovered_at

FROM ops.people_source_discovery_registry;