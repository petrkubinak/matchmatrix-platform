/*
MATCHMATRIX SQL 19_3_A PC2 MEDIA FB FAILED ROUTE AUDIT

CO TO JE:
- Kontrola chybně spuštěného PC2 MEDIA FB commandu.

K ČEMU TO JE:
- Ověříme, že command_id=9 posílá official_site media do špatného runneru.

KDE TO UVIDÍME:
- ops.pc2_run_command_queue
- ops.ingest_planner
- ops.runtime_execution_history

JAK SE TO VYUŽIJE:
- Podle výsledku opravíme PC2 command tak, aby MEDIA běžela přes media worker,
  ne přes run_unified_ingest_v1.py.
*/

SELECT
    id,
    sport_code,
    target_layer,
    command_title,
    command_text,
    run_status,
    run_group,
    worker_name,
    worker_script,
    last_result,
    notes
FROM ops.pc2_run_command_queue
WHERE id = 9;

SELECT
    id,
    provider,
    sport_code,
    entity,
    season,
    run_group,
    priority,
    status,
    attempts,
    last_attempt,
    next_run
FROM ops.ingest_planner
WHERE id = 8818;

SELECT
    id,
    created_at,
    worker_name,
    status,
    return_code,
    command_text,
    stdout_preview,
    stderr_preview
FROM ops.runtime_execution_history
WHERE command_text ILIKE '%PC2_MEDIA_FB%'
   OR stdout_preview ILIKE '%official_site%'
ORDER BY created_at DESC
LIMIT 10;