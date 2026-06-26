/*
MATCHMATRIX SQL 111_K Top Development Tasks V1

CO TO JE:
- TOP backlog pro vývoj.

K ČEMU TO JE:
- Ukáže jen nejdůležitější úkoly.
- Vhodné pro panel a AI OPS.

KDE TO UVIDÍME:
- Panel V18+
- OPS Dashboard
- Development Priority

JAK SE TO VYUŽIJE:
- Co dělat dnes
- Co dělat po PRO
- Co má největší business hodnotu
*/


CREATE OR REPLACE VIEW ops.v_top_development_tasks_v1 AS
SELECT

    id,

    sport_code,
    entity,

    priority_score,

    task_title,
    task_description,

    action_code,
    task_status,

    CASE

        WHEN action_code='PAID_PLAN_REQUIRED'
        THEN 'POČKAT NA PRO'

        WHEN priority_score >= 100
        THEN 'KRITICKÁ PRIORITA'

        WHEN priority_score >= 90
        THEN 'VELMI VYSOKÁ PRIORITA'

        WHEN priority_score >= 80
        THEN 'VYSOKÁ PRIORITA'

        ELSE 'BĚŽNÁ PRIORITA'

    END AS priority_group_cz,

    created_at

FROM ops.development_task_queue

WHERE task_status='PENDING'

ORDER BY

    priority_score DESC,
    created_at ASC;



CREATE OR REPLACE VIEW ops.v_top_development_tasks_panel_v1 AS
SELECT

    sport_code         AS "Sport",
    entity             AS "Entita",

    priority_score     AS "Priorita",

    priority_group_cz  AS "Skupina",

    action_code        AS "Typ",

    task_description   AS "Doporučená akce",

    task_status        AS "Stav"

FROM ops.v_top_development_tasks_v1;