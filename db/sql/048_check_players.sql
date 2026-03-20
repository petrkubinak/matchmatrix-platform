-- MatchMatrix
-- 048_check_players.sql

SELECT COUNT(*) AS public_players
FROM public.players;

SELECT COUNT(*) AS public_player_provider_map
FROM public.player_provider_map;

SELECT COUNT(*) AS staging_player_season_stats
FROM staging.stg_provider_player_season_stats;

SELECT COUNT(*) AS staging_player_match_stats
FROM staging.stg_provider_player_stats;

SELECT COUNT(*) AS public_player_season_statistics
FROM public.player_season_statistics;

SELECT COUNT(*) AS public_player_match_statistics
FROM public.player_match_statistics;

SELECT provider, season_code, COUNT(*) AS rows_count
FROM public.player_season_statistics
GROUP BY provider, season_code
ORDER BY season_code DESC, provider;

SELECT *
FROM public.player_season_statistics
ORDER BY updated_at DESC
LIMIT 50;