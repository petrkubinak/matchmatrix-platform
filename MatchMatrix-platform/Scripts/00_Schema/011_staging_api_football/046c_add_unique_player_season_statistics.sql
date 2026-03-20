-- 046c_add_unique_player_season_statistics.sql

CREATE UNIQUE INDEX IF NOT EXISTS ux_player_season_statistics_main
ON public.player_season_statistics (player_id, team_id, league_id, season);