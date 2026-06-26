/*
MATCHMATRIX SQL 110_D Create Autonomous Result Collector V1

CO TO JE:
- Sběrač výsledků autonomních akcí.

K ČEMU TO JE:
- Sleduje stav autonomní fronty.
- Připravuje výsledek pro learning vrstvu.
- Odděluje akce čekající, běžící, dokončené a chybové.

KDE TO UVIDÍME:
- Panel V18+
- AI OPS
- AUTONOMNÍ FRONTA
- LEARNING LOOP

JAK SE TO VYUŽIJE:
- Launcher spustí akci.
- Collector vyhodnotí výsledek.
- Learning writer později zapíše zkušenost.
*/


CREATE OR REPLACE VIEW ops.v_autonomous_result_collector_v1 AS
SELECT
    q.id AS queue_id,
    q.action_type,
    q.provider,
    q.sport_code,
    q.entity,
    q.provider_league_id AS league_id,
    q.season,
    q.run_group,
    q.priority_score,
    q.risk_level,
    q.execution_status,
    q.execution_result,
    q.created_at,
    q.started_at,
    q.finished_at,

    CASE
        WHEN q.execution_status = 'PENDING'
        THEN 'ČEKÁ NA SPUŠTĚNÍ'

        WHEN q.execution_status = 'RUNNING'
        THEN 'BĚŽÍ'

        WHEN q.execution_status = 'SUCCESS'
        THEN 'DOKONČENO OK'

        WHEN q.execution_status = 'FAILED'
        THEN 'DOKONČENO S CHYBOU'

        ELSE 'NEZNÁMÝ STAV'
    END AS collector_state_cz,

    CASE
        WHEN q.execution_status = 'SUCCESS'
        THEN 'CONFIRMED_OK'

        WHEN q.execution_status = 'FAILED'
        THEN 'FAILED_AGAIN'

        WHEN q.execution_status IN ('PENDING','RUNNING')
        THEN 'WAITING'

        ELSE 'NEW_ERROR'
    END AS suggested_learning_outcome,

    CASE
        WHEN q.execution_status = 'SUCCESS'
        THEN 'Autonomní akce proběhla úspěšně.'

        WHEN q.execution_status = 'FAILED'
        THEN 'Autonomní akce skončila chybou.'

        WHEN q.execution_status = 'PENDING'
        THEN 'Akce zatím čeká na spuštění.'

        WHEN q.execution_status = 'RUNNING'
        THEN 'Akce právě běží.'

        ELSE 'Stav akce není rozpoznán.'
    END AS collector_note_cz

FROM ops.autonomous_execution_queue q
ORDER BY
    q.created_at DESC,
    q.id DESC;


CREATE OR REPLACE VIEW ops.v_autonomous_result_collector_summary_v1 AS
SELECT
    COUNT(*) AS total_actions,

    COUNT(*) FILTER (
        WHERE execution_status = 'PENDING'
    ) AS pending_actions,

    COUNT(*) FILTER (
        WHERE execution_status = 'RUNNING'
    ) AS running_actions,

    COUNT(*) FILTER (
        WHERE execution_status = 'SUCCESS'
    ) AS success_actions,

    COUNT(*) FILTER (
        WHERE execution_status = 'FAILED'
    ) AS failed_actions,

    now() AS generated_at

FROM ops.v_autonomous_result_collector_v1;