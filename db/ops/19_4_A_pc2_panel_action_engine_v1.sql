/*
MATCHMATRIX SQL 19_4_A
PC2 Panel Action Engine V1

CO TO JE:
- Akční datová vrstva pro PC2 Command Center.

K ČEMU TO JE:
- Panel u každého řádku ukáže dostupná tlačítka:
  RUN, RETRY, READY, BLOCKED, DONE, CONTINUE, TEST.

KDE TO UVIDÍME:
- OPS Panel V18
- PC2 Command Center

JAK SE TO VYUŽIJE:
- Uživatel klikne v panelu.
- Panel podle action_code provede příslušný UPDATE nebo spustí command_text.
*/

CREATE OR REPLACE VIEW ops.v_pc2_panel_action_engine_v1 AS
SELECT
    q.id AS command_id,
    q.sport_code,
    q.sport_name,
    q.target_layer,
    q.run_status,
    COALESCE(r.execution_readiness_status, 'UNKNOWN') AS execution_readiness_status,
    COALESCE(r.planner_jobs, 0) AS planner_jobs,
    COALESCE(r.pending_jobs, 0) AS pending_jobs,
    COALESCE(r.done_jobs, 0) AS done_jobs,
    COALESCE(r.failed_jobs, 0) AS failed_jobs,
    q.command_title,
    q.command_text,

    action_code,
    action_label_cs,
    action_enabled,
    action_note_cs

FROM ops.pc2_run_command_queue q
LEFT JOIN ops.v_pc2_execution_readiness_audit_v1 r
    ON r.command_id = q.id
CROSS JOIN LATERAL (
    VALUES

    (
        'RUN',
        '▶ SPUSTIT',
        q.run_status = 'READY_TO_RUN',
        'Spustí command_text.'
    ),

    (
        'CONTINUE',
        '▶ POKRAČOVAT',
        q.run_status = 'DONE'
        AND COALESCE(r.pending_jobs, 0) > 0,
        'Vrátí DONE zpět na READY_TO_RUN, pokud existují pending planner joby.'
    ),

    (
        'RETRY',
        '↻ RETRY',
        q.run_status IN ('FAILED','BLOCKED','DONE'),
        'Resetuje příkaz na READY_TO_RUN.'
    ),

    (
        'SET_READY',
        '✓ READY',
        q.run_status <> 'RUNNING',
        'Nastaví příkaz na READY_TO_RUN.'
    ),

    (
        'SET_DONE',
        '✔ DONE',
        q.run_status <> 'RUNNING',
        'Ručně označí příkaz jako DONE.'
    ),

    (
        'SET_BLOCKED',
        '⛔ BLOCKED',
        q.run_status <> 'RUNNING',
        'Zablokuje příkaz.'
    ),

    (
        'SET_FAILED',
        '⚠ FAILED',
        q.run_status <> 'RUNNING',
        'Ručně označí příkaz jako FAILED.'
    ),

    (
        'TEST',
        '🔍 TEST',
        q.run_status <> 'RUNNING',
        'Spustí test/ověření workeru.'
    )

) AS a(
    action_code,
    action_label_cs,
    action_enabled,
    action_note_cs
)
WHERE q.run_group = '19_3_PC2_DEPENDENCY_QUEUE'
ORDER BY
    q.id,
    action_code;


CREATE OR REPLACE VIEW ops.v_pc2_panel_action_matrix_v1 AS
SELECT
    command_id,
    sport_code,
    target_layer,
    run_status,
    execution_readiness_status,
    planner_jobs,
    pending_jobs,
    done_jobs,
    failed_jobs,

    MAX(action_enabled::int) FILTER (WHERE action_code = 'RUN') AS can_run,
    MAX(action_enabled::int) FILTER (WHERE action_code = 'CONTINUE') AS can_continue,
    MAX(action_enabled::int) FILTER (WHERE action_code = 'RETRY') AS can_retry,
    MAX(action_enabled::int) FILTER (WHERE action_code = 'SET_READY') AS can_set_ready,
    MAX(action_enabled::int) FILTER (WHERE action_code = 'SET_DONE') AS can_set_done,
    MAX(action_enabled::int) FILTER (WHERE action_code = 'SET_BLOCKED') AS can_set_blocked,
    MAX(action_enabled::int) FILTER (WHERE action_code = 'SET_FAILED') AS can_set_failed,
    MAX(action_enabled::int) FILTER (WHERE action_code = 'TEST') AS can_test

FROM ops.v_pc2_panel_action_engine_v1
GROUP BY
    command_id,
    sport_code,
    target_layer,
    run_status,
    execution_readiness_status,
    planner_jobs,
    pending_jobs,
    done_jobs,
    failed_jobs
ORDER BY command_id;


SELECT
    command_id,
    sport_code,
    target_layer,
    run_status,
    execution_readiness_status,
    planner_jobs,
    pending_jobs,
    done_jobs,
    failed_jobs,
    can_run,
    can_continue,
    can_retry,
    can_set_ready,
    can_set_done,
    can_set_blocked,
    can_set_failed,
    can_test
FROM ops.v_pc2_panel_action_matrix_v1
ORDER BY command_id;