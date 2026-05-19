BEGIN;

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    state_reason = 'PEOPLE SCALE batch 02 confirmed',
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    last_run_group = 'FB_PEOPLE_SCALE_02',
    last_run_at = now(),
    last_check_at = now(),
    db_evidence_summary = 'FB scale batch 02: 10 leagues | RAW=10 | players=200 | mapped=200',
    next_action = 'Pokračovat FB_PEOPLE_SCALE_03 nebo přejít na team-based full coverage',
    updated_at = now()
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'players';

COMMIT;