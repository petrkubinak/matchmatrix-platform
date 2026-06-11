/*
MATCHMATRIX SQL 23_3_B
SYNC PROVIDER WORKER REGISTRY FROM UNIFIED V1

CO TO JE:
- Bezpečná synchronizace ops.provider_worker_registry z ops.unified_worker_registry.

K ČEMU TO JE:
- Harvest Provider Readiness Matrix zatím hlásí NEEDS_WORKER_OR_TEST,
  protože provider_worker_registry má jen 11 řádků.
- Přitom unified_worker_registry má 106 řádků a obsahuje reálnou pravdu o workerech.
- Tento skript doplní pouze ověřené runtime_ready workery.

KDE TO UVIDÍME:
- ops.provider_worker_registry
- ops.v_harvest_provider_readiness_matrix_v1
- MatchMatrix Operační Centrum
- HARVEST PŘIPRAVENOST PRO PC2

JAK SE TO VYUŽIJE:
- Panel začne ukazovat reálný stav workerů.
- PC2 harvest plán bude vycházet z funkčních workerů.
- Sníží se falešné NEEDS_WORKER_OR_TEST.
*/

INSERT INTO ops.provider_worker_registry (
    provider,
    sport_code,
    entity,
    worker_type,
    worker_script,
    is_supported,
    is_active,
    notes
)
SELECT
    u.provider,
    u.sport_code,
    u.entity,

    CASE
        WHEN u.pull_worker IS NOT NULL AND u.pull_worker <> '' THEN 'pull'
        WHEN u.parse_worker IS NOT NULL AND u.parse_worker <> '' THEN 'parse'
        WHEN u.merge_worker IS NOT NULL AND u.merge_worker <> '' THEN 'merge'
        ELSE 'unified'
    END AS worker_type,

    concat_ws(
        ' + ',
        NULLIF(u.pull_worker, ''),
        NULLIF(u.parse_worker, ''),
        NULLIF(u.merge_worker, '')
    ) AS worker_script,

    true AS is_supported,
    true AS is_active,

    'Synced from ops.unified_worker_registry by 23_3_B. Runtime ready worker for PC2 harvest readiness.'
FROM ops.unified_worker_registry u
WHERE u.runtime_ready = true
  AND (
        NULLIF(u.pull_worker, '') IS NOT NULL
     OR NULLIF(u.parse_worker, '') IS NOT NULL
     OR NULLIF(u.merge_worker, '') IS NOT NULL
  )
  AND lower(COALESCE(u.pull_worker, '')) NOT LIKE '%planned%'
  AND lower(COALESCE(u.parse_worker, '')) NOT LIKE '%planned%'
  AND lower(COALESCE(u.merge_worker, '')) NOT LIKE '%planned%'
  AND NOT EXISTS (
        SELECT 1
        FROM ops.provider_worker_registry p
        WHERE p.provider = u.provider
          AND p.sport_code = u.sport_code
          AND lower(p.entity) = lower(u.entity)
  );