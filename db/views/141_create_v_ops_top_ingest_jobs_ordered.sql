CREATE OR REPLACE VIEW ops.v_top_ingest_jobs_ordered AS
SELECT
    ingest_target_id,
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    target_enabled,
    tier,
    fixtures_days_back,
    fixtures_days_forward,
    odds_days_forward,
    max_requests_per_run,
    notes,
    run_group,
    entity,
    priority,
    entity_enabled,

    CASE entity
        WHEN 'leagues' THEN 10
        WHEN 'teams' THEN 20
        WHEN 'fixtures' THEN 30
        WHEN 'odds' THEN 40
        WHEN 'players' THEN 50
        WHEN 'player_season_stats' THEN 60
        WHEN 'coaches' THEN 70
        ELSE 999
    END AS entity_order
FROM ops.v_top_ingest_jobs;