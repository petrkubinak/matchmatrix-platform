-- 727_update_runtime_entity_audit_bsb_full_confirmed.sql

-- =========================================================
-- 1) BSB TEAMS = UPDATE existujícího řádku
-- =========================================================
update ops.runtime_entity_audit
set
    current_state = 'CONFIRMED',
    state_reason = 'BSB teams end-to-end potvrzeno: pull -> raw -> staging -> provider_map -> public.teams',
    panel_runner_exists = true,
    planner_target_exists = true,
    batch_target_exists = true,
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = false,
    last_run_group = 'BSB_CORE',
    last_check_at = now(),
    db_evidence_summary = 'stg_provider_teams=30 | team_provider_map=30 | public.teams=30',
    next_action = 'BSB core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    audit_note = 'BSB teams CONFIRMED po unify parseru a provider map.',
    updated_at = now()
where provider = 'api_baseball'
  and sport_code = 'BSB'
  and entity = 'teams';

-- =========================================================
-- 2) BSB FIXTURES = INSERT nového řádku
-- =========================================================
insert into ops.runtime_entity_audit (
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
    last_check_at,
    db_evidence_summary,
    next_action,
    audit_note,
    created_at,
    updated_at
)
values (
    'api_baseball',
    'BSB',
    'fixtures',
    'CONFIRMED',
    'BSB fixtures end-to-end potvrzeno: raw -> staging -> public.matches',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    'BSB_CORE',
    now(),
    'stg_provider_fixtures=2946 | public.matches=2945',
    'BSB core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    'BSB fixtures CONFIRMED vcetne merge do public.matches.',
    now(),
    now()
);

-- =========================================================
-- 3) BSB LEAGUES = INSERT nového řádku
-- =========================================================
insert into ops.runtime_entity_audit (
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
    last_check_at,
    db_evidence_summary,
    next_action,
    audit_note,
    created_at,
    updated_at
)
values (
    'api_baseball',
    'BSB',
    'leagues',
    'CONFIRMED',
    'BSB leagues end-to-end potvrzeno: raw -> staging -> public.leagues',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    'BSB_CORE',
    now(),
    'stg_provider_leagues=77 | public.leagues=77',
    'BSB core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    'BSB leagues CONFIRMED vcetne canonical public.leagues.',
    now(),
    now()
);