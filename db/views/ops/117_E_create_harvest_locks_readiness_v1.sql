/*
===============================================================================
MATCHMATRIX SQL 117_E
HARVEST LOCKS READINESS V1

CO TO JE:
- Auditní view připravenosti lock systému pro více PC.

K ČEMU TO JE:
- Ověřuje existenci worker_locks.
- Kontroluje aktivní locky.
- Kontroluje historicky uvolněné locky.
- Pomáhá zabránit duplicitnímu harvestu.

KDE TO UVIDÍME:
- OPS Panel
- Mission Control
- Harvest Dashboard
- Audit Snapshoty

JAK SE TO VYUŽIJE:
- příprava druhého PC
- ochrana proti duplicitním workerům
- kontrola bezpečného harvestu

ZDROJ DAT:
- ops.worker_locks
- ops.active_worker_runs

VÝSTUP:
- locks_readiness_score
- locks_readiness_status
- recommendation_cz

VLIV NA HARVEST:
- Přímý
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_harvest_locks_readiness_v1 AS
WITH lock_stats AS (
    SELECT
        COUNT(*) AS total_locks,
        COUNT(*) FILTER (
            WHERE expires_at IS NOT NULL
              AND expires_at > NOW()
        ) AS active_locks,
        COUNT(*) FILTER (
            WHERE expires_at IS NOT NULL
              AND expires_at <= NOW()
        ) AS released_or_expired_locks,
        MAX(updated_at) AS last_lock_update
    FROM ops.worker_locks
),
active_runs AS (
    SELECT
        COUNT(*) AS active_worker_runs
    FROM ops.active_worker_runs
)
SELECT
    l.total_locks,
    l.active_locks,
    l.released_or_expired_locks,
    a.active_worker_runs,
    l.last_lock_update,

    LEAST(
        100,
        (
            CASE WHEN l.total_locks > 0 THEN 35 ELSE 0 END
            +
            CASE WHEN l.released_or_expired_locks > 0 THEN 25 ELSE 0 END
            +
            CASE WHEN a.active_worker_runs >= 0 THEN 20 ELSE 0 END
            +
            CASE WHEN l.last_lock_update IS NOT NULL THEN 15 ELSE 0 END
        )
    ) AS locks_readiness_score,

    CASE
        WHEN l.total_locks = 0 THEN 'LOCK_SYSTEM_EMPTY'
        WHEN l.total_locks > 0 AND l.released_or_expired_locks > 0 THEN 'LOCK_SYSTEM_EXISTS'
        ELSE 'LOCK_SYSTEM_REVIEW'
    END AS locks_readiness_status,

    CASE
        WHEN l.total_locks = 0
            THEN 'Lock systém existuje tabulkou, ale nemá žádné záznamy. Otestovat worker lock.'
        WHEN a.active_worker_runs > 0
            THEN 'Aktuálně běží workery. Ověřit, že mají odpovídající locky.'
        WHEN l.released_or_expired_locks > 0
            THEN 'Lock systém má historii použití. Další krok je multi-PC dry-run.'
        ELSE 'Ověřit lock workflow přes bezpečný test workeru.'
    END AS recommendation_cz

FROM lock_stats l
CROSS JOIN active_runs a;