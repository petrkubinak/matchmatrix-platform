BEGIN;

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    state_reason = 'PEOPLE TEAM SCALE batch 01 confirmed',
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    last_run_group = 'FB_PEOPLE_TEAM_SCALE_01',
    last_run_at = now(),
    last_check_at = now(),
    db_evidence_summary = 'FB team scale 01: teams=20 | RAW=20 | players=400 | mapped=395',
    next_action = 'Přidat pagination support pro team players endpoint nebo spustit další team batch',
    updated_at = now()
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'players';

COMMIT;