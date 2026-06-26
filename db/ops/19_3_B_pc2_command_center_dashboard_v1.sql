/*
MATCHMATRIX SQL 19_3_B

PC2 COMMAND CENTER DASHBOARD DATA VIEW V1

CO TO JE:
- Centrální datová vrstva pro budoucí záložku PC2 Command Center.

K ČEMU TO JE:
- Jedno view pro OPS Panel V18.
- Není potřeba načítat 5 různých view.

KDE TO UVIDÍME:
- PC2 Command Center
- Harvest Readiness
- OPS Dashboard

JAK SE TO VYUŽIJE:
- KPI
- Prioritní sporty
- Další akce
- Harvest roadmapa
*/

-- =====================================================
-- DASHBOARD DATA
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_command_center_dashboard_v1 AS
SELECT
    r.sport_code,
    r.sport_name,

    r.next_harvest_layer,
    r.roadmap_bucket,

    r.pc2_execution_order,
    r.harvest_priority,

    r.core_pct,
    r.people_pct,
    r.media_pct,
    r.odds_pct,
    r.total_pct,

    r.provider_gap_total,
    r.provider_missing_count,
    r.provider_research_required_count,
    r.provider_partial_count,

    r.free_provider_candidates,
    r.limited_free_provider_candidates,
    r.paid_provider_candidates,

    r.photo_license_review_count,
    r.photo_wait_for_paid_count,

    r.pc2_next_action_cs,

    CASE
        WHEN r.next_harvest_layer = 'CORE'
            THEN 'KRITICKÁ PRIORITA'

        WHEN r.next_harvest_layer = 'PEOPLE'
            THEN 'VYSOKÁ PRIORITA'

        WHEN r.next_harvest_layer = 'MEDIA'
            THEN 'STŘEDNÍ PRIORITA'

        ELSE 'PŘIPRAVENO'
    END AS priority_label_cs,

    now() AS generated_at

FROM ops.v_pc2_master_harvest_roadmap_v1 r
ORDER BY
    r.pc2_execution_order,
    r.harvest_priority,
    r.sport_code;


-- =====================================================
-- KPI VIEW
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_command_center_dashboard_kpi_v1 AS
SELECT

    COUNT(*) AS total_sports,

    COUNT(*) FILTER (
        WHERE next_harvest_layer = 'CORE'
    ) AS core_sports,

    COUNT(*) FILTER (
        WHERE next_harvest_layer = 'PEOPLE'
    ) AS people_sports,

    COUNT(*) FILTER (
        WHERE next_harvest_layer = 'MEDIA'
    ) AS media_sports,

    SUM(provider_gap_total) AS total_provider_gaps,

    SUM(photo_license_review_count) AS total_photo_reviews,

    SUM(photo_wait_for_paid_count) AS total_photo_wait_for_paid

FROM ops.v_pc2_command_center_dashboard_v1;


-- =====================================================
-- TOP PRIORITY SPORTS
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_command_center_top_priority_v1 AS
SELECT *
FROM ops.v_pc2_command_center_dashboard_v1
ORDER BY
    pc2_execution_order,
    harvest_priority,
    provider_gap_total DESC,
    sport_code;


-- =====================================================
-- NEXT ACTIONS
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_command_center_next_actions_v1 AS
SELECT
    sport_code,
    sport_name,
    next_harvest_layer,
    priority_label_cs,
    pc2_next_action_cs
FROM ops.v_pc2_command_center_dashboard_v1
ORDER BY
    pc2_execution_order,
    sport_code;


-- =====================================================
-- QUICK CHECK
-- =====================================================

SELECT
    next_harvest_layer,
    priority_label_cs,
    COUNT(*) AS sports_count
FROM ops.v_pc2_command_center_dashboard_v1
GROUP BY
    next_harvest_layer,
    priority_label_cs
ORDER BY
    MIN(pc2_execution_order);
