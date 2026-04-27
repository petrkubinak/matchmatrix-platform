INSERT INTO ops.runtime_entity_audit (
    provider,
    sport_code,
    entity,
    current_state,
    state_reason,
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
VALUES (
    'api_volleyball',
    'VB',
    'players',
    'PLANNED',
    'BLOCKED_PROVIDER: API-Volleyball endpoint /players does not exist.',
    true,
    true,
    false,
    false,
    false,
    false,
    'VB_PLAYERS_TEST',
    now(),
    'pull_api_volleyball_players_raw_v1.ps1 executed successfully, but API returned endpoint error.',
    'RAW saved: api_volleyball_players_search_a_20260425_090423.json | errors.endpoint=This endpoint do not exist. | results=0',
    'Najít náhradního providera pro VB players / people layer.',
    'VB core zůstává CONFIRMED. Players nejsou core blocker, jde o people layer.',
    now(),
    now()
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    current_state = 'PLANNED',
    state_reason = EXCLUDED.state_reason,
    pull_confirmed = EXCLUDED.pull_confirmed,
    raw_confirmed = EXCLUDED.raw_confirmed,
    staging_confirmed = EXCLUDED.staging_confirmed,
    provider_map_confirmed = EXCLUDED.provider_map_confirmed,
    public_merge_confirmed = EXCLUDED.public_merge_confirmed,
    downstream_confirmed = EXCLUDED.downstream_confirmed,
    last_run_group = EXCLUDED.last_run_group,
    last_check_at = EXCLUDED.last_check_at,
    last_log_summary = EXCLUDED.last_log_summary,
    db_evidence_summary = EXCLUDED.db_evidence_summary,
    next_action = EXCLUDED.next_action,
    audit_note = EXCLUDED.audit_note,
    updated_at = now();

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    state_reason,
    next_action
FROM ops.runtime_entity_audit
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
ORDER BY entity;