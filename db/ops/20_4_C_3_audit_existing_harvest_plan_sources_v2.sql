/*
MATCHMATRIX SCRIPT

NÁZEV:
20_4_C_3_audit_existing_harvest_plan_sources_v2.sql

CO TO JE:
Audit existujících plánovacích tabulek pro harvest.

K ČEMU TO JE:
Ověřit, kde už v DB existuje skutečný plán:
sport → provider → entity / league / season / run_group / status / priority.

KDE TO UVIDÍME:
DBeaver
Později OPS Panel → Harvest Command Center.

JAK SE TO VYUŽIJE:
Nebudeme vytvářet duplicitní harvest_plan_master.
Napojíme Operator Run Queue na existující plánovací zdroje.
*/

SELECT
    'ops.ingest_planner' AS source_table,
    COUNT(*) AS rows_total,
    COUNT(*) FILTER (WHERE status IN ('pending', 'READY', 'ready')) AS rows_ready,
    COUNT(*) FILTER (WHERE status IN ('done', 'DONE')) AS rows_done,
    COUNT(*) FILTER (WHERE status IN ('failed', 'FAILED', 'error', 'ERROR')) AS rows_failed,
    COUNT(DISTINCT sport_code) AS sports_count,
    COUNT(DISTINCT provider) AS providers_count,
    COUNT(DISTINCT entity) AS entities_count,
    MIN(created_at) AS first_created_at,
    MAX(updated_at) AS last_updated_at
FROM ops.ingest_planner

UNION ALL

SELECT
    'ops.ingest_targets' AS source_table,
    COUNT(*) AS rows_total,
    COUNT(*) FILTER (WHERE enabled = true) AS rows_ready,
    NULL AS rows_done,
    NULL AS rows_failed,
    COUNT(DISTINCT sport_code) AS sports_count,
    COUNT(DISTINCT provider) AS providers_count,
    NULL AS entities_count,
    MIN(created_at) AS first_created_at,
    MAX(updated_at) AS last_updated_at
FROM ops.ingest_targets

UNION ALL

SELECT
    'ops.ingest_entity_plan' AS source_table,
    COUNT(*) AS rows_total,
    COUNT(*) FILTER (WHERE enabled = true) AS rows_ready,
    NULL AS rows_done,
    NULL AS rows_failed,
    COUNT(DISTINCT sport_code) AS sports_count,
    COUNT(DISTINCT provider) AS providers_count,
    COUNT(DISTINCT entity) AS entities_count,
    MIN(created_at) AS first_created_at,
    MAX(updated_at) AS last_updated_at
FROM ops.ingest_entity_plan

UNION ALL

SELECT
    'ops.scheduler_queue' AS source_table,
    COUNT(*) AS rows_total,
    COUNT(*) FILTER (WHERE status IN ('pending', 'READY', 'ready')) AS rows_ready,
    COUNT(*) FILTER (WHERE status IN ('done', 'DONE')) AS rows_done,
    COUNT(*) FILTER (WHERE status IN ('failed', 'FAILED', 'error', 'ERROR')) AS rows_failed,
    COUNT(DISTINCT sport_code) AS sports_count,
    COUNT(DISTINCT provider) AS providers_count,
    NULL AS entities_count,
    MIN(queue_day::timestamptz) AS first_created_at,
    MAX(finished_at) AS last_updated_at
FROM ops.scheduler_queue

UNION ALL

SELECT
    'ops.autonomous_execution_queue' AS source_table,
    COUNT(*) AS rows_total,
    COUNT(*) FILTER (WHERE execution_status IN ('PENDING', 'READY', 'ready')) AS rows_ready,
    COUNT(*) FILTER (WHERE execution_status IN ('DONE', 'done')) AS rows_done,
    COUNT(*) FILTER (WHERE execution_status IN ('FAILED', 'ERROR', 'failed', 'error')) AS rows_failed,
    COUNT(DISTINCT sport_code) AS sports_count,
    COUNT(DISTINCT provider) AS providers_count,
    COUNT(DISTINCT entity) AS entities_count,
    MIN(created_at) AS first_created_at,
    MAX(finished_at) AS last_updated_at
FROM ops.autonomous_execution_queue

ORDER BY source_table;