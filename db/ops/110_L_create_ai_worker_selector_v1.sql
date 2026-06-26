/*
MATCHMATRIX SQL 110_L Create AI Worker Selector V1

CO TO JE:
- První rozhodovací engine pro AI OPS.

K ČEMU TO JE:
- Vybere správný worker pro danou akci.
- Ověří, zda worker existuje a je aktivní.
- Vrátí důvod rozhodnutí.

KDE TO UVIDÍME:
- Panel V18
- SPUSTIT DALŠÍ
- AI OPS

JAK SE TO VYUŽIJE:
- AI vytvoří akci.
- Selector najde worker.
- Launcher worker spustí.
*/


CREATE OR REPLACE VIEW ops.v_ai_worker_selector_v1 AS
SELECT

    q.id                                    AS queue_id,

    q.action_type                           AS action_code,

    r.worker_code,

    w.worker_type,

    w.worker_path,

    q.provider,
    q.sport_code,
    q.entity,
    q.provider_league_id                    AS league_id,
    q.season,
    q.run_group,

    CASE
        WHEN w.worker_code IS NULL
            THEN false
        WHEN w.is_active = false
            THEN false
        ELSE true
    END                                     AS can_execute,

    CASE
        WHEN w.worker_code IS NULL
            THEN 'Worker není registrován.'

        WHEN w.is_active = false
            THEN 'Worker je deaktivovaný.'

        ELSE 'Worker nalezen a připraven.'
    END                                     AS selector_reason_cz,

    CASE
        WHEN w.worker_code IS NULL
            THEN 'VYSOKÉ'

        WHEN w.is_active = false
            THEN 'VYSOKÉ'

        ELSE 'NÍZKÉ'
    END                                     AS selector_risk_cz,

    now()                                   AS evaluated_at

FROM ops.autonomous_execution_queue q

LEFT JOIN ops.worker_execution_rules r
       ON r.action_code = q.action_type
      AND r.is_active = true

LEFT JOIN ops.worker_capability_registry w
       ON w.worker_code = r.worker_code

WHERE q.execution_status = 'PENDING';