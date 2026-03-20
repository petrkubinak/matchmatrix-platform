CREATE OR REPLACE VIEW ops.v_top_ingest_targets AS
SELECT
    id,
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    enabled,
    tier,
    fixtures_days_back,
    fixtures_days_forward,
    odds_days_forward,
    max_requests_per_run,
    notes,
    created_at,
    updated_at,
    run_group
FROM ops.ingest_targets
WHERE enabled = TRUE
  AND run_group IN (
      'FOOTBALL_MAINTENANCE_TOP',
      'BK_MAINTENANCE_TOP',
      'HK_MAINTENANCE_TOP'
  );