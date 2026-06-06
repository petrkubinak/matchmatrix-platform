/*
MATCHMATRIX SQL 111_H Next Development Plan V1

CO TO JE:
- Automatický plán dalšího vývoje.

K ČEMU TO JE:
- AI OPS ví co dodělat.
- Panel ukáže další doporučené kroky.
- Převádí coverage gap na konkrétní úkoly.

KDE TO UVIDÍME:
- Panel V18+
- AI OPS
- Development Roadmap

JAK SE TO VYUŽIJE:
- Co chybí
- Jaká je priorita
- Čeká/nečeká na PRO
- Jaký typ práce je potřeba
*/


CREATE OR REPLACE VIEW ops.v_next_development_plan_v1 AS
SELECT

    sport_code,
    entity,

    business_priority,

    ready_count,
    missing_count,
    paid_count,

    CASE

        WHEN paid_count > 0
        THEN 'ČEKÁ NA PRO'

        WHEN missing_count > 0
        THEN 'VÝVOJ'

        ELSE 'HOTOVO'

    END AS task_state_cz,

    CASE

        WHEN sport_code='FB'
         AND entity='odds'
        THEN 'Porovnat API-Football odds vs THEODDS a připravit multi-provider odds vrstvu.'

        WHEN sport_code='FB'
         AND entity='player_season_stats'
        THEN 'Dokončit player season statistics pipeline.'

        WHEN sport_code='BK'
         AND entity='players'
        THEN 'Dokončit BK PEOPLE pipeline.'

        WHEN sport_code='HK'
         AND entity='players'
        THEN 'Ověřit SportsDataIO fallback a HK people coverage.'

        WHEN sport_code='HB'
         AND entity='players'
        THEN 'Připravit handball players fallback strategii.'

        WHEN sport_code='VB'
         AND entity='players'
        THEN 'Najít a ověřit alternativního VB provideru.'

        ELSE 'Naplánovat implementaci dle coverage roadmapy.'

    END AS recommended_action_cz,

    CASE

        WHEN paid_count > 0
        THEN 'PAID_PLAN_REQUIRED'

        WHEN missing_count > 0
        THEN 'IMPLEMENTATION_REQUIRED'

        ELSE 'COMPLETED'

    END AS action_code

FROM ops.v_coverage_priority_dashboard_v1;