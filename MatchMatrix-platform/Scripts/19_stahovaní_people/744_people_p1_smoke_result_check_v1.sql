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
WHERE provider IN ('api_football', 'api_sport')
  AND sport_code IN ('FB', 'BK')
  AND entity IN ('players', 'coaches')
ORDER BY provider, sport_code, entity;