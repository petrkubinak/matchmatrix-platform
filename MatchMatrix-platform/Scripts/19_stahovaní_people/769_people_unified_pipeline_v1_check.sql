SELECT
    id,
    provider,
    sport_code,
    entity_type,
    parse_status,
    parse_message,
    jsonb_array_length(payload_json->'response') AS response_count,
    fetched_at
FROM staging.stg_api_payloads
WHERE id IN (747, 748, 749)
ORDER BY id;

SELECT
    provider,
    sport_code,
    entity,
    technical_status,
    final_verdict,
    evidence_note,
    next_step
FROM ops.provider_people_audit
WHERE (provider, sport_code, entity) IN (
    ('api_football', 'FB', 'players'),
    ('api_football', 'FB', 'coaches'),
    ('api_american_football', 'AFB', 'players')
)
ORDER BY provider, sport_code, entity;