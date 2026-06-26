/*
742_people_smoke_test_queue_v1.sql

Účel:
- vytvoří přehled, co testovat jako první v PEOPLE vrstvě
- nic nestahuje
- jen ukáže prioritu smoke testů players/coaches
*/

SELECT
    priority_rank,
    provider,
    sport_code,
    entity,
    endpoint_name,
    endpoint_exists,
    endpoint_returns_data,
    requires_pro,
    alternative_provider_needed,
    CASE
        WHEN endpoint_exists = true OR endpoint_returns_data = true THEN 'P1_TEST_FIRST'
        WHEN alternative_provider_needed = false THEN 'P2_VERIFY_PROVIDER'
        ELSE 'P3_FIND_ALT_PROVIDER'
    END AS smoke_priority,
    next_step
FROM ops.provider_people_audit
WHERE final_verdict IN ('WAIT_ENDPOINT_AUDIT', 'WAIT_PROVIDER')
ORDER BY
    CASE
        WHEN endpoint_exists = true OR endpoint_returns_data = true THEN 1
        WHEN alternative_provider_needed = false THEN 2
        ELSE 3
    END,
    priority_rank,
    provider,
    sport_code,
    entity;