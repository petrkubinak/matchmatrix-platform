/*
MATCHMATRIX SQL 19_2_H

DEPENDENCY BASED HARVEST PLANNER V1

CO TO JE:
- Harvest planner založený na závislostech vrstev.

K ČEMU TO JE:
- Core musí existovat dříve než People.
- People musí existovat dříve než Media.
- Media musí existovat dříve než Context Engine.

KDE TO UVIDÍME:
- OPS Panel V18
- Harvest Readiness
- PC2 Planning

JAK SE TO VYUŽIJE:
- Automatické doporučení další vrstvy harvestu.
*/

-- =====================================================
-- LAYER PRIORITY MAP
-- =====================================================

CREATE TABLE IF NOT EXISTS ops.harvest_dependency_layers (

    layer_code TEXT PRIMARY KEY,

    layer_order INTEGER NOT NULL,

    layer_name TEXT NOT NULL,

    depends_on_layer TEXT,

    active_flag BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO ops.harvest_dependency_layers
(
    layer_code,
    layer_order,
    layer_name,
    depends_on_layer
)
VALUES
('CORE',1,'Core Layer',NULL),
('PEOPLE',2,'People Layer','CORE'),
('MEDIA',3,'Media Layer','PEOPLE'),
('CONTEXT',4,'Context Layer','MEDIA')
ON CONFLICT (layer_code) DO NOTHING;

-- =====================================================
-- HARVEST STATUS VIEW
-- =====================================================

CREATE OR REPLACE VIEW ops.v_harvest_dependency_status_v1 AS

SELECT

    s.sport_code,

    CASE
        WHEN EXISTS (
            SELECT 1
            FROM public.matches m
            LIMIT 1
        )
        THEN 'READY'
        ELSE 'MISSING'
    END AS core_status,

    CASE
        WHEN EXISTS (
            SELECT 1
            FROM public.players p
            LIMIT 1
        )
        THEN 'READY'
        ELSE 'MISSING'
    END AS people_status,

    CASE
        WHEN EXISTS (
            SELECT 1
            FROM public.articles a
            LIMIT 1
        )
        THEN 'READY'
        ELSE 'MISSING'
    END AS media_status

FROM
(
    SELECT DISTINCT sport_code
    FROM ops.provider_missing_matrix
) s;

-- =====================================================
-- NEXT RECOMMENDED LAYER
-- =====================================================

CREATE OR REPLACE VIEW ops.v_next_harvest_layer_v1 AS

SELECT

    sport_code,

    core_status,

    people_status,

    media_status,

    CASE

        WHEN core_status <> 'READY'
            THEN 'CORE'

        WHEN people_status <> 'READY'
            THEN 'PEOPLE'

        WHEN media_status <> 'READY'
            THEN 'MEDIA'

        ELSE 'CONTEXT'

    END AS next_layer

FROM ops.v_harvest_dependency_status_v1;

-- =====================================================
-- HARVEST READINESS SUMMARY
-- =====================================================

CREATE OR REPLACE VIEW ops.v_harvest_dependency_summary_v1 AS

SELECT

    next_layer,

    COUNT(*) AS sports_count

FROM ops.v_next_harvest_layer_v1
GROUP BY next_layer
ORDER BY next_layer;

-- =====================================================
-- PC2 HARVEST QUEUE
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_harvest_queue_v1 AS

SELECT

    sport_code,

    next_layer,

    CASE

        WHEN next_layer='CORE'
            THEN 1

        WHEN next_layer='PEOPLE'
            THEN 2

        WHEN next_layer='MEDIA'
            THEN 3

        ELSE 4

    END AS execution_priority

FROM ops.v_next_harvest_layer_v1
ORDER BY
    execution_priority,
    sport_code;

-- =====================================================
-- QUICK CHECK
-- =====================================================

SELECT *
FROM ops.v_harvest_dependency_summary_v1;