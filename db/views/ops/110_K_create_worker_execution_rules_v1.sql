/*
MATCHMATRIX SQL 110_K Create Worker Execution Rules V1

CO TO JE:
- Pravidla mapování AI akce -> worker.

K ČEMU TO JE:
- AI OPS nebude vybírat worker natvrdo.
- Podle typu akce najde správný worker.
- Základ autonomního rozhodování.

KDE TO UVIDÍME:
- Panel V18+
- Autonomous Launcher
- AI OPS

JAK SE TO VYUŽIJE:
- AI vytvoří akci.
- Najde execution rule.
- Vybere worker.
- Spustí worker.
*/


CREATE TABLE IF NOT EXISTS ops.worker_execution_rules (

    id bigserial PRIMARY KEY,

    action_code text NOT NULL UNIQUE,

    worker_code text NOT NULL,

    priority_order integer NOT NULL DEFAULT 100,

    requires_provider boolean NOT NULL DEFAULT false,
    requires_sport boolean NOT NULL DEFAULT false,
    requires_entity boolean NOT NULL DEFAULT false,

    requires_league_id boolean NOT NULL DEFAULT false,
    requires_season boolean NOT NULL DEFAULT false,

    description_cz text,

    is_active boolean NOT NULL DEFAULT true,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);



INSERT INTO ops.worker_execution_rules
(
    action_code,
    worker_code,
    priority_order,

    requires_provider,
    requires_sport,
    requires_entity,

    requires_league_id,
    requires_season,

    description_cz
)
VALUES

(
    'RUN_PLANNER_TARGET',
    'INGEST_PLANNER_WORKER',
    1,
    true,true,true,
    true,true,
    'Spustí konkrétní planner job.'
),

(
    'RUN_PEOPLE_PLAYERS',
    'PEOPLE_PIPELINE_V22',
    1,
    true,true,true,
    true,true,
    'Spustí PEOPLE pipeline.'
),

(
    'RUN_MEDIA_REFRESH',
    'MEDIA_PIPELINE_V1',
    1,
    false,false,false,
    false,false,
    'Obnoví media vrstvu.'
),

(
    'RUN_MEDIA_BREAKING_NEWS',
    'MEDIA_BREAKING_NEWS_V1',
    1,
    false,false,false,
    false,false,
    'Přepočítá breaking news.'
),

(
    'RUN_MEDIA_QUALITY_FILTER',
    'MEDIA_QUALITY_FILTER_V1',
    1,
    false,false,false,
    false,false,
    'Spustí quality filter.'
),

(
    'RUN_MEDIA_VELOCITY',
    'MEDIA_VELOCITY_SNAPSHOT_V1',
    1,
    false,false,false,
    false,false,
    'Vytvoří velocity snapshot.'
),

(
    'RUN_ODDS_REFRESH',
    'THEODDS_INGEST_V3',
    1,
    false,false,false,
    false,false,
    'Spustí odds refresh.'
),

(
    'RUN_CORE_MERGE',
    'UNIFIED_STAGING_PUBLIC_MERGE_V3',
    1,
    false,false,false,
    false,false,
    'Provede merge staging -> public.'
),

(
    'RUN_FULL_HARVEST',
    'FULL_HARVEST_CYCLE_V1',
    1,
    true,true,true,
    false,false,
    'Spustí kompletní harvest sportu.'
),

(
    'RUN_MASTER_LAYER',
    'HARVEST_MASTER_V1',
    1,
    false,false,false,
    false,false,
    'Spustí vrstvu core/people/media/all.'
)

ON CONFLICT (action_code)
DO UPDATE SET

    worker_code = EXCLUDED.worker_code,
    priority_order = EXCLUDED.priority_order,

    requires_provider = EXCLUDED.requires_provider,
    requires_sport = EXCLUDED.requires_sport,
    requires_entity = EXCLUDED.requires_entity,

    requires_league_id = EXCLUDED.requires_league_id,
    requires_season = EXCLUDED.requires_season,

    description_cz = EXCLUDED.description_cz,

    is_active = true,
    updated_at = now();



CREATE OR REPLACE VIEW ops.v_worker_execution_rules_panel_v1 AS
SELECT

    r.action_code                AS "Akce",

    r.worker_code                AS "Worker",

    w.worker_type                AS "Typ workeru",

    r.priority_order             AS "Priorita",

    r.requires_provider          AS "Provider",

    r.requires_sport             AS "Sport",

    r.requires_entity            AS "Entita",

    r.requires_league_id         AS "Liga",

    r.requires_season            AS "Sezóna",

    r.description_cz             AS "Popis",

    r.is_active                  AS "Aktivní"

FROM ops.worker_execution_rules r
LEFT JOIN ops.worker_capability_registry w
    ON w.worker_code = r.worker_code
ORDER BY
    r.priority_order,
    r.action_code;