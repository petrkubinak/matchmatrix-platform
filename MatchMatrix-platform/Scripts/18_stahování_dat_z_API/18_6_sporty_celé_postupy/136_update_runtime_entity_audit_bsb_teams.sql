-- =====================================================
-- 136_update_runtime_entity_audit_bsb_teams.sql
-- BSB teams -> runtime_entity_audit
-- =====================================================

DELETE FROM ops.runtime_entity_audit
WHERE provider = 'api_baseball'
  AND sport_code = 'BSB'
  AND entity = 'teams';

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
    'api_baseball',
    'BSB',
    'teams',
    'CONFIRMED',
    'BSB teams pull/raw/parser/provider_map potvrzeny',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    false,
    'BSB_CORE',
    now(),
    now(),
    'BSB teams parser OK | raw=32 | skipped=2 | staging=30 | provider_map=30',
    'staging.stg_provider_teams: provider=api_baseball, sport_code=baseball, external_league_id=1, season=2024, rows_count=30, distinct_teams=30 | public.team_provider_map provider=api_baseball: 30 | public.teams ext_source=api_baseball: 30',
    'Implementovat BSB fixtures raw->staging->public.matches',
    '2026-04-12: BSB teams hotovo, dalsi krok fixtures',
    now(),
    now()
);