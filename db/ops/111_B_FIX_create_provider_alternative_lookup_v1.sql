/*
MATCHMATRIX SQL 111_B FIX Create Provider Alternative Lookup V1

CO TO JE:
- Vyhledávač alternativních providerů podle skutečné struktury ops.provider_entity_coverage.

K ČEMU TO JE:
- Najde jiné providery pro stejný sport/entity.
- Ukáže, zda jsou enabled, primary/fallback, free/paid a jakou mají kvalitu.

KDE TO UVIDÍME:
- Panel V18+
- AI OPS
- Provider Switch Engine
*/


CREATE OR REPLACE VIEW ops.v_provider_alternative_lookup_v1 AS
SELECT

    ps.provider                    AS current_provider,
    ps.sport_code,
    ps.entity,

    ps.success_rate_pct,

    c.provider                     AS alternative_provider,

    c.coverage_status,
    c.is_enabled,
    c.provider_priority,
    c.quality_rating,
    c.availability_scope,
    c.free_plan_supported,
    c.paid_plan_supported,
    c.expected_depth,
    c.is_primary_source,
    c.is_fallback_source,
    c.source_endpoint,
    c.worker_script,
    c.notes,
    c.limitations,
    c.next_action,

    CASE

        WHEN c.provider = ps.provider
            THEN false

        WHEN c.is_enabled = true
         AND c.coverage_status IN
             (
                'CONFIRMED',
                'IMPLEMENTED',
                'IMPLEMENTED_CORE',
                'READY_AUTOMAT',
                'READY_VALIDATE'
             )
        THEN true

        WHEN c.is_enabled = true
         AND c.is_fallback_source = true
        THEN true

        ELSE false

    END AS candidate_for_switch,

    CASE

        WHEN c.provider = ps.provider
            THEN 'Aktuální provider.'

        WHEN c.is_enabled = true
         AND c.coverage_status IN
             (
                'CONFIRMED',
                'IMPLEMENTED',
                'IMPLEMENTED_CORE',
                'READY_AUTOMAT',
                'READY_VALIDATE'
             )
        THEN 'Vhodný kandidát pro ověření.'

        WHEN c.is_enabled = true
         AND c.is_fallback_source = true
        THEN 'Fallback provider vhodný k testu.'

        WHEN c.is_enabled = false
        THEN 'Provider je vypnutý.'

        ELSE 'Provider zatím není připravený.'

    END AS recommendation_cz

FROM ops.v_provider_failure_summary_v1 ps

JOIN ops.provider_entity_coverage c
     ON c.sport_code = ps.sport_code
    AND c.entity = ps.entity;



CREATE OR REPLACE VIEW ops.v_provider_alternative_panel_v1 AS
SELECT

    current_provider        AS "Aktuální provider",
    sport_code             AS "Sport",
    entity                 AS "Entita",

    success_rate_pct       AS "Úspěšnost %",

    alternative_provider   AS "Alternativní provider",

    coverage_status        AS "Coverage",
    is_enabled             AS "Enabled",
    provider_priority      AS "Priorita providera",
    quality_rating         AS "Kvalita",
    availability_scope     AS "Dostupnost",
    free_plan_supported    AS "Free plán",
    paid_plan_supported    AS "Paid plán",
    expected_depth         AS "Hloubka dat",
    is_primary_source      AS "Primary",
    is_fallback_source     AS "Fallback",

    source_endpoint        AS "Endpoint",
    worker_script          AS "Worker",

    candidate_for_switch   AS "Lze použít",

    recommendation_cz      AS "Doporučení",

    notes                  AS "Poznámka",
    limitations            AS "Limity",
    next_action            AS "Další krok"

FROM ops.v_provider_alternative_lookup_v1
ORDER BY
    current_provider,
    candidate_for_switch DESC,
    provider_priority NULLS LAST,
    alternative_provider;