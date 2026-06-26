CREATE OR REPLACE FUNCTION ops.fn_write_autonomous_learning_v1()
RETURNS TABLE (
    write_ok boolean,
    written_rows integer,
    message text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_written integer := 0;
BEGIN

    INSERT INTO ops.repair_outcome_learning
    (
        reason_code,
        provider,
        sport_code,
        entity,
        repair_action,
        outcome_code,
        outcome_note,
        created_at
    )
    SELECT
        COALESCE(q.action_reason, q.action_type) AS reason_code,
        q.provider,
        q.sport_code,
        q.entity,
        q.action_type AS repair_action,

        CASE
            WHEN q.execution_status = 'SUCCESS'
            THEN 'CONFIRMED_OK'
            WHEN q.execution_status = 'FAILED'
            THEN 'FAILED_AGAIN'
            ELSE 'WAITING'
        END AS outcome_code,

        LEFT(
            'queue_id=' || q.id::text ||
            ' | league=' || COALESCE(q.provider_league_id::text, '-') ||
            ' | season=' || COALESCE(q.season::text, '-') ||
            ' | run_group=' || COALESCE(q.run_group, '-') ||
            ' | result=' || COALESCE(q.execution_result, ''),
            1000
        ) AS outcome_note,

        now()

    FROM ops.autonomous_execution_queue q
    WHERE q.execution_status IN ('SUCCESS', 'FAILED')
      AND NOT EXISTS (
          SELECT 1
          FROM ops.repair_outcome_learning l
          WHERE l.outcome_note LIKE ('queue_id=' || q.id::text || ' |%')
      );

    GET DIAGNOSTICS v_written = ROW_COUNT;

    RETURN QUERY
    SELECT
        true,
        v_written,
        ('Learning zapsán. Nových řádků: ' || v_written)::text;

END;
$$;