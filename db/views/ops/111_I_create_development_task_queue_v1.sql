/*
MATCHMATRIX SQL 111_I Development Task Queue V1

CO TO JE:
- Fronta vývojových úkolů generovaná z roadmapy.

K ČEMU TO JE:
- AI OPS bude mít skutečný backlog.
- Panel ukáže co je Pending, Blocked, Done.
- Později bude možné přidávat automatické návrhy.

KDE TO UVIDÍME:
- Panel V18+
- AI OPS
- Development Queue

JAK SE TO VYUŽIJE:
- Priority roadmap
- Task queue
- Progress tracking
*/


CREATE TABLE IF NOT EXISTS ops.development_task_queue
(
    id bigserial PRIMARY KEY,

    sport_code text NOT NULL,
    entity text NOT NULL,

    priority_score integer NOT NULL,

    task_title text NOT NULL,
    task_description text,

    task_status text NOT NULL DEFAULT 'PENDING',

    action_code text,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);



CREATE OR REPLACE FUNCTION ops.fn_build_development_task_queue_v1()
RETURNS TABLE
(
    success boolean,
    inserted_rows integer,
    message text
)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_inserted integer;
BEGIN

    INSERT INTO ops.development_task_queue
    (
        sport_code,
        entity,
        priority_score,
        task_title,
        task_description,
        action_code
    )
    SELECT

        sport_code,
        entity,
        business_priority,

        sport_code || ' - ' || entity,

        recommended_action_cz,

        action_code

    FROM ops.v_next_development_plan_v1 p

    WHERE p.action_code <> 'COMPLETED'

    AND NOT EXISTS
    (
        SELECT 1
        FROM ops.development_task_queue q
        WHERE q.sport_code = p.sport_code
        AND q.entity = p.entity
        AND q.action_code = p.action_code
    );

    GET DIAGNOSTICS v_inserted = ROW_COUNT;

    RETURN QUERY
    SELECT
        true,
        v_inserted,
        'Development task queue aktualizována.';

END;
$$;



CREATE OR REPLACE VIEW ops.v_development_task_queue_v1 AS
SELECT

    id,

    sport_code,
    entity,

    priority_score,

    task_title,
    task_description,

    action_code,

    task_status,

    created_at

FROM ops.development_task_queue
ORDER BY

    CASE task_status
        WHEN 'PENDING' THEN 1
        WHEN 'IN_PROGRESS' THEN 2
        WHEN 'BLOCKED_PAID_PLAN' THEN 3
        WHEN 'DONE' THEN 4
        ELSE 99
    END,

    priority_score DESC,
    created_at;