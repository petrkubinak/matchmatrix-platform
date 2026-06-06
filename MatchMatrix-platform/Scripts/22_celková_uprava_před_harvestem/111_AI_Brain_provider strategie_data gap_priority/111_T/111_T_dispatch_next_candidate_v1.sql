/*
MATCHMATRIX SQL 111_T

DISPATCH NEXT CANDIDATE V1

CO TO JE:
- Vybere nejlepší PENDING akci z dispatch fronty.
- Označí ji jako SELECTED.

K ČEMU TO JE:
- Dispatcher bude vždy pracovat jen s jednou jasně vybranou akcí.

KDE TO UVIDÍME:
- ops.dispatch_queue

JAK SE TO VYUŽIJE:
- Další krok připraví worker command pro vybranou akci.
*/

WITH next_item AS (
    SELECT
        id
    FROM ops.dispatch_queue
    WHERE dispatch_status = 'PENDING'
    ORDER BY
        brain_score DESC,
        brain_rank ASC,
        created_at ASC
    LIMIT 1
)
UPDATE ops.dispatch_queue q
SET
    dispatch_status = 'SELECTED',
    dispatched_at = NOW(),
    execution_notes = 'Vybráno dispatcherem jako další kandidát.'
FROM next_item n
WHERE q.id = n.id
RETURNING
    q.id,
    q.brain_rank,
    q.brain_score,
    q.provider,
    q.sport_code,
    q.entity,
    q.league_id,
    q.season,
    q.run_group,
    q.dispatch_status,
    q.execution_notes;