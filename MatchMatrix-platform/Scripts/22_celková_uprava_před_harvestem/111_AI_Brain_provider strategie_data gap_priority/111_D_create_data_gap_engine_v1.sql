/*
MATCHMATRIX SQL 111_D Create Data Gap Engine V1

CO TO JE:
- AI Data Gap Engine.

K ČEMU TO JE:
- Určí proč data chybí.
- Rozliší technický problém od obchodního omezení.
- Připraví roadmapu doplnění dat.

KDE TO UVIDÍME:
- Panel V18+
- DATA COVERAGE
- AI OPS

JAK SE TO VYUŽIJE:
- Co máme
- Co nemáme
- Proč to nemáme
- Co udělat dál
*/


CREATE OR REPLACE VIEW ops.v_data_gap_engine_v1 AS
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

        WHEN coverage_status='blocked'
         AND free_plan_supported=true
         AND paid_plan_supported=true
        THEN 'WAIT_FOR_PAID_PLAN'

        WHEN coverage_status='planned'
        THEN 'NOT_IMPLEMENTED_YET'

        WHEN coverage_status='hold'
        THEN 'ON_HOLD'

        WHEN coverage_status='blocked'
        THEN 'PROVIDER_LIMITATION'

        WHEN coverage_status IN
            (
                'IMPLEMENTED',
                'IMPLEMENTED_CORE',
                'CONFIRMED',
                'READY_AUTOMAT',
                'READY_VALIDATE'
            )
        THEN 'READY'

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

        WHEN coverage_status='blocked'
        THEN 'Provider aktuálně neumožňuje získání dat.'

        WHEN coverage_status IN
            (
                'IMPLEMENTED',
                'IMPLEMENTED_CORE',
                'CONFIRMED',
                'READY_AUTOMAT',
                'READY_VALIDATE'
            )
        THEN 'Připraveno ke stahování.'

        ELSE 'Vyžaduje analýzu.'

    END AS gap_reason_cz

FROM ops.provider_entity_coverage
WHERE is_enabled = true;