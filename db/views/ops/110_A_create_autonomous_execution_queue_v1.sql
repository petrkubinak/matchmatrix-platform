/*
MATCHMATRIX SQL 110_A Create Autonomous Execution Queue V1

CO TO JE:
- Fronta autonomních akcí.

K ČEMU TO JE:
- AI OPS zde připravuje akce ke spuštění.
- Worker launcher bude číst právě tuto frontu.

KDE TO UVIDÍME:
- Panel V18+
- AI OPS
- AUTONOMNÍ FRONTA

JAK SE TO VYUŽIJE:
- AI doporučí akci
- zapíše ji do fronty
- launcher ji provede
- collector vyhodnotí výsledek
*/


CREATE TABLE IF NOT EXISTS ops.autonomous_execution_queue (

    id bigserial PRIMARY KEY,

    action_type text NOT NULL,

    provider text,
    sport_code text,
    entity text,

    provider_league_id text,
    season text,
    run_group text,

    priority_score integer NOT NULL DEFAULT 0,

    risk_level text NOT NULL DEFAULT 'LOW',

    action_reason text,

    execution_status text NOT NULL DEFAULT 'PENDING',

    execution_result text,

    created_at timestamptz NOT NULL DEFAULT now(),

    started_at timestamptz,

    finished_at timestamptz,

    created_by text NOT NULL DEFAULT 'AI_OPS'

);



CREATE INDEX IF NOT EXISTS ix_autonomous_execution_queue_status
ON ops.autonomous_execution_queue(execution_status);



CREATE INDEX IF NOT EXISTS ix_autonomous_execution_queue_priority
ON ops.autonomous_execution_queue(priority_score DESC);



CREATE OR REPLACE VIEW ops.v_autonomous_execution_queue_v1 AS
SELECT

    id,

    action_type,

    provider,
    sport_code,
    entity,

    provider_league_id AS league_id,

    season,
    run_group,

    priority_score,

    risk_level,

    action_reason,

    execution_status,

    execution_result,

    created_at,

    started_at,

    finished_at

FROM ops.autonomous_execution_queue
ORDER BY
    priority_score DESC,
    created_at ASC;



CREATE OR REPLACE VIEW ops.v_autonomous_execution_summary_v1 AS
SELECT

    COUNT(*) AS total_actions,

    COUNT(*) FILTER (
        WHERE execution_status='PENDING'
    ) AS pending_actions,

    COUNT(*) FILTER (
        WHERE execution_status='RUNNING'
    ) AS running_actions,

    COUNT(*) FILTER (
        WHERE execution_status='SUCCESS'
    ) AS success_actions,

    COUNT(*) FILTER (
        WHERE execution_status='FAILED'
    ) AS failed_actions,

    now() AS generated_at

FROM ops.autonomous_execution_queue;