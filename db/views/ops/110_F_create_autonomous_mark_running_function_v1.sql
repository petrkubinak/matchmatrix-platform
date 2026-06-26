/*
MATCHMATRIX SQL 110_F Create Autonomous Mark Running Function V1

CO TO JE:
- Bezpečná funkce pro přepnutí autonomní akce ze stavu PENDING do RUNNING.

K ČEMU TO JE:
- Aby launcher mohl převzít jednu připravenou akci.
- Aby se zabránilo spuštění více akcí najednou.
- Aby byl vidět začátek běhu.

KDE TO UVIDÍME:
- Panel V18+
- AI OPS
- AUTONOMNÍ FRONTA
- AKTIVNÍ BĚHY

JAK SE TO VYUŽIJE:
- Launcher najde akci READY.
- Zavolá tuto funkci.
- Akce se označí jako RUNNING.
*/


CREATE OR REPLACE FUNCTION ops.fn_mark_next_autonomous_action_running_v1()
RETURNS TABLE (
    mark_ok boolean,
    queue_id bigint,
    message text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_action record;
BEGIN

    SELECT *
    INTO v_action
    FROM ops.v_launcher_next_action_v1
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            false,
            NULL::bigint,
            'Žádná akce není připravena ke spuštění.'::text;
        RETURN;
    END IF;

    UPDATE ops.autonomous_execution_queue q
    SET
        execution_status = 'RUNNING',
        started_at = now()
    WHERE q.id = v_action.queue_id
      AND q.execution_status = 'PENDING';

    RETURN QUERY
    SELECT
        true,
        v_action.queue_id,
        'Akce byla označena jako RUNNING.'::text;

END;
$$;