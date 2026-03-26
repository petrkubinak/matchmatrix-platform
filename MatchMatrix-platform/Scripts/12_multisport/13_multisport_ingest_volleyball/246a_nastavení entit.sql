SELECT
    provider,
    sport_code,
    entity,
    enabled,
    source_endpoint,
    target_table,
    worker_script
FROM ops.ingest_entity_plan
WHERE enabled = true
  AND (
        source_endpoint IS NULL
     OR target_table IS NULL
  )
ORDER BY provider, sport_code, entity;