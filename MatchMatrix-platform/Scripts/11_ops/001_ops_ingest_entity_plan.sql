---ingest_entity_plan
SELECT
    provider,
    sport_code,
    entity,
    enabled,
    priority,
    scope_type,
    requires_league,
    requires_season,
    default_run_group,
    ingest_mode
FROM ops.ingest_entity_plan
ORDER BY provider, sport_code, priority, entity;