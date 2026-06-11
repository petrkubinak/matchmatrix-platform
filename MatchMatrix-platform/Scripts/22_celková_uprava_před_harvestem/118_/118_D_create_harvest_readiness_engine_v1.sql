/*
MATCHMATRIX SQL 118_D
CREATE HARVEST READINESS ENGINE V1 - FIXED

CO TO JE:
- Centrální engine připravenosti projektu pro V18.

K ČEMU TO JE:
- Vypočítá celkovou připravenost harvestu.
- Ukáže nejslabší vrstvy.
- Ukáže nejbližší milníky.
- Dá V18 okamžitou odpověď:
  "Jsme připraveni na masivní harvest?"

KDE TO UVIDÍME:
- V18 Harvest Command Center
- OPS Dashboard
- Launch Progress

JAK SE TO VYUŽIJE:
- Hlavní KPI panelu V18.
*/

DROP VIEW IF EXISTS ops.v_harvest_readiness_summary_v1;
DROP VIEW IF EXISTS ops.v_harvest_readiness_engine_v1;

CREATE OR REPLACE VIEW ops.v_harvest_readiness_engine_v1 AS
WITH layer_stats AS (
    SELECT
        ROUND(AVG(readiness_percent), 2) AS overall_layer_readiness,
        COUNT(*) AS total_layers,
        COUNT(*) FILTER (WHERE readiness_status = 'READY') AS ready_layers,
        COUNT(*) FILTER (WHERE readiness_status = 'PARTIAL') AS partial_layers,
        COUNT(*) FILTER (WHERE readiness_status = 'NOT_READY') AS not_ready_layers,
        COUNT(*) FILTER (WHERE readiness_status = 'PLANNED') AS planned_layers
    FROM ops.layer_readiness_status
),
roadmap_stats AS (
    SELECT
        ROUND(AVG(progress_percent), 2) AS roadmap_progress,
        COUNT(*) FILTER (WHERE milestone_status = 'DONE') AS completed_milestones,
        COUNT(*) FILTER (WHERE milestone_status = 'IN_PROGRESS') AS active_milestones,
        COUNT(*) FILTER (WHERE milestone_status = 'PLANNED') AS planned_milestones,
        MIN(target_date) FILTER (WHERE milestone_status <> 'DONE') AS next_target_date
    FROM ops.project_roadmap_milestones_v1
),
critical_layers AS (
    SELECT
        string_agg(layer_code, ', ' ORDER BY readiness_percent ASC) AS weakest_layers
    FROM (
        SELECT
            layer_code,
            readiness_percent
        FROM ops.layer_readiness_status
        ORDER BY readiness_percent ASC
        LIMIT 3
    ) q
)
SELECT
    CURRENT_TIMESTAMP AS generated_at,
    ls.overall_layer_readiness,
    rs.roadmap_progress,

    ROUND(
        (
            ls.overall_layer_readiness * 0.70
            +
            rs.roadmap_progress * 0.30
        ), 2
    ) AS harvest_readiness_percent,

    CASE
        WHEN (
            ls.overall_layer_readiness * 0.70
            +
            rs.roadmap_progress * 0.30
        ) >= 90 THEN 'READY'
        WHEN (
            ls.overall_layer_readiness * 0.70
            +
            rs.roadmap_progress * 0.30
        ) >= 75 THEN 'NEAR_READY'
        WHEN (
            ls.overall_layer_readiness * 0.70
            +
            rs.roadmap_progress * 0.30
        ) >= 50 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END AS readiness_status,

    ls.total_layers,
    ls.ready_layers,
    ls.partial_layers,
    ls.not_ready_layers,
    ls.planned_layers,

    rs.completed_milestones,
    rs.active_milestones,
    rs.planned_milestones,
    rs.next_target_date,

    cl.weakest_layers,

    CASE
        WHEN EXISTS (
            SELECT 1
            FROM ops.layer_readiness_status
            WHERE layer_code = 'WEB'
              AND readiness_percent < 50
        )
        THEN 'WEB'
        ELSE NULL
    END AS biggest_blocker,

    CASE
        WHEN EXISTS (
            SELECT 1
            FROM ops.layer_readiness_status
            WHERE layer_code = 'ODDS'
              AND readiness_percent < 75
        )
        THEN 'ODDS EXPANSION'
        WHEN EXISTS (
            SELECT 1
            FROM ops.layer_readiness_status
            WHERE layer_code = 'PEOPLE'
              AND readiness_percent < 90
        )
        THEN 'PEOPLE EXPANSION'
        ELSE 'PRO HARVEST PREPARATION'
    END AS recommended_next_step

FROM layer_stats ls
CROSS JOIN roadmap_stats rs
CROSS JOIN critical_layers cl;

CREATE OR REPLACE VIEW ops.v_harvest_readiness_summary_v1 AS
SELECT
    harvest_readiness_percent,
    readiness_status,
    weakest_layers,
    biggest_blocker,
    recommended_next_step,
    next_target_date
FROM ops.v_harvest_readiness_engine_v1;

SELECT *
FROM ops.v_harvest_readiness_summary_v1;