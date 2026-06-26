SELECT
    planner_id,
    provider_league_id,
    league_name,
    season,
    run_group,
    priority,
    planner_status,
    staging_players,
    note
FROM ops.fb_players_pro_priority_buckets
WHERE bucket_code = 'WAVE_1_TOP'
ORDER BY season DESC, priority, provider_league_id;