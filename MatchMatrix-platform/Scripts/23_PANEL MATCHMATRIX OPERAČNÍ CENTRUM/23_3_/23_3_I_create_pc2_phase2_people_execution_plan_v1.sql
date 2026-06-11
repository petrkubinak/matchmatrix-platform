/*
MATCHMATRIX SQL 23_3_I

PC2 PHASE 2 PEOPLE EXECUTION PLAN V1

CO TO JE:
- Operační plán druhé fáze PC2.
- Převádí People Harvest Queue na konkrétní pořadí spuštění.

K ČEMU TO JE:
- Určuje pořadí harvestu hráčů, trenérů a statistik.
- Odděluje READY, REVIEW, PAID a BLOCKED.
- Připravuje skutečný harmonogram po dokončení CORE historie.

KDE TO UVIDÍME:
- OPS Panel
- PC2 Dashboard
- People Command Center
- Harvest Ready

JAK SE TO VYUŽIJE:
- Po dokončení CORE historie.
- Nejdříve FB a AFB players.
- Poté BK a CK review.
- Následně paid providery.
- Nakonec blocked/provider review položky.

NAVAZUJE NA:
- 23_3_H_create_pc2_phase2_people_harvest_queue_v1.sql

DALŠÍ KROK:
- 23_3_J_create_pc2_media_provider_audit_v1.sql
*/

DROP VIEW IF EXISTS ops.v_pc2_phase2_people_execution_plan_v1;

CREATE OR REPLACE VIEW ops.v_pc2_phase2_people_execution_plan_v1 AS

WITH planned AS (

    SELECT
        queue_order,
        people_wave,
        sport_code,
        provider,
        entity,
        people_step,
        people_queue_status,
        harvest_readiness_status,
        recommended_next_step,

        CASE
            WHEN people_queue_status = 'READY_FOR_PC2' THEN 1
            WHEN people_queue_status = 'REVIEW_THEN_RUN' THEN 2
            WHEN people_queue_status = 'WAIT_FOR_PAID_PLAN' THEN 3
            WHEN people_queue_status = 'WAIT_FOR_PAID_OR_TEST' THEN 4
            WHEN people_queue_status = 'BLOCKED_REVIEW' THEN 5
            ELSE 6
        END AS execution_priority

    FROM ops.v_pc2_phase2_people_harvest_queue_v1

)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY
            execution_priority,
            people_wave,
            people_step,
            sport_code,
            provider
    ) AS execution_order,

    people_wave,

    sport_code,

    provider,

    entity,

    people_queue_status,

    harvest_readiness_status,

    CASE

        WHEN people_queue_status = 'READY_FOR_PC2'
            THEN 'RUN_NOW'

        WHEN people_queue_status = 'REVIEW_THEN_RUN'
            THEN 'REVIEW_AND_RUN'

        WHEN people_queue_status = 'WAIT_FOR_PAID_PLAN'
            THEN 'WAIT_FOR_PROVIDER_PLAN'

        WHEN people_queue_status = 'WAIT_FOR_PAID_OR_TEST'
            THEN 'SMOKE_TEST_FIRST'

        WHEN people_queue_status = 'BLOCKED_REVIEW'
            THEN 'FIX_PROVIDER_HEALTH'

        ELSE
            'MANUAL_REVIEW'

    END AS execution_action,

    recommended_next_step,

    now() AS refreshed_at

FROM planned;