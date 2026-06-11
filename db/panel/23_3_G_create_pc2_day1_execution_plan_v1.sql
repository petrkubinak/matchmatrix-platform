/*
MATCHMATRIX SQL 23_3_G

PC2 DAY 1 EXECUTION PLAN V1

CO TO JE:
- První operační plán pro nový PC2.

K ČEMU TO JE:
- Určuje přesné pořadí CORE history harvestu pro první den.

KDE TO UVIDÍME:
- OPS Panel
- PC2 Dashboard
- Harvest Ready
- Operační Centrum

JAK SE TO VYUŽIJE:
- PC2 pojede podle vln: FB → AFB/BK/HK → BSB/HB/VB → CK/FH/RGB.

NAVAZUJE NA:
- 23_3_D_create_harvest_master_plan_pc2_v1.sql
- 23_3_E_create_pc2_phase1_core_harvest_queue_v1.sql
- 23_3_F_create_pc2_phase1_capacity_estimate_v1.sql

DALŠÍ KROK:
- 23_3_H_create_pc2_phase2_people_harvest_queue_v1.sql
*/

DROP VIEW IF EXISTS ops.v_pc2_day1_execution_plan_v1;

CREATE OR REPLACE VIEW ops.v_pc2_day1_execution_plan_v1 AS
WITH base AS (
    SELECT
        sport_code,
        provider,
        entity,
        execution_step,
        queue_status
    FROM ops.v_pc2_phase1_core_harvest_queue_v1
),
planned AS (
    SELECT
        sport_code,
        provider,
        entity,
        execution_step,
        queue_status,
        CASE
            WHEN sport_code = 'FB' THEN 'WAVE_1'
            WHEN sport_code IN ('AFB','BK','HK') THEN 'WAVE_2'
            WHEN sport_code IN ('BSB','HB','VB') THEN 'WAVE_3'
            ELSE 'WAVE_4'
        END AS execution_wave,
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
            wave_order,
            execution_step,
            sport_code,
            provider
    ) AS execution_order,
    execution_wave,
    sport_code,
    provider,
    entity,
    execution_step,
    queue_status,
    CASE
        WHEN execution_step = 1 THEN 'LOAD_LEAGUES'
        WHEN execution_step = 2 THEN 'LOAD_TEAMS'
        WHEN execution_step = 3 THEN 'LOAD_FIXTURES'
        ELSE 'REVIEW'
    END AS execution_action,
    CASE
        WHEN execution_wave = 'WAVE_1' THEN 'START IMMEDIATELY'
        WHEN execution_wave = 'WAVE_2' THEN 'START AFTER FOOTBALL'
        WHEN execution_wave = 'WAVE_3' THEN 'RUN PARALLEL'
        ELSE 'LOW PRIORITY'
    END AS recommendation,
    now() AS refreshed_at
FROM planned;