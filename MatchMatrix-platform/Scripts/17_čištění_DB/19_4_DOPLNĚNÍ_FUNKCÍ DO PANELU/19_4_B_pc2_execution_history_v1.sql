/*
MATCHMATRIX SQL 19_4_B
PC2 Execution History V1

CO TO JE:
- Historická evidence PC2 spuštění.

K ČEMU TO JE:
- Aby každý běh z panelu zůstal uložený:
  kdo/co se spustilo, sport, vrstva, výsledek, return_code, zpráva, čas.

KDE TO UVIDÍME:
- OPS Panel V18 / PC2 historie
- audit PC2 běhů

JAK SE TO VYUŽIJE:
- Po každém spuštění panel zapíše výsledek.
- Uvidíme OK / FAILED / EMPTY_RUN / ROUTING_ERROR.
*/

CREATE TABLE IF NOT EXISTS ops.pc2_execution_history (
    id BIGSERIAL PRIMARY KEY,

    command_id BIGINT,
    sport_code TEXT,
    sport_name TEXT,
    target_layer TEXT,

    command_title TEXT,
    command_text TEXT,

    run_group TEXT,
    provider TEXT,
    entity TEXT,

    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    duration_seconds NUMERIC,

    return_code INTEGER,
    result_status TEXT,
    processed_jobs INTEGER DEFAULT 0,

    result_message TEXT,
    log_tail TEXT,

    created_at TIMESTAMPTZ DEFAULT now()
);


CREATE OR REPLACE VIEW ops.v_pc2_execution_history_v1 AS
SELECT
    id,
    command_id,
    sport_code,
    sport_name,
    target_layer,
    result_status,
    processed_jobs,
    return_code,
    started_at,
    finished_at,
    duration_seconds,
    command_title,
    run_group,
    provider,
    entity,
    result_message,
    log_tail,
    created_at
FROM ops.pc2_execution_history
ORDER BY id DESC;


-- Ruční zápis posledního BK běhu jako EMPTY_RUN
INSERT INTO ops.pc2_execution_history (
    command_id,
    sport_code,
    sport_name,
    target_layer,
    command_title,
    command_text,
    run_group,
    provider,
    entity,
    started_at,
    finished_at,
    duration_seconds,
    return_code,
    result_status,
    processed_jobs,
    result_message,
    log_tail
)
SELECT
    id,
    sport_code,
    sport_name,
    target_layer,
    command_title,
    command_text,
    'PC2_PEOPLE_BK',
    NULL,
    'players',
    last_started_at,
    last_finished_at,
    EXTRACT(EPOCH FROM (last_finished_at - last_started_at)),
    0,
    'EMPTY_RUN',
    0,
    'BK PEOPLE doběhl bez chyby, ale planner queue byla prázdná.',
    last_result
FROM ops.pc2_run_command_queue
WHERE id = 4;


SELECT *
FROM ops.v_pc2_execution_history_v1
ORDER BY id DESC
LIMIT 20;