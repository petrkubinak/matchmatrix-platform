/*
MATCHMATRIX SQL 19_3_C Find FB Media Workers

CO TO JE:
- Audit dostupných media workerů pro FB MEDIA.

K ČEMU TO JE:
- Najdeme správný worker místo chybného run_unified_ingest_v1.py.

KDE TO UVIDÍME:
- ops.provider_worker_registry
- ops.unified_worker_registry
- ops.provider_entity_coverage
- ops.media_source_health_audit
- ops.runtime_entity_audit

JAK SE TO VYUŽIJE:
- Podle výsledku vytvoříme nový správný PC2 command pro MEDIA FB.
*/

SELECT
    provider,
    sport_code,
    entity,
    worker_type,
    worker_script,
    is_supported,
    is_active,
    notes
FROM ops.provider_worker_registry
WHERE sport_code IN ('FB', 'football')
  AND (
        entity ILIKE '%media%'
     OR entity ILIKE '%article%'
     OR entity ILIKE '%highlight%'
  )
ORDER BY provider, entity, worker_type;

SELECT
    provider,
    sport_code,
    entity,
    pull_worker,
    parse_worker,
    merge_worker,
    source_table,
    target_table,
    runtime_ready,
    panel_ready,
    scheduler_ready,
    migration_state,
    notes
FROM ops.unified_worker_registry
WHERE sport_code IN ('FB', 'football')
  AND (
        entity ILIKE '%media%'
     OR entity ILIKE '%article%'
     OR entity ILIKE '%highlight%'
  )
ORDER BY provider, entity;

SELECT
    provider,
    sport_code,
    entity,
    coverage_status,
    source_endpoint,
    target_table,
    worker_script,
    notes,
    limitations,
    next_action
FROM ops.provider_entity_coverage
WHERE sport_code IN ('FB', 'football')
  AND (
        entity ILIKE '%media%'
     OR entity ILIKE '%article%'
     OR entity ILIKE '%highlight%'
  )
ORDER BY provider, entity;

SELECT
    provider,
    sport_code,
    entity,
    source_name,
    source_type,
    found_urls,
    inserted_rows,
    updated_rows,
    skipped_rows,
    worker_script,
    health_status,
    health_note,
    last_run_at
FROM ops.media_source_health_audit
WHERE sport_code IN ('FB', 'football')
ORDER BY last_run_at DESC
LIMIT 30;

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    last_run_group,
    last_log_summary,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE sport_code IN ('FB', 'football')
  AND (
        entity ILIKE '%media%'
     OR entity ILIKE '%article%'
     OR entity ILIKE '%highlight%'
  )
ORDER BY provider, entity;