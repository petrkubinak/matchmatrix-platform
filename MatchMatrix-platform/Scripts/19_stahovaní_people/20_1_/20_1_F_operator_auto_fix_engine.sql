/*
===============================================================================
MATCHMATRIX 20_1_F – OPERATOR AUTO FIX ENGINE
===============================================================================

CO TO JE:
První bezpečný auto-fix engine pro operátorský panel DENNÍ PRÁCE.

K ČEMU TO JE:
Umožní budoucímu tlačítku OPRAVIT provést doporučenou opravu,
pokud je v katalogu označená jako auto_executable = true.

KDE TO UVIDÍME:
OPS Panel
→ DENNÍ PRÁCE
→ CHYBY / STOP
→ OPRAVIT

Databáze:
ops.fn_operator_execute_fix_v1(monitor_id)

JAK SE TO VYUŽIJE:
Panel po kliknutí na OPRAVIT zavolá funkci:

SELECT *
FROM ops.fn_operator_execute_fix_v1(2);

Funkce:
- najde doporučenou opravu
- zapíše audit do ops.operator_fix_execution_log
- pokud je oprava povolená, provede bezpečný reset
- vrátí výsledek operátorovi

NAVAZUJE NA:
20_1_A_harvest_run_monitor.sql
20_1_B_harvest_run_monitor_views.sql
20_1_C_operator_fix_catalog.sql
20_1_D_operator_fix_recommendations.sql
20_1_E_operator_fix_execution_log.sql

DALŠÍ KROK:
20_1_G_operator_fix_panel_binding.sql
===============================================================================
*/

CREATE OR REPLACE FUNCTION ops.fn_operator_execute_fix_v1(
    p_monitor_id BIGINT,
    p_executed_by TEXT DEFAULT 'PANEL_OPERATOR'
)
RETURNS TABLE
(
    success BOOLEAN,
    fix_execution_id BIGINT,
    out_monitor_id BIGINT,
    out_fix_code TEXT,
    execution_status TEXT,
    execution_message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
    v_fix_execution_id BIGINT;
    v_before_state JSONB;
    v_after_state JSONB;
BEGIN

    SELECT rec.*
    INTO r
    FROM ops.v_operator_fix_recommendations_v1 rec
    WHERE rec.monitor_id = p_monitor_id
    ORDER BY rec.confidence_pct DESC
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            false,
            NULL::BIGINT,
            p_monitor_id,
            NULL::TEXT,
            'FAILED'::TEXT,
            'Nebyla nalezena doporučená oprava pro tento monitor_id.'::TEXT;
        RETURN;
    END IF;

    SELECT to_jsonb(m)
    INTO v_before_state
    FROM ops.harvest_run_monitor m
    WHERE m.monitor_id = p_monitor_id;

    INSERT INTO ops.operator_fix_execution_log
    (
        monitor_id,
        run_key,
        fix_id,
        fix_code,
        error_code,
        sport_code,
        sport_name,
        provider,
        entity_type,
        target_layer,
        target_table,
        target_action,
        executed_by,
        execution_mode,
        execution_status,
        started_at,
        before_state
    )
    VALUES
    (
        r.monitor_id,
        r.run_key,
        r.fix_id,
        r.fix_code,
        r.last_error_code,
        r.sport_code,
        r.sport_name,
        r.provider,
        r.entity_type,
        r.target_layer,
        r.target_table,
        r.target_action,
        p_executed_by,
        CASE
            WHEN r.auto_executable THEN 'AUTO_EXECUTABLE_WITH_CONFIRM'
            ELSE 'MANUAL_ONLY'
        END,
        'RUNNING',
        now(),
        v_before_state
    )
    RETURNING ops.operator_fix_execution_log.fix_execution_id
    INTO v_fix_execution_id;

    IF COALESCE(r.auto_executable, false) = false THEN

        UPDATE ops.operator_fix_execution_log l
        SET
            execution_status = 'BLOCKED',
            execution_result = 'MANUAL_REQUIRED',
            execution_message = 'Oprava není označená jako auto_executable. Vyžaduje ruční kontrolu operátora.',
            finished_at = now(),
            updated_at = now()
        WHERE l.fix_execution_id = v_fix_execution_id;

        RETURN QUERY
        SELECT
            false,
            v_fix_execution_id,
            p_monitor_id,
            r.fix_code,
            'BLOCKED'::TEXT,
            'Tato oprava vyžaduje ruční kontrolu.'::TEXT;
        RETURN;

    END IF;

    IF r.target_action IN ('SET_READY', 'RESET_COMMAND_READY') THEN

        UPDATE ops.harvest_run_monitor m
        SET
            run_status = 'READY',
            run_status_cz = 'Připraveno',
            error_count = 0,
            last_error_code = NULL,
            last_error_message = NULL,
            result_message = 'Běh byl auto-fixem vrácen do READY.',
            operator_recommendation = 'Spusť akci znovu.',
            updated_at = now()
        WHERE m.monitor_id = p_monitor_id;

        UPDATE ops.pc2_run_command_queue q
        SET
            run_status = 'READY_TO_RUN',
            last_result = 'AUTO_FIX_RESET_TO_READY',
            updated_at = now()
        FROM ops.harvest_run_monitor m
        WHERE m.monitor_id = p_monitor_id
          AND m.command_id IS NOT NULL
          AND q.id = m.command_id;

    ELSE

        UPDATE ops.operator_fix_execution_log l
        SET
            execution_status = 'BLOCKED',
            execution_result = 'UNSUPPORTED_ACTION',
            execution_message = 'Target action zatím není podporovaná auto-fix enginem.',
            finished_at = now(),
            updated_at = now()
        WHERE l.fix_execution_id = v_fix_execution_id;

        RETURN QUERY
        SELECT
            false,
            v_fix_execution_id,
            p_monitor_id,
            r.fix_code,
            'BLOCKED'::TEXT,
            'Tento typ opravy zatím není podporovaný.'::TEXT;
        RETURN;

    END IF;

    SELECT to_jsonb(m)
    INTO v_after_state
    FROM ops.harvest_run_monitor m
    WHERE m.monitor_id = p_monitor_id;

    UPDATE ops.operator_fix_execution_log l
    SET
        execution_status = 'SUCCESS',
        execution_result = 'FIX_APPLIED',
        execution_message = 'Auto-fix byl úspěšně proveden.',
        after_state = v_after_state,
        finished_at = now(),
        updated_at = now()
    WHERE l.fix_execution_id = v_fix_execution_id;

    RETURN QUERY
    SELECT
        true,
        v_fix_execution_id,
        p_monitor_id,
        r.fix_code,
        'SUCCESS'::TEXT,
        'Auto-fix byl úspěšně proveden.'::TEXT;

END;
$$;