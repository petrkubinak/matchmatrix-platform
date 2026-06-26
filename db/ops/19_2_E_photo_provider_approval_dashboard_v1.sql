/*
MATCHMATRIX SQL 19_2_E Photo Provider Approval Dashboard V1

CO TO JE:
- Vytváří schvalovací dashboard nad photo/logo/stadium providery.
- Rozděluje kandidáty na READY_FOR_TEST, CHECK_TERMS, WAIT_FOR_PAID a BLOCKED.

K ČEMU TO JE:
- Aby bylo jasné, které zdroje můžeme testovat hned.
- Aby bylo jasné, které zdroje čekají na kontrolu licencí.
- Aby bylo jasné, které zdroje čekají na placený plán.

KDE TO UVIDÍME:
- OPS Panel V18
- Provider Command Center
- Photo Provider Research
- PC2 Harvest Readiness

JAK SE TO VYUŽIJE:
- Pro přípravu photo/logo workerů.
- Pro rozhodnutí, co půjde spustit na PC2.
- Pro bezpečné rozlišení FREE vs PAID zdrojů.
*/

-- =====================================================
-- 1) Approval dashboard
-- =====================================================

CREATE OR REPLACE VIEW ops.v_photo_provider_approval_dashboard_v1 AS
SELECT
    research_rank,
    sport_code,
    sport_name,
    entity_type,
    current_status,
    priority_score,
    recommended_provider,
    access_type,
    research_provider_url,
    research_status,

    CASE
        WHEN research_status = 'WAIT_FOR_PAID' THEN 'ČEKÁ NA PLACENÝ PLÁN'
        WHEN terms_check_required = true THEN 'NUTNÁ KONTROLA LICENCE'
        WHEN harvest_ready_after_check = true THEN 'PŘIPRAVENO K TESTU'
        ELSE 'KONTROLA'
    END AS approval_status_cs,

    CASE
        WHEN access_type = 'PAID' THEN 'PAID_PROVIDER'
        WHEN access_type = 'ENTERPRISE' THEN 'ENTERPRISE_PROVIDER'
        WHEN access_type IN ('FREE','LIMITED_FREE') AND terms_check_required = true THEN 'LICENSE_REVIEW'
        WHEN access_type IN ('FREE','LIMITED_FREE') AND harvest_ready_after_check = true THEN 'READY_FOR_TEST'
        ELSE 'REVIEW_REQUIRED'
    END AS approval_bucket,

    terms_check_required,
    harvest_ready_after_check,
    api_available,
    automation_possible,
    worker_needed,
    license_note,
    next_action,
    notes,
    updated_at
FROM ops.provider_missing_matrix
WHERE entity_type IN (
    'PLAYER_PHOTOS',
    'COACH_PHOTOS',
    'TEAM_LOGOS',
    'STADIUM_PHOTOS'
)
ORDER BY
    research_rank,
    priority_score DESC,
    sport_code,
    entity_type;


-- =====================================================
-- 2) Approval summary
-- =====================================================

CREATE OR REPLACE VIEW ops.v_photo_provider_approval_summary_v1 AS
SELECT
    approval_bucket,
    access_type,
    COUNT(*) AS rows_count,
    MIN(research_rank) AS best_rank,
    MAX(priority_score) AS max_priority
FROM ops.v_photo_provider_approval_dashboard_v1
GROUP BY
    approval_bucket,
    access_type
ORDER BY
    best_rank,
    rows_count DESC;


-- =====================================================
-- 3) Free candidates waiting for license check
-- =====================================================

CREATE OR REPLACE VIEW ops.v_photo_provider_free_license_check_v1 AS
SELECT
    research_rank,
    sport_code,
    sport_name,
    entity_type,
    priority_score,
    recommended_provider,
    research_provider_url,
    license_note,
    next_action,
    worker_needed,
    updated_at
FROM ops.v_photo_provider_approval_dashboard_v1
WHERE approval_bucket = 'LICENSE_REVIEW'
ORDER BY
    research_rank,
    priority_score DESC,
    sport_code,
    entity_type;


-- =====================================================
-- 4) Paid candidates
-- =====================================================

CREATE OR REPLACE VIEW ops.v_photo_provider_paid_candidates_v1 AS
SELECT
    research_rank,
    sport_code,
    sport_name,
    entity_type,
    priority_score,
    recommended_provider,
    access_type,
    license_note,
    next_action,
    worker_needed,
    updated_at
FROM ops.v_photo_provider_approval_dashboard_v1
WHERE approval_bucket IN (
    'PAID_PROVIDER',
    'ENTERPRISE_PROVIDER'
)
ORDER BY
    priority_score DESC,
    sport_code,
    entity_type;


-- =====================================================
-- 5) PC2 candidate view
-- =====================================================

CREATE OR REPLACE VIEW ops.v_photo_provider_pc2_candidates_v1 AS
SELECT
    research_rank,
    sport_code,
    sport_name,
    entity_type,
    priority_score,
    recommended_provider,
    access_type,
    approval_bucket,
    api_available,
    automation_possible,
    harvest_ready_after_check,
    worker_needed,
    next_action
FROM ops.v_photo_provider_approval_dashboard_v1
WHERE automation_possible = true
ORDER BY
    research_rank,
    priority_score DESC,
    sport_code,
    entity_type;


-- =====================================================
-- 6) Quick check
-- =====================================================

SELECT
    approval_bucket,
    access_type,
    COUNT(*) AS rows_count
FROM ops.v_photo_provider_approval_dashboard_v1
GROUP BY
    approval_bucket,
    access_type
ORDER BY
    approval_bucket,
    access_type;