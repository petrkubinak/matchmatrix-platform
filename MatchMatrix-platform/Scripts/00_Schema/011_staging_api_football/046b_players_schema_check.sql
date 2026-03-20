-- 046_players_schema_check.sql

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE
    (table_schema = 'public' AND table_name IN (
        'players',
        'player_provider_map',
        'player_external_identity',
        'player_season_statistics',
        'player_match_statistics',
        'player_team_history'
    ))
    OR
    (table_schema = 'staging' AND table_name IN (
        'stg_provider_players',
        'stg_provider_player_profiles',
        'stg_provider_player_season_stats',
        'stg_provider_player_stats'
    ))
ORDER BY table_schema, table_name, ordinal_position;