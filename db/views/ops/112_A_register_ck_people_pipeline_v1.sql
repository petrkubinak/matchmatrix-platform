/*
MATCHMATRIX SQL 112_A
REGISTER CK PEOPLE PIPELINE V1

CO TO JE:
- Zapíše potvrzenou Cricket PEOPLE pipeline do OPS registrů.

K ČEMU TO JE:
- Brain, Dispatcher a panel uvidí, že CK players už mají funkční CUSTOM_WORKER.
*/

INSERT INTO ops.provider_worker_registry (
    provider,
    sport_code,
    entity,
    worker_type,
    worker_script,
    is_supported,
    is_active,
    notes
)
VALUES (
    'api_cricket',
    'CK',
    'players',
    'CUSTOM_WORKER',
    'workers/people/cricket/pull_api_cricket_squads_v1.py + workers/people/cricket/pull_api_cricket_squad_players_v1.py + workers/people/cricket/parse_api_cricket_squad_players_v1.py + workers/people/cricket/merge_api_cricket_players_to_public_v1.py',
    true,
    true,
    'CK PEOPLE pipeline ověřena end-to-end na IPL 2024: 10 týmů, 236 hráčů, 236 provider map.'
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    worker_type = EXCLUDED.worker_type,
    worker_script = EXCLUDED.worker_script,
    is_supported = EXCLUDED.is_supported,
    is_active = EXCLUDED.is_active,
    notes = EXCLUDED.notes,
    updated_at = NOW();


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
    'api_cricket',
    'CK',
    'players',
    'CONFIRMED',
    'Cricket PEOPLE pipeline ověřena přes custom Cricbuzz squads/squad players flow.',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    'PEOPLE_CRICKET_IPL_2024',
    NOW(),
    NOW(),
    'RAW squads payload 1474, squad player payloads 1475-1484, parser inserted 236 staging players, merge inserted 236 public players and 236 provider maps.',
    'staging.stg_provider_players api_cricket/CK/2024 = 236 distinct players; public.players sport_id=14/ext_source=api_cricket = 236; player_provider_map provider=api_cricket = 236.',
    'Rozšířit CK PEOPLE pipeline na další série/sezóny a doplnit team_id mapping do public.players.',
    'První kompletní custom PEOPLE worker mimo unified ingest. Potvrzuje architekturu provider_worker_registry CUSTOM_WORKER.',
    NOW(),
    NOW()
)
ON CONFLICT DO NOTHING;