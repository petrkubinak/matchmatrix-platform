/*
743_people_p1_smoke_scope_v1.sql

Účel:
- vytáhne pouze P1 kandidáty pro první reálný endpoint smoke test
- podle toho potom připravíme pull/smoke skript
*/

SELECT
    provider,
    sport_code,
    entity,
    endpoint_name,
    requires_pro,
    endpoint_exists,
    endpoint_returns_data,
    provider_role,
    source_category,
    technical_status,
    final_verdict,
    next_step
FROM ops.provider_people_audit
WHERE
    (endpoint_exists = true OR endpoint_returns_data = true)
    AND final_verdict = 'WAIT_ENDPOINT_AUDIT'
ORDER BY priority_rank, provider, sport_code, entity;