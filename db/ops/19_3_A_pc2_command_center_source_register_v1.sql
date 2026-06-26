/*
MATCHMATRIX SQL 19_3_A

PC2 COMMAND CENTER SOURCE REGISTER V1

CO TO JE:
- Registrace zdrojových view pro budoucí PC2 Command Center.

K ČEMU TO JE:
- Jeden centrální seznam view používaných PC2 panelem.

KDE TO UVIDÍME:
- OPS Panel V18
- PC2 Command Center

JAK SE TO VYUŽIJE:
- Panel bude vědět, odkud číst data.
*/

CREATE TABLE IF NOT EXISTS ops.pc2_command_center_sources (

    source_id BIGSERIAL PRIMARY KEY,

    source_name TEXT NOT NULL UNIQUE,

    source_type TEXT NOT NULL,

    source_schema TEXT NOT NULL,

    source_object TEXT NOT NULL,

    purpose TEXT,

    panel_section TEXT,

    active_flag BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO ops.pc2_command_center_sources
(
    source_name,
    source_type,
    source_schema,
    source_object,
    purpose,
    panel_section
)
VALUES

(
    'PC2_MASTER_ROADMAP',
    'VIEW',
    'ops',
    'v_pc2_master_harvest_roadmap_v1',
    'Hlavní roadmapa harvestu',
    'ROADMAP'
),

(
    'PC2_MASTER_KPI',
    'VIEW',
    'ops',
    'v_pc2_master_harvest_kpi_v1',
    'Souhrnné KPI',
    'KPI'
),

(
    'PC2_NEXT_ACTION_QUEUE',
    'VIEW',
    'ops',
    'v_pc2_master_next_action_queue_v1',
    'Další doporučené akce',
    'QUEUE'
),

(
    'PC2_PHOTO_READINESS',
    'VIEW',
    'ops',
    'v_pc2_photo_harvest_readiness_v1',
    'Photo readiness',
    'PHOTO'
),

(
    'PC2_SPORT_QUEUE',
    'VIEW',
    'ops',
    'v_sport_detail_harvest_queue_v1',
    'Sportovní harvest fronta',
    'SPORT_QUEUE'
)

ON CONFLICT (source_name) DO NOTHING;


CREATE OR REPLACE VIEW ops.v_pc2_command_center_sources_v1 AS
SELECT
    source_name,
    source_type,
    source_schema,
    source_object,
    purpose,
    panel_section,
    active_flag
FROM ops.pc2_command_center_sources
ORDER BY
    panel_section,
    source_name;


SELECT
    panel_section,
    COUNT(*) AS source_count
FROM ops.v_pc2_command_center_sources_v1
GROUP BY panel_section
ORDER BY panel_section;