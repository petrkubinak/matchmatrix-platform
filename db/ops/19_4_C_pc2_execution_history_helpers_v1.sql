/*
MATCHMATRIX SQL 19_4_C
PC2 Execution History Helpers V1

CO TO JE:
- Pomocná DB funkce pro zápis výsledků PC2 běhů do historie.

K ČEMU TO JE:
- Panel bude po každém běhu automaticky zapisovat výsledek do ops.pc2_execution_history.

KDE TO UVIDÍME:
- PC2 historie v panelu
- ops.v_pc2_execution_history_v1

JAK SE TO VYUŽIJE:
- Panel zavolá funkci po doběhu commandu.
*/

CREATE OR REPLACE FUNCTION ops.fn_pc2_insert_execution_history_v1(
    p_command_id BIGINT,
    p_return_code INTEGER,
    p_result_status TEXT,
    p_processed_jobs INTEGER,
    p_result_message TEXT,
    p_log_tail TEXT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    INSERT INTO ops.pc2_execution_history (
        command_id,
        sport_code,
        sport_name,
        target_layer,
        command_title,
        command_text,
        run_group,
        entity,
        started_at,
        finished_at,
        duration_seconds,
        return_code,
        result_status,
        processed_jobs,
        result_message,
        log_tail
    )
    SELECT
        q.id,
        q.sport_code,
        q.sport_name,
        q.target_layer,
        q.command_title,
        q.command_text,
        regexp_replace(q.command_text, '^.*--run-group\s+([A-Za-z0-9_]+).*$','\1'),
        regexp_replace(q.command_text, '^.*--entity\s+([A-Za-z0-9_]+).*$','\1'),
        q.last_started_at,
        q.last_finished_at,
        EXTRACT(EPOCH FROM (q.last_finished_at - q.last_started_at)),
        p_return_code,
        p_result_status,
        COALESCE(p_processed_jobs, 0),
        p_result_message,
        p_log_tail
    FROM ops.pc2_run_command_queue q
    WHERE q.id = p_command_id
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;