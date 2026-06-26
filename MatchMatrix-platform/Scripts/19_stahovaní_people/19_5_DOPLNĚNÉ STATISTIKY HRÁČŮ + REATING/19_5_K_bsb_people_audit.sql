/*
===============================================================================
MATCHMATRIX SQL 19_5_K
BSB PEOPLE AUDIT
===============================================================================

CO TO JE:
- Audit Baseball PEOPLE pipeline na PC2.

K ČEMU TO JE:
- Ověření, proč je BSB PEOPLE stále pouze READY_TO_RUN.
- Zjištění skutečného workeru, planner jobů a runtime stavu.

KDE TO UVIDÍME:
- PC2 Command Center
- OPS dashboard
- Runtime audit
- Planner queue

JAK SE TO VYUŽIJE:
- Navazuje skript 19_5_L_bsb_people_fix.sql
- Pokud bude routing špatně, opravíme command.
- Pokud bude planner prázdný, vytvoříme/resetujeme job.
- Pokud bude provider vracet 0 dat, označíme TECH_READY_EMPTY.
===============================================================================
*/

-- ============================================================================
-- 1. PC2 COMMAND
-- ============================================================================

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
WHERE id = 5;


-- ============================================================================
-- 2. PLANNER JOBY
-- ============================================================================

SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run
FROM ops.ingest_planner
WHERE sport_code = 'BSB'
  AND entity = 'players'
ORDER BY id DESC;


-- ============================================================================
-- 3. WORKER REGISTRY
-- ============================================================================

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
WHERE sport_code = 'BSB'
  AND entity = 'players';


-- ============================================================================
-- 4. PROVIDER WORKER REGISTRY
-- ============================================================================

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
WHERE sport_code = 'BSB'
  AND entity = 'players';


-- ============================================================================
-- 5. RUNTIME AUDIT
-- ============================================================================

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
WHERE sport_code = 'BSB'
  AND entity = 'players';


-- ============================================================================
-- 6. PC2 PEOPLE FRONTA
-- ============================================================================

SELECT *
FROM ops.v_pc2_people_harvest_queue_v1
WHERE sport_code = 'BSB';


-- ============================================================================
-- 7. PEOPLE PIPELINE SUMMARY
-- ============================================================================

SELECT *
FROM ops.v_people_pipeline_summary_v1
WHERE sport_code = 'BSB';