CREATE OR REPLACE VIEW ops.v_fb_test_execution_order AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            CASE layer
                WHEN 'FB_TOP' THEN 10
                WHEN 'FB_FD_CORE' THEN 20
                WHEN 'FB_API_EXPANSION' THEN 30
                ELSE 999
            END,
            CASE entity
                WHEN 'leagues' THEN 10
                WHEN 'teams' THEN 20
                WHEN 'fixtures' THEN 30
                WHEN 'players' THEN 40
                WHEN 'player_season_stats' THEN 50
                WHEN 'coaches' THEN 60
                ELSE 999
            END,
            provider,
            canonical_league_id,
            provider_league_id
    ) AS execution_order,

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
FROM ops.v_fb_test_mode_orchestrator;