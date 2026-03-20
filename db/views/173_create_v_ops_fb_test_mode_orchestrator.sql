CREATE OR REPLACE VIEW ops.v_fb_test_mode_orchestrator AS
SELECT
    'FB_TOP' AS layer,
    t.provider,
    t.sport_code,
    t.run_group,
    iep.entity,
    COALESCE(NULLIF(TRIM(t.season), ''), '2024') AS effective_season,
    t.id AS ingest_target_id,
    t.canonical_league_id,
    t.provider_league_id,
    t.max_requests_per_run,
    t.fixtures_days_back,
    t.fixtures_days_forward,
    t.notes
FROM ops.ingest_targets t
JOIN ops.ingest_entity_plan iep
  ON iep.provider = t.provider
 AND iep.sport_code = t.sport_code
WHERE t.enabled = TRUE
  AND iep.enabled = TRUE
  AND t.sport_code = 'FB'
  AND t.provider = 'api_football'
  AND t.run_group = 'FOOTBALL_MAINTENANCE_TOP'
  AND iep.entity <> 'odds'
  AND COALESCE(NULLIF(TRIM(t.season), ''), '2024') IN ('2022', '2023', '2024')

UNION ALL

SELECT
    layer,
    provider,
    sport_code,
    run_group,
    entity,
    effective_season,
    ingest_target_id,
    canonical_league_id,
    provider_league_id,
    max_requests_per_run,
    fixtures_days_back,
    fixtures_days_forward,
    notes
FROM ops.v_fb_test_mode_all_layers;