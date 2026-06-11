/*
MATCHMATRIX SQL 23_3_E

PC2 PHASE 1 CORE HARVEST QUEUE V1

CO TO JE:
- První produkční harvest fronta pro nové PC2.
- Obsahuje pouze CORE HISTORY položky, které jsou připravené ke spuštění.

K ČEMU TO JE:
- Určuje přesné pořadí historického stahování základních dat.
- Slouží jako vstup pro planner, scheduler a budoucí automatické spuštění harvestu.
- Zajišťuje, že nejdříve budou staženy ligy, potom týmy a následně zápasy.

KDE TO UVIDÍME:
- OPS Panel V18/V19
- HARVEST READY
- PC2 HARVEST DASHBOARD
- HARVEST MASTER PLAN

JAK SE TO VYUŽIJE:
- Po spuštění nového PC2 bude tato fronta představovat první vlnu harvestu.
- Nejprve se naplní public.leagues.
- Poté public.teams.
- Nakonec public.matches.
- Výstup vytvoří historickou CORE databázi napříč sporty.
- Po dokončení bude navazovat PHASE_2_PEOPLE_HISTORY.

NAVAZUJE NA:
- 23_3_A_create_harvest_provider_readiness_matrix_v1.sql
- 23_3_B_sync_provider_worker_registry_from_unified_v1.sql
- 23_3_D_create_harvest_master_plan_pc2_v1.sql

DALŠÍ KROK:
- 23_3_F_create_pc2_phase2_people_harvest_queue_v1.sql
*/

DROP VIEW IF EXISTS ops.v_pc2_phase1_core_harvest_queue_v1;

CREATE OR REPLACE VIEW ops.v_pc2_phase1_core_harvest_queue_v1 AS

SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            sport_code,
            provider,
            entity
    ) AS queue_order,

    sport_code,
    provider,
    entity,

    pc2_phase,
    execution_strategy,

    harvest_readiness_status,

    free_plan_supported,
    paid_plan_supported,

    has_active_worker,

    source_endpoint,
    target_table,

    registered_workers,

    harvest_priority_score,

    CASE
        WHEN entity = 'leagues'
            THEN 1
        WHEN entity = 'teams'
            THEN 2
        WHEN entity = 'fixtures'
            THEN 3
        ELSE 99
    END AS execution_step,

    'READY_FOR_PC2' AS queue_status,

    refreshed_at

FROM ops.v_harvest_master_plan_pc2_v1

WHERE pc2_phase = 'PHASE_1_CORE_HISTORY'
  AND execution_strategy = 'START_IMMEDIATELY'
  AND harvest_readiness_status = 'READY';