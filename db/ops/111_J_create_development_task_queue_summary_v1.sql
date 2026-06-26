CREATE OR REPLACE VIEW ops.v_development_task_queue_summary_v1 AS
SELECT
    task_status,
    action_code,
    COUNT(*) AS task_count,
    MAX(priority_score) AS max_priority,
    MIN(created_at) AS oldest_task_at,
    now() AS generated_at
FROM ops.development_task_queue
GROUP BY
    task_status,
    action_code
ORDER BY
    task_status,
    max_priority DESC;


CREATE OR REPLACE VIEW ops.v_development_task_queue_panel_summary_v1 AS
SELECT
    task_status AS "Stav",
    action_code AS "Typ úkolu",
    task_count AS "Počet",
    max_priority AS "Nejvyšší priorita",
    oldest_task_at AS "Nejstarší úkol",
    generated_at AS "Vygenerováno"
FROM ops.v_development_task_queue_summary_v1;