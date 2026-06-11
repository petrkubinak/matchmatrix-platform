/*
MATCHMATRIX SQL 23_3_H

PC2 PHASE 2 PEOPLE HARVEST QUEUE V1

CO TO JE:
- Fronta pro druhou fázi PC2 harvestu: PEOPLE HISTORY.
- Navazuje po dokončení CORE historie.

K ČEMU TO JE:
- Připraví seznam pro stahování hráčů, trenérů, profilů a statistik.
- Rozdělí PEOPLE harvest na READY / PARTIAL / BLOCKED / PAID / REVIEW.
- Ukáže, co můžeme pustit hned po CORE a co je nutné nejdříve opravit.

KDE TO UVIDÍME:
- OPS Panel
- PC2 Dashboard
- People Command Center
- Harvest Ready

JAK SE TO VYUŽIJE:
- Po dokončení CORE historie se podle této fronty spustí PEOPLE harvest.
- Nejprve READY položky.
- Potom PARTIAL po kontrole.
- BLOCKED položky půjdou do provider/worker review.
- PAID položky až po aktivaci placeného plánu.

NAVAZUJE NA:
- 23_3_A_create_harvest_provider_readiness_matrix_v1.sql
- 23_3_D_create_harvest_master_plan_pc2_v1.sql
- 23_3_G_create_pc2_day1_execution_plan_v1.sql

DALŠÍ KROK:
- 23_3_I_create_pc2_phase2_people_execution_plan_v1.sql
*/

DROP VIEW IF EXISTS ops.v_pc2_phase2_people_harvest_queue_v1;

CREATE OR REPLACE VIEW ops.v_pc2_phase2_people_harvest_queue_v1 AS

WITH base AS (
    SELECT
        roadmap_order,
        sport_code,
        provider,
        entity,
        harvest_layer,
        pc2_phase,
        execution_strategy,
        harvest_readiness_status,
        free_plan_supported,
        paid_plan_supported,
        has_active_worker,
        quality_rating,
        expected_depth,
        recommended_next_step,
        harvest_priority_score,
        source_endpoint,
        target_table,
        registered_workers,
        notes,
        limitations,
        refreshed_at
    FROM ops.v_harvest_master_plan_pc2_v1
    WHERE pc2_phase = 'PHASE_2_PEOPLE_HISTORY'
),

planned AS (
    SELECT
        *,
        CASE
            WHEN entity = 'players' THEN 1
            WHEN entity = 'coaches' THEN 2
            WHEN entity = 'player_profiles' THEN 3
            WHEN entity = 'player_stats' THEN 4
            WHEN entity = 'player_season_stats' THEN 5
            ELSE 99
        END AS people_step,

        CASE
            WHEN harvest_readiness_status = 'READY' THEN 'READY_FOR_PC2'
            WHEN harvest_readiness_status = 'PARTIAL' THEN 'REVIEW_THEN_RUN'
            WHEN harvest_readiness_status = 'PAID_READY' THEN 'WAIT_FOR_PAID_PLAN'
            WHEN harvest_readiness_status = 'WAIT_FOR_PAID_OR_TEST' THEN 'WAIT_FOR_PAID_OR_TEST'
            WHEN harvest_readiness_status = 'BLOCKED' THEN 'BLOCKED_REVIEW'
            ELSE 'NEEDS_WORKER_OR_PROVIDER_REVIEW'
        END AS people_queue_status,

        CASE
            WHEN sport_code = 'FB' THEN 'WAVE_1'
            WHEN sport_code IN ('AFB','BK','HK') THEN 'WAVE_2'
            WHEN sport_code IN ('BSB','HB','VB') THEN 'WAVE_3'
            ELSE 'WAVE_4'
        END AS people_wave,

        CASE
            WHEN sport_code = 'FB' THEN 1
            WHEN sport_code IN ('AFB','BK','HK') THEN 2
            WHEN sport_code IN ('BSB','HB','VB') THEN 3
            ELSE 4
        END AS wave_order
    FROM base
)

SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            CASE people_queue_status
                WHEN 'READY_FOR_PC2' THEN 1
                WHEN 'REVIEW_THEN_RUN' THEN 2
                WHEN 'WAIT_FOR_PAID_PLAN' THEN 3
                WHEN 'WAIT_FOR_PAID_OR_TEST' THEN 4
                WHEN 'BLOCKED_REVIEW' THEN 5
                ELSE 6
            END,
            wave_order,
            people_step,
            sport_code,
            provider
    ) AS queue_order,

    people_wave,
    sport_code,
    provider,
    entity,

    people_step,
    people_queue_status,

    harvest_readiness_status,
    free_plan_supported,
    paid_plan_supported,
    has_active_worker,

    quality_rating,
    expected_depth,

    recommended_next_step,
    harvest_priority_score,

    source_endpoint,
    target_table,
    registered_workers,

    notes,
    limitations,
    refreshed_at

FROM planned;