/*
===============================================================================
MATCHMATRIX SQL 117_A
HARVEST READINESS DASHBOARD V1

CO TO JE:
- Centrální dashboard připravenosti na hromadný harvest.

K ČEMU TO JE:
- Jedno místo pro sledování stavu projektu.
- Zdroj pro OPS panel.
- Zdroj pro audit snapshot worker.

KDE TO UVIDÍME:
- Mission Control
- OPS panel
- Audit reporty
- Budoucí admin web

JAK SE TO VYUŽIJE:
- rozhodování co dělat dál
- kontrola připravenosti harvestu
- roadmap monitoring
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_harvest_readiness_dashboard_v1 AS
SELECT

    CURRENT_TIMESTAMP AS snapshot_time,

    ROUND(
        AVG(progress_percent),
        2
    ) AS overall_harvest_readiness,

    MAX(CASE
        WHEN milestone_code = 'HARVEST_DB_READY'
        THEN progress_percent
    END) AS db_ready_percent,

    MAX(CASE
        WHEN milestone_code = 'HARVEST_PEOPLE_READY'
        THEN progress_percent
    END) AS people_ready_percent,

    MAX(CASE
        WHEN milestone_code = 'HARVEST_MEDIA_READY'
        THEN progress_percent
    END) AS media_ready_percent,

    MAX(CASE
        WHEN milestone_code = 'HARVEST_PANEL_READY'
        THEN progress_percent
    END) AS panel_ready_percent,

    MAX(CASE
        WHEN milestone_code = 'HARVEST_LOCKS_READY'
        THEN progress_percent
    END) AS locks_ready_percent,

    COUNT(*) FILTER (
        WHERE status = 'DONE'
    ) AS done_tasks,

    COUNT(*) FILTER (
        WHERE status = 'IN_PROGRESS'
    ) AS in_progress_tasks,

    COUNT(*) FILTER (
        WHERE status = 'PLANNED'
    ) AS planned_tasks

FROM ops.project_milestones
WHERE milestone_code IN (
    'HARVEST_DB_READY',
    'HARVEST_PEOPLE_READY',
    'HARVEST_MEDIA_READY',
    'HARVEST_PANEL_READY',
    'HARVEST_LOCKS_READY',
    'HARVEST_DRY_RUN_READY'
);