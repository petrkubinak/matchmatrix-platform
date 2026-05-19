CREATE OR REPLACE VIEW ops.v_fb_test_mode_all_layers AS
SELECT
    'FB_FD_CORE' AS layer,
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
FROM ops.v_fb_fd_core_ingest_jobs_test_mode

UNION ALL

SELECT
    'FB_API_EXPANSION' AS layer,
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
FROM ops.v_fb_api_expansion_ingest_jobs_test_mode;