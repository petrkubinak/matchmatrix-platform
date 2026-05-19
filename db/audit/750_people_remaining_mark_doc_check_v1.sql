/*
750_people_remaining_mark_doc_check_v1.sql

Účel:
- CK / TN / MMA nepouštět naslepo přes obecný API-Sport endpoint
- označit je k ověření dokumentace / alternativního providera
*/

BEGIN;

UPDATE ops.provider_people_audit
SET
    technical_status = 'DOC_CHECK_REQUIRED',
    data_quality_status = 'UNKNOWN',
    final_verdict = 'WAIT_PROVIDER_DOC_CHECK',
    alternative_provider_needed = true,
    evidence_note = 'CK/TN/MMA people endpointy nebyly smoke-testovány obecným API-Sport patternem. Vyžadují ověření konkrétní dokumentace/provider endpointu.',
    next_step = 'Ověřit dokumentaci providera pro players/coaches. Pokud endpoint existuje, připravit samostatný smoke test; pokud ne, hledat alternativního people providera.',
    updated_at = now()
WHERE provider IN ('api_cricket', 'api_tennis', 'api_mma')
  AND sport_code IN ('CK', 'TN', 'MMA')
  AND entity IN ('players', 'coaches')
  AND final_verdict = 'WAIT_ENDPOINT_AUDIT';

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    technical_status,
    final_verdict,
    alternative_provider_needed,
    next_step
FROM ops.provider_people_audit
WHERE provider IN ('api_cricket', 'api_tennis', 'api_mma')
ORDER BY provider, sport_code, entity;