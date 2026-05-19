SELECT
    provider,
    sport_code,
    entity,
    endpoint_exists,
    endpoint_tested,
    endpoint_returns_data,
    technical_status,
    data_quality_status,
    final_verdict,
    alternative_provider_needed,
    evidence_note,
    next_step,
    updated_at
FROM ops.provider_people_audit
WHERE entity IN ('players', 'coaches')
ORDER BY
    CASE
        WHEN final_verdict = 'ENDPOINT_EXISTS' THEN 1
        WHEN final_verdict = 'WAIT_SCOPE_FIX' THEN 2
        WHEN final_verdict = 'WAIT_PROVIDER' THEN 3
        ELSE 4
    END,
    priority_rank,
    provider,
    sport_code,
    entity;