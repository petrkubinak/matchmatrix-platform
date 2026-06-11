/*
MATCHMATRIX SQL 19_2_C
Provider Missing Matrix Dashboard V1

CO TO JE:
- Dashboardové pohledy nad ops.provider_missing_matrix.

K ČEMU TO JE:
- Přehled datových mezer.
- Přehled providerů.
- Přehled FREE vs PAID.
- Prioritizace před PC2 harvestem.

KDE TO UVIDÍME:
- OPS Panel V18
- Provider Command Center
- Harvest Readiness

JAK SE TO VYUŽIJE:
- Výzkum providerů.
- Plánování PC2.
- Rozhodování o PRO licencích.
*/

-- =====================================================
-- DETAIL DASHBOARD
-- =====================================================

CREATE OR REPLACE VIEW ops.v_provider_missing_dashboard_v1 AS
SELECT
    sport_code,
    sport_name,

    layer_code,
    entity_type,

    current_status,

    priority_score,

    current_provider,
    recommended_provider,

    provider_type,
    access_type,

    historical_supported,
    live_supported,

    api_available,
    automation_possible,

    COALESCE(estimated_coverage_pct,0) AS estimated_coverage_pct,

    blocker_reason,
    next_action,

    updated_at

FROM ops.provider_missing_matrix
ORDER BY
    priority_score DESC,
    sport_code,
    entity_type;


-- =====================================================
-- STATUS SUMMARY
-- =====================================================

CREATE OR REPLACE VIEW ops.v_provider_missing_status_summary_v1 AS
SELECT
    current_status,
    COUNT(*) AS total_rows
FROM ops.provider_missing_matrix
GROUP BY current_status
ORDER BY total_rows DESC;


-- =====================================================
-- SPORT SUMMARY
-- =====================================================

CREATE OR REPLACE VIEW ops.v_provider_missing_sport_summary_v1 AS
SELECT
    sport_code,

    COUNT(*) AS total_entities,

    COUNT(*) FILTER (
        WHERE current_status='READY'
    ) AS ready_count,

    COUNT(*) FILTER (
        WHERE current_status='PARTIAL'
    ) AS partial_count,

    COUNT(*) FILTER (
        WHERE current_status='MISSING'
    ) AS missing_count,

    COUNT(*) FILTER (
        WHERE current_status='RESEARCH_REQUIRED'
    ) AS research_required_count,

    COUNT(*) FILTER (
        WHERE current_status='WAIT_FOR_PAID_PLAN'
    ) AS wait_for_paid_count

FROM ops.provider_missing_matrix
GROUP BY sport_code
ORDER BY sport_code;


-- =====================================================
-- ACCESS SUMMARY
-- =====================================================

CREATE OR REPLACE VIEW ops.v_provider_missing_access_summary_v1 AS
SELECT
    access_type,
    COUNT(*) AS total_rows
FROM ops.provider_missing_matrix
GROUP BY access_type
ORDER BY total_rows DESC;


-- =====================================================
-- TOP PRIORITY GAPS
-- =====================================================

CREATE OR REPLACE VIEW ops.v_provider_missing_top_priority_v1 AS
SELECT
    sport_code,
    entity_type,
    current_status,
    priority_score,
    recommended_provider,
    access_type,
    next_action
FROM ops.provider_missing_matrix
WHERE current_status IN (
    'MISSING',
    'RESEARCH_REQUIRED',
    'WAIT_FOR_PAID_PLAN'
)
ORDER BY
    priority_score DESC,
    sport_code,
    entity_type;


-- =====================================================
-- PC2 HARVEST READY
-- =====================================================

CREATE OR REPLACE VIEW ops.v_provider_pc2_ready_v1 AS
SELECT
    sport_code,
    entity_type,
    recommended_provider,
    access_type,
    api_available,
    automation_possible
FROM ops.provider_missing_matrix
WHERE
    automation_possible = true
ORDER BY
    sport_code,
    entity_type;


-- =====================================================
-- QUICK CHECK
-- =====================================================

SELECT
    current_status,
    COUNT(*) AS rows_count
FROM ops.provider_missing_matrix
GROUP BY current_status
ORDER BY rows_count DESC;