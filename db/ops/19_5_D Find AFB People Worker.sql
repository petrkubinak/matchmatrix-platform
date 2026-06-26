/*
MATCHMATRIX SQL 19_5_D Find AFB People Worker

CO TO JE:
- Audit dostupného workeru pro AFB players.

K ČEMU TO JE:
- AFB PEOPLE nesmí běžet přes generic unified ingest.
- Potřebujeme najít správný samostatný worker.

KDE TO UVIDÍME:
- registry workerů
- runtime audit
- PC2 command

JAK SE TO VYUŽIJE:
- Přepíšeme command_id=3 na správný AFB players worker.
*/

SELECT
    provider,
    sport_code,
    entity,
    worker_type,
    worker_script,
    is_supported,
    is_active,
    notes
FROM ops.provider_worker_registry
WHERE sport_code = 'AFB'
   OR provider ILIKE '%american%';

SELECT
    provider,
    sport_code,
    entity,
    pull_worker,
    parse_worker,
    merge_worker,
    source_table,
    target_table,
    runtime_ready,
    panel_ready,
    scheduler_ready,
    migration_state,
    notes
FROM ops.unified_worker_registry
WHERE sport_code = 'AFB'
   OR provider ILIKE '%american%';

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    last_run_group,
    last_log_summary,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE sport_code = 'AFB'
   OR provider ILIKE '%american%';

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
WHERE id = 3
   OR sport_code = 'AFB';