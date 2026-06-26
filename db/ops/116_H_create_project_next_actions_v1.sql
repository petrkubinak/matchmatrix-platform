/*
===============================================================================
MATCHMATRIX SQL 116_H
PROJECT NEXT ACTIONS V1
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_project_next_actions_v1 AS
SELECT
    milestone_code,
    milestone_name,
    category,
    planned_date,
    status,
    progress_percent,
    priority,

    CASE
        WHEN planned_date < CURRENT_DATE AND status <> 'DONE'
            THEN 'PO TERMÍNU'
        WHEN planned_date <= CURRENT_DATE + INTERVAL '7 days' AND status <> 'DONE'
            THEN 'TEĎ ŘEŠIT'
        WHEN planned_date <= CURRENT_DATE + INTERVAL '14 days' AND status <> 'DONE'
            THEN 'BRZY'
        ELSE 'POZDĚJI'
    END AS action_window_cz,

    CASE
        WHEN planned_date < CURRENT_DATE AND status <> 'DONE'
            THEN 'RED'
        WHEN planned_date <= CURRENT_DATE + INTERVAL '7 days' AND status <> 'DONE'
            THEN 'ORANGE'
        WHEN planned_date <= CURRENT_DATE + INTERVAL '14 days' AND status <> 'DONE'
            THEN 'YELLOW'
        ELSE 'BLUE'
    END AS action_color,

    description,
    updated_at
FROM ops.project_milestones
WHERE status <> 'DONE'
ORDER BY
    CASE
        WHEN planned_date < CURRENT_DATE THEN 1
        WHEN planned_date <= CURRENT_DATE + INTERVAL '7 days' THEN 2
        WHEN planned_date <= CURRENT_DATE + INTERVAL '14 days' THEN 3
        ELSE 9
    END,
    priority,
    planned_date;