-- 132_update_runtime_entity_audit_bk_fixtures_batch_ok.sql

UPDATE ops.runtime_entity_audit
SET
    current_state            = 'CONFIRMED',
    state_reason             = 'BK fixtures batch probehl plne OK pres shared API-Sport dispatch. Vsech 5 targetu vratilo RESULT OK bez runtime erroru.',
    panel_runner_exists      = TRUE,
    planner_target_exists    = TRUE,
    batch_target_exists      = TRUE,
    pull_confirmed           = TRUE,
    raw_confirmed            = TRUE,
    staging_confirmed        = TRUE,
    provider_map_confirmed   = TRUE,
    public_merge_confirmed   = TRUE,
    downstream_confirmed     = FALSE,
    last_run_group           = 'BK_TOP',
    last_run_at              = NOW(),
    last_check_at            = NOW(),
    last_log_summary         = 'MATCHMATRIX UNIFIED INGEST BATCH V1 | BK fixtures | TARGETS TOTAL=5 | OK=5 | ERROR=0',
    db_evidence_summary      = 'BK fixtures batch runtime potvrzen: league_id 12, 120, 117, 198, 202 | NO TEAM MATCH=0 | NO MATCH ID=0',
    next_action              = 'Prevest BK rucni SQL kroky do finalniho opakovatelneho pipeline baliku.',
    audit_note               = 'BK fixtures uz nejsou jen core merge proof. Je potvrzen i batch runtime pres panel/orchestraci.',
    updated_at               = NOW()
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'fixtures';

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
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'fixtures';