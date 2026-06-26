/*
MATCHMATRIX SQL 111_E Create Data Gap Engine V2

CO TO JE:
- Oprava klasifikace READY stavů.

K ČEMU TO JE:
- runtime_tested už nebude UNKNOWN
- tech_ready už nebude UNKNOWN
- public-confirmed už nebude UNKNOWN

KDE TO UVIDÍME:
- Data Gap Panel
- Coverage Dashboard
- AI OPS

JAK SE TO VYUŽIJE:
- Přesnější vyhodnocení skutečného stavu projektu.
*/


CREATE OR REPLACE VIEW ops.v_data_gap_engine_v2 AS
SELECT

    provider,
    sport_code,
    entity,

    coverage_status,
    free_plan_supported,
    paid_plan_supported,

    notes,
    limitations,
    next_action,

    CASE

        /* čeká na PRO */

        WHEN coverage_status='blocked'
         AND free_plan_supported=true
         AND paid_plan_supported=true
        THEN 'WAIT_FOR_PAID_PLAN'


        /* implementace chybí */

        WHEN coverage_status='planned'
        THEN 'NOT_IMPLEMENTED_YET'


        /* pozastaveno */

        WHEN coverage_status='hold'
        THEN 'ON_HOLD'


        /* hotovo */

        WHEN coverage_status IN
        (
            'runtime_tested',
            'tech_ready',
            'public_confirmed',
            'public-confirmed',
            'IMPLEMENTED',
            'IMPLEMENTED_CORE',
            'CONFIRMED',
            'READY_AUTOMAT',
            'READY_VALIDATE'
        )
        THEN 'READY'


        /* provider blokuje */

        WHEN coverage_status='blocked'
        THEN 'PROVIDER_LIMITATION'


        ELSE 'UNKNOWN'

    END AS gap_status_code,



    CASE

        WHEN coverage_status='blocked'
         AND free_plan_supported=true
         AND paid_plan_supported=true
        THEN 'Čeká na aktivaci placeného plánu.'

        WHEN coverage_status='planned'
        THEN 'Pipeline zatím není implementována.'

        WHEN coverage_status='hold'
        THEN 'Vývoj dočasně pozastaven.'

        WHEN coverage_status IN
        (
            'runtime_tested',
            'tech_ready',
            'public_confirmed',
            'public-confirmed',
            'IMPLEMENTED',
            'IMPLEMENTED_CORE',
            'CONFIRMED',
            'READY_AUTOMAT',
            'READY_VALIDATE'
        )
        THEN 'Připraveno ke stahování.'

        WHEN coverage_status='blocked'
        THEN 'Provider aktuálně neumožňuje získání dat.'

        ELSE 'Vyžaduje analýzu.'

    END AS gap_reason_cz

FROM ops.provider_entity_coverage
WHERE is_enabled = true;



CREATE OR REPLACE VIEW ops.v_data_gap_panel_v2 AS
SELECT

    provider                AS "Provider",
    sport_code              AS "Sport",
    entity                  AS "Entita",

    gap_status_code         AS "Status",

    gap_reason_cz           AS "Důvod",

    coverage_status         AS "Coverage",

    free_plan_supported     AS "Free",
    paid_plan_supported     AS "Paid",

    next_action             AS "Další krok",

    limitations             AS "Omezení"

FROM ops.v_data_gap_engine_v2
ORDER BY
    sport_code,
    entity,
    provider;