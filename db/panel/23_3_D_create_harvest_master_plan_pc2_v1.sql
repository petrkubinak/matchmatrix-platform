/*
MATCHMATRIX SQL 23_3_D

HARVEST MASTER PLAN PC2 V1

CO TO JE:
- Hlavní plán velkého harvestu pro nové PC2.
- Sjednocuje provider readiness, worker readiness a roadmapu harvestu.

K ČEMU TO JE:
- Přesně určí co budeme stahovat.
- Určí pořadí fází.
- Ukáže blokace.
- Bude hlavním zdrojem pro Panel V19.

KDE TO UVIDÍME:
- HARVEST PŘIPRAVENOST
- PC2 ROADMAP
- OPERAČNÍ CENTRUM

JAK SE TO VYUŽIJE:
- Historický backfill.
- People harvest.
- Media harvest.
- Live ingest plán.
*/

DROP VIEW IF EXISTS ops.v_harvest_master_plan_pc2_v1;

CREATE OR REPLACE VIEW ops.v_harvest_master_plan_pc2_v1 AS

SELECT

    ROW_NUMBER() OVER (
        ORDER BY
            CASE harvest_layer
                WHEN 'CORE'   THEN 1
                WHEN 'PEOPLE' THEN 2
                WHEN 'MEDIA'  THEN 3
                WHEN 'ODDS'   THEN 4
                ELSE 5
            END,
            harvest_priority_score DESC
    ) AS roadmap_order,

    sport_code,

    harvest_layer,

    provider,

    entity,

    harvest_readiness_status,

    free_plan_supported,

    paid_plan_supported,

    has_active_worker,

    quality_rating,

    expected_depth,

    CASE
        WHEN harvest_layer = 'CORE'
            THEN 'PHASE_1_CORE_HISTORY'

        WHEN harvest_layer = 'PEOPLE'
            THEN 'PHASE_2_PEOPLE_HISTORY'

        WHEN harvest_layer = 'MEDIA'
            THEN 'PHASE_3_MEDIA_HISTORY'

        WHEN harvest_layer = 'ODDS'
            THEN 'PHASE_4_ODDS_HISTORY'

        ELSE
            'PHASE_5_OTHER'
    END AS pc2_phase,

    CASE
        WHEN harvest_layer = 'CORE'
             AND harvest_readiness_status = 'READY'
            THEN 'START_IMMEDIATELY'

        WHEN harvest_layer = 'PEOPLE'
             AND harvest_readiness_status IN ('READY','PARTIAL')
            THEN 'AFTER_CORE'

        WHEN harvest_layer = 'MEDIA'
            THEN 'AFTER_PEOPLE'

        WHEN harvest_layer = 'ODDS'
            THEN 'OPTIONAL_AFTER_MEDIA'

        ELSE
            'REVIEW_REQUIRED'
    END AS execution_strategy,

    recommended_next_step,

    harvest_priority_score,

    source_endpoint,

    target_table,

    registered_workers,

    notes,

    limitations,

    refreshed_at

FROM ops.v_harvest_provider_readiness_matrix_v1;