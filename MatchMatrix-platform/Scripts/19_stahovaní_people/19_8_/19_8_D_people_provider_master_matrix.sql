/*
===============================================================================
MATCHMATRIX 19_8_D – PEOPLE PROVIDER MASTER MATRIX
===============================================================================

CO TO JE:
Finální master matice providerů pro People Layer.

K ČEMU TO JE:
Spojuje Source Gap Analysis, Provider Roadmap a Provider Scorecard
do jednoho hlavního přehledu.

KDE TO UVIDÍME:

OPS Panel
→ PEOPLE
→ PROVIDER MASTER MATRIX

Databáze:
ops.v_people_provider_master_matrix_v1

JAK SE TO VYUŽIJE:

- hlavní přehled People providerů
- plánování PC2 práce
- výběr FREE / PAID providerů
- rozhodnutí co enrichovat a co hledat znovu
- příprava Photo Layer 2.0
- příprava PRO / paid měsíce

NAVAZUJE NA:

19_7_A People Source Gap Analysis
19_7_A2 People Source Gap Analysis Fix
19_7_B People Provider Roadmap
19_7_C People PC2 Work Queue
19_8_A People Source Discovery Registry
19_8_B People Source Discovery Dashboard
19_8_B1 People Source Discovery Seed
19_8_C People Provider Scorecard

DALŠÍ KROK:

19_8_E People Provider Action Queue

===============================================================================
*/

DROP VIEW IF EXISTS ops.v_people_provider_master_matrix_v1;

CREATE VIEW ops.v_people_provider_master_matrix_v1 AS
SELECT
    sc.sport_code,
    sc.entity_type,
    sc.provider_name,
    sc.access_type,
    sc.status,

    sc.supports_players,
    sc.supports_coaches,
    sc.supports_photos,
    sc.supports_birth_date,
    sc.supports_nationality,
    sc.supports_position,

    sc.quality_score,
    sc.provider_total_score,
    sc.provider_rating,
    sc.primary_gap,

    r.total_players,
    r.profile_quality_pct,
    r.gap_type,
    r.priority_score AS sport_priority_score,
    r.recommended_provider_path,
    r.pc2_work_type,
    r.next_action,

    CASE
        WHEN sc.provider_rating = 'READY'
             AND sc.access_type IN ('FREE', 'FREE_LIMITED')
        THEN 'USE_NOW'

        WHEN sc.provider_rating = 'READY'
             AND sc.access_type = 'PAID'
        THEN 'USE_WHEN_PAID_ACTIVE'

        WHEN sc.provider_rating = 'GOOD'
             AND sc.primary_gap = 'PHOTO_GAP'
        THEN 'USE_FOR_PROFILE_THEN_PHOTO_FALLBACK'

        WHEN sc.provider_rating = 'GOOD'
             AND sc.primary_gap = 'PROFILE_GAP'
        THEN 'USE_WITH_FALLBACK_PROFILE_SOURCE'

        WHEN sc.provider_rating = 'PARTIAL'
        THEN 'RESEARCH_AND_TEST'

        WHEN sc.provider_rating = 'RESEARCH'
        THEN 'FIND_REPLACEMENT_OR_VERIFY'

        WHEN sc.provider_rating = 'PHOTO_FALLBACK'
        THEN 'PHOTO_FALLBACK_SOURCE'

        ELSE 'MANUAL_REVIEW'
    END AS master_decision,

    CASE
        WHEN sc.sport_code = 'FB' THEN 1
        WHEN sc.sport_code = 'BK' THEN 2
        WHEN sc.sport_code = 'BSB' THEN 3
        WHEN sc.sport_code = 'HK' THEN 4
        WHEN sc.sport_code = 'MMA' THEN 5
        WHEN sc.sport_code = 'TN' THEN 6
        WHEN sc.sport_code = 'CK' THEN 7
        WHEN sc.sport_code = 'AFB' THEN 8
        WHEN sc.sport_code = 'ALL' THEN 99
        ELSE 50
    END AS sport_order,

    sc.notes,
    sc.discovered_at

FROM ops.v_people_provider_scorecard_v1 sc
LEFT JOIN ops.v_people_provider_roadmap_v1 r
    ON r.sport_code = sc.sport_code;