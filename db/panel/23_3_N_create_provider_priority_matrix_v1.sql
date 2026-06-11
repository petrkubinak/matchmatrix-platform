/*
MATCHMATRIX SQL 23_3_N

PROVIDER PRIORITY MATRIX V1

CO TO JE:
- Prioritizační matice provider research úkolů.

K ČEMU TO JE:
- Určuje co řešit nejdříve.
- Převádí research plán na pořadí.
- Pomáhá OPS panelu doporučit další krok.

KDE TO UVIDÍME:
- OPS Panel
- Provider Command Center
- AI Recommendations
- PC2 Dashboard

JAK SE TO VYUŽIJE:
- AI doporučení.
- OPS doporučení.
- PC2 příprava.
- Provider roadmap.

NAVAZUJE NA:
- 23_3_M_create_provider_research_master_plan_v1.sql

DALŠÍ KROK:
- 23_3_O_create_pc2_go_live_checklist_v1.sql
*/

DROP VIEW IF EXISTS ops.v_provider_priority_matrix_v1;

CREATE OR REPLACE VIEW ops.v_provider_priority_matrix_v1 AS

SELECT

    ROW_NUMBER() OVER (
        ORDER BY

            CASE priority_level
                WHEN 'CRITICAL' THEN 1
                WHEN 'HIGH' THEN 2
                WHEN 'MEDIUM' THEN 3
                ELSE 4
            END,

            priority_order
    ) AS provider_priority_rank,

    research_area,

    sport_code,

    target_entity,

    priority_level,

    research_task,

    business_reason,

    CASE

        WHEN target_entity = 'PLAYER_PHOTOS'
            THEN 100

        WHEN target_entity = 'TEAM_LOGOS'
            THEN 95

        WHEN target_entity = 'COACH_PHOTOS'
            THEN 90

        WHEN target_entity = 'STADIUM_PHOTOS'
            THEN 85

        WHEN target_entity = 'PLAYERS'
            THEN 80

        WHEN target_entity = 'SPORTSDATAIO'
            THEN 75

        WHEN target_entity = 'HISTORICAL_ODDS'
            THEN 60

        ELSE 50

    END AS strategic_score,

    CASE

        WHEN target_entity IN (
            'PLAYER_PHOTOS',
            'TEAM_LOGOS'
        )
            THEN 'WEB_AND_APP_CRITICAL'

        WHEN target_entity IN (
            'COACH_PHOTOS',
            'STADIUM_PHOTOS'
        )
            THEN 'WEB_ENHANCEMENT'

        WHEN target_entity = 'PLAYERS'
            THEN 'PEOPLE_EXPANSION'

        WHEN target_entity = 'HISTORICAL_ODDS'
            THEN 'OPTIONAL_LAYER'

        ELSE
            'REVIEW'

    END AS expected_business_value,

    now() AS refreshed_at

FROM ops.v_provider_research_master_plan_v1;