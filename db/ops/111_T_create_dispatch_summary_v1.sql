/*
MATCHMATRIX SQL 111_T
CREATE DISPATCH SUMMARY V1

CO TO JE:
- Souhrn stavů dispatch fronty.

K ČEMU TO JE:
- Panel uvidí, kolik akcí čeká, kolik bylo přeskočeno, kolik je připraveno a kolik doběhlo.

KDE TO UVIDÍME:
- Budoucí panel AI OPS / Dispatcher.

JAK SE TO VYUŽIJE:
- Rychlý přehled stavu autonomního dispatcheru.
*/

CREATE OR REPLACE VIEW ops.v_dispatch_summary_v1 AS
SELECT
    dispatch_status,
    COUNT(*) AS total_count,
    MAX(created_at) AS last_created_at,
    MAX(dispatched_at) AS last_dispatched_at,
    MAX(completed_at) AS last_completed_at
FROM ops.dispatch_queue
GROUP BY
    dispatch_status
ORDER BY
    dispatch_status;