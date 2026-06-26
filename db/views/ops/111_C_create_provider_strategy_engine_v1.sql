/*
MATCHMATRIX SQL 111_C Provider Strategy Engine V1

CO TO JE:
- Strategické rozhodování nad providery.

K ČEMU TO JE:
- Rozhodne:
    KEEP_PROVIDER
    TEST_ALTERNATIVE
    NEED_NEW_PROVIDER
    WAIT_FOR_PAID_PLAN

KDE TO UVIDÍME:
- Panel V18+
- AI OPS
- Provider Strategy

JAK SE TO VYUŽIJE:
- AI nebude řešit jen chyby.
- Bude umět určit proč provider nefunguje.
- A co je správný další krok.
*/


CREATE OR REPLACE VIEW ops.v_provider_strategy_engine_v1 AS
SELECT

    a.current_provider,
    a.sport_code,
    a.entity,

    a.success_rate_pct,

    a.coverage_status,
    a.free_plan_supported,
    a.paid_plan_supported,

    a.candidate_for_switch,

    CASE

        WHEN a.coverage_status = 'blocked'
             AND a.free_plan_supported = true
             AND a.paid_plan_supported = true
        THEN 'WAIT_FOR_PAID_PLAN'

        WHEN a.candidate_for_switch = true
        THEN 'TEST_ALTERNATIVE'

        WHEN a.success_rate_pct < 25
        THEN 'NEED_NEW_PROVIDER'

        ELSE 'KEEP_PROVIDER'

    END AS strategy_code,

    CASE

        WHEN a.coverage_status = 'blocked'
             AND a.free_plan_supported = true
             AND a.paid_plan_supported = true
        THEN 'Provider je omezen free plánem. Po aktivaci PRO znovu ověřit.'

        WHEN a.candidate_for_switch = true
        THEN 'Existuje alternativní provider. Doporučeno provést smoke test.'

        WHEN a.success_rate_pct < 25
        THEN 'Provider dlouhodobě selhává. Nutné hledat nový zdroj.'

        ELSE 'Provider funguje správně.'

    END AS strategy_reason_cz,

    CASE

        WHEN a.coverage_status = 'blocked'
             AND a.free_plan_supported = true
             AND a.paid_plan_supported = true
        THEN 95

        WHEN a.candidate_for_switch = true
        THEN 80

        WHEN a.success_rate_pct < 25
        THEN 100

        ELSE 70

    END AS confidence_score

FROM ops.v_provider_alternative_lookup_v1 a;