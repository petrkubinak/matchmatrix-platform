SELECT
    provider,
    sport_code,
    entity,
    technical_status,
    final_verdict,
    evidence_note,
    next_step,
    updated_at
FROM ops.provider_people_audit
WHERE final_verdict IN ('PUBLIC_CONFIRMED', 'STAGING_CONFIRMED')
ORDER BY provider, sport_code, entity;