BEGIN;

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    state_reason = 'PEOPLE SCALE batch 01 confirmed (10 leagues)',
    planner_target_exists = true,
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = false,
    last_run_group = 'FB_PEOPLE_SCALE_01',
    last_run_at = now(),
    last_check_at = now(),
    db_evidence_summary = 'FB scale batch: 10 leagues | RAW=10 | players=200 | mapped=181',
    next_action = 'Spustit další scale batch (FB_PEOPLE_SCALE_02)',
    updated_at = now()
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'players';

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    last_run_group,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'players';