/*
MATCHMATRIX SQL 110_C Create Autonomous Queue Insert Function V1

CO TO JE:
- Funkce pro vložení kandidáta do autonomní fronty.

K ČEMU TO JE:
- AI OPS vybere nejlepšího kandidáta.
- Kandidát se vloží do execution queue.
- Zatím se ještě nespouští worker.

KDE TO UVIDÍME:
- AI OPS
- AUTONOMNÍ FRONTA
- PANEL V18+

JAK SE TO VYUŽIJE:
- vybrat kandidáta
- vložit do queue
- launcher později provede spuštění
*/


CREATE OR REPLACE FUNCTION ops.fn_enqueue_next_autonomous_action_v1()
RETURNS TABLE (
    enqueue_ok boolean,
    queue_id bigint,
    message text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_candidate record;
    v_queue_id bigint;
BEGIN

    SELECT *
    INTO v_candidate
    FROM ops.v_worker_launcher_next_v1
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            false,
            NULL::bigint,
            'Nebyl nalezen žádný kandidát.'::text;
        RETURN;
    END IF;


    INSERT INTO ops.autonomous_execution_queue (
        action_type,
        provider,
        sport_code,
        entity,
        provider_league_id,
        season,
        run_group,
        priority_score,
        risk_level,
        action_reason,
        execution_status
    )
    VALUES (
        'RUN_PLANNER_TARGET',
        v_candidate.provider,
        v_candidate.sport_code,
        v_candidate.entity,
        v_candidate.league_id,
        v_candidate.season,
        v_candidate.run_group,
        v_candidate.priority_score,
        v_candidate.ai_risk_level,
        v_candidate.ai_reason,
        'PENDING'
    )
    RETURNING id
    INTO v_queue_id;


    RETURN QUERY
    SELECT
        true,
        v_queue_id,
        'Kandidát byl vložen do autonomní fronty.'::text;

END;
$$;