/*
MATCHMATRIX SQL 19_3_M
PC2 Orchestration Actions Layer V1

CO TO JE:
- Přidá akční vrstvu pro PC2 Command Center.

K ČEMU TO JE:
- Aby šlo z panelu měnit stav PC2 příkazů bez DBeaveru:
  READY, BLOCKED, RETRY, DISABLED.

KDE TO UVIDÍME:
- OPS Panel V18
- PC2 Command Center

JAK SE TO VYUŽIJE:
- Panel načte dostupné akce.
- Uživatel klikne na akci.
- Panel provede UPDATE nad ops.pc2_run_command_queue.
*/

CREATE OR REPLACE VIEW ops.v_pc2_orchestration_actions_v1 AS
SELECT
    q.id AS command_id,
    q.sport_code,
    q.sport_name,
    q.target_layer,
    q.run_status,
    a.action_code,
    a.action_label_cs,
    a.action_sql_hint,
    a.action_enabled,
    a.action_note_cs
FROM ops.pc2_run_command_queue q
CROSS JOIN LATERAL (
    VALUES
    (
        'SET_READY',
        '✓ OZNAČIT READY',
        'UPDATE ops.pc2_run_command_queue SET run_status = ''READY_TO_RUN'', updated_at = now() WHERE id = ' || q.id || ';',
        q.run_status IN ('FAILED','BLOCKED','DISABLED','DONE'),
        'Vrátí příkaz do fronty ke spuštění.'
    ),
    (
        'SET_BLOCKED',
        '⛔ BLOKOVAT',
        'UPDATE ops.pc2_run_command_queue SET run_status = ''BLOCKED'', updated_at = now() WHERE id = ' || q.id || ';',
        q.run_status <> 'RUNNING',
        'Zastaví příkaz, dokud nebude ručně opraven.'
    ),
    (
        'SET_DISABLED',
        '🛑 VYPNOUT',
        'UPDATE ops.pc2_run_command_queue SET run_status = ''DISABLED'', updated_at = now() WHERE id = ' || q.id || ';',
        q.run_status <> 'RUNNING',
        'Skryje příkaz z běžné spouštěcí logiky.'
    ),
    (
        'RETRY',
        '↻ RETRY',
        'UPDATE ops.pc2_run_command_queue SET run_status = ''READY_TO_RUN'', last_started_at = NULL, last_finished_at = NULL, last_result = ''Retry requested from PC2 panel.'', updated_at = now() WHERE id = ' || q.id || ';',
        q.run_status IN ('FAILED','BLOCKED','DONE'),
        'Resetuje příkaz na READY_TO_RUN.'
    )
) AS a(
    action_code,
    action_label_cs,
    action_sql_hint,
    action_enabled,
    action_note_cs
)
WHERE q.run_group = '19_3_PC2_DEPENDENCY_QUEUE'
ORDER BY
    q.id,
    a.action_code;


CREATE OR REPLACE VIEW ops.v_pc2_orchestration_panel_v1 AS
SELECT
    r.command_id,
    r.sport_code,
    r.sport_name,
    r.target_layer,
    r.provider,
    r.entity,
    r.planner_jobs,
    r.pending_jobs,
    r.done_jobs,
    r.failed_jobs,
    r.missing_league_jobs,
    r.execution_readiness_status,
    r.next_fix_action,
    q.run_status,
    q.command_title,
    q.command_text,
    q.last_result,
    q.updated_at
FROM ops.v_pc2_execution_readiness_audit_v1 r
JOIN ops.pc2_run_command_queue q
    ON q.id = r.command_id
ORDER BY
    r.command_id;


SELECT
    command_id,
    sport_code,
    target_layer,
    run_status,
    execution_readiness_status,
    planner_jobs,
    pending_jobs,
    next_fix_action
FROM ops.v_pc2_orchestration_panel_v1
ORDER BY command_id;