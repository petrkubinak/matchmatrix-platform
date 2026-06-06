/*
===============================================================================
MATCHMATRIX SQL 116_D
PROJECT MILESTONES DASHBOARD V1
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_project_milestones_dashboard_v1 AS
SELECT
    milestone_code,
    milestone_name,
    category,
    planned_date,
    completed_date,
    status,
    priority,
    progress_percent,

    CASE
        WHEN status = 'DONE' THEN 'HOTOVO'
        WHEN status = 'IN_PROGRESS' THEN 'ROZPRACOVÁNO'
        WHEN status = 'PLANNED' THEN 'PLÁNOVÁNO'
        WHEN status = 'BLOCKED' THEN 'BLOKOVÁNO'
        ELSE 'NEZNÁMÝ STAV'
    END AS status_cz,

    CASE
        WHEN status = 'DONE' THEN 'GREEN'
        WHEN status = 'IN_PROGRESS' THEN 'YELLOW'
        WHEN status = 'PLANNED' THEN 'BLUE'
        WHEN status = 'BLOCKED' THEN 'RED'
        ELSE 'PURPLE'
    END AS status_color,

    CASE
        WHEN status <> 'DONE'
         AND planned_date < CURRENT_DATE
        THEN true
        ELSE false
    END AS is_overdue,

    CASE
        WHEN status <> 'DONE'
         AND planned_date >= CURRENT_DATE
         AND planned_date <= CURRENT_DATE + INTERVAL '14 days'
        THEN true
        ELSE false
    END AS is_due_soon,

    description,
    updated_at
FROM ops.project_milestones
ORDER BY priority, planned_date;