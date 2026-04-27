-- 751_confirm_ck_core_pipeline.sql

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    state_reason = 'CK core pipeline potvrzena end-to-end v novem modelu',
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = false,
    last_check_at = now(),
    last_log_summary = 'CK core confirmed | stg_provider_fixtures=44 | stg_provider_leagues=35 | stg_provider_teams=77+ | public.matches=44 | public.leagues mapped | public.team_provider_map mapped',
    db_evidence_summary = 'api_cricket CK core pipeline confirmed end-to-end',
    next_action = 'Dalsi krok pripadne odds / people / downstream entity',
    updated_at = now()
WHERE provider = 'api_cricket'
  AND sport_code = 'CK'
  AND entity IN ('fixtures', 'leagues', 'teams');


UPDATE ops.sport_completion_audit
SET
    current_status = 'CONFIRMED',
    production_readiness = 'READY',
    db_layer_ready = true,
    planner_ready = false,
    queue_ready = false,
    public_ready = true,
    key_gap = 'Bez zasadniho blockeru v core vrstve',
    next_step = 'Dalsi krok pripadne odds / people / downstream entity',
    evidence_note = 'CK core confirmed | public.matches=44 | public.leagues active | public.team_provider_map mapped',
    updated_at = now()
WHERE sport_code = 'CK'
  AND entity IN ('fixtures', 'leagues', 'teams')
  AND layer_type = 'core';