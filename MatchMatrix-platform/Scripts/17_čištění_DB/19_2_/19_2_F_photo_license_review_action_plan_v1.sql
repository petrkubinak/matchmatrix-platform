/*
MATCHMATRIX SQL 19_2_F
Photo License Review Action Plan V1

CO TO JE:
- Akční plán pro ověření licencí photo/logo providerů.
- Připravuje kandidáty pro schválení do PC2 harvestu.

K ČEMU TO JE:
- Oddělit bezpečné zdroje.
- Připravit budoucí photo worker pipeline.
- Minimalizovat právní rizika.

KDE TO UVIDÍME:
- OPS Panel V18
- Provider Command Center
- Photo Provider Research

JAK SE TO VYUŽIJE:
- Převod LICENSE_REVIEW -> READY_FOR_TEST
- Převod LICENSE_REVIEW -> REJECTED
- Převod WAIT_FOR_PAID -> APPROVED po aktivaci placeného plánu
*/

-- =====================================================
-- ACTION PLAN VIEW
-- =====================================================

CREATE OR REPLACE VIEW ops.v_photo_license_review_action_plan_v1 AS
SELECT
    research_rank,

    sport_code,
    sport_name,

    entity_type,

    priority_score,

    recommended_provider,
    access_type,

    research_provider_url,

    CASE
        WHEN recommended_provider ILIKE '%Wikimedia%'
            THEN 'OVĚŘIT COMMONS LICENCE'

        WHEN recommended_provider ILIKE '%Wikipedia%'
            THEN 'OVĚŘIT ZDROJ OBRÁZKU'

        WHEN recommended_provider ILIKE '%Official%'
            THEN 'OVĚŘIT PODMÍNKY OFICIÁLNÍHO WEBU'

        WHEN access_type = 'PAID'
            THEN 'OVĚŘIT PLACENÝ PLÁN'

        ELSE 'MANUÁLNÍ KONTROLA'
    END AS review_action,

    CASE
        WHEN access_type = 'FREE'
            THEN 1

        WHEN access_type = 'LIMITED_FREE'
            THEN 2

        WHEN access_type = 'PAID'
            THEN 3

        ELSE 9
    END AS review_priority,

    research_status,

    worker_needed,

    next_action,

    updated_at

FROM ops.provider_missing_matrix
WHERE
    entity_type IN (
        'PLAYER_PHOTOS',
        'COACH_PHOTOS',
        'TEAM_LOGOS',
        'STADIUM_PHOTOS'
    )
ORDER BY
    review_priority,
    research_rank,
    priority_score DESC;

-- =====================================================
-- REVIEW SUMMARY
-- =====================================================

CREATE OR REPLACE VIEW ops.v_photo_license_review_summary_v1 AS
SELECT
    review_action,
    COUNT(*) AS rows_count
FROM ops.v_photo_license_review_action_plan_v1
GROUP BY review_action
ORDER BY rows_count DESC;

-- =====================================================
-- FREE CANDIDATES
-- =====================================================

CREATE OR REPLACE VIEW ops.v_photo_license_free_candidates_v1 AS
SELECT *
FROM ops.v_photo_license_review_action_plan_v1
WHERE access_type = 'FREE'
ORDER BY
    research_rank,
    priority_score DESC;

-- =====================================================
-- LIMITED FREE CANDIDATES
-- =====================================================

CREATE OR REPLACE VIEW ops.v_photo_license_limited_candidates_v1 AS
SELECT *
FROM ops.v_photo_license_review_action_plan_v1
WHERE access_type = 'LIMITED_FREE'
ORDER BY
    research_rank,
    priority_score DESC;

-- =====================================================
-- PAID CANDIDATES
-- =====================================================

CREATE OR REPLACE VIEW ops.v_photo_license_paid_candidates_v1 AS
SELECT *
FROM ops.v_photo_license_review_action_plan_v1
WHERE access_type = 'PAID'
ORDER BY
    research_rank,
    priority_score DESC;

-- =====================================================
-- QUICK CHECK
-- =====================================================

SELECT
    review_action,
    COUNT(*) AS rows_count
FROM ops.v_photo_license_review_action_plan_v1
GROUP BY review_action
ORDER BY rows_count DESC;