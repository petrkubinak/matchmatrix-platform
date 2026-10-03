SELECT
    layer_type,
    time_mode,
    scope_type,
    completion_status,
    count(*) AS scope_count,
    count(*) FILTER (WHERE ingest_target_id IS NOT NULL) AS target_links,
    count(*) FILTER (WHERE scope_coverage_id IS NOT NULL) AS exact_coverage_links,
    count(*) FILTER (WHERE canonical_season_id IS NOT NULL) AS canonical_season_links,
    count(*) FILTER (
        WHERE nullif(btrim(source_season_key), '') IS NOT NULL
    ) AS source_season_keys,
    min(scope_key) AS example_scope_key
FROM ops.harvest_scope_completion
WHERE source_id = 18
  AND sport_code = 'HB'
  AND entity = 'fixtures'
GROUP BY layer_type, time_mode, scope_type, completion_status
ORDER BY layer_type, time_mode, scope_type, completion_status;