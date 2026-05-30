/*
MATCHMATRIX SQL 106_G

Co to je:
Automation-ready execution queue.

K čemu to je:
Vrací pouze:
- reálně spustitelné routy
- valid automation candidates
- runtime ready providers

Použití:
- scheduler
- autonomous execution
- retry engine
- Control Panel RUN NOW
*/

CREATE OR REPLACE VIEW ops.v_automation_ready_queue_v1 AS

SELECT
    *

FROM ops.v_automation_execution_queue_v2

WHERE
    automation_ready IS TRUE

    AND execution_state IN (
        'CAN_RUN_NOW',
        'FAILOVER_READY'
    )

    AND (
        worker_script IS NOT NULL
        OR entity IN (
            'fixtures',
            'teams',
            'leagues',
            'players',
            'media'
        )
    )

    AND provider_gap = 'OK'

ORDER BY
    sport_code,
    entity,
    routing_rank;