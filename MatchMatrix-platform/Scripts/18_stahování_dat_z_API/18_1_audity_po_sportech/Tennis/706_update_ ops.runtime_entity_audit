UPDATE ops.runtime_entity_audit
SET
    current_state = 'PARTIAL',
    state_reason = 'TN leagues pull + raw + parser + public.leagues merge confirmed via RapidAPI search endpoint; current source is search-based seed, not final production tournament feed.',
    panel_runner_exists = false,
    planner_target_exists = true,
    batch_target_exists = false,
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = false,
    public_merge_confirmed = true,
    downstream_confirmed = false,
    last_run_group = 'TN_CORE',
    last_run_at = now(),
    last_check_at = now(),
    last_log_summary = 'TN leagues RAW SAVED=4 | PARSED UPSERTS=5 | public.leagues merged=5',
    db_evidence_summary = 'staging.api_tennis_leagues_raw run_id=1776781841 inserted 4 rows; staging.api_tennis_leagues parsed 5 tournament rows; public.leagues ext_source=api_tennis inserted 5 rows',
    next_action = 'Nahradit search-based endpoint za přesnější tournament/competition feed nebo rozšířit parser o controlled search strategy.',
    audit_note = 'Initial runnable TN leagues skeleton confirmed.',
    updated_at = now()
WHERE provider = 'api_tennis'
  AND sport_code = 'TN'
  AND entity = 'leagues';