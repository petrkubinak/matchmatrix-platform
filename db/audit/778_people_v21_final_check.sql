SELECT
    id,
    provider,
    sport_code,
    entity,
    run_group,
    status,
    attempts,
    last_attempt
FROM ops.ingest_planner
WHERE id IN (5845, 5846, 5847)
ORDER BY id;

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
WHERE id IN (756, 757, 758)
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
    ('api_american_football', 'AFB', 'players'),
    ('api_football', 'FB', 'players'),
    ('api_football', 'FB', 'coaches')
)
ORDER BY provider, sport_code, entity;