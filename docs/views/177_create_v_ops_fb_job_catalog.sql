CREATE OR REPLACE VIEW ops.v_fb_job_catalog AS
SELECT
    layer,

    CASE layer
        WHEN 'FB_TOP' THEN 10
        WHEN 'FB_FD_CORE' THEN 20
        WHEN 'FB_API_EXPANSION' THEN 30
        ELSE 999
    END AS layer_order,

    provider,
    sport_code,
    run_group,
    entity,

    CASE entity
        WHEN 'leagues' THEN 10
        WHEN 'teams' THEN 20
        WHEN 'fixtures' THEN 30
        WHEN 'players' THEN 40
        WHEN 'player_season_stats' THEN 50
        WHEN 'coaches' THEN 60
        ELSE 999
    END AS entity_order,

    CONCAT(
        'FB__',
        layer,
        '__',
        provider,
        '__',
        entity
    ) AS job_code,

    COUNT(*) AS target_count,
    SUM(COALESCE(max_requests_per_run, 1)) AS planned_requests,
    MIN(effective_season) AS min_effective_season,
    MAX(effective_season) AS max_effective_season

FROM ops.v_fb_test_mode_orchestrator
GROUP BY
    layer,
    provider,
    sport_code,
    run_group,
    entity;