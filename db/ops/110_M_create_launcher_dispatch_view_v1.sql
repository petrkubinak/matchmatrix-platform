/*
MATCHMATRIX SQL 110_M Create Launcher Dispatch View V1

CO TO JE:
- Finální dispatch zdroj pro Python launcher.

K ČEMU TO JE:
- Launcher už nebude rozhodovat ručně.
- Načte jeden připravený řádek a spustí doporučený worker.
- Spojuje autonomní frontu, pravidla a registry workerů.

KDE TO UVIDÍME:
- Panel V18
- SPUSTIT DALŠÍ
- AUTONOMNÍ LAUNCHER

JAK SE TO VYUŽIJE:
- Python launcher přečte v_launcher_dispatch_v1.
- Přepne queue item do RUNNING.
- Spustí worker_path.
- Zapíše SUCCESS/FAILED.
*/


CREATE OR REPLACE VIEW ops.v_launcher_dispatch_v1 AS
SELECT
    s.queue_id,
    s.action_code,
    s.worker_code,
    s.worker_type,
    s.worker_path,

    s.provider,
    s.sport_code,
    s.entity,
    s.league_id,
    s.season,
    s.run_group,

    s.can_execute,

    CASE
        WHEN s.can_execute = true
        THEN 'READY_TO_LAUNCH'
        ELSE 'BLOCKED'
    END AS dispatch_state,

    s.selector_reason_cz AS dispatch_reason_cz,
    s.selector_risk_cz AS dispatch_risk_cz,
    s.evaluated_at

FROM ops.v_ai_worker_selector_v1 s
WHERE s.can_execute = true
ORDER BY
    s.evaluated_at ASC,
    s.queue_id ASC;



CREATE OR REPLACE VIEW ops.v_launcher_dispatch_next_v1 AS
SELECT *
FROM ops.v_launcher_dispatch_v1
ORDER BY
    evaluated_at ASC,
    queue_id ASC
LIMIT 1;



CREATE OR REPLACE VIEW ops.v_launcher_dispatch_summary_v1 AS
SELECT
    COUNT(*) AS total_ready,
    COUNT(*) FILTER (WHERE dispatch_state = 'READY_TO_LAUNCH') AS ready_to_launch,
    now() AS generated_at
FROM ops.v_launcher_dispatch_v1;