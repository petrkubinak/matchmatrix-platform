SELECT
    provider,
    sport_code,
    entity,
    final_verdict,
    evidence_note,
    next_step
FROM ops.provider_people_audit
WHERE final_verdict = 'ENDPOINT_EXISTS'
ORDER BY priority_rank, provider, sport_code, entity;