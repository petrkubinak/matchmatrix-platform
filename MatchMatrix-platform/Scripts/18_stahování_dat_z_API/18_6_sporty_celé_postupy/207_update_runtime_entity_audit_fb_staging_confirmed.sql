-- =====================================================================
-- 207_update_runtime_entity_audit_fb_staging_confirmed.sql
-- MatchMatrix - potvrzení FB staging vrstvy v ops.runtime_entity_audit
-- =====================================================================

-- -------------------------------------------------
-- TEAMS
-- -------------------------------------------------
INSERT INTO ops.runtime_entity_audit
(
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
    last_log_summary,
    db_evidence_summary,
    next_action,
    audit_note,
    created_at,
    updated_at
)
VALUES
(
    'api_football',
    'football',
    'teams',
    'PARTIAL',
    'FB teams bridge completed into staging.stg_provider_teams.',
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    false,
    false,
    'FB_CORE',
    now(),
    'FB teams bridge finished.',
    'staging.stg_provider_teams provider=api_football count=1458',
    'Build/verify team_provider_map for api_football.',
    'Staging layer confirmed; canonical/provider map not yet confirmed.',
    now(),
    now()
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    current_state          = EXCLUDED.current_state,
    state_reason           = EXCLUDED.state_reason,
    panel_runner_exists    = EXCLUDED.panel_runner_exists,
    planner_target_exists  = EXCLUDED.planner_target_exists,
    batch_target_exists    = EXCLUDED.batch_target_exists,
    pull_confirmed         = EXCLUDED.pull_confirmed,
    raw_confirmed          = EXCLUDED.raw_confirmed,
    staging_confirmed      = EXCLUDED.staging_confirmed,
    provider_map_confirmed = EXCLUDED.provider_map_confirmed,
    public_merge_confirmed = EXCLUDED.public_merge_confirmed,
    downstream_confirmed   = EXCLUDED.downstream_confirmed,
    last_run_group         = EXCLUDED.last_run_group,
    last_check_at          = EXCLUDED.last_check_at,
    last_log_summary       = EXCLUDED.last_log_summary,
    db_evidence_summary    = EXCLUDED.db_evidence_summary,
    next_action            = EXCLUDED.next_action,
    audit_note             = EXCLUDED.audit_note,
    updated_at             = now();

-- -------------------------------------------------
-- FIXTURES
-- -------------------------------------------------
INSERT INTO ops.runtime_entity_audit
(
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
    last_log_summary,
    db_evidence_summary,
    next_action,
    audit_note,
    created_at,
    updated_at
)
VALUES
(
    'api_football',
    'football',
    'fixtures',
    'PARTIAL',
    'FB fixtures bridge completed into staging.stg_provider_fixtures.',
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    false,
    false,
    'FB_CORE',
    now(),
    'FB fixtures bridge finished.',
    'staging.stg_provider_fixtures provider=api_football count=76608',
    'Prepare canonical merge with football_data + api_football combined strategy.',
    'Staging layer confirmed; public.matches merge not yet confirmed.',
    now(),
    now()
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    current_state          = EXCLUDED.current_state,
    state_reason           = EXCLUDED.state_reason,
    panel_runner_exists    = EXCLUDED.panel_runner_exists,
    planner_target_exists  = EXCLUDED.planner_target_exists,
    batch_target_exists    = EXCLUDED.batch_target_exists,
    pull_confirmed         = EXCLUDED.pull_confirmed,
    raw_confirmed          = EXCLUDED.raw_confirmed,
    staging_confirmed      = EXCLUDED.staging_confirmed,
    provider_map_confirmed = EXCLUDED.provider_map_confirmed,
    public_merge_confirmed = EXCLUDED.public_merge_confirmed,
    downstream_confirmed   = EXCLUDED.downstream_confirmed,
    last_run_group         = EXCLUDED.last_run_group,
    last_check_at          = EXCLUDED.last_check_at,
    last_log_summary       = EXCLUDED.last_log_summary,
    db_evidence_summary    = EXCLUDED.db_evidence_summary,
    next_action            = EXCLUDED.next_action,
    audit_note             = EXCLUDED.audit_note,
    updated_at             = now();

-- -------------------------------------------------
-- LEAGUES
-- -------------------------------------------------
INSERT INTO ops.runtime_entity_audit
(
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
    last_log_summary,
    db_evidence_summary,
    next_action,
    audit_note,
    created_at,
    updated_at
)
VALUES
(
    'api_football',
    'football',
    'leagues',
    'PARTIAL',
    'FB leagues bridge completed into staging.stg_provider_leagues.',
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    false,
    false,
    'FB_CORE',
    now(),
    'FB leagues bridge finished.',
    'staging.stg_provider_leagues provider=api_football count=1225',
    'Prepare league canonical/provider sync if needed.',
    'Staging layer confirmed; public league merge not yet confirmed.',
    now(),
    now()
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    current_state          = EXCLUDED.current_state,
    state_reason           = EXCLUDED.state_reason,
    panel_runner_exists    = EXCLUDED.panel_runner_exists,
    planner_target_exists  = EXCLUDED.planner_target_exists,
    batch_target_exists    = EXCLUDED.batch_target_exists,
    pull_confirmed         = EXCLUDED.pull_confirmed,
    raw_confirmed          = EXCLUDED.raw_confirmed,
    staging_confirmed      = EXCLUDED.staging_confirmed,
    provider_map_confirmed = EXCLUDED.provider_map_confirmed,
    public_merge_confirmed = EXCLUDED.public_merge_confirmed,
    downstream_confirmed   = EXCLUDED.downstream_confirmed,
    last_run_group         = EXCLUDED.last_run_group,
    last_check_at          = EXCLUDED.last_check_at,
    last_log_summary       = EXCLUDED.last_log_summary,
    db_evidence_summary    = EXCLUDED.db_evidence_summary,
    next_action            = EXCLUDED.next_action,
    audit_note             = EXCLUDED.audit_note,
    updated_at             = now();

-- -------------------------------------------------
-- KONTROLA
-- -------------------------------------------------
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE provider = 'api_football'
  AND sport_code = 'football'
  AND entity IN ('teams', 'fixtures', 'leagues')
ORDER BY entity;