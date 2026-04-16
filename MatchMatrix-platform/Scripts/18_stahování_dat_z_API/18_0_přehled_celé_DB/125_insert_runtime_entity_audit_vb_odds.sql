-- 125_insert_runtime_entity_audit_vb_odds.sql

INSERT INTO ops.runtime_entity_audit (
    provider,
    sport_code,
    entity,
    current_state,
    state_reason,
    panel_runner_exists,
    planner_target_exists,
    batch_target_exists,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    last_run_group,
    last_run_at,
    last_check_at,
    last_log_summary,
    db_evidence_summary,
    next_action,
    audit_note,
    created_at,
    updated_at
)
VALUES (
    'api_volleyball',
    'VB',
    'odds',
    'PLANNED',
    'VB odds jsou architektonicky pripraveny. GenericApiSportProvider vraci rizeny WARNING, ze runtime je zatim vypnuty a ceka na placeny API plan.',
    TRUE,
    TRUE,
    TRUE,
    FALSE,
    FALSE,
    FALSE,
    FALSE,
    FALSE,
    FALSE,
    'VB_CORE',
    NOW(),
    NOW(),
    'run_unified_ingest_batch_v1 -> run_unified_ingest_v1 | STATUS WARNING | odds pripraveny architektonicky, runtime vypnuty',
    'VB odds: dispatch i batch warning handling potvrzeny, bez runtime pullu a bez DB datove stopy',
    'Aktivovat realny odds runtime po prechodu na placeny API plan a doplnit pull/raw/staging/public validaci.',
    'VB odds uz nejsou chyba orchestrace. Jsou vedome vedeny jako prepared/planned feature.',
    NOW(),
    NOW()
);

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    public_merge_confirmed,
    last_run_group,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity = 'odds';