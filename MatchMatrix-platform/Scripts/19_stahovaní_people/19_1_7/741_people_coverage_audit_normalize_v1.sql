/*
741_people_coverage_audit_normalize_v1.sql

Účel:
- sjednotí provider_people_audit po seed skriptu 740
- opraví rozpor: NOT_TESTED nesmí mít endpoint_tested=true
- ponechá historicky zjištěné informace pouze tam, kde endpoint opravdu něco vrací
*/

BEGIN;

UPDATE ops.provider_people_audit
SET
    endpoint_tested = false,
    technical_status = 'NOT_TESTED',
    data_quality_status = 'UNKNOWN',
    final_verdict = 'WAIT_ENDPOINT_AUDIT',
    evidence_note = 'Normalizováno po seed auditu. Reálný endpoint test bude proveden samostatným smoke testem.',
    next_step = 'Spustit people endpoint smoke test pro provider/sport/entity a podle výsledku přepsat na ENDPOINT_EXISTS / BLOCKED_PROVIDER / PAID_ONLY / RUNTIME_READY.',
    updated_at = now()
WHERE final_verdict = 'WAIT_ENDPOINT_AUDIT'
  AND technical_status = 'NOT_TESTED';

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    endpoint_exists,
    endpoint_tested,
    endpoint_returns_data,
    technical_status,
    final_verdict,
    alternative_provider_needed,
    next_step
FROM ops.provider_people_audit
ORDER BY priority_rank, provider, sport_code, entity;