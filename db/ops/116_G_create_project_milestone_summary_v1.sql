/*
===============================================================================
MATCHMATRIX SQL 116_G
PROJECT MILESTONE SUMMARY V1
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_project_milestone_summary_v1 AS
SELECT
    category,
    COUNT(*) AS total_milestones,
    COUNT(*) FILTER (WHERE status = 'DONE') AS done_count,
    COUNT(*) FILTER (WHERE status = 'IN_PROGRESS') AS in_progress_count,
    COUNT(*) FILTER (WHERE status = 'PLANNED') AS planned_count,
    COUNT(*) FILTER (WHERE status = 'BLOCKED') AS blocked_count,
    ROUND(AVG(progress_percent), 2) AS avg_progress_percent,
    MIN(planned_date) FILTER (WHERE status <> 'DONE') AS next_open_planned_date,
    COUNT(*) FILTER (
        WHERE status <> 'DONE'
          AND planned_date < CURRENT_DATE
    ) AS overdue_count,
    COUNT(*) FILTER (
        WHERE status <> 'DONE'
          AND planned_date >= CURRENT_DATE
          AND planned_date <= CURRENT_DATE + INTERVAL '14 days'
    ) AS due_soon_count
FROM ops.project_milestones
GROUP BY category
ORDER BY
    MIN(priority),
    category;