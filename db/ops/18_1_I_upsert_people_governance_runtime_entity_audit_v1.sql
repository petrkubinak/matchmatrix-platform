/*
MATCHMATRIX SQL 18_1_I
UPSERT PEOPLE GOVERNANCE INTO RUNTIME ENTITY AUDIT V1

CO TO JE:
- Zápis dokončených governance bloků do ops.runtime_entity_audit.

K ČEMU TO JE:
- Aby OPS runtime audit věděl, že:
  - Team Duplicate Prevention je připravená.
  - Player Identity Governance je aktivní.
  - Player Provider Map Governance je v řízeném HOLD stavu.

KDE TO UVIDÍME:
- OPS Panel V18
- Runtime Audit
- People Layer
- Governance Dashboard

JAK SE TO VYUŽIJE:
- Panel a OPS Brain budou číst stav přímo z runtime_entity_audit.
- Další people ingest workery budou vědět, že identity guardy jsou aktivní.
*/

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
    updated_at
)
VALUES
(
    'matchmatrix_governance',
    'ALL',
    'team_duplicate_prevention',
    'CONFIRMED',
    'Team duplicate prevention dokončeno. CRITICAL=0, missing_canonical=0, real provider duplicate=0, HIGH=7 vše v HOLD.',
    true,
    false,
    false,
    false,
    false,
    false,
    true,
    true,
    true,
    '17_9_TEAM_DUPLICATE_PREVENTION',
    now(),
    now(),
    '17_9_A až 17_9_K dokončeno. Insert guard aktivní: provider_guard_rows=9510, name_guard_rows=9510, hold_guard_rows=7.',
    'Dashboard: prevention_status=CONTROLLED_HOLD. TEAM_DUPLICATE_PREVENTION=READY, TEAM_INSERT_GUARD=ACTIVE.',
    'Napojit do OPS Panel V18 / Team Quality.',
    'Governance runtime zápis po dokončení Team Duplicate Prevention.',
    now()
),
(
    'matchmatrix_governance',
    'ALL',
    'player_identity_governance',
    'CONFIRMED',
    'Player Identity Governance dokončeno. CRITICAL=0, HIGH=0, MEDIUM=106, LOW=15, HOLD=121, status CONTROLLED_HOLD.',
    true,
    false,
    false,
    false,
    false,
    false,
    true,
    true,
    true,
    '18_A_TO_18_F_PLAYER_IDENTITY_GOVERNANCE',
    now(),
    now(),
    '18_A až 18_F dokončeno. Player insert guard aktivní: provider_player_guard_rows=19396, name_birth_guard_rows=5145, hold_identity_guard_rows=121.',
    'Dashboard: player_identity_status=CONTROLLED_HOLD. PLAYER_DUPLICATE_PREVENTION=READY, PLAYER_INSERT_GUARD=ACTIVE.',
    'Napojit do OPS Panel V18 / People Identity Governance.',
    'Governance runtime zápis po dokončení Player Identity Governance.',
    now()
),
(
    'matchmatrix_governance',
    'ALL',
    'player_provider_map_governance',
    'PARTIAL',
    'Player Provider Map Governance je v CONTROLLED_HOLD. Kolize jsou v HOLD, G. Gibson zůstává ruční případ bez bezpečné provider mapy.',
    true,
    false,
    false,
    false,
    false,
    false,
    true,
    false,
    true,
    '18_1_PLAYER_PROVIDER_MAP_GOVERNANCE',
    now(),
    now(),
    '18_1_A až 18_1_H dokončeno. provider_identity_collision_rows=8, collision_hold_groups=4, possible_merge_groups=1, provider_map_review_groups=3, player_without_provider_map_rows=1.',
    'Final dashboard: governance_status=CONTROLLED_HOLD, ok_rows=20027, total_rows=20036.',
    'G. Gibson ručně ověřit. Hiago později bezpečný merge audit. Benny/Vitinho/L. Jenkins řešit jako provider map review.',
    'Governance runtime zápis po dokončení Player Provider Map Governance.',
    now()
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    current_state = EXCLUDED.current_state,
    state_reason = EXCLUDED.state_reason,
    panel_runner_exists = EXCLUDED.panel_runner_exists,
    planner_target_exists = EXCLUDED.planner_target_exists,
    batch_target_exists = EXCLUDED.batch_target_exists,
    pull_confirmed = EXCLUDED.pull_confirmed,
    raw_confirmed = EXCLUDED.raw_confirmed,
    staging_confirmed = EXCLUDED.staging_confirmed,
    provider_map_confirmed = EXCLUDED.provider_map_confirmed,
    public_merge_confirmed = EXCLUDED.public_merge_confirmed,
    downstream_confirmed = EXCLUDED.downstream_confirmed,
    last_run_group = EXCLUDED.last_run_group,
    last_run_at = EXCLUDED.last_run_at,
    last_check_at = EXCLUDED.last_check_at,
    last_log_summary = EXCLUDED.last_log_summary,
    db_evidence_summary = EXCLUDED.db_evidence_summary,
    next_action = EXCLUDED.next_action,
    audit_note = EXCLUDED.audit_note,
    updated_at = now();