SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed
FROM ops.runtime_entity_audit
WHERE provider = 'api_american_football'
  AND sport_code = 'AFB'
  AND entity = 'players';