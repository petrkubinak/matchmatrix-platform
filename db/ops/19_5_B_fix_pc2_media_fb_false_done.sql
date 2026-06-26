/*
MATCHMATRIX SQL 19_3_B Fix PC2 MEDIA FB False DONE

CO TO JE:
- Oprava špatně označeného PC2 MEDIA FB commandu.

K ČEMU TO JE:
- Command nesmí být DONE, když v logu uvnitř běhu skončil ERROR.
- Planner job 8818 ponecháme jako error, protože routování je špatné.

KDE TO UVIDÍME:
- PC2 Command Center
- ops.pc2_run_command_queue
- ops.ingest_planner

JAK SE TO VYUŽIJE:
- Připravíme čistý stav pro nový správný media worker.
*/

BEGIN;

UPDATE ops.pc2_run_command_queue
SET
    run_status = 'BLOCKED',
    last_result = 'FALSE_DONE_FIXED: command returned 0, but inner unified ingest failed with RETURNCODE=2. official_site/football/media is not supported by run_unified_ingest_v1.',
    notes = COALESCE(notes, '') || E'\nBLOCKED 2026-06-14: MEDIA FB musí běžet přes media worker, ne přes run_unified_ingest_v1.',
    panel_action_enabled = false,
    updated_at = now()
WHERE id = 9;

UPDATE ops.ingest_planner
SET
    status = 'blocked',
    next_run = NULL,
    updated_at = now()
WHERE id = 8818;

COMMIT;

SELECT
    id,
    sport_code,
    target_layer,
    command_title,
    run_status,
    panel_action_enabled,
    last_result,
    notes
FROM ops.pc2_run_command_queue
WHERE id = 9;

SELECT
    id,
    provider,
    sport_code,
    entity,
    run_group,
    status,
    attempts,
    next_run
FROM ops.ingest_planner
WHERE id = 8818;