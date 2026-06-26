/*
MATCHMATRIX SQL 110_I Create Worker Capability Registry V1

CO TO JE:
- Registr schopností workerů.

K ČEMU TO JE:
- AI OPS ví co který worker umí.
- Launcher vybírá správný worker.
- Základ pro budoucí autonomní orchestration.

KDE TO UVIDÍME:
- AI OPS
- Worker Registry
- Autonomous Launcher

JAK SE TO VYUŽIJE:
- AI zjistí požadovanou akci
- najde vhodný worker
- sestaví správný command
*/


CREATE TABLE IF NOT EXISTS ops.worker_capability_registry (

    id bigserial PRIMARY KEY,

    worker_code text NOT NULL UNIQUE,

    worker_path text NOT NULL,

    supports_provider boolean NOT NULL DEFAULT false,
    supports_sport boolean NOT NULL DEFAULT false,
    supports_entity boolean NOT NULL DEFAULT false,

    supports_league_id boolean NOT NULL DEFAULT false,
    supports_season boolean NOT NULL DEFAULT false,

    supports_run_group boolean NOT NULL DEFAULT false,

    supports_direct_execution boolean NOT NULL DEFAULT false,

    worker_type text NOT NULL,

    notes text,

    is_active boolean NOT NULL DEFAULT true,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);



INSERT INTO ops.worker_capability_registry
(
    worker_code,
    worker_path,
    supports_provider,
    supports_sport,
    supports_entity,
    supports_league_id,
    supports_season,
    supports_run_group,
    supports_direct_execution,
    worker_type,
    notes
)
VALUES

(
    'INGEST_CYCLE_V3',
    'workers/run_ingest_cycle_v3.py',
    true,
    true,
    true,
    false,
    false,
    true,
    true,
    'ORCHESTRATOR',
    'Pouze provider/sport/entity/run_group.'
),

(
    'INGEST_PLANNER_WORKER',
    'workers/run_ingest_planner_jobs.py',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    'PLANNER',
    'Umí league_id a season přes planner DB.'
),

(
    'MEDIA_PIPELINE_V1',
    'workers/run_media_pipeline_v1.py',
    false,
    false,
    false,
    false,
    false,
    false,
    true,
    'MEDIA',
    'Media orchestrátor.'
)

ON CONFLICT (worker_code)
DO NOTHING;



CREATE OR REPLACE VIEW ops.v_worker_capability_registry_v1 AS
SELECT

    worker_code           AS "Worker",

    worker_type           AS "Typ",

    supports_provider     AS "Provider",

    supports_sport        AS "Sport",

    supports_entity       AS "Entity",

    supports_league_id    AS "Liga",

    supports_season       AS "Sezóna",

    supports_run_group    AS "Run Group",

    supports_direct_execution
                           AS "Přímé spuštění",

    notes                 AS "Poznámka",

    is_active             AS "Aktivní"

FROM ops.worker_capability_registry
ORDER BY worker_code;