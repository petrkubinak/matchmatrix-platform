/*
===============================================================================
MATCHMATRIX 19_8_C – PEOPLE PROVIDER SCORECARD
===============================================================================

CO TO JE:
Hodnotící karta providerů People Layer.

K ČEMU TO JE:
Přepočítává capabilities providerů na jednotné skóre
a určuje jejich skutečnou použitelnost pro MatchMatrix.

KDE TO UVIDÍME:

OPS Panel
→ PEOPLE
→ PROVIDER SCORECARD

Databáze:
ops.v_people_provider_scorecard_v1

JAK SE TO VYUŽIJE:

- výběr providerů pro PC2
- plánování placených providerů
- People Layer roadmap
- Photo Layer 2.0
- Source Discovery

NAVAZUJE NA:

19_7_A People Source Gap Analysis
19_7_A2 People Source Gap Analysis Fix
19_7_B People Provider Roadmap
19_7_C People PC2 Work Queue
19_8_A People Source Discovery Registry
19_8_B People Source Discovery Dashboard

DALŠÍ KROK:

19_8_D People Provider Master Matrix

===============================================================================
*/

DROP VIEW IF EXISTS ops.v_people_provider_scorecard_v1;

CREATE VIEW ops.v_people_provider_scorecard_v1 AS
SELECT

    registry_id,
    sport_code,
    entity_type,
    provider_name,
    access_type,
    status,

    supports_players,
    supports_coaches,
    supports_photos,
    supports_birth_date,
    supports_nationality,
    supports_position,

    quality_score,

    (
        quality_score

        + CASE WHEN supports_players THEN 20 ELSE 0 END
        + CASE WHEN supports_coaches THEN 10 ELSE 0 END
        + CASE WHEN supports_photos THEN 15 ELSE 0 END
        + CASE WHEN supports_birth_date THEN 15 ELSE 0 END
        + CASE WHEN supports_nationality THEN 10 ELSE 0 END
        + CASE WHEN supports_position THEN 10 ELSE 0 END

        + CASE
            WHEN access_type = 'FREE' THEN 15
            WHEN access_type = 'FREE_LIMITED' THEN 10
            ELSE 0
          END

    ) AS provider_total_score,

    CASE

        WHEN entity_type = 'PHOTOS'
        THEN 'PHOTO_FALLBACK'

        WHEN
            quality_score >= 90
            AND supports_players
            AND supports_birth_date
            AND supports_position
        THEN 'READY'

        WHEN
            quality_score >= 70
        THEN 'GOOD'

        WHEN
            quality_score >= 50
        THEN 'PARTIAL'

        ELSE 'RESEARCH'

    END AS provider_rating,

    CASE

        WHEN entity_type = 'PHOTOS'
        THEN 'PHOTO_LAYER'

        WHEN supports_birth_date = FALSE
             AND supports_nationality = FALSE
        THEN 'PROFILE_GAP'

        WHEN supports_photos = FALSE
        THEN 'PHOTO_GAP'

        ELSE 'READY'

    END AS primary_gap,

    notes,
    discovered_at

FROM ops.people_source_discovery_registry;