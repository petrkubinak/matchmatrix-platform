UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = true,
    state_reason = 'HB leagues confirmed: staging 211 distinct leagues / public 211 leagues',
    updated_at = NOW()
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'leagues';

SELECT
    provider,
    sport_code,
    entity,
    current_state
FROM ops.runtime_entity_audit
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
ORDER BY entity;