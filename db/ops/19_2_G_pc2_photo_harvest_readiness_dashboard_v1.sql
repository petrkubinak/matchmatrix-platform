/*
MATCHMATRIX SQL 19_2_G
PC2 Photo Harvest Readiness Dashboard V1 - FIXED

CO TO JE:
- Finální dashboard připravenosti photo/logo providerů pro PC2.
- Opravená verze bez chybějících sloupců api_available / automation_possible.

K ČEMU TO JE:
- Rozhodnutí, co půjde do prvního PC2 photo/logo testu.
- Oddělení FREE, LIMITED_FREE a PAID zdrojů.
- Vstup pro budoucí Photo Asset Worker.

KDE TO UVIDÍME:
- OPS Panel V18
- Provider Command Center
- PC2 Harvest Readiness

JAK SE TO VYUŽIJE:
- Prioritizace photo harvestu.
- Příprava automatických workerů.
*/

-- =====================================================
-- 1) PC2 READINESS DASHBOARD
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_photo_harvest_readiness_v1 AS
SELECT
    research_rank,
    sport_code,
    sport_name,
    entity_type,

    priority_score,

    recommended_provider,
    access_type,

    review_bucket,

    CASE
        WHEN review_bucket = 'PAID_PROVIDER_PLAN_CHECK'
            THEN 'WAIT_FOR_PAID'

        WHEN review_bucket = 'WIKIMEDIA_COMMONS_IMAGE_LICENSE_CHECK'
            THEN 'LICENSE_REVIEW'

        WHEN review_bucket = 'OFFICIAL_SITE_TERMS_CHECK'
            THEN 'LICENSE_REVIEW'

        ELSE 'MANUAL_REVIEW'
    END AS pc2_status,

    CASE
        WHEN review_bucket = 'WIKIMEDIA_COMMONS_IMAGE_LICENSE_CHECK'
            THEN 1

        WHEN review_bucket = 'OFFICIAL_SITE_TERMS_CHECK'
            THEN 2

        WHEN review_bucket = 'PAID_PROVIDER_PLAN_CHECK'
            THEN 4

        ELSE 9
    END AS pc2_priority,

    worker_needed,
    review_action_cs,
    next_action,
    updated_at

FROM ops.v_photo_license_review_action_plan_v2
ORDER BY
    pc2_priority,
    research_rank,
    priority_score DESC;


-- =====================================================
-- 2) SUMMARY
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_photo_harvest_readiness_summary_v1 AS
SELECT
    pc2_status,
    COUNT(*) AS rows_count
FROM ops.v_pc2_photo_harvest_readiness_v1
GROUP BY pc2_status
ORDER BY rows_count DESC;


-- =====================================================
-- 3) WIKIMEDIA / COMMONS FIRST TEST CANDIDATES
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_photo_commons_first_test_v1 AS
SELECT *
FROM ops.v_pc2_photo_harvest_readiness_v1
WHERE review_bucket = 'WIKIMEDIA_COMMONS_IMAGE_LICENSE_CHECK'
ORDER BY
    research_rank,
    priority_score DESC,
    sport_code,
    entity_type;


-- =====================================================
-- 4) OFFICIAL SITE LICENSE REVIEW
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_photo_official_site_review_v1 AS
SELECT *
FROM ops.v_pc2_photo_harvest_readiness_v1
WHERE review_bucket = 'OFFICIAL_SITE_TERMS_CHECK'
ORDER BY
    research_rank,
    priority_score DESC,
    sport_code,
    entity_type;


-- =====================================================
-- 5) PAID CANDIDATES
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_photo_wait_for_paid_v1 AS
SELECT *
FROM ops.v_pc2_photo_harvest_readiness_v1
WHERE pc2_status = 'WAIT_FOR_PAID'
ORDER BY
    pc2_priority,
    research_rank,
    priority_score DESC;


-- =====================================================
-- 6) ALL LICENSE REVIEW
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_photo_license_review_v1 AS
SELECT *
FROM ops.v_pc2_photo_harvest_readiness_v1
WHERE pc2_status = 'LICENSE_REVIEW'
ORDER BY
    pc2_priority,
    research_rank,
    priority_score DESC;


-- =====================================================
-- 7) COMPATIBILITY VIEW - READY FOR TEST
-- Poznámka:
-- Zatím nedáváme READY_FOR_TEST bez ověření licence.
-- Tento view ukazuje první technické kandidáty pro test po license checku.
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_photo_ready_for_test_v1 AS
SELECT *
FROM ops.v_pc2_photo_harvest_readiness_v1
WHERE review_bucket = 'WIKIMEDIA_COMMONS_IMAGE_LICENSE_CHECK'
ORDER BY
    research_rank,
    priority_score DESC,
    sport_code,
    entity_type;


-- =====================================================
-- 8) QUICK CHECK
-- =====================================================

SELECT
    pc2_status,
    COUNT(*) AS rows_count
FROM ops.v_pc2_photo_harvest_readiness_v1
GROUP BY pc2_status
ORDER BY rows_count DESC;