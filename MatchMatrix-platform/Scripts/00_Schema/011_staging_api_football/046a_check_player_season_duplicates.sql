-- 046a_check_player_season_duplicates.sql

SELECT
    player_id,
    team_id,
    league_id,
    season,
    COUNT(*) AS dup_count
FROM public.player_season_statistics
GROUP BY
    player_id,
    team_id,
    league_id,
    season
HAVING COUNT(*) > 1
ORDER BY dup_count DESC, season DESC, player_id;