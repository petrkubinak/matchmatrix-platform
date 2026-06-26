/*
===============================================================================
MATCHMATRIX 20_1_J – OPERATOR DASHBOARD SUMMARY
===============================================================================

CO TO JE:
Souhrnné view pro horní operátorské karty v záložce DENNÍ PRÁCE.

K ČEMU TO JE:
Panel získá jeden zdroj pro rychlé rozhodnutí:
- kolik akcí je READY
- kolik běží
- kolik je HOTOVO
- kolik je v CHYBĚ
- co je doporučená další akce

KDE TO UVIDÍME:
OPS Panel
→ DENNÍ PRÁCE
→ horní grafické karty:
DNEŠNÍ POSTUP / AKTUÁLNÍ BĚH / POSLEDNÍ VÝSLEDEK / CHYBY / STOP

Databáze:
ops.v_operator_dashboard_summary_v1

JAK SE TO VYUŽIJE:
Panel bude číst jeden řádek z tohoto view a podle něj kreslit:
- semafor
- počty stavů
- doporučenou akci
- barvu operátorského stavu

NAVAZUJE NA:
20_1_A_harvest_run_monitor.sql
20_1_B_harvest_run_monitor_views.sql
20_1_I_operator_next_action.sql

DALŠÍ KROK:
20_1_K_operator_panel_visual_binding.py
===============================================================================
*/

DROP VIEW IF EXISTS ops.v_operator_dashboard_summary_v1;

CREATE VIEW ops.v_operator_dashboard_summary_v1
AS
WITH queue_summary AS
(
    SELECT
        COUNT(*) AS total_commands,

        COUNT(*) FILTER (
            WHERE run_status IN ('READY', 'READY_TO_RUN', 'PŘIPRAVENO')
        ) AS ready_commands,

        COUNT(*) FILTER (
            WHERE run_status IN ('RUNNING', 'BĚŽÍ')
        ) AS running_commands,

        COUNT(*) FILTER (
            WHERE run_status IN ('DONE', 'HOTOVO')
        ) AS done_commands,

        COUNT(*) FILTER (
            WHERE run_status IN ('ERROR', 'FAILED', 'CHYBA')
        ) AS error_commands,

        COUNT(*) FILTER (
            WHERE run_status IN ('BLOCKED', 'BLOKOVÁNO')
        ) AS blocked_commands

    FROM ops.pc2_run_command_queue
    WHERE panel_visible = true
),
next_action AS
(
    SELECT
        command_id,
        sport_code,
        sport_name,
        target_layer,
        command_title,
        run_status,
        operator_action,
        priority_score,
        recommendation_reason,
        traffic_light
    FROM ops.v_operator_next_action_v1
    ORDER BY operator_rank
    LIMIT 1
),
monitor_today AS
(
    SELECT
        total_runs,
        done_runs,
        running_runs,
        waiting_runs,
        error_runs,
        blocked_runs,
        day_progress_pct,
        traffic_light AS monitor_traffic_light,
        operator_message AS monitor_message
    FROM ops.v_operator_today_progress_v1
    LIMIT 1
),
last_result AS
(
    SELECT
        sport_code AS last_sport_code,
        sport_name AS last_sport_name,
        provider AS last_provider,
        entity_type AS last_entity_type,
        target_layer AS last_target_layer,
        run_status AS last_run_status,
        result_pct,
        error_count AS last_error_count,
        result_message AS last_result_message,
        operator_message AS last_operator_message,
        traffic_light AS last_result_traffic_light
    FROM ops.v_operator_last_result_v1
    LIMIT 1
),
stop_errors AS
(
    SELECT
        COUNT(*) AS active_stop_errors
    FROM ops.v_operator_stop_errors_v1
)
SELECT
    now() AS generated_at,

    q.total_commands,
    q.ready_commands,
    q.running_commands,
    q.done_commands,
    q.error_commands,
    q.blocked_commands,

    CASE
        WHEN q.total_commands = 0 THEN 0
        ELSE ROUND(100.0 * q.done_commands / q.total_commands, 2)
    END AS queue_done_pct,

    COALESCE(m.total_runs, 0) AS monitor_total_runs,
    COALESCE(m.done_runs, 0) AS monitor_done_runs,
    COALESCE(m.running_runs, 0) AS monitor_running_runs,
    COALESCE(m.waiting_runs, 0) AS monitor_waiting_runs,
    COALESCE(m.error_runs, 0) AS monitor_error_runs,
    COALESCE(m.blocked_runs, 0) AS monitor_blocked_runs,
    COALESCE(m.day_progress_pct, 0) AS monitor_day_progress_pct,

    n.command_id AS next_command_id,
    n.sport_code AS next_sport_code,
    n.sport_name AS next_sport_name,
    n.target_layer AS next_target_layer,
    n.command_title AS next_command_title,
    n.run_status AS next_run_status,
    n.operator_action AS next_operator_action,
    n.priority_score AS next_priority_score,
    n.recommendation_reason AS next_recommendation_reason,

    l.last_sport_code,
    l.last_sport_name,
    l.last_provider,
    l.last_entity_type,
    l.last_target_layer,
    l.last_run_status,
    l.result_pct AS last_result_pct,
    l.last_error_count,
    l.last_result_message,
    l.last_operator_message,

    COALESCE(s.active_stop_errors, 0) AS active_stop_errors,

    CASE
        WHEN q.error_commands > 0 OR COALESCE(s.active_stop_errors, 0) > 0 THEN 'RED'
        WHEN q.running_commands > 0 THEN 'YELLOW'
        WHEN q.ready_commands > 0 THEN 'GREEN'
        WHEN q.done_commands = q.total_commands AND q.total_commands > 0 THEN 'GREEN'
        ELSE 'YELLOW'
    END AS operator_traffic_light,

    CASE
        WHEN q.error_commands > 0 OR COALESCE(s.active_stop_errors, 0) > 0
            THEN 'Nejdříve vyřeš červené chyby.'
        WHEN q.running_commands > 0
            THEN 'Sleduj běžící harvest.'
        WHEN q.ready_commands > 0
            THEN 'Můžeš spustit další připravenou akci.'
        WHEN q.done_commands = q.total_commands AND q.total_commands > 0
            THEN 'Fronta je hotová.'
        ELSE 'Zkontroluj stav fronty.'
    END AS operator_main_message

FROM queue_summary q
CROSS JOIN next_action n
LEFT JOIN monitor_today m ON true
LEFT JOIN last_result l ON true
LEFT JOIN stop_errors s ON true;