UPDATE ops.fb_entity_audit
SET
    primary_provider = 'api_football',
    fallback_provider = 'football_data',
    coverage_status = 'tech_ready + runtime fallback',
    real_data_flow = TRUE,
    execution_mode = 'validate_only',
    automator_ready = FALSE,
    requires_pro = FALSE,
    staging_table = 'staging.stg_provider_leagues',
    public_dependency = 'public.leagues',
    post_process = 'provider map / merge / canonical league sync',
    known_issues = 'api_football free plan omezený na sezony 2022-2024; football_data slouží jako fallback/history',
    notes = 'Primary deep provider = api_football; runtime fallback = football_data; do automatu až po potvrzení execution flow',
    updated_at = now()
WHERE entity = 'leagues';

UPDATE ops.fb_entity_audit
SET
    primary_provider = 'api_football',
    fallback_provider = 'football_data',
    coverage_status = 'tech_ready + runtime fallback',
    real_data_flow = TRUE,
    execution_mode = 'validate_only',
    automator_ready = FALSE,
    requires_pro = FALSE,
    staging_table = 'staging.stg_provider_teams',
    public_dependency = 'public.teams + team_provider_map + team_aliases',
    post_process = 'provider map / alias sync / canonical merge',
    known_issues = 'api_football free plan omezený na sezony 2022-2024; football_data je fallback/history; team identity musí zůstat canonical-first',
    notes = 'Primary deep provider = api_football; runtime fallback = football_data; do automatu až po potvrzení team flow',
    updated_at = now()
WHERE entity = 'teams';

UPDATE ops.fb_entity_audit
SET
    primary_provider = 'api_football',
    fallback_provider = 'football_data',
    coverage_status = 'tech_ready + runtime fallback',
    real_data_flow = TRUE,
    execution_mode = 'validate_only',
    automator_ready = FALSE,
    requires_pro = FALSE,
    staging_table = 'staging.stg_provider_fixtures',
    public_dependency = 'public.matches',
    post_process = 'merge to public.matches + downstream refresh standings/form/features',
    known_issues = 'api_football free plan omezený na sezony 2022-2024; football_data dnes reálně drží aktuální fixtures/results přes legacy větev',
    notes = 'Strategicky primary = api_football, ale runtime realita dnes stojí i na football_data fallbacku; před automatem potvrdit execution path',
    updated_at = now()
WHERE entity = 'fixtures';