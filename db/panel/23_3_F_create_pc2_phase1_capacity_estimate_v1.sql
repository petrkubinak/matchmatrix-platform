/*
MATCHMATRIX SQL 23_3_F

PC2 PHASE 1 CAPACITY ESTIMATE V1

CO TO JE:
- Audit připravenosti a odhad objemu CORE historického harvestu pro nové PC2.

K ČEMU TO JE:
- Odhad počtu úloh.
- Odhad provider streamů.
- Rozdělení sportů do vln.
- Příprava API limitů a pořadí harvestu.

KDE TO UVIDÍME:
- OPS Panel
- HARVEST READY
- PC2 DASHBOARD
- HARVEST MASTER PLAN

JAK SE TO VYUŽIJE:
- Rozhodnutí co spustit první.
- Rozdělení harvestu do vln.
- Příprava historického backfill plánu.

NAVAZUJE NA:
- 23_3_A_create_harvest_provider_readiness_matrix_v1.sql
- 23_3_D_create_harvest_master_plan_pc2_v1.sql
- 23_3_E_create_pc2_phase1_core_harvest_queue_v1.sql

DALŠÍ KROK:
- 23_3_G_create_pc2_phase2_people_harvest_queue_v1.sql
*/

DROP VIEW IF EXISTS ops.v_pc2_phase1_capacity_estimate_v1;

CREATE OR REPLACE VIEW ops.v_pc2_phase1_capacity_estimate_v1 AS

WITH base AS (
    SELECT
        sport_code,
        provider,
        entity
    FROM ops.v_pc2_phase1_core_harvest_queue_v1
),

sport_summary AS (
    SELECT
        sport_code,
        COUNT(*) AS harvest_tasks,
        COUNT(DISTINCT provider) AS providers,
        SUM(CASE WHEN entity = 'leagues' THEN 1 ELSE 0 END) AS league_streams,
        SUM(CASE WHEN entity = 'teams' THEN 1 ELSE 0 END) AS team_streams,
        SUM(CASE WHEN entity = 'fixtures' THEN 1 ELSE 0 END) AS fixture_streams
    FROM base
    GROUP BY sport_code
),

scored AS (
    SELECT
        sport_code,
        harvest_tasks,
        providers,
        league_streams,
        team_streams,
        fixture_streams,

        CASE
            WHEN sport_code = 'FB' THEN 'VERY_HIGH'
            WHEN sport_code IN ('BK','HK','HB','AFB') THEN 'HIGH'
            WHEN sport_code IN ('BSB','VB','RGB','CK') THEN 'MEDIUM'
            ELSE 'LOW'
        END AS estimated_volume,

        CASE
            WHEN sport_code = 'FB' THEN 'WAVE_1'
            WHEN sport_code IN ('BK','HK','AFB') THEN 'WAVE_2'
            WHEN sport_code IN ('HB','VB','BSB') THEN 'WAVE_3'
            ELSE 'WAVE_4'
        END AS recommended_wave,

        CASE
            WHEN sport_code = 'FB' THEN 'START FIRST'
            WHEN sport_code IN ('BK','HK','AFB') THEN 'START AFTER FOOTBALL'
            ELSE 'RUN IN PARALLEL'
        END AS recommendation,

        now() AS refreshed_at
    FROM sport_summary
)

SELECT *
FROM scored;