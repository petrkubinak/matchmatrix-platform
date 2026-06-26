/*
746_people_all_smoke_scope_v1.sql

Účel:
- vytáhne všechny people entity, které čekají na endpoint smoke test
- podle výsledku připravíme jeden rozšířený Python smoke tester pro více sportů
*/

SELECT
    priority_rank,
    provider,
    sport_code,
    entity,
    endpoint_name,
    requires_pro,
    endpoint_exists,
    endpoint_tested,
    endpoint_returns_data,
    technical_status,
    final_verdict,
    alternative_provider_needed,
    next_step
FROM ops.provider_people_audit
WHERE final_verdict IN ('WAIT_ENDPOINT_AUDIT', 'WAIT_SCOPE_FIX', 'WAIT_PROVIDER')
ORDER BY
    CASE
        WHEN final_verdict = 'WAIT_ENDPOINT_AUDIT' THEN 1
        WHEN final_verdict = 'WAIT_SCOPE_FIX' THEN 2
        WHEN final_verdict = 'WAIT_PROVIDER' THEN 3
        ELSE 9
    END,
    priority_rank,
    provider,
    sport_code,
    entity;