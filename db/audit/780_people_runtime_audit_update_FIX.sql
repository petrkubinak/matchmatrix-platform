BEGIN;

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    state_reason = 'PEOPLE V2.1 pipeline end-to-end confirmed',
    planner_target_exists = true,
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = false,
    last_run_group = 'AFB_PEOPLE_V2',
    last_run_at = now(),
    last_check_at = now(),
    db_evidence_summary = 'AFB players RAW->staging->public OK (86 mapped)',
    next_action = 'Rozšířit scope na více týmů/sezon',
    updated_at = now()
WHERE provider = 'api_american_football'
  AND sport_code = 'AFB'
  AND entity = 'players';

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    state_reason = 'PEOPLE V2.1 pipeline confirmed',
    planner_target_exists = true,
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = false,
    last_run_group = 'FB_PEOPLE_V2',
    last_run_at = now(),
    last_check_at = now(),
    db_evidence_summary = 'FB players RAW->staging->public mapping OK',
    next_action = 'Rozšířit league scope',
    updated_at = now()
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'players';

UPDATE ops.runtime_entity_audit
SET
    current_state = 'PARTIAL',
    state_reason = 'Staging OK, public coaches model missing',
    planner_target_exists = true,
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = false,
    public_merge_confirmed = false,
    downstream_confirmed = false,
    last_run_group = 'FB_PEOPLE_V2',
    last_run_at = now(),
    last_check_at = now(),
    db_evidence_summary = 'FB coaches RAW->staging OK (3 rows)',
    next_action = 'Navrhnout public coaches model',
    updated_at = now()
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'coaches';

COMMIT;

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
    last_run_group,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE (provider, sport_code, entity) IN (
    ('api_american_football', 'AFB', 'players'),
    ('api_football', 'FB', 'players'),
    ('api_football', 'FB', 'coaches')
)
ORDER BY provider, sport_code, entity;