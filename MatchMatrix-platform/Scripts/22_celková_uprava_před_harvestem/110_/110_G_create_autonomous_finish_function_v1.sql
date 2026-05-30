/*
MATCHMATRIX SQL 110_G Create Autonomous Finish Function V1

CO TO JE:
- Ukončení autonomní akce.

K ČEMU TO JE:
- Přepne RUNNING na SUCCESS nebo FAILED.
- Zapíše výsledek běhu.
- Připraví data pro learning vrstvu.

KDE TO UVIDÍME:
- AI OPS
- AUTONOMNÍ FRONTA
- RESULT COLLECTOR

JAK SE TO VYUŽIJE:
- Worker doběhne.
- Collector vyhodnotí výsledek.
- Zavolá tuto funkci.
*/


CREATE OR REPLACE FUNCTION ops.fn_finish_autonomous_action_v1(
    p_queue_id bigint,
    p_success boolean,
    p_result text DEFAULT NULL
)
RETURNS TABLE (
    finish_ok boolean,
    queue_id bigint,
    final_status text,
    message text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status text;
BEGIN

    SELECT
        CASE
            WHEN p_success THEN 'SUCCESS'
            ELSE 'FAILED'
        END
    INTO v_status;

    UPDATE ops.autonomous_execution_queue
    SET
        execution_status = v_status,
        execution_result = p_result,
        finished_at = now()
    WHERE id = p_queue_id
      AND execution_status = 'RUNNING';

    IF NOT FOUND THEN

        RETURN QUERY
        SELECT
            false,
            p_queue_id,
            NULL::text,
            'Akce nebyla nalezena nebo není ve stavu RUNNING.'::text;

        RETURN;
    END IF;

    RETURN QUERY
    SELECT
        true,
        p_queue_id,
        v_status,
        'Akce byla úspěšně ukončena.'::text;

END;
$$;